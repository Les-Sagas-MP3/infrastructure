data "template_file" "inventory" {
  template = file("${path.module}/templates/ansible-inventory.yml.tftpl")
  vars = {
    ip_address       = google_compute_address.environment.address
    environment_name = var.environment_name
    domain           = var.domain
    bucket_name      = google_storage_bucket.environment.name
    app_subdomain    = var.app_subdomain
    app_version      = var.app_version
    app_archive_url  = var.app_archive_url
    api_subdomain    = var.api_subdomain
    api_version      = var.api_version
    api_archive_url  = var.api_archive_url
  }
}

resource "local_file" "inventory" {
  filename = "${path.root}/../ansible/inventory-${var.environment_name}.yml"
  content  = data.template_file.inventory.rendered
}