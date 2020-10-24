terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-3"
}

output "lessagasmp3_ip" {
  value = aws_eip.lessagasmp3.public_ip
}
