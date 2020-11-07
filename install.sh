#!/bin/bash

# Insert ssh key
ssh-add "D:\\Users\\Thomah\\Keys\\Les Sagas MP3\\ec2-user\\id_rsa"

# Run Terraform
echo "Run Terraform"
#terraform init
#terraform apply -auto-approve
echo "Terraform ended successfully"

# Get output from Terraform
TF_OUTPUT=$(terraform output)
INSTANCE_IP=$(echo $TF_OUTPUT | sed 's/lessagasmp3_ip = //g')
echo "Instance public IP: ${INSTANCE_IP}"

# Prepare file copies to instance
DEPOSIT_PATH=/home/ec2-user
DB_DEPOSIT_PATH=$DEPOSIT_PATH/db
CORE_DEPOSIT_PATH=$DEPOSIT_PATH/core
NGINX_DEPOSIT_PATH=$DEPOSIT_PATH/nginx
DEPLOY_DEPOSIT_PATH=$DEPOSIT_PATH/deploy

# Prepare destination paths
ssh -o "StrictHostKeyChecking no" ec2-user@$INSTANCE_IP "sudo rm -rf $DEPOSIT_PATH/*"
ssh ec2-user@$INSTANCE_IP "mkdir $DEPOSIT_PATH"
ssh ec2-user@$INSTANCE_IP "mkdir $DB_DEPOSIT_PATH"
ssh ec2-user@$INSTANCE_IP "mkdir $CORE_DEPOSIT_PATH"
ssh ec2-user@$INSTANCE_IP "mkdir $NGINX_DEPOSIT_PATH"
ssh ec2-user@$INSTANCE_IP "mkdir $DEPLOY_DEPOSIT_PATH"

# Copy ssh keys
scp "D:\\Users\\Thomah\\Keys\\Les Sagas MP3\\github\\id_rsa.pub" ec2-user@$INSTANCE_IP:$DEPOSIT_PATH/github.pub

# Copy DB files
scp db/install_db.sh ec2-user@$INSTANCE_IP:$DB_DEPOSIT_PATH/install_db.sh
scp db/pgdg.repo ec2-user@$INSTANCE_IP:$DB_DEPOSIT_PATH/pgdg.repo
scp db/pg_hba.conf ec2-user@$INSTANCE_IP:$DB_DEPOSIT_PATH/pg_hba.conf

# Copy core files
scp core/install_core.sh ec2-user@$INSTANCE_IP:$CORE_DEPOSIT_PATH/install_core.sh
scp core/application.properties ec2-user@$INSTANCE_IP:$CORE_DEPOSIT_PATH/application.properties
scp core/core.sh ec2-user@$INSTANCE_IP:$CORE_DEPOSIT_PATH/core.sh
scp core/core.service ec2-user@$INSTANCE_IP:$CORE_DEPOSIT_PATH/core.service

# Copy nginx files
scp nginx/root.conf ec2-user@$INSTANCE_IP:$NGINX_DEPOSIT_PATH/root.conf
scp nginx/api.conf ec2-user@$INSTANCE_IP:$NGINX_DEPOSIT_PATH/api.conf
scp nginx/app.conf ec2-user@$INSTANCE_IP:$NGINX_DEPOSIT_PATH/app.conf
scp nginx/www.conf ec2-user@$INSTANCE_IP:$NGINX_DEPOSIT_PATH/www.conf
scp nginx/install_nginx.sh ec2-user@$INSTANCE_IP:$NGINX_DEPOSIT_PATH/install_nginx.sh

# Copy deploy script
scp deploy/core.sh ec2-user@$INSTANCE_IP:$DEPLOY_DEPOSIT_PATH/core.sh
scp deploy/app.sh ec2-user@$INSTANCE_IP:$DEPLOY_DEPOSIT_PATH/app.sh
scp deploy/install_deploy.sh ec2-user@$INSTANCE_IP:$DEPLOY_DEPOSIT_PATH/install_deploy.sh

# Copy main script
scp conf_instance.sh ec2-user@$INSTANCE_IP:$DEPOSIT_PATH
scp install_instance.sh ec2-user@$INSTANCE_IP:$DEPOSIT_PATH

# Run target installation
ssh ec2-user@$INSTANCE_IP "sudo $DEPOSIT_PATH/install_instance.sh"
