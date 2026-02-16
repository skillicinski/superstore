terraform {
    required_providers {
        snowflake = {
            source = "snowflakedb/snowflake"
            version = "2.13.0"
        }
        google = {
            source = "hashicorp/google"
            version = "7.19.0"
        }
    }

    backend "gcs" {
        bucket = "project-2c81508f-6a88-4f9c-86d-tfstate"
        prefix = "superstore"
    }
}

provider "snowflake" {
    organization_name       = var.snowflake_organization_name
    account_name            = var.snowflake_account_name
    user                    = var.snowflake_user
    
    // optional
    role      = "ACCOUNTADMIN"

    // A simple configuration of the provider with private key authentication.
    authenticator           = "SNOWFLAKE_JWT"
    private_key             = var.snowflake_private_key

    // preview features
    preview_features_enabled = [
        "snowflake_storage_integration_gcs_resource",
        "snowflake_stage_external_gcs_resource"
    ]
}

provider "google" {
    project = var.gcp_project_id
    region  = var.gcp_region
    zone    = var.gcp_zone
}