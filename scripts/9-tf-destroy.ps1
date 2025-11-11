param(
    [Parameter(Mandatory=$true)][string]$ENVIRONMENT_TEMPLATE,
    [string]$ENVIRONMENT_NAME = $null
)

if (-not $ENVIRONMENT_NAME) { $ENVIRONMENT_NAME = $ENVIRONMENT_TEMPLATE }

$TF_STATES_BACKEND = "les-sagas-mp3-infrastructure"

# Resolve project path (parent of script folder)
$ScriptDir = Split-Path -Parent $PSCommandPath
$PROJECT_PATH = (Resolve-Path (Join-Path $ScriptDir "..")).Path

# Check gcloud availability (optional)
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Warning "gcloud CLI not found on PATH. Continuing but gcloud-related steps may fail."
}

# Check terraform availability
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error "terraform not found on PATH."
    exit 1
}

# Init Terraform
Set-Location -Path (Join-Path $PROJECT_PATH "terraform")
& terraform init -backend-config="bucket=$TF_STATES_BACKEND" -backend-config="prefix=$ENVIRONMENT_NAME" -reconfigure
if ($LASTEXITCODE -ne 0) { Write-Error "terraform init failed"; exit $LASTEXITCODE }

# Set local variables for Terraform
$env:TF_VAR_ssh_user = $env:USERNAME
$env:TF_VAR_environment_name = $ENVIRONMENT_NAME

# Build extra args to override variables in default_versions (optional)
$extraArgs = @()
if ($env:TF_VAR_app_version) { $extraArgs += "-var=app_version=$($env:TF_VAR_app_version)" }
if ($env:TF_VAR_api_version) { $extraArgs += "-var=api_version=$($env:TF_VAR_api_version)" }

# Ensure .plan directory exists
$planDir = Join-Path (Get-Location) ".plan"
if (-not (Test-Path $planDir)) { New-Item -ItemType Directory -Path $planDir | Out-Null }

# Run plan (destroy)
$varFiles = @("-var-file=environments/default_versions.tfvars", ("-var-file=environments/{0}.tfvars" -f $ENVIRONMENT_TEMPLATE))
$planArgs = $varFiles + $extraArgs + @("-out", ".plan/destroy.tfplan", "-destroy")
Write-Host "▶️ terraform plan $($planArgs -join ' ')"
& terraform plan @planArgs
if ($LASTEXITCODE -ne 0) { Write-Error "terraform plan (destroy) failed"; exit $LASTEXITCODE }

# Export plan as JSON
Write-Host "▶️ terraform show -> .plan/destroy.json"
& terraform show -no-color -json ".plan/destroy.tfplan" | Out-File -Encoding UTF8 ".plan/destroy.json"
if ($LASTEXITCODE -ne 0) { Write-Error "terraform show failed"; exit $LASTEXITCODE }

# Run destroy
$destroyArgs = $varFiles + $extraArgs + @("-auto-approve")
Write-Host "▶️ terraform destroy $($destroyArgs -join ' ')"
& terraform destroy @destroyArgs
if ($LASTEXITCODE -ne 0) { Write-Error "terraform destroy failed"; exit $LASTEXITCODE }

Write-Host "✔️  Destroy complete."
