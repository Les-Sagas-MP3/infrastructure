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
./scripts/1-tf-plan.sh
./scripts/2-tf-apply.sh
```

Specify required variables :

```bash
export ANS_PRIVATE_KEY_PATH="<path to private key matching TF_VAR_ssh_public_key>"
```

Run Ansible playbook :

```bash
./scripts/3-ans.sh
```

## Destroy

When not needed anymore, destroy all GCP resources :

```bash
./scripts/9-tf-destroy.sh
```
