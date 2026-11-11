# Runs the same checks as CI before pushing.
# Usage (from repo root):  .\lint.ps1
# Requires terraform and tflint in PATH.
# If the execution policy blocks it:
#   powershell -ExecutionPolicy Bypass -File .\lint.ps1

$ErrorActionPreference = 'Stop'
$tfDir = Join-Path $PSScriptRoot 'terraform'

# Prefer tools installed locally by tools/install-tools.ps1.
$toolsDir = Join-Path $PSScriptRoot '.tools'
if (Test-Path (Join-Path $toolsDir 'terraform.exe')) {
    $env:PATH = "$toolsDir;$env:PATH"
}

# Use the local provider mirror only if the user has no CLI config of their own.
if (-not $env:TF_CLI_CONFIG_FILE) {
    $localRc = Join-Path $PSScriptRoot '.terraformrc'
    if (Test-Path $localRc) {
        $env:TF_CLI_CONFIG_FILE = $localRc
    }
}

function Assert-Command([string]$name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Command not found: $name. Run .\tools\install-tools.ps1 or install it manually."
    }
}

Assert-Command 'terraform'
Assert-Command 'tflint'

# pre-commit is optional: without it the checks below run directly.
Push-Location $PSScriptRoot
try {
    if (Get-Command 'pre-commit' -ErrorAction SilentlyContinue) {
        Write-Host '==> pre-commit (fmt, validate, tflint)'
        pre-commit run --all-files
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    else {
        Write-Host '==> pre-commit not found, running checks directly'
    }
}
finally {
    Pop-Location
}

Push-Location $tfDir
try {
    Write-Host '==> terraform fmt -check -recursive'
    terraform fmt -check -recursive -diff
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host '==> terraform init -backend=false'
    terraform init -backend=false -input=false -lockfile=readonly
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host '==> terraform validate'
    terraform validate
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host '==> tflint --init'
    tflint --init
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host '==> tflint'
    tflint
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host '==> terraform test'
    terraform test
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
finally {
    Pop-Location
}
