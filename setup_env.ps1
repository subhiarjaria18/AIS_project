# PowerShell environment setup for this project
# Usage: Right-click > Run with PowerShell OR run: ./setup_env.ps1

param(
    [string]$VenvPath = ".venv",
    [string]$PythonExe = "python"
)

Write-Host "=== NLP Assignment: Environment Setup ===" -ForegroundColor Cyan

# 1) Detect python
try {
    $pyVersion = & $PythonExe --version 2>$null
} catch {
    $pyVersion = $null
}

if (-not $pyVersion) {
    Write-Host "Python not found in PATH." -ForegroundColor Yellow
    Write-Host "Install Python 3.9+ from https://www.python.org/downloads/windows/ and re-run this script." -ForegroundColor Yellow
    Write-Host "Tip: During install, check 'Add python.exe to PATH'." -ForegroundColor Yellow
    exit 1
}

Write-Host "Found $pyVersion" -ForegroundColor Green

# 2) Create venv if missing
if (-not (Test-Path $VenvPath)) {
    Write-Host "Creating virtual environment at $VenvPath ..." -ForegroundColor Cyan
    & $PythonExe -m venv $VenvPath
    if ($LASTEXITCODE -ne 0) { Write-Error "Failed to create venv."; exit 1 }
}

# 3) Use venv's Python directly (no activation required)
$VenvPython = Join-Path $VenvPath "Scripts/python.exe"
if (-not (Test-Path $VenvPython)) {
    Write-Error "Venv python not found at $VenvPython"
    exit 1
}

# 4) Upgrade pip and wheel
& $VenvPython -m pip install --upgrade pip wheel setuptools
if ($LASTEXITCODE -ne 0) { Write-Error "Failed to upgrade pip/wheel/setuptools in venv."; exit 1 }

# 5) Install project requirements
Write-Host "Installing requirements from requirements.txt ..." -ForegroundColor Cyan
& $VenvPython -m pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) { Write-Error "pip install failed in venv."; exit 1 }

# 6) Download spaCy model
Write-Host "Downloading spaCy model en_core_web_sm ..." -ForegroundColor Cyan
& $VenvPython -m spacy download en_core_web_sm
if ($LASTEXITCODE -ne 0) { Write-Warning "spaCy model download may have failed. You can retry: `$VenvPython -m spacy download en_core_web_sm" }

# 7) Register Jupyter kernel for the venv
Write-Host "Registering Jupyter kernel 'nlp-assignment' ..." -ForegroundColor Cyan
& $VenvPython -m ipykernel install --user --name "nlp-assignment" --display-name "Python (nlp-assignment)"
if ($LASTEXITCODE -ne 0) { Write-Warning "Kernel registration may have failed. You can retry: `$VenvPython -m ipykernel install --user --name nlp-assignment --display-name 'Python (nlp-assignment)'" }

Write-Host "Setup complete. Select kernel 'Python (nlp-assignment)' in VS Code for the notebook." -ForegroundColor Green
