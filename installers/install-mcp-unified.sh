#!/bin/bash
# Unified MCP Server Installer for macOS/Linux
# Supports Python and Node.js implementations

set -e

echo "🚀 Cloudflare Network Diagnostic Tool - MCP Server Installer"
echo "================================================="

VERSION="1.0.0"
INSTALL_DIR="${HOME}/.local/cloudflare-mcp"
LOG_FILE="${INSTALL_DIR}/install.log"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "${LOG_FILE}"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "${LOG_FILE}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "${LOG_FILE}"
}

# Create installation directory
mkdir -p "${INSTALL_DIR}"
mkdir -p "${LOG_FILE%/*}"

log "Installing to: ${INSTALL_DIR}"

# Check for Python
if command -v python3 &> /dev/null; then
    log "Python 3 found: $(python3 --version)"
    PYTHON_AVAILABLE=true
else
    warning "Python 3 not found"
    PYTHON_AVAILABLE=false
fi

# Check for Node.js
if command -v node &> /dev/null; then
    log "Node.js found: $(node --version)"
    NODE_AVAILABLE=true
else
    warning "Node.js not found"
    NODE_AVAILABLE=false
fi

# Install Python server if available
if [ "$PYTHON_AVAILABLE" = true ]; then
    log "Installing Python MCP Server..."
    mkdir -p "${INSTALL_DIR}/server/python"
    cp server/index.py "${INSTALL_DIR}/server/python/" 2>/dev/null || warning "Python server file not found"
    chmod +x "${INSTALL_DIR}/server/python/index.py"
    log "✓ Python server installed"
fi

# Install Node server if available
if [ "$NODE_AVAILABLE" = true ]; then
    log "Installing Node.js MCP Server..."
    mkdir -p "${INSTALL_DIR}/server/node"
    cp server/index.js "${INSTALL_DIR}/server/node/" 2>/dev/null || warning "Node server file not found"
    cp server/package.json "${INSTALL_DIR}/server/node/" 2>/dev/null || warning "package.json not found"
    cd "${INSTALL_DIR}/server/node"
    npm install 2>/dev/null || warning "npm install failed"
    log "✓ Node.js server installed"
fi

# Copy configuration files
log "Copying configuration files..."
mkdir -p "${INSTALL_DIR}/config"
cp server/mcp-server.json "${INSTALL_DIR}/config/" 2>/dev/null || warning "mcp-server.json not found"
cp server/mcp-client.json "${INSTALL_DIR}/config/" 2>/dev/null || warning "mcp-client.json not found"

log ""
log "✅ Installation complete!"
log "Version: ${VERSION}"
log "Install directory: ${INSTALL_DIR}"
log "Log file: ${LOG_FILE}"
log ""
log "Next steps:"
log "  1. Configure your MCP client to use: ${INSTALL_DIR}/server/"
log "  2. Set environment variables as needed"
log "  3. Restart your MCP client"
log ""
log "For more information, visit: https://github.com/hyrated117/Cloudflare-Network-Diagnostic-Tool-v1.0"
