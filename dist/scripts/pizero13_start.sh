#!/bin/bash

# P4wnP1 A.L.O.A. — Pi Zero 1.3 Startup Script
#
# The Pi Zero 1.3 has NO built-in WiFi or Bluetooth.
# This script configures USB-only networking via RNDIS + CDC-ECM.
# For WiFi capability, attach a USB WiFi adapter (e.g. Alfa AWUS036NHA)
# and run: P4wnP1_cli wifi set ap -r US -c 6 -s "P4wnP1-1.3" -k "changeme"

# ---- USB Gadget: RNDIS + CDC-ECM (no WiFi needed) ----
P4wnP1_cli usb set \
  --vid 0x1d6c \
  --pid 0x1347 \
  --manufacturer "P4wnP1" \
  --sn "deadbeef1337" \
  --product "P4wnP1 Pi Zero 1.3" \
  --rndis \
  --cdc-ecm

# ---- USB Ethernet: usbeth DHCP server ----
# Pi Zero gets 172.16.0.1; assigns 172.16.0.2 to host (PC or Android)
P4wnP1_cli net set server \
  -i usbeth \
  -a 172.16.0.1 \
  -m 255.255.255.248 \
  -o "3:" \
  -o "6:" \
  -r "172.16.0.2|172.16.0.2|5m"

# ---- Blink LED twice: ready ----
P4wnP1_cli led -b 2

# ---- Start tool installer (if installed) ----
if [ -f /usr/local/P4wnP1/tool_installer/server.py ]; then
  nohup python3 /usr/local/P4wnP1/tool_installer/server.py \
    --mode local \
    --port 8080 \
    >> /var/log/p4wnp1_installer.log 2>&1 &
  echo "Tool installer started at http://172.16.0.1:8080"
fi
