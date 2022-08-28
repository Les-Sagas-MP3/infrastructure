#!/bin/bash

PROJECT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/.."

# Run plan
cd $PROJECT_PATH/terraform
terraform plan -var-file=env_production.tfvars -out .plan/apply.tfplan
terraform show -no-color -json .plan/apply.tfplan > .plan/apply.json
