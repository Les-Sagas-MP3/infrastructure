param()

# Basic config
$GCP_REGION = "europe-west9"
$GCP_PROJECT_NUMBER = "798614005646"
$GCP_NETWORK_NAME = "les-sagas-mp3"
$GCP_DNS_MANAGED_ZONE_NAME = "les-sagas-mp3"
$GCP_DNS_MANAGED_ZONE_DNS_NAME = "les-sagas-mp3.fr"
$GCP_DNS_MANAGED_ZONE_DESCRIPTION = "Les Sagas MP3"
$GCP_CI_SA_NAME = "infrastructure"
$GCP_CI_SA_DESCRIPTION = "Infrastructure Deployment"
$GCP_CI_BUCKET_NAME = "les-sagas-mp3-build"
$GCP_CI_GITHUB_TOKEN = "github-token"

# Helpers
function Invoke-Gcloud {
    param([Alias("Args")][string[]]$ArgsList)
    $cmd = "gcloud " + ($ArgsList -join ' ')
    Write-Host "▶️ $cmd"
    & gcloud @ArgsList 2>&1
    return $LASTEXITCODE
}

# Ensure gcloud is available
if (-not (Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Error "gcloud CLI not found on PATH."
    exit 1
}

# Resolve project path (not strictly required and not used in this script)
# $PSCommandPath can be referenced if needed in the future; no assignment required now.

# Set GCP region
Write-Host "▶️ Set GCP region to : $GCP_REGION"
Invoke-Gcloud -Args @("config", "set", "compute/region", $GCP_REGION) | Out-Null

# Verify access to project by project number
$gcpProjectsJson = & gcloud projects list --filter="projectNumber:$GCP_PROJECT_NUMBER" --format=json 2>$null
if ([string]::IsNullOrWhiteSpace($gcpProjectsJson)) {
    Write-Error "❌ GCP Project has not been found."
    exit 1
}
$gcpProjects = $gcpProjectsJson | ConvertFrom-Json
if ($null -eq $gcpProjects -or $gcpProjects.Count -ne 1) {
    Write-Error "❌ GCP Project has not been found."
    exit 1
}

# Set the current project
$gcpProjectId = $gcpProjects[0].projectId
Write-Host "▶️ Set GCP project to : $gcpProjectId ($GCP_PROJECT_NUMBER)"
Invoke-Gcloud -Args @("config", "set", "project", $gcpProjectId) | Out-Null

# Activate required APIs
$services = @(
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "osconfig.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com"
)
foreach ($s in $services) {
    Invoke-Gcloud -Args @("services", "enable", $s) | Out-Null
}

# Get DNS managed zone
$gcpDnsJson = & gcloud dns managed-zones list --filter="dnsName:$GCP_DNS_MANAGED_ZONE_DNS_NAME" --format=json 2>$null
$gcpDns = @()
if (-not [string]::IsNullOrWhiteSpace($gcpDnsJson)) {
    $gcpDns = $gcpDnsJson | ConvertFrom-Json
}
if ($gcpDns.Count -eq 0) {
    Write-Host "▶️ Create GCP DNS managed zone"
    Invoke-Gcloud -Args @("dns", "managed-zones", "create", $GCP_DNS_MANAGED_ZONE_NAME, "--description=$GCP_DNS_MANAGED_ZONE_DESCRIPTION", "--dns-name=$GCP_DNS_MANAGED_ZONE_DNS_NAME") | Out-Null
}

# Get GCP networks matching the name
$gcpNetworksJson = & gcloud compute networks list --filter="name:$GCP_NETWORK_NAME" --format=json 2>$null
$gcpNetworks = @()
if (-not [string]::IsNullOrWhiteSpace($gcpNetworksJson)) {
    $gcpNetworks = $gcpNetworksJson | ConvertFrom-Json
}
if ($gcpNetworks.Count -eq 0) {
    Write-Host "▶️ Create GCP network"
    Invoke-Gcloud -Args @("compute", "networks", "create", $GCP_NETWORK_NAME, "--subnet-mode=custom") | Out-Null

    Invoke-Gcloud -Args @("compute", "firewall-rules", "create", "http", "--network=$GCP_NETWORK_NAME", "--direction=INGRESS", "--allow=tcp:80", "--source-ranges=0.0.0.0/0", "--target-tags=http", "--priority=1000") | Out-Null
    Invoke-Gcloud -Args @("compute", "firewall-rules", "create", "https", "--network=$GCP_NETWORK_NAME", "--direction=INGRESS", "--allow=tcp:443", "--source-ranges=0.0.0.0/0", "--target-tags=https", "--priority=1000") | Out-Null
    Invoke-Gcloud -Args @("compute", "firewall-rules", "create", "ssh", "--network=$GCP_NETWORK_NAME", "--direction=INGRESS", "--allow=tcp:22", "--source-ranges=0.0.0.0/0", "--target-tags=ssh", "--priority=65534") | Out-Null
    Invoke-Gcloud -Args @("compute", "firewall-rules", "create", "icmp", "--network=$GCP_NETWORK_NAME", "--direction=INGRESS", "--action=allow", "--rules=icmp", "--source-ranges=0.0.0.0/0", "--target-tags=icmp", "--priority=65534") | Out-Null
}

# Get email of authenticated user
$gcpAuthAccountJson = & gcloud auth list --filter=status:ACTIVE --format=json 2>$null
$gcpAuthAccounts = @()
if (-not [string]::IsNullOrWhiteSpace($gcpAuthAccountJson)) {
    $gcpAuthAccounts = $gcpAuthAccountJson | ConvertFrom-Json
}
if ($gcpAuthAccounts.Count -ne 1) {
    Write-Error "❌ No active account detected."
    exit 1
}
$gcpAuthEmail = $gcpAuthAccounts[0].account

# Grant Cloud Storage Admin role to authenticated user
Invoke-Gcloud -Args @("projects", "add-iam-policy-binding", $gcpProjectId, "--member=user:$gcpAuthEmail", "--role=roles/storage.admin") | Out-Null

# Get CI service account
$gcpServiceAccountsJson = & gcloud iam service-accounts list --filter=("name:" + $GCP_CI_SA_NAME) --format=json 2>$null
$gcpServiceAccounts = @()
if (-not [string]::IsNullOrWhiteSpace($gcpServiceAccountsJson)) {
    $gcpServiceAccounts = $gcpServiceAccountsJson | ConvertFrom-Json
}
if ($gcpServiceAccounts.Count -eq 0) {
    Write-Host "▶️ Create CI service account"
    Invoke-Gcloud -Args @("iam", "service-accounts", "create", $GCP_CI_SA_NAME, "--display-name", $GCP_CI_SA_DESCRIPTION) | Out-Null

    $sa = "$GCP_CI_SA_NAME@$gcpProjectId.iam.gserviceaccount.com"
    $roles = @(
        "roles/editor",
        "roles/cloudbuild.builds.builder",
        "roles/storage.admin",
        "roles/secretmanager.secretAccessor",
        "roles/cloudbuild.builds.editor",
        "roles/resourcemanager.projectIamAdmin",
        "roles/iam.serviceAccountOpenIdTokenCreator",
        "roles/iam.serviceAccountTokenCreator"
    )
    foreach ($r in $roles) {
        Invoke-Gcloud -Args @("projects", "add-iam-policy-binding", $gcpProjectId, "--member=serviceAccount:$sa", "--role=$r") | Out-Null
    }
}

# Get CI Bucket
$gcpBucketsJson = & gcloud storage buckets list --filter="name:$GCP_CI_BUCKET_NAME" --format=json 2>$null
$gcpBuckets = @()
if (-not [string]::IsNullOrWhiteSpace($gcpBucketsJson)) {
    $gcpBuckets = $gcpBucketsJson | ConvertFrom-Json
}
if ($gcpBuckets.Count -eq 0) {
    Write-Host "▶️ Create GCP Bucket for Cloud Build"
    Invoke-Gcloud -Args @("storage", "buckets", "create", ("gs://" + $GCP_CI_BUCKET_NAME), "--location=" + $GCP_REGION) | Out-Null
}

# Create secret for GitHub notifications
$gcpSecretGitHubTokenJson = & gcloud secrets list --filter="name:$GCP_CI_GITHUB_TOKEN" --format=json 2>$null
$gcpSecrets = @()
if (-not [string]::IsNullOrWhiteSpace($gcpSecretGitHubTokenJson)) {
    $gcpSecrets = $gcpSecretGitHubTokenJson | ConvertFrom-Json
}
if ($gcpSecrets.Count -eq 0) {
    Write-Host "▶️ Create GCP secret for GitHub Token"
    if (-not $env:GITHUB_TOKEN) {
        Write-Warning "GITHUB_TOKEN environment variable not set. Creating empty secret."
        $tmpPath = [System.IO.Path]::GetTempFileName()
        Set-Content -Path $tmpPath -Value ""
    } else {
        $tmpPath = [System.IO.Path]::GetTempFileName()
        Set-Content -Path $tmpPath -Value $env:GITHUB_TOKEN -NoNewline
    }
    Invoke-Gcloud -Args @("secrets", "create", $GCP_CI_GITHUB_TOKEN, "--data-file=$tmpPath") | Out-Null
    Remove-Item -Path $tmpPath -Force -ErrorAction SilentlyContinue
}

Write-Host "✔️  Initialization complete."