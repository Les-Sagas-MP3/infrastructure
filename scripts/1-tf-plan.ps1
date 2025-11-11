param(
    [Parameter(Mandatory=$true)][string]$ENVIRONMENT_TEMPLATE,
    [string]$ENVIRONMENT_NAME = $null
)

if (-not $ENVIRONMENT_NAME) { $ENVIRONMENT_NAME = $ENVIRONMENT_TEMPLATE }

$GCP_REGION = "europe-west9"
$TF_STATES_BACKEND = "les-sagas-mp3-infrastructure"

# Resolve project path (parent of script folder)
$ScriptDir = Split-Path -Parent $PSCommandPath
$PROJECT_PATH = (Resolve-Path (Join-Path $ScriptDir "..")).Path

# Check gcloud availability
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Error "gcloud CLI not found on PATH."
    exit 1
}

# Check terraform availability
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error "terraform not found on PATH."
    exit 1
}

# Get GCP Buckets matching the Terraform states backend
$gcpBucketsJson = & gcloud storage buckets list --filter="name:$TF_STATES_BACKEND" --format=json 2>$null
$gcpBuckets = @()
if (-not [string]::IsNullOrWhiteSpace($gcpBucketsJson)) {
    try { $gcpBuckets = $gcpBucketsJson | ConvertFrom-Json } catch {}
}

if (($null -eq $gcpBuckets) -or ($gcpBuckets.Count -eq 0)) {
    Write-Host "▶️ Create GCP Bucket to store Terraform states"
    & gcloud storage buckets create ("gs://" + $TF_STATES_BACKEND) --location=$GCP_REGION
    if ($LASTEXITCODE -ne 0) { Write-Error "Failed to create GCP bucket"; exit $LASTEXITCODE }
}

# Init Terraform
Set-Location -Path (Join-Path $PROJECT_PATH "terraform")
& terraform init -backend-config="bucket=$TF_STATES_BACKEND" -backend-config="prefix=$ENVIRONMENT_NAME" -reconfigure -upgrade
if ($LASTEXITCODE -ne 0) { Write-Error "terraform init failed"; exit $LASTEXITCODE }

# Set local variables for Terraform
$env:TF_VAR_ssh_user = $env:USERNAME.ToLower()
$env:TF_VAR_environment_name = $ENVIRONMENT_NAME

# Build extra args to override variables in default_versions
$extraArgs = @()
if ($env:TF_VAR_app_version)    { $extraArgs += "-var=app_version=$($env:TF_VAR_app_version)" }
if ($env:TF_VAR_api_version)    { $extraArgs += "-var=api_version=$($env:TF_VAR_api_version)" }

# Ensure .plan directory exists
$planDir = Join-Path (Get-Location) ".plan"
if (-not (Test-Path $planDir)) { New-Item -ItemType Directory -Path $planDir | Out-Null }

# Run plan
$varFiles = @("-var-file=environments/default_versions.tfvars", ("-var-file=environments/{0}.tfvars" -f $ENVIRONMENT_TEMPLATE))
$planArgs = $varFiles + $extraArgs + ("-out", ".plan/apply.tfplan")
Write-Host "▶️ terraform plan $($planArgs -join ' ')"
& terraform plan @planArgs
if ($LASTEXITCODE -ne 0) { Write-Error "terraform plan failed"; exit $LASTEXITCODE }

# Export plan as JSON
Write-Host "▶️ terraform show -> .plan/apply.json"
& terraform show -no-color -json ".plan/apply.tfplan" | Out-File -Encoding UTF8 ".plan/apply.json"
if ($LASTEXITCODE -ne 0) { Write-Error "terraform show failed"; exit $LASTEXITCODE }

Write-Host "✔️  Plan complete."
exit 0