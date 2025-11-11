param(
    [string]$ENVIRONMENT_TEMPLATE = $null,
    [string]$ENVIRONMENT_NAME = $null
)

# Resolve project path (parent of script folder)
$ScriptDir = Split-Path -Parent $PSCommandPath
$PROJECT_PATH = (Resolve-Path (Join-Path $ScriptDir "..")).Path

# Check terraform availability
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error "terraform not found on PATH."
    exit 1
}

# Ensure terraform folder exists
$TerraformDir = Join-Path $PROJECT_PATH "terraform"
if (-not (Test-Path $TerraformDir)) {
    Write-Error "Terraform directory not found: $TerraformDir"
    exit 1
}

Set-Location -Path $TerraformDir

$planFile = Join-Path (Get-Location) ".plan\apply.tfplan"
if (-not (Test-Path $planFile)) {
    Write-Error "Plan file not found: $planFile. Run 1-tf-plan first."
    exit 1
}

Write-Host "▶️ Running terraform apply -auto-approve $planFile"
& terraform apply -auto-approve $planFile
$rc = $LASTEXITCODE

if ($rc -ne 0) {
    Write-Error "terraform apply failed with exit code $rc"
    exit $rc
}

Write-Host "✔️  Apply complete."
exit 0