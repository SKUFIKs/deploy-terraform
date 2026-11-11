# Installs local Terraform and TFLint into .tools/ (git-ignored).
# Usage (from repo root):  .\tools\install-tools.ps1
# If the execution policy blocks it:
#   powershell -ExecutionPolicy Bypass -File .\tools\install-tools.ps1

param(
    [string]$TerraformVersion = '1.17.1',
    [string]$TflintVersion = '0.66.0',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repoRoot = Split-Path -Parent $PSScriptRoot
$toolsDir = Join-Path $repoRoot '.tools'
$cacheDir = Join-Path $toolsDir 'downloads'
New-Item -ItemType Directory -Force -Path $toolsDir, $cacheDir | Out-Null

function Get-RemoteFile([string]$url, [string]$path) {
    Write-Host "==> $url"
    Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
}

function Expand-To([string]$zip, [string]$dir) {
    Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Expand-Archive -Path $zip -DestinationPath $dir -Force
}

$terraformExe = Join-Path $toolsDir 'terraform.exe'
if ($Force -or -not (Test-Path $terraformExe)) {
    $zip = Join-Path $cacheDir "terraform_$TerraformVersion.zip"
    $urls = @(
        "https://hashicorp-releases.yandexcloud.net/terraform/$TerraformVersion/terraform_${TerraformVersion}_windows_amd64.zip",
        "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_${TerraformVersion}_windows_amd64.zip"
    )

    $downloaded = $false
    foreach ($url in $urls) {
        try {
            Get-RemoteFile $url $zip
            $downloaded = $true
            break
        }
        catch {
            Write-Warning "Download failed: $url"
        }
    }

    if (-not $downloaded) {
        throw "Could not download Terraform $TerraformVersion."
    }

    $extractDir = Join-Path $cacheDir 'terraform'
    Expand-To $zip $extractDir
    Copy-Item (Join-Path $extractDir 'terraform.exe') $terraformExe -Force
}

$tflintExe = Join-Path $toolsDir 'tflint.exe'
if ($Force -or -not (Test-Path $tflintExe)) {
    $zip = Join-Path $cacheDir "tflint_$TflintVersion.zip"
    $url = "https://github.com/terraform-linters/tflint/releases/download/v$TflintVersion/tflint_windows_amd64.zip"
    Get-RemoteFile $url $zip

    $extractDir = Join-Path $cacheDir 'tflint'
    Expand-To $zip $extractDir
    Copy-Item (Join-Path $extractDir 'tflint.exe') $tflintExe -Force
}

# Local Terraform CLI config. The provider mirror is useful where
# registry.terraform.io is unavailable (for example, GEO restrictions).
$rcPath = Join-Path $repoRoot '.terraformrc'
if ($Force -or -not (Test-Path $rcPath)) {
    $rc = @"
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
"@
    [System.IO.File]::WriteAllText($rcPath, $rc, (New-Object System.Text.UTF8Encoding($false)))
}

Write-Host ''
& $terraformExe version
& $tflintExe --version
Write-Host ''
Write-Host 'Installed to .tools/. Run: .\lint.ps1'
