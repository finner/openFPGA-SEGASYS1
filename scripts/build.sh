#!/usr/bin/env bash
# Build Analogue Pocket bitstream with Docker Quartus (Apple Silicon friendly).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FPGA="$ROOT/src/fpga"
IMAGE="${QUARTUS_DOCKER_IMAGE:-didiermalenfant/quartus:22.1-apple-silicon}"
PLATFORM="${QUARTUS_DOCKER_PLATFORM:-linux/amd64}"

cd "$FPGA"

echo "==> Cleaning previous build (optional)"
if [[ "${1:-}" == "clean" ]]; then
  docker run --platform "$PLATFORM" -t --rm -v "$FPGA":/build -w /build \
    "$IMAGE" quartus_sh --clean ap_core.qpf
fi

echo "==> Compiling ap_core.qpf with $IMAGE"
docker run --platform "$PLATFORM" -t --rm -v "$FPGA":/build -w /build \
  "$IMAGE" quartus_sh --flow compile ap_core.qpf

RBF="$FPGA/output_files/ap_core.rbf"
if [[ ! -f "$RBF" ]]; then
  # Some flows name it bitstream.rbf
  RBF="$FPGA/output_files/bitstream.rbf"
fi

if [[ ! -f "$RBF" ]]; then
  echo "ERROR: expected RBF not found under output_files/" >&2
  ls -la "$FPGA/output_files" || true
  exit 1
fi

echo "==> Reversing RBF bytes -> dist/Cores/finn2k1.SEGASYS1/bitstream.rbf_r"
python3 "$ROOT/scripts/reverse_rbf.py" "$RBF" \
  "$ROOT/dist/Cores/finn2k1.SEGASYS1/bitstream.rbf_r"

echo "==> Done. Copy dist/ to your Pocket SD card root."
