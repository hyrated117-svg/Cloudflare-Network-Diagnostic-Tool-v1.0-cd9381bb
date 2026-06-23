#!/bin/sh

echo "[1/7] Updating Alpine packages..."
apk update

echo "[2/7] Installing build dependencies..."
apk add build-base git go wget

echo "[3/7] Creating workspace..."
mkdir -p /root/src
cd /root/src

echo "[4/7] Cloning GitHub CLI source..."
git clone https://github.com/cli/cli.git
cd cli

echo "[5/7] Building GitHub CLI..."
make

echo "[6/7] Installing gh into /usr/local/bin..."
cp bin/gh /usr/local/bin/

echo "[7/7] Cleaning up..."
cd /root
echo "export PATH=/usr/local/bin:\$PATH" >> ~/.profile

echo ""
echo "🎉 GitHub CLI installed successfully!"
echo "Run: gh --version"
echo ""
