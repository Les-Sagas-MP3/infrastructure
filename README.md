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
./scripts/0-init-gcp.sh
```

Apply Terraform configuration :

```bash
./scripts/1-tf-plan.sh
./scripts/2-tf-apply.sh
```

## Destroy

When not needed anymore, destroy all GCP resources :

```bash
./scripts/9-tf-destroy.sh
```
