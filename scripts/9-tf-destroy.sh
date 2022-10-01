#!/bin/bash

GCP_REGION="europe-west9"
TF_STATES_BACKEND="les-sagas-mp3-infrastructure"

PROJECT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/.."

ENVIRONMENT_TEMPLATE=$1
ENVIRONMENT_NAME="${2:-$1}"

# Init Terraform
cd $PROJECT_PATH/terraform
terraform init -backend-config="bucket=$TF_STATES_BACKEND" -backend-config="prefix=$ENVIRONMENT_NAME" -reconfigure

# Set local variables
export TF_VAR_ssh_user=$(whoami)
export TF_VAR_environment_name=$ENVIRONMENT_NAME

# Run plan
cd $PROJECT_PATH/terraform
terraform plan -var-file=environments/default_versions.tfvars -var-file=environments/$ENVIRONMENT_TEMPLATE.tfvars -out .plan/destroy.tfplan -destroy
terraform show -no-color -json .plan/destroy.tfplan > .plan/destroy.json

# Run destroy
terraform destroy -var-file=environments/default_versions.tfvars -var-file=environments/$ENVIRONMENT_TEMPLATE.tfvars -auto-approve
