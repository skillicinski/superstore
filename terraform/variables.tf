variable "snowflake_organization_name" {
    type        = string
    description = "Snowflake organization name"
}

variable "snowflake_account_name" {
    type        = string
    description = "Snowflake account name"
}

variable "snowflake_user" {
    type        = string
    description = "Snowflake user name"
}

variable "snowflake_private_key" {
    type        = string
    sensitive   = true
    description = "Snowflake private key (PEM content)"
}

variable "gcp_project_id" {
    type        = string
    description = "Google Cloud Project ID"
}

variable "gcp_region" {
    type        = string
    default     = "europe-west4"
    description = "Google Cloud region"
}

variable "gcp_zone" {
    type        = string
    default     = "europe-west4-a"
    description = "Google Cloud zone"
}
