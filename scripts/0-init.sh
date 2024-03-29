#!/bin/bash

GCP_REGION="europe-west9"
GCP_PROJECT_NUMBER="798614005646"
GCP_NETWORK_NAME="les-sagas-mp3"
GCP_DNS_MANAGED_ZONE_NAME="les-sagas-mp3"
GCP_DNS_MANAGED_ZONE_DNS_NAME="les-sagas-mp3.fr"
GCP_DNS_MANAGED_ZONE_DESCRIPTION="Les Sagas MP3"
GCP_CI_SA_NAME="infrastructure"
GCP_CI_SA_DESCRIPTION="Infrastructure Deployment"
GCP_CI_BUCKET_NAME="les-sagas-mp3-build"
GCP_CI_SA_GITHUB="github"
GCP_CI_GITHUB_TOKEN="github-token"

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
gcloud services enable cloudbuild.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable osconfig.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable storage.googleapis.com

# Get DNS managed zone
gcpDnsJson=$(gcloud dns managed-zones list --filter=dnsName:$GCP_DNS_MANAGED_ZONE_DNS_NAME --format=json)
gcpDnsLength=$(echo $gcpDnsJson | jq '. | length')

# Create DNS managed zone if not exists
if [ $gcpDnsLength -eq 0 ]; then
    echo "▶️ Create GCP DNS managed zone"
    gcloud dns managed-zones create $GCP_DNS_MANAGED_ZONE_NAME --description="$GCP_DNS_MANAGED_ZONE_DESCRIPTION" --dns-name=$GCP_DNS_MANAGED_ZONE_DNS_NAME
fi

# Get GCP networks maching the name
gcpNetworksJson=$(gcloud compute networks list --filter=name:$GCP_NETWORK_NAME --format=json)
gcpNetworksLength=$(echo $gcpNetworksJson | jq '. | length')

# Create main network if not exists
if [ $gcpNetworksLength -eq 0 ]; then
    echo "▶️ Create GCP network"
    gcloud compute networks create $GCP_NETWORK_NAME --subnet-mode=custom
    gcloud compute firewall-rules create "http" --network=$GCP_NETWORK_NAME --direction="INGRESS" --allow=tcp:80 --source-ranges="0.0.0.0/0" --target-tags="http" --priority=1000
    gcloud compute firewall-rules create "https" --network=$GCP_NETWORK_NAME --direction="INGRESS" --allow=tcp:443 --source-ranges="0.0.0.0/0" --target-tags="https" --priority=1000
    gcloud compute firewall-rules create "ssh" --network=$GCP_NETWORK_NAME --direction="INGRESS" --allow=tcp:22 --source-ranges="0.0.0.0/0" --target-tags="ssh" --priority=65534
    gcloud compute firewall-rules create "icmp" --network=$GCP_NETWORK_NAME --direction="INGRESS" --action=allow --rules=icmp --source-ranges="0.0.0.0/0" --target-tags="icmp" --priority=65534
fi

# Get email of authenticated user
gcpAuthAccountJson=$(gcloud auth list --filter=status:ACTIVE --format=json)
gcpAuthAccountLength=$(echo $gcpNetworksJson | jq '. | length')
if [ $gcpAuthAccountLength -ne 1 ]; then
    echo "❌ No active account detected."
    exit 1
fi

# Grant Cloud Storage Admin role to authenticated user
gcpAuthEmail=$(echo $gcpAuthAccountJson | jq -r '.[0].account')
gcloud projects add-iam-policy-binding $gcpProjectId --member=user:$gcpAuthEmail --role=roles/storage.admin

# Get CI service account
gcpServiceAccountsJson=$(gcloud iam service-accounts list --filter=name:$GCP_CI_SA_NAME --format=json)
gcpServiceAccountsLength=$(echo $gcpServiceAccountsJson | jq '. | length')
if [ $gcpServiceAccountsLength -eq 0 ]; then
    echo "▶️ Create CI service account"
    gcloud iam service-accounts create $GCP_CI_SA_NAME --display-name "$GCP_CI_SA_DESCRIPTION"
    gcloud projects add-iam-policy-binding $gcpProjectId --member=serviceAccount:$GCP_CI_SA_NAME@$gcpProjectId.iam.gserviceaccount.com --role='roles/editor'
    gcloud projects add-iam-policy-binding $gcpProjectId --member=serviceAccount:$GCP_CI_SA_NAME@$gcpProjectId.iam.gserviceaccount.com --role='roles/cloudbuild.builds.builder'
    gcloud projects add-iam-policy-binding $gcpProjectId --member=serviceAccount:$GCP_CI_SA_NAME@$gcpProjectId.iam.gserviceaccount.com --role='roles/storage.admin'
    gcloud projects add-iam-policy-binding $gcpProjectId --member=serviceAccount:$GCP_CI_SA_NAME@$gcpProjectId.iam.gserviceaccount.com --role='roles/secretmanager.secretAccessor'
    gcloud projects add-iam-policy-binding $gcpProjectId --member=serviceAccount:$GCP_CI_SA_NAME@$gcpProjectId.iam.gserviceaccount.com --role='roles/cloudbuild.builds.editor'
    gcloud projects add-iam-policy-binding $gcpProjectId --member=serviceAccount:$GCP_CI_SA_NAME@$gcpProjectId.iam.gserviceaccount.com --role='roles/resourcemanager.projectIamAdmin'
    gcloud projects add-iam-policy-binding $gcpProjectId --member=serviceAccount:$GCP_CI_SA_NAME@$gcpProjectId.iam.gserviceaccount.com --role='roles/iam.serviceAccountOpenIdTokenCreator'
    gcloud projects add-iam-policy-binding $gcpProjectId --member=serviceAccount:$GCP_CI_SA_NAME@$gcpProjectId.iam.gserviceaccount.com --role='roles/iam.serviceAccountTokenCreator'
fi

# Get CI Bucket
gcpBucketsJson=$(gcloud storage buckets list --filter=name:$GCP_CI_BUCKET_NAME --format=json)
gcpBucketsLength=$(echo $gcpBucketsJson | jq '. | length')

# Create CI bucket if not exists
if [ $gcpBucketsLength -eq 0 ]; then
    echo "▶️ Create GCP Bucket for Cloud Build"
    gcloud storage buckets create gs://$GCP_CI_BUCKET_NAME --location=$GCP_REGION
fi

# Create secret for GitHub notifications
gcpSecretGitHubTokenJson=$(gcloud secrets list --filter=name:$GCP_CI_GITHUB_TOKEN --format=json)
gcpSecretGitHubTokenLength=$(echo $gcpSecretGitHubTokenJson | jq '. | length')
if [ $gcpSecretGitHubTokenLength -eq 0 ]; then
    echo "▶️ Create GCP secret for GitHub Token"
    printf "$GITHUB_TOKEN" | gcloud secrets create $GCP_CI_GITHUB_TOKEN --data-file=-
fi
