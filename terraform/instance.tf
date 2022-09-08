resource "google_compute_instance" "environment" {
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
    subnetwork         = google_compute_subnetwork.environment.name
    subnetwork_project = var.gcp_project
    access_config {
      nat_ip = google_compute_address.environment.address
    }
  }

  service_account {
    email  = google_service_account.environment.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  tags = [
    "icmp",
    "ssh",
    "http",
    "https"
  ]
}
