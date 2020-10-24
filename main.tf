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

resource "aws_instance" "les-sagas-mp3" {
  ami           = "ami-0de12f76efe134f2f"
  instance_type = "t2.micro"
}
