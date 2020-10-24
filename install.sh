#!/bin/bash

echo "Start Terraform"
terraform init
terraform apply
echo "Terraform ended successfully"

TF_OUTPUT=$(terraform output)
INSTANCE_IP=$(echo $TF_OUTPUT | sed 's/lessagasmp3_ip = //g')
echo "Instance public IP : ${INSTANCE_IP}"
