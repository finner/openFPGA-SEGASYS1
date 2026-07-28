# openFPGA-SEGASYS1

Sega System 1 / System 2 arcade core for Analogue Pocket.

Ported from [MiSTer Arcade-SEGASYS1](https://github.com/MiSTer-devel/Arcade-SEGASYS1_MiSTer)
by MiSTer-X, with System 2 support from
[blackwine’s fork](https://github.com/blackwine/Arcade-SEGASYS1_MiSTer).

## Status

System 1 + System 2 openFPGA port (v0.18):

- Vendored blackwine game RTL (`SEGASYSTEM1`, MC8123, T80, SN76489, HVGEN, spinner)
- APF `core_top` with ROM load, SYSMODE/quirks/DSW/flip via Interact, I2S audio
- Full 32KB sound ROM; 128KB sprite ROM in on-board SRAM; 8KB MC8123 key ROM
- Verified on hardware: System 1 (Wonder Boy, Flicky, …), Choplifter, WBML (JP + English VC)

**Presets ready (build `.rom` from `mra/` when you have the zips):**
Wonder Boy System 2 (`wboysys2`), Toki no Senshi (`tokisens`, vertical+CW),
UFO Senshi Yohko Chan (`ufosensi`), DakkoChan House (`dakkochn`, mahjong mux in RTL).

Not yet: high-score save/load; split-opcode bootlegs
(`wbmlb`); some titles blackwine never shipped (119, Bopeep, Shooting Master, Warball).
DakkoChan needs a **bitstream rebuild** for the mahjong keyboard mux (assets alone may only attract).

**Important:** blackwine uses a different packed `.rom` layout than the original MiSTer System 1
core. Rebuild all `.rom` files from the MRAs in `mra/` after updating. `.rom` / `.sys` files
are gitignored — build them locally with [mra-tools-c](https://github.com/sebdel/mra-tools-c/).

### SYSMODE quick reference (common System 2)

| Game | SYSMODE | Notes |
|------|---------|--------|
| Choplifter / UFO Senshi | `0x41` | System 2 + rowscroll |
| WBML / Wonder Boy Sys2 / DakkoChan | `0x01` | System 2, no rowscroll |
| Toki no Senshi | `0x13` | System 2 + vertical + CW |

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
2. Build ROMs (examples):

```bash
./tools/mra -z roms -O dist/Assets/segasys1/finn2k1.SEGASYS1 \
  "mra/Flicky (128k Version, 315-5051).mra"
./tools/mra -z roms -O dist/Assets/segasys1/finn2k1.SEGASYS1 \
  "mra/Choplifter (unprotected).mra"
./tools/mra -z roms -O dist/Assets/segasys1/finn2k1.SEGASYS1 \
  "mra/Wonder Boy in Monster Land (MC-8123).mra"
# also write matching .sys bytes from each MRA rom index=1 (or use the JSON presets)
```

3. Launch **SEGASYS1** from openFPGA and choose a JSON preset (Flicky, Choplifter, WBML, …).

## Controls

| Pocket | Arcade |
|--------|--------|
| D-Pad | Joystick |
| A / B / X | Trig1 / Trig2 / Trig3 (order can swap via SYSMODE bit7) |
| Start | Start 1P (Start on P2 pad = Start 2P) |
| Select | Coin |
| L1 | Pause |

Water Match uses P2 d-pad (or face buttons) as the second stick. Block Gal uses left/right as spinner.

## SYSMODE

Each game JSON preset programs SYSMODE/quirks/DSW from the MiSTer MRA. You can override them in Core Settings / Interact.

| Bit | Meaning |
|-----|---------|
| 0 | System 2 |
| 1 | Vertical |
| 2 | H240 |
| 3 | Water Match dual-stick |
| 4 | CW (vs CCW) for vertical scaler |
| 5 | Spinner (Block Gal) |
| 6 | System 2 rowscroll (Choplifter; **not** WBML) |
| 7 | Swap trig1/trig2 |

Byte 1 of the `.sys` slot is the blackwine **quirks** value (Noboranka, DakkoChan, etc.).

## Attribution

Original MiSTer System 1 core by MiSTer-X. System 2 / MC8123 work by blackwine.
T80 by Daniel Wallner. SN76489 core as included upstream.
openFPGA scaffolding patterns adapted from community arcade ports (e.g. openFPGA-Bagman).

## License

Integration code in this repository is provided under GPL-3.0-or-later, matching typical MiSTer/openFPGA arcade licensing. See component directories for their licenses.
