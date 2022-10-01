# Les Sagas MP3 - Infrastructure

## Prerequisites

Authorize gcloud to access GCP :

```bash
gcloud auth login
```

Authorize third-apps (such as Terraform) to access GCP :

```bash
gcloud auth application-default login
```

## Execution

Prepare GCP Project :

```bash
./scripts/0-init.sh
```

Specify required variables :

```bash
export TF_VAR_ssh_public_key="<content of public key>"
```

Apply Terraform configuration :

```bash
./scripts/1-tf-plan.sh <env_template> <env_name>
./scripts/2-tf-apply.sh
```

Specify required variables :

```bash
export ANS_PRIVATE_KEY_PATH="<path to private key matching TF_VAR_ssh_public_key>"
```

Run Ansible playbook :

```bash
./scripts/3-ans.sh <env_name>
```

## Destroy

When not needed anymore, destroy all GCP resources :

```bash
./scripts/9-tf-destroy.sh <env_template>
```

## Note for review environments

The following environment variables must be defined :

```

# For an app review
export TF_VAR_app_version="<app version>"
export TF_VAR_app_archive_url="<URL to download archive containing dist>"
export TF_VAR_app_subdomain="app-review-<unique id>"

# For an api review
export TF_VAR_api_version="<api version>"
export TF_VAR_api_archive_url="<URL to download executable jar>"
export TF_VAR_api_subdomain="api-review-<unique id>"

```