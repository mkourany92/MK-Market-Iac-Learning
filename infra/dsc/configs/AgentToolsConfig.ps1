# DSC Configuration — Agent Tools Compliance (Approach 2)
# WHY Machine Config: Azure checks every 15 min — auto-corrects drift
# WHY prod: ensures any VM added to prod always meets the compliance baseline
# Compiled by compile-dsc.ps1 → uploaded to Storage → assigned via Bicep

Configuration AgentToolsConfig {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node localhost {

        # ── Azure CLI ──────────────────────────────────────────────────────────
        # WHY: Pipeline uses 'az' commands — must always be present
        Script AzureCLI {
            GetScript = {
                if (Get-Command az -ErrorAction SilentlyContinue) { return @{ Result = "Installed" } }
                else { return @{ Result = "Missing" } }
            }
            TestScript = { return [bool](Get-Command az -ErrorAction SilentlyContinue) }
            SetScript  = {
                $msi = "$env:TEMP\AzureCLI.msi"
                Invoke-WebRequest -Uri "https://aka.ms/installazurecliwindows" -OutFile $msi
                Start-Process msiexec.exe -Args "/I $msi /quiet /norestart" -Wait
            }
        }

        # ── Git ────────────────────────────────────────────────────────────────
        # WHY: Pipeline checks out code from Azure DevOps repo
        Script Git {
            GetScript = {
                if (Get-Command git -ErrorAction SilentlyContinue) { return @{ Result = "Installed" } }
                else { return @{ Result = "Missing" } }
            }
            TestScript = { return [bool](Get-Command git -ErrorAction SilentlyContinue) }
            SetScript = {
                $installer = "$env:TEMP\GitInstaller.exe"
                Invoke-WebRequest `
                    -Uri "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/Git-2.44.0-64-bit.exe" `
                    -OutFile $installer
                Start-Process $installer -Args "/SILENT /NORESTART" -Wait
            }
        }

        # ── Node.js 20+ ────────────────────────────────────────────────────────
        # WHY: Webapp build requires Node 20 — enforce minimum version
        Script NodeJS {
            GetScript = {
                if (Get-Command node -ErrorAction SilentlyContinue) { return @{ Result = "Installed" } }
                else { return @{ Result = "Missing" } }
            }
            TestScript = {
                if (-not (Get-Command node -ErrorAction SilentlyContinue)) { return $false }
                $ver = (node --version) -replace 'v', ''
                return ([version]$ver).Major -ge 20
            }
            SetScript = {
                $installer = "$env:TEMP\NodeInstaller.msi"
                Invoke-WebRequest `
                    -Uri "https://nodejs.org/dist/v20.12.0/node-v20.12.0-x64.msi" `
                    -OutFile $installer
                Start-Process msiexec.exe -Args "/I $installer /quiet /norestart" -Wait
            }
        }

        # ── WSL2 Windows Feature ───────────────────────────────────────────────
        # WHY: Agent runs Ubuntu inside WSL2 — feature must be enabled
        WindowsOptionalFeature WSL {
            Name   = "Microsoft-Windows-Subsystem-Linux"
            Ensure = "Enable"
        }

        WindowsOptionalFeature VirtualMachinePlatform {
            Name   = "VirtualMachinePlatform"
            Ensure = "Enable"
        }
    }
}

AgentToolsConfig -OutputPath "$PSScriptRoot\output"