resource "google_service_account" "environment" {
  project      = var.gcp_project
  account_id   = var.environment_name
  display_name = "Environment service account for ${var.environment_name}"
}

resource "google_project_iam_binding" "monitoring-metricWriter" {
  project = var.gcp_project
  role    = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.environment.email}"
  ]
}

resource "google_project_iam_binding" "logging-logWriter" {
  project = var.gcp_project
  role    = "roles/logging.logWriter"
  members = [
    "serviceAccount:${google_service_account.environment.email}"
  ]
}
