resource "google_service_account" "environment" {
  project      = var.gcp_project
  account_id   = var.environment_name
  display_name = "Environment service account"
}
