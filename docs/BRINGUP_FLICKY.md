# Flicky bring-up checklist (first hardware target)

## Prep
- [ ] Docker Desktop installed (Apple Silicon) with linux/amd64 enabled
- [ ] `./scripts/build.sh` completes and produces `dist/Cores/finn2k1.SEGASYS1/bitstream.rbf_r`
- [ ] Build `flicky.rom` with mra-tools-c from `mra/Flicky (128k Version, 315-5051).mra`
- [ ] Copy `dist/` to Pocket SD card; place `flicky.rom` next to `Flicky.json`

## On device
- [ ] Core appears under openFPGA as SEGASYS1
- [ ] Loading Flicky JSON boots without black screen hang
- [ ] Attract / title screen video is stable (256x224 horizontal)
- [ ] Audio present (PSG)
- [ ] Coin (Select) + Start insert credit / start game
- [ ] D-pad + A (flap) control correctly
- [ ] L1 pauses; menu pause freezes CPU
- [ ] Interact Reset recovers cleanly

## Next after Flicky
- [ ] My Hero / Wonder Boy (horizontal)
- [ ] Vertical titles (SYSMODE bit1) with 90° scaler mode
- [ ] Block Gal spinner / Water Match dual-stick

## Note after System 2 port
- Rebuild `flicky.rom` from the updated blackwine MRA (ROM map changed).
