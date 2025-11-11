param(
    [Parameter(Mandatory=$true)][string]$env
)

# Resolve paths
$ScriptDir = Split-Path -Parent $PSCommandPath
$ProjectPath = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$AnsibleDir = Join-Path $ProjectPath "ansible"

# Check podman availability
if (-not (Get-Command podman -ErrorAction SilentlyContinue)) {
    Write-Error "Podman not found on PATH. Install Podman and try again."
    exit 1
}

# Inventory existence check
$inventoryFile = Join-Path $AnsibleDir ("inventory-$env.yml")
if (-not (Test-Path $inventoryFile)) {
    Write-Error "Inventory file not found: $inventoryFile"
    exit 1
}

# Helper to convert Windows path to container-friendly (/c/Users/...) for podman/dockerd mounts
function Convert-For-Container($path) {
    $p = (Resolve-Path $path).Path -replace '\\','/'
    if ($p -match '^([A-Za-z]):') {
        $drive = $matches[1].ToLower()
        $p = $p -replace '^[A-Za-z]:', "/$drive"
    }
    return $p
}

# Prepare mounts and env forwarding
$mounts = @()
# mount project
$mounts += ("{0}:/work" -f (Convert-For-Container $ProjectPath))

# If firebase credentials path provided, mount it and point container to it
$containerFirebaseVar = ""
if ($env:FIREBASE_CREDENTIALS_PATH -and (Test-Path $env:FIREBASE_CREDENTIALS_PATH)) {
    $hostFb = Convert-For-Container (Resolve-Path $env:FIREBASE_CREDENTIALS_PATH).Path
    $mounts += ("{0}:/tmp/firebase_credentials:ro" -f $hostFb)
    $containerFirebaseVar = "/tmp/firebase_credentials"
}

# If ansible private key provided, mount it and point container to it
$privateKeyArg = ""
if ($env:ANS_PRIVATE_KEY_PATH -and (Test-Path $env:ANS_PRIVATE_KEY_PATH)) {
    $hostKey = Convert-For-Container (Resolve-Path $env:ANS_PRIVATE_KEY_PATH).Path
    $mounts += ("{0}:/tmp/ans_private_key:ro" -f $hostKey)
    $privateKeyArg = "--private-key /tmp/ans_private_key"
}

# Use the provided ansible image
$image = "cnieg/ansible:1.0.91-ansible-10.2.0-r0"
$podmanArgs = @("run","--rm")

# mount each volume
foreach ($m in $mounts) { $podmanArgs += "-v"; $podmanArgs += $m }

# set working dir to ansible folder
$podmanArgs += "-w"; $podmanArgs += "/work/ansible"

# forward http proxy env if present (optional)
if ($env:http_proxy)  { $podmanArgs += "-e"; $podmanArgs += ("http_proxy={0}" -f $env:http_proxy) }
if ($env:https_proxy) { $podmanArgs += "-e"; $podmanArgs += ("https_proxy={0}" -f $env:https_proxy) }

# pass firebase env only when mounted (inside container)
if ($containerFirebaseVar) { $podmanArgs += "-e"; $podmanArgs += ("FIREBASE_CREDENTIALS_PATH={0}" -f $containerFirebaseVar) }

# Build inner command: run ansible-galaxy then ansible-playbook (image already contains ansible)
$user = $env:USERNAME.ToLower()
$extraVars = if ($containerFirebaseVar) { "firebase_credentials=$containerFirebaseVar" } else { "firebase_credentials=$env:FIREBASE_CREDENTIALS_PATH" }

# Always disable host key checking inside container (insecure but requested)
$podmanArgs += "-e"; $podmanArgs += "ANSIBLE_HOST_KEY_CHECKING=False"

# Use a single-line command (avoid embedded newlines / backslashes that break /bin/sh on Linux images)
if ($privateKeyArg) {
    $innerCmd = 'set -e; if [ -f /tmp/ans_private_key ]; then cp /tmp/ans_private_key /tmp/ans_private_key_fixed || true; chmod 600 /tmp/ans_private_key_fixed || true; fi; ansible-galaxy install -r requirements.yml --force || true; ansible-playbook -i inventory-' + $env + '.yml --extra-vars "' + $extraVars + '" --user ' + $user + ' --private-key /tmp/ans_private_key_fixed playbook.yml'
} else {
    $innerCmd = 'set -e; ansible-galaxy install -r requirements.yml --force || true; ansible-playbook -i inventory-' + $env + '.yml --extra-vars "' + $extraVars + '" --user ' + $user + ' playbook.yml'
}

# ensure no stray CR/LF characters
$innerCmd = $innerCmd -replace "`r", " " -replace "`n", " "

# append command to run inside container
$podmanArgs += $image
$podmanArgs += "/bin/sh"; $podmanArgs += "-lc"; $podmanArgs += $innerCmd

# Show the full podman command for debugging
$quotedArgs = $podmanArgs | ForEach-Object {
    if ($_ -match '\s' -or $_ -match '[`"$]') { '"' + ($_ -replace '"','\"') + '"' } else { $_ }
}
$podmanCmd = 'podman ' + ($quotedArgs -join ' ')
Write-Host "▶️ Podman command:"
Write-Host $podmanCmd

# Run podman (use call operator to stream output and preserve exit code)
Write-Host "▶️ Running Ansible inside Podman (image: $image)..."
& podman @podmanArgs
$rc = $LASTEXITCODE
