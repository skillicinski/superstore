# Set up project locally and configure GitHub secrets
setup:
    #!/usr/bin/env bash
    set -euo pipefail

    read_with_default() {
        local var_name=$1
        local current=$(grep "^${var_name}=" .env 2>/dev/null | cut -d= -f2)
        local prompt="${var_name}"
        [[ -n "$current" ]] && prompt="${prompt} [${current}]"
        read -rp "${prompt}: " value
        echo "${value:-$current}"
    }

    echo "=== Snowflake configuration ==="
    account=$(read_with_default SNOWFLAKE_ACCOUNT)
    user=$(read_with_default SNOWFLAKE_USER)
    passphrase=$(read_with_default SNOWFLAKE_PRIVATE_KEY_PASSPHRASE)

    echo "SNOWFLAKE_ACCOUNT=${account}" > .env
    echo "SNOWFLAKE_USER=${user}" >> .env
    echo "SNOWFLAKE_PRIVATE_KEY_PASSPHRASE=${passphrase}" >> .env

    echo ".env written"

    echo ""
    echo "=== GitHub Actions secrets ==="
    gh secret set SNOWFLAKE_ACCOUNT --body "$account"
    gh secret set SNOWFLAKE_USER --body "$user"
    gh secret set SNOWFLAKE_PRIVATE_KEY < rsa_key.p8
    echo "GitHub secrets set"

    echo ""
    echo "=== Installing dependencies ==="
    uv sync
    echo ""
    echo "Setup complete!"

# Local dbt run
[group('dbt')]
dbt *args:
    #!/usr/bin/env bash
    export $(cat .env | xargs)
    export SNOWFLAKE_PRIVATE_KEY=$(cat rsa_key.p8)
    cd dbt
    uv run dbt {{ args }}

# Build Docker image
[group('docker')]
docker-build:
    docker build -t superstore-dbt .

# Test Docker image against Snowflake
[group('docker')]
docker-test: docker-build
    docker run --env-file .env -e SNOWFLAKE_PRIVATE_KEY="$(cat rsa_key.p8)" superstore-dbt

# Tag and push to Artifact Registry
[group('docker')]
docker-push: docker-build
    docker tag superstore-dbt europe-west4-docker.pkg.dev/project-2c81508f-6a88-4f9c-86d/superstore/superstore-dbt:latest
    docker push europe-west4-docker.pkg.dev/project-2c81508f-6a88-4f9c-86d/superstore/superstore-dbt:latest

# Load Docker image into kind cluster
[group('k8s')]
k8s-load: docker-build
    kind load docker-image superstore-dbt:latest

# Create Snowflake credentials secret in cluster
[group('k8s')]
k8s-secret:
    #!/usr/bin/env bash
    set -euo pipefail
    kubectl create secret generic snowflake-credentials \
      --from-literal=SNOWFLAKE_ACCOUNT="$(grep SNOWFLAKE_ACCOUNT .env | cut -d= -f2)" \
      --from-literal=SNOWFLAKE_USER="$(grep SNOWFLAKE_USER .env | cut -d= -f2)" \
      --from-literal=SNOWFLAKE_PRIVATE_KEY_PASSPHRASE="$(grep SNOWFLAKE_PRIVATE_KEY_PASSPHRASE .env | cut -d= -f2)" \
      --from-file=SNOWFLAKE_PRIVATE_KEY=rsa_key.p8

# Run dbt Job in kind cluster
[group('k8s')]
k8s-run:
    #!/usr/bin/env bash
    set -euo pipefail
    cat k8s/dbt-job.yml | \
      sed 's|europe-west4-docker.pkg.dev/.*/superstore-dbt:latest|superstore-dbt:latest|' | \
      sed '/image:/a\'$'\n''          imagePullPolicy: Never' | \
      kubectl apply -f -
