data "template_file" "inventory" {
  template = file("${path.module}/templates/ansible-inventory.yml.tftpl")
  vars = {
    ip_address       = google_compute_address.main.address
    environment_name = var.environment_name
    app_url          = var.app_url
    api_url          = var.api_url
  }
}

resource "local_file" "inventory" {
  filename = "${path.root}/../ansible/inventory-${var.environment_name}.yml"
  content  = data.template_file.inventory.rendered
}