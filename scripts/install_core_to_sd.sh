#!/usr/bin/env bash
# Copy core files to a mounted Pocket SD card.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/dist/Cores/finn2k1.SEGASYS1"

SD=""
for v in /Volumes/*; do
  # Prefer a real Pocket card (Assets + Cores), skip the Mac boot volume.
  if [[ -d "$v/Assets" && -d "$v/Cores" && -e "$v/Analogue_Pocket.json" ]]; then
    SD="$v"
    break
  fi
done
if [[ -z "$SD" ]]; then
  for v in /Volumes/*; do
    if [[ -d "$v/Assets" && -d "$v/Cores" ]]; then
      SD="$v"
      break
    fi
  done
fi

if [[ -z "$SD" ]]; then
  echo "No Pocket SD mounted under /Volumes. Plug it in and re-run."
  exit 1
fi

DEST="$SD/Cores/finn2k1.SEGASYS1"
mkdir -p "$DEST"
rm -rf "$SD/Settings/finn2k1.SEGASYS1"
cp -f "$SRC/bitstream.rbf_r" "$SRC/video.json" "$SRC/interact.json" "$SRC/core.json" "$DEST/"
echo "Installed to $DEST"
echo "Removed $SD/Settings/finn2k1.SEGASYS1 (if present)"
echo "Core version should read: $(python3 -c "import json;print(json.load(open('$SRC/core.json'))['core']['metadata']['version'])")"
ls -la "$DEST/bitstream.rbf_r" "$DEST/video.json" "$DEST/core.json"
