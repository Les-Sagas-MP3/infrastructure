#!/bin/bash

PROJECT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/.."

# Run plan
cd $PROJECT_PATH/terraform
terraform plan -var-file=environments/$1.tfvars -out .plan/destroy.tfplan -destroy
terraform show -no-color -json .plan/destroy.tfplan > .plan/destroy.json

# Run destroy
terraform destroy -var-file=environments/$1.tfvars -auto-approve
