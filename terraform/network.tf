data "google_compute_network" "main" {
  project = var.gcp_project
  name    = var.gcp_network_name
}

resource "google_compute_subnetwork" "environment" {
  project       = var.gcp_project
  region        = var.gcp_region
  name          = var.environment_name
  ip_cidr_range = var.gcp_subnetwork_cidr
  network       = data.google_compute_network.main.id
}

resource "google_compute_address" "environment" {
  project = var.gcp_project
  region  = var.gcp_region
  name    = var.environment_name
}

resource "google_compute_firewall" "http" {
  project   = var.gcp_project
  name      = "http"
  network   = data.google_compute_network.main.self_link
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["http"]
}

resource "google_compute_firewall" "https" {
  project   = var.gcp_project
  name      = "https"
  network   = data.google_compute_network.main.self_link
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["https"]
}

resource "google_compute_firewall" "test_ssh" {
  project   = var.gcp_project
  name      = "ssh"
  network   = data.google_compute_network.main.self_link
  direction = "INGRESS"
  priority  = 65534

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["ssh"]
}

resource "google_compute_firewall" "icmp" {
  project   = var.gcp_project
  name      = "icmp"
  network   = data.google_compute_network.main.self_link
  direction = "INGRESS"
  priority  = 65534

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["icmp"]
}
