# Unified MCP Server Installer for Windows PowerShell
# Supports Python and Node.js implementations

param(
    [string]$InstallDir = "$env:APPDATA\Cloudflare-MCP"
)

$ErrorActionPreference = "Stop"
$version = "1.0.0"
$logFile = Join-Path $InstallDir "install.log"

function Write-Info {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $msg = "[$timestamp] [INFO] $Message"
    Write-Host $msg -ForegroundColor Green
    Add-Content -Path $logFile -Value $msg
}

function Write-Error-Custom {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $msg = "[$timestamp] [ERROR] $Message"
    Write-Host $msg -ForegroundColor Red
    Add-Content -Path $logFile -Value $msg
    exit 1
}

function Write-Warning-Custom {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $msg = "[$timestamp] [WARN] $Message"
    Write-Host $msg -ForegroundColor Yellow
    Add-Content -Path $logFile -Value $msg
}

Write-Host "🚀 Cloudflare Network Diagnostic Tool - MCP Server Installer" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

# Create installation directory
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

Write-Info "Installing to: $InstallDir"

# Check for Python
$pythonAvailable = $false
if (Get-Command python.exe -ErrorAction SilentlyContinue) {
    $pythonVersion = python.exe --version 2>&1
    Write-Info "Python found: $pythonVersion"
    $pythonAvailable = $true
} else {
    Write-Warning-Custom "Python not found"
}

# Check for Node.js
$nodeAvailable = $false
if (Get-Command node.exe -ErrorAction SilentlyContinue) {
    $nodeVersion = node.exe --version 2>&1
    Write-Info "Node.js found: $nodeVersion"
    $nodeAvailable = $true
} else {
    Write-Warning-Custom "Node.js not found"
}

# Install Python server
if ($pythonAvailable) {
    Write-Info "Installing Python MCP Server..."
    $pythonDir = Join-Path $InstallDir "server\python"
    New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null
    
    if (Test-Path "server\index.py") {
        Copy-Item -Path "server\index.py" -Destination $pythonDir -Force
        Write-Info "✓ Python server installed"
    } else {
        Write-Warning-Custom "Python server file not found"
    }
}

# Install Node server
if ($nodeAvailable) {
    Write-Info "Installing Node.js MCP Server..."
    $nodeDir = Join-Path $InstallDir "server\node"
    New-Item -ItemType Directory -Path $nodeDir -Force | Out-Null
    
    if (Test-Path "server\index.js") {
        Copy-Item -Path "server\index.js" -Destination $nodeDir -Force
    }
    if (Test-Path "server\package.json") {
        Copy-Item -Path "server\package.json" -Destination $nodeDir -Force
    }
    
    Push-Location $nodeDir
    npm install 2>&1 | Out-Null
    Pop-Location
    
    Write-Info "✓ Node.js server installed"
}

# Copy configuration files
Write-Info "Copying configuration files..."
$configDir = Join-Path $InstallDir "config"
New-Item -ItemType Directory -Path $configDir -Force | Out-Null

if (Test-Path "server\mcp-server.json") {
    Copy-Item -Path "server\mcp-server.json" -Destination $configDir -Force
}
if (Test-Path "server\mcp-client.json") {
    Copy-Item -Path "server\mcp-client.json" -Destination $configDir -Force
}

Write-Host "`n" -NoNewline
Write-Info "✅ Installation complete!"
Write-Info "Version: $version"
Write-Info "Install directory: $InstallDir"
Write-Info "Log file: $logFile"
Write-Host "`n" -NoNewline
Write-Info "Next steps:"
Write-Info "  1. Configure your MCP client to use: $InstallDir\server\"
Write-Info "  2. Set environment variables as needed"
Write-Info "  3. Restart your MCP client"
Write-Host "`n" -NoNewline
Write-Info "For more information, visit: https://github.com/hyrated117/Cloudflare-Network-Diagnostic-Tool-v1.0"
