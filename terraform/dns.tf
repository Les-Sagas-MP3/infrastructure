data "google_dns_managed_zone" "lessagasmp3" {
  project = var.gcp_project
  name    = "les-sagas-mp3"
}

resource "google_dns_record_set" "dns" {
  project      = var.gcp_project
  name         = "${environment_name}.${data.google_dns_managed_zone.lessagasmp3.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.lessagasmp3.name
  rrdatas      = [google_compute_instance.environment.network_interface[0].access_config[0].nat_ip]
}

resource "google_dns_record_set" "api" {
  project      = var.gcp_project
  name         = "${var.api_subdomain}.${data.google_dns_managed_zone.lessagasmp3.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.lessagasmp3.name
  rrdatas      = [data.google_dns_managed_zone.lessagasmp3.dns_name]
}

resource "google_dns_record_set" "app" {
  project      = var.gcp_project
  name         = "${var.app_subdomain}.${data.google_dns_managed_zone.lessagasmp3.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.lessagasmp3.name
  rrdatas      = [data.google_dns_managed_zone.lessagasmp3.dns_name]
}
