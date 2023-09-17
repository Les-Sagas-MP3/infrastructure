resource "google_storage_bucket" "environment" {
  project       = var.gcp_project
  location      = var.gcp_region
  name          = "les-sagas-mp3-${var.environment_name}"
  storage_class = "STANDARD"
  force_destroy = true
  lifecycle_rule {
    condition {
      matches_prefix = ["backup/"]
      age = 30
    }
    action {
      type = "Delete"
    }
  }
  labels = {
    environment = var.environment_name
    managedby   = "terraform"
  }
}

data "google_iam_policy" "environment" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "serviceAccount:${google_service_account.environment.email}",
    ]
  }
  binding {
    role = "roles/storage.objectCreator"
    members = [
      "serviceAccount:${google_service_account.environment.email}",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "environment" {
  bucket      = google_storage_bucket.environment.name
  policy_data = data.google_iam_policy.environment.policy_data
}

data "google_storage_bucket" "build" {
  name = "les-sagas-mp3-build"
}

data "google_iam_policy" "build" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
      "serviceAccount:${google_service_account.environment.email}",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "build" {
  bucket      = data.google_storage_bucket.build.name
  policy_data = data.google_iam_policy.build.policy_data
}
