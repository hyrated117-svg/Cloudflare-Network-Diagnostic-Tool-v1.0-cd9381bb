# Python-specific MCP Server Installer for Windows

param(
    [string]$InstallDir = "$env:APPDATA\Cloudflare-MCP"
)

Write-Host "🐍 Installing Python MCP Server" -ForegroundColor Green

$version = "1.0.0"

# Create install directory
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

$serverDir = Join-Path $InstallDir "server"
New-Item -ItemType Directory -Path $serverDir -Force | Out-Null

# Check Python installation
if (-not (Get-Command python.exe -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Python 3 is required but not installed." -ForegroundColor Red
    exit 1
}

$pythonVersion = python.exe --version 2>&1
Write-Host "✓ $pythonVersion detected" -ForegroundColor Green

# Copy server files
if (Test-Path "server\index.py") {
    Copy-Item -Path "server\index.py" -Destination $serverDir -Force
}

# Create virtual environment
$venvPath = Join-Path $InstallDir "venv"
python.exe -m venv $venvPath

# Activate and install dependencies
$activateScript = Join-Path $venvPath "Scripts\Activate.ps1"
& $activateScript

Write-Host "Installing dependencies..." -ForegroundColor Cyan
pip install --upgrade pip setuptools wheel
pip install flask requests pyyaml

Write-Host "✅ Python MCP Server installed successfully!" -ForegroundColor Green
Write-Host "Location: $serverDir\index.py"
Write-Host "Virtual environment: $venvPath"
