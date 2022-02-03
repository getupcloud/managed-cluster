provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.service_account_key
}
