# openFPGA-SEGASYS1
#
# Sega System 1 arcade core for Analogue Pocket.
# Ported from [MiSTer Arcade-SEGASYS1](https://github.com/MiSTer-devel/Arcade-SEGASYS1_MiSTer)
# by MiSTer-X.

## Status

Initial openFPGA port (v0.16):

- Vendored MiSTer game RTL (`SEGASYSTEM1`, T80, SN76489, HVGEN, spinner)
- APF `core_top` with ROM load, SYSMODE/DSW/flip via Interact, I2S audio
- Asset presets for all 18 MiSTer-supported games
- First bring-up target: **Flicky** (horizontal)

Not yet: high-score save/load, Choplifter/Gardia/Noboranka (unsupported on MiSTer too).

## Requirements

- Analogue Pocket (openFPGA)
- Docker Desktop on Apple Silicon (Quartus has no native macOS ARM build)
- [mra-tools-c](https://github.com/sebdel/mra-tools-c/) to build `.rom` files from MAME zips
- Legal MAME ROM sets matching the `.mra` files in `mra/`

## Build (M1 Mac)

```bash
# once: install Docker Desktop, enable Rosetta / linux/amd64
chmod +x scripts/build.sh
./scripts/build.sh
```

This runs Quartus inside `didiermalenfant/quartus:22.1-apple-silicon` and writes
`dist/Cores/finn2k1.SEGASYS1/bitstream.rbf_r`.

## Install on Pocket

1. Copy the contents of `dist/` to the root of the Pocket SD card (merge folders).
2. Build ROMs (example Flicky):

```bash
mra "mra/Flicky (128k Version, 315-5051).mra"
# place flicky.rom into Assets/segasys1/finn2k1.SEGASYS1/ (or Assets/segasys1/common/)
```

3. Launch **SEGASYS1** from openFPGA and choose the Flicky JSON preset.

## Controls

| Pocket | Arcade |
|--------|--------|
| D-Pad | Joystick |
| A / B / X | Trig1 / Trig2 / Trig3 |
| Start | Start 1P (Start on P2 pad = Start 2P) |
| Select | Coin |
| L1 | Pause |

Water Match uses P2 d-pad (or face buttons) as the second stick. Block Gal uses left/right as spinner.

## SYSMODE

Each game JSON preset programs SYSMODE/DSW from the MiSTer MRA. You can override them in Core Settings / Interact.

## Attribution

Original MiSTer core by MiSTer-X. T80 by Daniel Wallner. SN76489 core as included upstream.
openFPGA scaffolding patterns adapted from community arcade ports (e.g. openFPGA-Bagman).

## License

Integration code in this repository is provided under GPL-3.0-or-later, matching typical MiSTer/openFPGA arcade licensing. See component directories for their licenses.
