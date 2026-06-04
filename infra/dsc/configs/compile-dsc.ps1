# Compile DSC config to Azure Machine Configuration package
# WHY: Azure Guest Configuration requires a specific .zip package format
# Run this locally ONCE, then commit the SAS URL to Bicep parameters
# Output: SAS URL to paste into prod/main.parameters.json

param (
    [string]$StorageAccountName = "mkmarketdevst",
    [string]$StorageResourceGroup = "mkmarket-dev-rg",
    [string]$ContainerName = "dsc-packages"
)

$ErrorActionPreference = "Stop"

# â'€â'€ 1. Install required modules â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€
foreach ($mod in @('GuestConfiguration', 'Az.Storage')) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host ('Installing module: ' + $mod)
        Install-Module $mod -Force -AllowClobber -Scope CurrentUser
    }
}
Import-Module GuestConfiguration
Import-Module Az.Storage

# â'€â'€ 2. Compile DSC â†’ MOF â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€
Write-Host "Compiling AgentToolsConfig DSC..."
. "$PSScriptRoot\AgentToolsConfig.ps1"
# Output: $PSScriptRoot\output\localhost.mof

# â'€â'€ 3. Package MOF â†’ .zip for Guest Configuration â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€
$outDir = "$PSScriptRoot\output\package"
$pkgParams = @{
    Name          = 'AgentToolsConfig'
    Configuration = "$PSScriptRoot\output\localhost.mof"
    Type          = 'AuditAndSet'
    Path          = $outDir
    Force         = $true
}
New-GuestConfigurationPackage @pkgParams
Write-Host ('Package created: ' + $outDir + '\AgentToolsConfig\AgentToolsConfig.zip')

# â'€â'€ 4. Upload to Azure Storage â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€
Write-Host "Uploading to storage account: $StorageAccountName"
$ctx = (Get-AzStorageAccount -ResourceGroupName $StorageResourceGroup -Name $StorageAccountName).Context

if (-not (Get-AzStorageContainer -Name $ContainerName -Context $ctx -EA SilentlyContinue)) {
    New-AzStorageContainer -Name $ContainerName -Context $ctx -Permission Off
}

$uploadParams = @{
    Container = $ContainerName
    File      = "$outDir\AgentToolsConfig\AgentToolsConfig.zip"
    Blob      = "AgentToolsConfig.zip"
    Context   = $ctx
    Force     = $true
}
Set-AzStorageBlobContent @uploadParams | Out-Null

# â'€â'€ 5. Generate SAS URL (1 year) â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€â'€
$sasParams = @{
    Container  = $ContainerName
    Blob       = "AgentToolsConfig.zip"
    Context    = $ctx
    Permission = "r"
    ExpiryTime = (Get-Date).AddYears(1)
    FullUri    = $true
}
$sasUrl = New-AzStorageBlobSASToken @sasParams

Write-Host ""
Write-Host '=== DONE - Copy this URL to prod/main.parameters.json ==='
$msg = 'dscPackageSasUrl: ' + $sasUrl
Write-Host $msg