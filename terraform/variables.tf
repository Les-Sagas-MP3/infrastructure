variable "gcp_region" {
  type        = string
  description = "GCP region"
}

variable "gcp_project" {
  type        = string
  description = "GCP project name"
}

variable "gcp_network_name" {
  type        = string
  description = "GCP network name"
}

variable "gcp_subnetwork_cidr" {
  type        = string
  description = "GCP subnetwork CIDR"
}

variable "gcp_instance_zone" {
  type        = string
  description = "GCP instance zone"
}

variable "gcp_instance_type" {
  type        = string
  description = "GCP instance type"
}

variable "environment_name" {
  type        = string
  description = "Environment name"
}

variable "ssh_user" {
  type        = string
  description = "SSH username"
  default     = "provisioning"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key"
}
