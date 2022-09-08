#!/bin/bash

GCP_REGION="europe-west9"
TF_STATES_BACKEND="les-sagas-mp3-infrastructure"

PROJECT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/.."

# Get GCP Buckets maching the Terraform states backend
gcpBucketsJson=$(gcloud alpha storage buckets list --filter=id:$TF_STATES_BACKEND --format=json)
gcpBucketsLength=$(echo $gcpBucketsJson | jq '. | length')

# Create Terraform bucket if not exists
if [ $gcpBucketsLength -eq 0 ]; then
    echo "▶️ Create GCP Bucket to store Terraform states"
    gcloud alpha storage buckets create gs://$TF_STATES_BACKEND --location=$GCP_REGION
fi

# Init Terraform
cd $PROJECT_PATH/terraform
terraform init -backend-config="bucket=$TF_STATES_BACKEND" -backend-config="prefix=$1" -migrate-state

# Run plan
cd $PROJECT_PATH/terraform
terraform plan -var-file=env_$1.tfvars -out .plan/apply.tfplan
terraform show -no-color -json .plan/apply.tfplan > .plan/apply.json
