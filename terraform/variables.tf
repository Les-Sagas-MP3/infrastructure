variable "gcp_region" {
  type        = string
  description = "GCP region"
  default     = "europe-west9"
}

variable "gcp_project" {
  type        = string
  description = "GCP project name"
  default     = "les-sagas-mp3"
}

variable "gcp_network_name" {
  type        = string
  description = "GCP network name"
  default     = "les-sagas-mp3"
}

variable "gcp_subnetwork_cidr" {
  type        = string
  description = "GCP subnetwork CIDR"
}

variable "gcp_instance_zone" {
  type        = string
  description = "GCP instance zone"
  default     = "europe-west9-a"
}

variable "gcp_instance_type" {
  type        = string
  description = "GCP instance type"
  default     = "e2-micro"
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

variable "ssh_private_key" {
  type        = string
  description = "SSH private key"
  sensitive   = true
}

variable "domain" {
  type        = string
  description = "App subdomain"
  default     = "les-sagas-mp3.fr"
}

variable "app_subdomain" {
  type        = string
  description = "App subdomain"
  default     = "app"
}

variable "app_version" {
  type        = string
  description = "App version"
}

variable "app_remote_src" {
  type        = bool
  description = "Is App dist located on /opt/les-sagas-mp3/build ?"
  default     = false
}

variable "api_subdomain" {
  type        = string
  description = "API subdomain"
  default     = "api"
}

variable "api_version" {
  type        = string
  description = "API version"
}

variable "api_remote_src" {
  type        = bool
  description = "Is API executable located on /opt/les-sagas-mp3/build ?"
  default     = false
}
