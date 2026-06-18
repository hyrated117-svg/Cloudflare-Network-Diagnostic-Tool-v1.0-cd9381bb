#!/usr/bin/env python3
"""
Python-based MCP Server Installer
Cross-platform installation for macOS, Linux, and Windows
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path
from datetime import datetime

VERSION = "1.0.0"
PROJECT_NAME = "Cloudflare Network Diagnostic Tool"

class MCPInstaller:
    def __init__(self, install_dir=None):
        if install_dir:
            self.install_dir = Path(install_dir)
        else:
            home = Path.home()
            self.install_dir = home / ".local" / "cloudflare-mcp"
        
        self.server_dir = self.install_dir / "server"
        self.venv_dir = self.install_dir / "venv"
        self.log_file = self.install_dir / "install.log"
        
    def log(self, message, level="INFO"):
        """Log messages to file and console."""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        msg = f"[{timestamp}] [{level}] {message}"
        print(msg)
        
        self.install_dir.mkdir(parents=True, exist_ok=True)
        with open(self.log_file, "a") as f:
            f.write(msg + "\n")
    
    def error(self, message):
        """Log error and exit."""
        self.log(message, "ERROR")
        sys.exit(1)
    
    def warning(self, message):
        """Log warning."""
        self.log(message, "WARN")
    
    def check_python(self):
        """Verify Python 3.8+ is available."""
        if sys.version_info < (3, 8):
            self.error("Python 3.8+ is required")
        self.log(f"Python {sys.version.split()[0]} detected")
    
    def create_directories(self):
        """Create necessary directories."""
        self.log(f"Creating directories at {self.install_dir}")
        self.install_dir.mkdir(parents=True, exist_ok=True)
        self.server_dir.mkdir(parents=True, exist_ok=True)
    
    def copy_server_files(self):
        """Copy server files to installation directory."""
        self.log("Copying server files...")
        
        source_file = Path("server/index.py")
        if source_file.exists():
            dest_file = self.server_dir / "index.py"
            shutil.copy2(source_file, dest_file)
            dest_file.chmod(0o755)
            self.log(f"✓ Copied {source_file} to {dest_file}")
        else:
            self.warning(f"Server file not found: {source_file}")
    
    def create_venv(self):
        """Create Python virtual environment."""
        self.log(f"Creating virtual environment at {self.venv_dir}")
        
        try:
            subprocess.run(
                [sys.executable, "-m", "venv", str(self.venv_dir)],
                check=True,
                capture_output=True
            )
            self.log("✓ Virtual environment created")
        except subprocess.CalledProcessError as e:
            self.error(f"Failed to create virtual environment: {e}")
    
    def install_dependencies(self):
        """Install Python dependencies."""
        self.log("Installing dependencies...")
        
        # Determine pip path
        if sys.platform == "win32":
            pip_path = self.venv_dir / "Scripts" / "pip.exe"
        else:
            pip_path = self.venv_dir / "bin" / "pip"
        
        dependencies = ["flask", "requests", "pyyaml", "jsonschema"]
        
        try:
            subprocess.run(
                [str(pip_path), "install", "--upgrade", "pip", "setuptools", "wheel"],
                check=True,
                capture_output=True
            )
            
            subprocess.run(
                [str(pip_path), "install"] + dependencies,
                check=True,
                capture_output=True
            )
            self.log("✓ Dependencies installed")
        except subprocess.CalledProcessError as e:
            self.error(f"Failed to install dependencies: {e}")
    
    def copy_config_files(self):
        """Copy configuration files."""
        self.log("Copying configuration files...")
        
        config_dir = self.install_dir / "config"
        config_dir.mkdir(exist_ok=True)
        
        for config_file in ["mcp-server.json", "mcp-client.json"]:
            source = Path(f"server/{config_file}")
            if source.exists():
                dest = config_dir / config_file
                shutil.copy2(source, dest)
                self.log(f"✓ Copied {config_file}")
    
    def install(self):
        """Execute full installation."""
        print(f"🚀 {PROJECT_NAME} - MCP Server Installer v{VERSION}")
        print("=" * 50)
        print()
        
        self.check_python()
        self.create_directories()
        self.copy_server_files()
        self.create_venv()
        self.install_dependencies()
        self.copy_config_files()
        
        print()
        self.log("✅ Installation complete!")
        print(f"Install directory: {self.install_dir}")
        print(f"Log file: {self.log_file}")
        print()
        print("Next steps:")
        print(f"  1. Activate virtual environment: source {self.venv_dir}/bin/activate")
        print(f"  2. Run server: python {self.server_dir}/index.py")
        print(f"  3. Configure your MCP client to use: {self.install_dir}/server/")
        print()

if __name__ == "__main__":
    installer = MCPInstaller()
    installer.install()
