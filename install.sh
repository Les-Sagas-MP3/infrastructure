#!/bin/bash

# Run Terraform
echo "Run Terraform"
terraform init
terraform apply
echo "Terraform ended successfully"

# Get output from Terraform
TF_OUTPUT=$(terraform output)
INSTANCE_IP=$(echo $TF_OUTPUT | sed 's/lessagasmp3_ip = //g')
echo "Instance public IP: ${INSTANCE_IP}"

# Copy script to instance
ssh-add "D:\\Users\\Thomah\\Keys\\Les Sagas MP3\\SSH\\id_rsa"
DEPOSIT_PATH=/home/ec2-user/core
ssh ec2-user@$INSTANCE_IP "mkdir $DEPOSIT_PATH"
scp core/application.properties ec2-user@$INSTANCE_IP:$DEPOSIT_PATH/application.properties
scp core/core.sh ec2-user@$INSTANCE_IP:$DEPOSIT_PATH/core.sh
scp core/core.service ec2-user@$INSTANCE_IP:$DEPOSIT_PATH/core.service
scp configure_instance.sh ec2-user@$INSTANCE_IP:/home/ec2-user
ssh ec2-user@$INSTANCE_IP 'sudo ./configure_instance.sh'
