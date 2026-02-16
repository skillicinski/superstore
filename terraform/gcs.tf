resource "google_storage_bucket" "superstore" {
  name          				= "${var.gcp_project_id}-superstore-data"
  location      				= "EUROPE-WEST4"
  force_destroy 				= true
  uniform_bucket_level_access	= true
}

resource "google_storage_bucket_object" "orders" {
  name    = "seeds/orders.csv"
  source  = "${path.module}/../data/orders.csv"
  bucket  = google_storage_bucket.superstore.name
}

resource "google_storage_bucket_object" "people" {
  name    = "seeds/people.csv"
  source  = "${path.module}/../data/people.csv"
  bucket  = google_storage_bucket.superstore.name
}

resource "google_storage_bucket_object" "returns" {
  name    = "seeds/returns.csv"
  source  = "${path.module}/../data/returns.csv"
  bucket  = google_storage_bucket.superstore.name
}

resource "google_artifact_registry_repository" "superstore" {
	location      = "europe-west4"
	repository_id = "superstore"
	description   = "example docker repository"
	format        = "DOCKER"
}