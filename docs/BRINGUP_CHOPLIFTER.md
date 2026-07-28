# Choplifter bring-up checklist (System 2 target)

## Prep
- [ ] Rebuild bitstream after blackwine RTL port (`./scripts/build.sh`)
- [ ] Build `chopliftu.rom` with mra-tools-c from `mra/Choplifter (unprotected).mra`
  - Needs MAME `choplift.zip` (unprotected set)
- [ ] Copy `dist/` to Pocket SD; place `chopliftu.rom` next to `Choplifter.json`
- [ ] Confirm `chopliftu.sys` is `41` (System 2 + rowscroll)

## On device
- [ ] Choplifter JSON boots (not black screen / freeze)
- [ ] Title / attract video stable (horizontal, rowscroll planes)
- [ ] Audio present
- [ ] Coin + Start work
- [ ] Helicopter: d-pad move, A shoot, B direction change
- [ ] Hostages / scrolling look correct vs MAME (512×512 bg)
- [ ] Interact Reset recovers

## Regression
- [ ] Rebuild `flicky.rom` from updated blackwine MRA (new ROM map)
- [ ] Flicky still boots and plays
