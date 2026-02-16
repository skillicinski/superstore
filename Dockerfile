FROM python:3.12-slim

# Copy the uv binary into the image
COPY --from=ghcr.io/astral-sh/uv:0.10.2 /uv /uvx /bin/

# Copy the project files into the image
COPY pyproject.toml /app/
COPY uv.lock /app/
COPY dbt/superstore /app/dbt/superstore/
COPY entrypoint.sh /app/entrypoint.sh


# Disable development dependencies
ENV UV_NO_DEV=1

# Sync the project into a new environment
WORKDIR /app
RUN uv sync --locked

# Activate the environment
ENV PATH="/app/.venv/bin:$PATH"

# Switch working directory to match default 
# paths dbt assumes for config .yml files
WORKDIR /app/dbt/superstore/

# Make the entrypoint script executable (use absolute path)
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint (use absolute path)
ENTRYPOINT ["/app/entrypoint.sh"]
