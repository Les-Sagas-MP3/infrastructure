resource "google_secret_manager_secret" "ssh_key_environment" {
  project = var.gcp_project
  secret_id = "ssh_key_${var.environment_name}"

  replication {
    automatic = true
  }

  labels = {
    environment = var.environment_name
  }
}

resource "google_secret_manager_secret_version" "ssh_key_environment" {
  secret = google_secret_manager_secret.ssh_key_environment.id
  secret_data = var.ssh_private_key
}
