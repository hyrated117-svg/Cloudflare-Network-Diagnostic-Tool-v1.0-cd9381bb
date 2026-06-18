#!/bin/bash
# Python-specific MCP Server Installer

set -e

echo "🐍 Installing Python MCP Server"

VERSION="1.0.0"
INSTALL_DIR="${HOME}/.local/cloudflare-mcp"

mkdir -p "${INSTALL_DIR}/server"

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    exit 1
fi

echo "✓ Python $(python3 --version) detected"

# Copy server files
cp server/index.py "${INSTALL_DIR}/server/"
chmod +x "${INSTALL_DIR}/server/index.py"

# Create virtual environment
python3 -m venv "${INSTALL_DIR}/venv"
source "${INSTALL_DIR}/venv/bin/activate"

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip setuptools wheel
pip install flask requests pyyaml

echo "✅ Python MCP Server installed successfully!"
echo "Location: ${INSTALL_DIR}/server/index.py"
echo "Virtual environment: ${INSTALL_DIR}/venv"
