#!/bin/bash

GCP_REGION="europe-west9"
GCP_PROJECT_NUMBER="798614005646"
GCP_NETWORK_NAME="les-sagas-mp3"
TF_STATES_BACKEND="les-sagas-mp3-infrastructure"

PROJECT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/.."

# Set GCP region
echo "▶️ Set GCP region to : $GCP_REGION"
gcloud config set compute/region $GCP_REGION

# Verify if we access the project
gcpProjectsJson=$(gcloud projects list --filter=projectNumber:$GCP_PROJECT_NUMBER --format=json)
gcpProjectsLength=$(echo $gcpProjectsJson | jq '. | length')
if [ $gcpProjectsLength -ne 1 ]; then
    echo "❌ GCP Project has not been found."
    exit 1
fi

# Set the current project
gcpProjectId=$(echo $gcpProjectsJson | jq -r '.[0].projectId')
echo "▶️ Set GCP project to : $gcpProjectId ($GCP_PROJECT_NUMBER)"
gcloud config set project $gcpProjectId

# Activate required APIs
gcloud services enable compute.googleapis.com
gcloud services enable storage.googleapis.com

# Get GCP networks maching the name
gcpNetworksJson=$(gcloud compute networks list --filter=name:$GCP_NETWORK_NAME --format=json)
gcpNetworksLength=$(echo $gcpNetworksJson | jq '. | length')

# Create main network if not exists
if [ $gcpNetworksLength -eq 0 ]; then
    echo "▶️ Create GCP network"
    gcloud compute networks create $GCP_NETWORK_NAME --subnet-mode=custom
fi

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
terraform init -backend-config="bucket=$TF_STATES_BACKEND"
