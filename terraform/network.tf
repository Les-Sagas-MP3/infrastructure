data "google_compute_network" "main" {
  name    = var.gcp_network_name
  project = var.gcp_project
}

resource "google_compute_subnetwork" "environment" {
  region        = var.gcp_region
  project       = var.gcp_project
  name          = var.environment_name
  ip_cidr_range = var.gcp_subnetwork_cidr
  network       = data.google_compute_network.main.id
}
