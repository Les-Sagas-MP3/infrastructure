
variable "ssh_private_key" {
  type    = string
  default = "D:\\Users\\Thomah\\Keys\\Les Sagas MP3\\ec2-user\\id_rsa"
}


variable "ssh_public_key" {
  type    = string
  default = "D:\\Users\\Thomah\\Keys\\Les Sagas MP3\\ec2-user\\id_rsa.pub"
}

variable "tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default = {
    Name = "lessagasmp3",
    app = "lessagasmp3",
    environment = "production"
  }
}
