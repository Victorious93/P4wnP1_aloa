#!/bin/bash
# P4wnP1 A.L.O.A. — Pi Zero 1.3 First-Boot Setup Script
#
# Run this once on the Pi Zero 1.3 after flashing the SD card and
# logging in via SSH (ssh root@172.16.0.1) or serial console.
#
# Prerequisites: Raspberry Pi OS Lite (32-bit) flashed to SD card
#   with SSH enabled (/boot/ssh touchfile) and USB OTG configured.

set -euo pipefail

INSTALLER_DIR="/usr/local/P4wnP1/tool_installer"
P4WNPI_DIR="/usr/local/P4wnP1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "  P4wnP1 A.L.O.A. — Pi Zero 1.3 Setup"
echo "=========================================="
echo ""

# ---- 1. Enable USB OTG gadget mode in /boot/config.txt ----
if ! grep -q "dtoverlay=dwc2" /boot/config.txt 2>/dev/null; then
  echo "Enabling DWC2 USB OTG overlay..."
  echo "dtoverlay=dwc2" >> /boot/config.txt
fi

# Enable dwc2 and g_ether modules
if ! grep -q "dwc2" /etc/modules 2>/dev/null; then
  echo "dwc2" >> /etc/modules
fi

# ---- 2. Configure static USB networking ----
cat > /etc/network/interfaces.d/usb0 << 'EOF'
allow-hotplug usb0
iface usb0 inet static
  address 172.16.0.1
  netmask 255.255.255.248
EOF

# ---- 3. Install P4wnP1 dependencies ----
echo "Installing dependencies..."
apt-get update -qq
apt-get install -y --no-install-recommends \
  git dnsmasq hostapd iw wireless-tools \
  haveged avahi-daemon \
  python3 python3-pip python3-venv \
  curl wget net-tools iproute2 \
  openssl ca-certificates

# ---- 4. Install tool installer Python requirements ----
echo "Installing tool installer dependencies..."
pip3 install --quiet fastapi uvicorn paramiko aiofiles python-multipart

# ---- 5. Copy P4wnP1 binaries if building locally ----
if [ -f "$REPO_ROOT/build/P4wnP1_service" ]; then
  echo "Installing P4wnP1 service and CLI..."
  cp "$REPO_ROOT/build/P4wnP1_service" /usr/local/bin/
  cp "$REPO_ROOT/build/P4wnP1_cli" /usr/local/bin/
  chmod +x /usr/local/bin/P4wnP1_service /usr/local/bin/P4wnP1_cli
fi

# ---- 6. Install P4wnP1 runtime assets ----
mkdir -p "$P4WNPI_DIR"
if [ -d "$REPO_ROOT/dist" ]; then
  cp -R "$REPO_ROOT/dist/keymaps"    "$P4WNPI_DIR/" 2>/dev/null || true
  cp -R "$REPO_ROOT/dist/scripts"    "$P4WNPI_DIR/" 2>/dev/null || true
  cp -R "$REPO_ROOT/dist/HIDScripts" "$P4WNPI_DIR/" 2>/dev/null || true
  cp -R "$REPO_ROOT/dist/www"        "$P4WNPI_DIR/" 2>/dev/null || true
  cp -R "$REPO_ROOT/dist/db"         "$P4WNPI_DIR/" 2>/dev/null || true
  cp -R "$REPO_ROOT/dist/ums"        "$P4WNPI_DIR/" 2>/dev/null || true
  cp -R "$REPO_ROOT/dist/legacy"     "$P4WNPI_DIR/" 2>/dev/null || true
fi

# ---- 7. Install the Pi Zero 1.3 startup script ----
cp "$REPO_ROOT/dist/scripts/pizero13_start.sh" "$P4WNPI_DIR/scripts/"
chmod +x "$P4WNPI_DIR/scripts/pizero13_start.sh"

# ---- 8. Install tool installer ----
mkdir -p "$INSTALLER_DIR"
cp -R "$REPO_ROOT/tool_installer/." "$INSTALLER_DIR/"
chmod +x "$INSTALLER_DIR/run_ondevice.sh" 2>/dev/null || true

# ---- 9. Install systemd unit for P4wnP1 ----
if [ -f "$REPO_ROOT/dist/P4wnP1.service" ]; then
  cp "$REPO_ROOT/dist/P4wnP1.service" /etc/systemd/system/
fi

# ---- 10. Install systemd unit for tool installer ----
cat > /etc/systemd/system/p4wnp1-installer.service << 'EOF'
[Unit]
Description=P4wnP1 Tool Installer Web UI
After=network.target P4wnP1.service
Wants=P4wnP1.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/P4wnP1/tool_installer/server.py --mode local --port 8080
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# ---- 11. Enable services ----
systemctl daemon-reload
systemctl enable haveged avahi-daemon p4wnp1-installer.service
[ -f /etc/systemd/system/P4wnP1.service ] && systemctl enable P4wnP1.service || true

echo ""
echo "=========================================="
echo "  Setup complete!"
echo ""
echo "  Reboot the Pi Zero 1.3 and plug it into"
echo "  a PC or Android via USB."
echo ""
echo "  Then browse to:"
echo "    http://172.16.0.1:8080  → Tool Installer"
echo "    http://172.16.0.1:8000  → P4wnP1 Web UI"
echo ""
echo "  SSH: ssh root@172.16.0.1"
echo "=========================================="
