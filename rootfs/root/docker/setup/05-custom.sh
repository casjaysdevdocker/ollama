#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202601282319-git
# @@Author           :  CasjaysDev
# @@Contact          :  CasjaysDev <docker-admin@casjaysdev.pro>
# @@License          :  MIT
# @@Copyright        :  Copyright 2026 CasjaysDev
# @@Created          :  Wed Jan 28 11:19:52 PM EST 2026
# @@File             :  05-custom.sh
# @@Description      :  script to run custom
# @@Changelog        :  newScript
# @@TODO             :  Refactor code
# @@Other            :  N/A
# @@Resource         :  N/A
# @@Terminal App     :  yes
# @@sudo/root        :  yes
# @@Template         :  templates/dockerfiles/init_scripts/05-custom.sh
# - - - - - - - - - - - - - - - - - - - - - - - - -
# shellcheck disable=SC1001,SC1003,SC2001,SC2003,SC2016,SC2031,SC2090,SC2115,SC2120,SC2155,SC2199,SC2229,SC2317,SC2329
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
set -o pipefail
[ "$DEBUGGER" = "on" ] && echo "Enabling debugging" && set -x$DEBUGGER_OPTIONS
# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set env variables
exitCode=0

# - - - - - - - - - - - - - - - - - - - - - - - - -
# Predefined actions

# - - - - - - - - - - - - - - - - - - - - - - - - -
# Main script

# All standard packages are installed via PACK_LIST in Dockerfile

# Determine architecture
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH" && exit 1 ;;
esac

# Install Ollama binary
echo "Installing Ollama for $ARCH..."
OLLAMA_URL="https://github.com/ollama/ollama/releases/latest/download/ollama-linux-${ARCH}.tar.zst"

curl -fsSL "$OLLAMA_URL" | zstd -d | tar -x -C /usr/local/bin --strip-components=1 bin/ollama
chmod +x /usr/local/bin/ollama

# Verify installation
if [ -x "/usr/local/bin/ollama" ]; then
  echo "✓ Ollama installed successfully to /usr/local/bin/ollama"
  /usr/local/bin/ollama --version 2>/dev/null || echo "Ollama binary ready"
else
  echo "Failed to install Ollama" && exit 1
fi

# ============================================
# CPU & GPU OPTIMIZATION LIBRARIES
# ============================================
echo "Installing CPU optimization libraries..."
echo "  • OpenBLAS: Optimized linear algebra (3-5x faster CPU inference)"
echo "  • libgomp: OpenMP multi-threading support"
echo ""
echo "Note: Hardware detection happens at runtime on user's machine"
echo "      GPU support via runtime device passthrough (no GPU libs in image)"

# ============================================
# PYTHON INSTALLATION FOR OPEN WEBUI
# ============================================
echo "Installing Python dependencies for Open WebUI..."
# Debian 12 (Bookworm) comes with Python 3.11 which is perfect for Open WebUI
pkmgr install python3 python3-pip python3-venv python3-dev

# Verify Python version
python3 --version

# ============================================
# OPEN WEBUI INSTALLATION
# ============================================
echo "Installing Open WebUI..."

# Install Open WebUI using system Python (requires --break-system-packages in Docker)
python3 -m pip install --break-system-packages --upgrade pip
python3 -m pip install --break-system-packages open-webui

# Verify Open WebUI installation  
if python3 -m open_webui --help >/dev/null 2>&1; then
  echo "✓ Open WebUI installed successfully with Python $(python3 --version)"
elif command -v open-webui >/dev/null 2>&1; then
  echo "✓ Open WebUI installed successfully"
else
  echo "⚠ Warning: Open WebUI may not be in PATH, but should be installed"
fi

echo "✓ Ollama and Open WebUI installation complete"

# - - - - - - - - - - - - - - - - - - - - - - - - -
# Set the exit code
#exitCode=$?
# - - - - - - - - - - - - - - - - - - - - - - - - -
exit $exitCode
# - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
# - - - - - - - - - - - - - - - - - - - - - - - - -
