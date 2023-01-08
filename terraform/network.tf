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
