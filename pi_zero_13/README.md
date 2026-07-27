# P4wnP1 A.L.O.A. — Raspberry Pi Zero 1.3 Edition

This branch adapts P4wnP1 A.L.O.A. for the **Raspberry Pi Zero 1.3**, which has
no built-in WiFi or Bluetooth. All connectivity is via USB OTG.

---

## Hardware Differences vs Pi Zero W

| Feature | Pi Zero W | Pi Zero 1.3 |
|---|---|---|
| CPU | ARM1176 @ 1 GHz | ARM1176 @ 1 GHz |
| RAM | 512 MB | 512 MB |
| Built-in WiFi | ✅ 2.4 GHz 802.11 b/g/n | ❌ |
| Built-in Bluetooth | ✅ BT 4.1 + BLE | ❌ |
| USB OTG | ✅ | ✅ |
| Camera connector | ❌ | ✅ (v1.3 CSI) |
| Price | ~$15 | ~$5 |

---

## What Works Without External Hardware

- **HID keyboard/mouse emulation** (full DuckyScript engine)
- **USB mass storage emulation**
- **USB network adapter emulation** (RNDIS + CDC-ECM)
- **USB serial port emulation** (CDC-ACM)
- **Composite USB device** (all above simultaneously)
- **DHCP/DNS server** on USB network interface
- **Web UI** (P4wnP1 interface at 172.16.0.1:8000)
- **Tool Installer UI** (at 172.16.0.1:8080)
- **SSH access** (root@172.16.0.1)
- **GPIO / sensors** (external hardware via GPIO pins)

## What Requires External USB Hardware

| Capability | Required USB Adapter |
|---|---|
| WiFi AP / Evil Twin | USB WiFi adapter with AP support (e.g. Alfa AWUS036NHA, TP-Link TL-WN722N v1) |
| WiFi monitor mode | USB WiFi adapter with monitor mode (Alfa AWUS036NHA, AR9271 chipset) |
| Bluetooth | USB Bluetooth adapter (e.g. Plugable USB-BT4LE) |
| SDR / RF monitoring | RTL-SDR USB dongle |
| ZigBee | USB ZigBee coordinator (e.g. ConBee II) |
| Z-Wave | USB Z-Wave stick (e.g. Aeotec Z-Stick) |
| Cellular | USB LTE modem with SIM (supported via OpenStick) |

> **Recommended WiFi adapter**: Alfa AWUS036NHA (Atheros AR9271) — supports
> monitor mode, packet injection, and AP mode; plug into the USB OTG port via
> a Micro-USB OTG adapter.

---

## Quick Start

### 1. Flash SD Card

Download Raspberry Pi OS Lite (32-bit) and flash with Raspberry Pi Imager.
Before ejecting, create a file named `ssh` in the `/boot` partition to enable SSH.

### 2. Enable USB OTG (add to `/boot/config.txt`)

```
dtoverlay=dwc2
```

And add to `/boot/cmdline.txt` (end of the single line, space-separated):
```
modules-load=dwc2,g_ether
```

### 3. Connect and SSH

Plug the Pi Zero 1.3 into your PC via the **USB data port** (not PWR IN).
Wait ~30 seconds, then:

```bash
ssh root@172.16.0.1
# default password: raspberry
```

### 4. Clone and Run Setup

```bash
git clone https://github.com/victorious93/p4wnp1_aloa.git
cd p4wnp1_aloa
git checkout claude/pi-zero-tool-installer-zh92ov
bash pi_zero_13/setup.sh
reboot
```

### 5. Use the Tool Installer

After reboot, plug into PC or Android (via USB OTG adapter).

- **PC**: Open browser → `http://172.16.0.1:8080`
- **Android**: Connect via USB OTG adapter → Open browser → `http://172.16.0.1:8080`
- **Android app**: Install the provided APK (see `android/` folder)

---

## Architecture

```
Your PC / Android
      │  USB cable (Micro-USB data port)
      ▼
Pi Zero 1.3
  ├── USB Gadget (RNDIS/CDC-ECM) → host gets IP 172.16.0.2
  ├── P4wnP1 Service    :8000  → HID/USB/Network config UI
  └── Tool Installer    :8080  → Select & install capabilities
```

---

## Startup Behavior

On boot, `pizero13_start.sh` runs as a P4wnP1 TriggerAction:

1. Enables RNDIS + CDC-ECM USB network gadget
2. Starts DHCP server on `usbeth` → assigns 172.16.0.2 to host
3. Blinks LED twice (ready signal)
4. Starts the tool installer web server on port 8080

---

## Build (Cross-Compile from x86 Host)

```bash
# Using Docker (recommended)
docker build -f build_support/Dockerfile -t p4wnp1-builder .
docker run --rm -v $(pwd)/build:/build p4wnp1-builder

# The build script already targets GOARM=6 (correct for Pi Zero 1.3)
# build_support/build_pizero13.sh is a documented wrapper
bash build_support/build_pizero13.sh
```

---

## Differences from Pi Zero W Version

| Component | Pi Zero W | Pi Zero 1.3 |
|---|---|---|
| Startup script | `servicestart.sh` (enables WiFi AP) | `pizero13_start.sh` (USB only) |
| WiFi subsystem | Nexmon-patched `brcmfmac` | Not loaded (no hardware) |
| Bluetooth subsystem | BlueZ via `brcm_patchram_plus` | Disabled (no hardware) |
| Default connectivity | RNDIS + CDC-ECM + WiFi AP | RNDIS + CDC-ECM only |
| Tool installer | Not included | Included (port 8080) |
