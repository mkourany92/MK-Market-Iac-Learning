# Agent Setup Script — Custom Script Extension (Approach 1)
# WHY CSE: Runs automatically via Bicep when VM is provisioned
# WHY PowerShell: VM is Windows Server 2022
# WHY dev+test only: prod has no agent VM (deployAgentVm = false)

$ErrorActionPreference = "Stop"
$LogFile = "C:\agent-setup.log"

function Log {
    param([string]$msg)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts $msg" | Tee-Object -FilePath $LogFile -Append
}

Log "=== Agent Setup Started ==="

# ── 1. Azure CLI ──────────────────────────────────────────────────────────────
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Log "Installing Azure CLI..."
    $msi = "$env:TEMP\AzureCLI.msi"
    Invoke-WebRequest -Uri "https://aka.ms/installazurecliwindows" -OutFile $msi
    Start-Process msiexec.exe -Args "/I $msi /quiet /norestart" -Wait
    Log "Azure CLI installed"
} else { Log "Azure CLI already present" }

# ── 2. Git ────────────────────────────────────────────────────────────────────
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Log "Installing Git..."
    winget install --id Git.Git -e --source winget --silent `
        --accept-package-agreements --accept-source-agreements
    Log "Git installed"
} else { Log "Git already present" }

# ── 3. Node.js 20 ─────────────────────────────────────────────────────────────
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Log "Installing Node.js 20 LTS..."
    winget install --id OpenJS.NodeJS.LTS -e --source winget --silent `
        --accept-package-agreements --accept-source-agreements
    Log "Node.js installed"
} else { Log "Node.js already present" }

# ── 4. WSL2 features ──────────────────────────────────────────────────────────
Log "Checking WSL2..."
$wsl = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($wsl.State -ne "Enabled") {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    Log "WSL2 enabled — reboot required to complete"
} else { Log "WSL2 already enabled" }

# ── 5. Docker Desktop ─────────────────────────────────────────────────────────
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Log "Installing Docker Desktop..."
    $dockerInstaller = "$env:TEMP\DockerDesktopInstaller.exe"
    Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile $dockerInstaller
    Start-Process $dockerInstaller -Args "install --quiet --accept-license" -Wait
    Log "Docker installed"
} else { Log "Docker already present" }

Log "=== Agent Setup Complete ==="