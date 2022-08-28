resource "google_service_account" "terraform" {
  project      = var.gcp_project
  account_id   = "terraform"
  display_name = "Terraform"
}

resource "google_compute_instance" "main" {
  project      = var.gcp_project
  zone         = var.gcp_instance_zone
  name         = var.environment_name
  machine_type = var.gcp_instance_type

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
    }
  }

  network_interface {
    network            = var.gcp_network_name
    subnetwork         = var.environment_name
    subnetwork_project = var.gcp_project
  }

  service_account {
    email  = google_service_account.terraform.email
    scopes = ["cloud-platform"]
  }
}