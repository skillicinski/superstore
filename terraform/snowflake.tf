resource "snowflake_warehouse" "main" {
  name                                  = "SKILLICINSKI"
  warehouse_size                        = "XSMALL"
  auto_suspend                          = 600
  auto_resume                           = "true"
  enable_query_acceleration             = "false"
  query_acceleration_max_scale_factor   = 8
  warehouse_type                        = "STANDARD"
  scaling_policy                        = "STANDARD"
  max_cluster_count                     = 1
  min_cluster_count                     = 1
}

resource "snowflake_database" "main" {
  name  = "SUPERSTORE"
}

resource "snowflake_schema" "seeds" {
  database              = snowflake_database.main.name
  name                  = "SEEDS"
  is_transient          = "false"
  with_managed_access   = "false"
}

resource "snowflake_schema" "staging" {
  database            = snowflake_database.main.name
  name                = "STAGING"
  is_transient        = "false"
  with_managed_access = "false"
}

resource "snowflake_schema" "models" {
  database              = snowflake_database.main.name
  name                  = "MODELS"
  is_transient          = "false"
  with_managed_access   = "false"
}

resource "snowflake_storage_integration_gcs" "gcs" {
  name                      = "GCS_SUPERSTORE"
  enabled                   = true
  storage_allowed_locations = ["gcs://${var.gcp_project_id}-superstore-data/seeds/"]
}

resource "snowflake_stage_external_gcs" "gcs_seeds" {
  name                = "GCS_SEEDS"
  database            = snowflake_database.main.name
  schema              = snowflake_schema.seeds.name
  url                 = "gcs://${var.gcp_project_id}-superstore-data/seeds/"
  storage_integration = snowflake_storage_integration_gcs.gcs.name
}
