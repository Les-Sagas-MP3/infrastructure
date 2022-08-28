#!/bin/bash

PROJECT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/.."

# Run apply
cd $PROJECT_PATH/terraform
terraform apply .plan/apply.tfplan -auto-approve
