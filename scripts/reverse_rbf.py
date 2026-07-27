#!/usr/bin/env python3
"""Byte-reverse an RBF into Analogue Pocket bitstream.rbf_r format."""
from __future__ import annotations

import sys
from pathlib import Path


def reverse_bytes(data: bytes) -> bytes:
    return bytes(int(f"{b:08b}"[::-1], 2) for b in data)


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} input.rbf output.rbf_r", file=sys.stderr)
        return 2
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    data = src.read_bytes()
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_bytes(reverse_bytes(data))
    print(f"wrote {dst} ({len(data)} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
