#!/bin/bash
# Build script for Raspberry Pi Zero 1.3
#
# Pi Zero 1.3 uses the same ARM1176JZF-S CPU as Pi Zero W.
# Target: linux/arm GOARM=6 (same as the existing build.sh)
#
# This script is a documented wrapper around build.sh that makes the
# Pi Zero 1.3 target explicit and confirms no additional changes are needed.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Building P4wnP1 A.L.O.A. for Raspberry Pi Zero 1.3"
echo "  GOOS=linux  GOARCH=arm  GOARM=6"
echo ""
echo "Note: Pi Zero 1.3 and Pi Zero W share the same ARM core."
echo "The existing build.sh already targets GOARM=6 — no changes needed."
echo ""

exec "$SCRIPT_DIR/build.sh" "$@"
