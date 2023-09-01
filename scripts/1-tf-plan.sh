#!/bin/bash

GCP_REGION="europe-west9"
TF_STATES_BACKEND="les-sagas-mp3-infrastructure"

PROJECT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/.."

ENVIRONMENT_TEMPLATE=$1
ENVIRONMENT_NAME="${2:-$1}"

# Get GCP Buckets maching the Terraform states backend
gcpBucketsJson=$(gcloud storage buckets list --filter=name:$TF_STATES_BACKEND --format=json)
gcpBucketsLength=$(echo $gcpBucketsJson | jq '. | length')

# Create Terraform bucket if not exists
if [ $gcpBucketsLength -eq 0 ]; then
    echo "▶️ Create GCP Bucket to store Terraform states"
    gcloud storage buckets create gs://$TF_STATES_BACKEND --location=$GCP_REGION
fi

# Init Terraform
cd $PROJECT_PATH/terraform
terraform init -backend-config="bucket=$TF_STATES_BACKEND" -backend-config="prefix=$ENVIRONMENT_NAME" -reconfigure -upgrade

# Set local variables
export TF_VAR_ssh_user=$(whoami)
export TF_VAR_environment_name=$ENVIRONMENT_NAME

# Build extra args to override variables in default_versions
EXTRA_ARGS=""
if [ -v TF_VAR_app_version ]; then EXTRA_ARGS="$EXTRA_ARGS -var=app_version=$TF_VAR_app_version"; fi
if [ -v TF_VAR_api_version ]; then EXTRA_ARGS="$EXTRA_ARGS -var=api_version=$TF_VAR_api_version"; fi

# Run plan
cd $PROJECT_PATH/terraform
terraform plan -var-file=environments/default_versions.tfvars -var-file=environments/$ENVIRONMENT_TEMPLATE.tfvars $EXTRA_ARGS -out .plan/apply.tfplan
terraform show -no-color -json .plan/apply.tfplan > .plan/apply.json
