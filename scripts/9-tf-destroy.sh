#!/bin/bash

PROJECT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/.."

ENVIRONMENT_TEMPLATE=$1
ENVIRONMENT_NAME="${2:-$1}"

# Run plan
cd $PROJECT_PATH/terraform
terraform plan -var-file=environments/$ENVIRONMENT_TEMPLATE.tfvars -out .plan/destroy.tfplan -destroy
terraform show -no-color -json .plan/destroy.tfplan > .plan/destroy.json

# Run destroy
terraform destroy -var-file=environments/$ENVIRONMENT_TEMPLATE.tfvars -auto-approve
