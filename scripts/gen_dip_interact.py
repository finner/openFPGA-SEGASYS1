#!/usr/bin/env python3
"""Generate per-asset Interact menus with named DIP lists from MRA <switches>."""
from __future__ import annotations

import glob
import json
import os
import re
import xml.etree.ElementTree as ET

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MRA_DIR = os.path.join(ROOT, "mra")
ASSET_DIR = os.path.join(ROOT, "dist/Assets/segasys1/finn2k1.SEGASYS1")
OUT_DIR = os.path.join(
    ROOT, "dist/Presets/finn2k1.SEGASYS1/Interact/segasys1/finn2k1.SEGASYS1"
)


def parse_bits(bits: str) -> tuple[int, int]:
    parts = [int(x) for x in bits.split(",")]
    if len(parts) == 1:
        return parts[0], parts[0]
    return min(parts), max(parts)


def dip_to_list(dip_el, next_id: int) -> tuple[dict | None, int]:
    name = (dip_el.get("name") or "DIP").strip()
    bits = dip_el.get("bits")
    ids = dip_el.get("ids")
    if not bits or not ids:
        return None, next_id
    lo, hi = parse_bits(bits)
    options = [s.strip() for s in ids.split(",") if s.strip()]
    if not options:
        return None, next_id
    # Pocket list max 16 options
    options = options[:16]
    width = hi - lo + 1
    # Map into DSW0 (bits 0-7) or DSW1 (bits 8-15)
    if lo >= 8:
        addr = "0x30000000"
        shift = lo - 8
        byte_lo, byte_hi = shift, shift + width - 1
    elif hi <= 7:
        addr = "0x20000000"
        shift = lo
        byte_lo, byte_hi = lo, hi
    else:
        # Spans both bytes — skip (rare)
        return None, next_id

    mod_mask = ((1 << width) - 1) << shift
    # Analogue: mask bits=1 are left untouched
    untouched = (0xFFFFFFFF ^ mod_mask) & 0xFFFFFFFF

    list_opts = []
    for i, label in enumerate(options):
        # Truncate long coin labels for 23-char UI limit
        shown = label if len(label) <= 23 else label[:20] + "..."
        list_opts.append({"name": shown, "value": i << shift})

    # defaultval = option index matching current default bits (set later)
    entry = {
        "name": name[:23],
        "id": next_id,
        "type": "list",
        "enabled": True,
        "persist": False,
        "writeonly": False,
        "address": addr,
        "mask": f"0x{untouched:08X}",
        "defaultval": 0,
        "options": list_opts,
        "_mod_mask": mod_mask,
        "_shift": shift,
        "_addr": addr,
    }
    return entry, next_id + 1


def parse_mra_switches(path: str) -> tuple[str | None, list[dict], int, int]:
    text = open(path, encoding="utf-8", errors="ignore").read()
    # Strip comments so commented-out dips are ignored
    text = re.sub(r"<!--.*?-->", "", text, flags=re.S)
    set_m = re.search(r"<setname>\s*([^<]+?)\s*</setname>", text)
    setname = set_m.group(1).strip() if set_m else None
    sw_m = re.search(r"<switches\b([^>]*)>(.*?)</switches>", text, re.S | re.I)
    if not sw_m:
        return setname, [], 0xFF, 0xFF
    attrs, body = sw_m.group(1), sw_m.group(2)
    def_m = re.search(r'default="([^"]+)"', attrs)
    dsw0, dsw1 = 0xFF, 0xFF
    if def_m:
        parts = [p.strip() for p in def_m.group(1).split(",")]
        if len(parts) >= 1:
            dsw0 = int(parts[0], 16)
        if len(parts) >= 2:
            dsw1 = int(parts[1], 16)

    # Wrap dips in a root for ElementTree
    root = ET.fromstring(f"<switches>{body}</switches>")
    entries: list[dict] = []
    nid = 10
    for dip in root.findall("dip"):
        entry, nid = dip_to_list(dip, nid)
        if entry:
            entries.append(entry)
        if len(entries) >= 12:  # leave room for Reset/Flip
            break
    return setname, entries, dsw0, dsw1


def apply_defaults(entries: list[dict], dsw0: int, dsw1: int) -> None:
    for e in entries:
        cur = dsw0 if e["_addr"] == "0x20000000" else dsw1
        bits = (cur & e["_mod_mask"]) >> e["_shift"]
        # Pick matching option index, else 0
        best = 0
        for i, opt in enumerate(e["options"]):
            if (opt["value"] >> e["_shift"]) == bits:
                best = i
                break
        e["defaultval"] = best
        del e["_mod_mask"]
        del e["_shift"]
        del e["_addr"]


def build_interact(entries: list[dict]) -> dict:
    variables = [
        {
            "name": "Reset",
            "id": 0,
            "type": "action",
            "enabled": True,
            "address": "0x80000000",
            "value": 1,
        }
    ]
    variables.extend(entries)
    variables.append(
        {
            "name": "Flip Screen",
            "id": 4,
            "type": "check",
            "enabled": True,
            "persist": True,
            "address": "0x40000000",
            "defaultval": 0,
            "value": 1,
            "value_off": 0,
        }
    )
    return {"interact": {"magic": "APF_VER_1", "variables": variables, "messages": []}}


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)

    # setname -> mra path
    mras: dict[str, str] = {}
    for path in glob.glob(os.path.join(MRA_DIR, "*.mra")):
        text = open(path, encoding="utf-8", errors="ignore").read()
        m = re.search(r"<setname>\s*([^<]+?)\s*</setname>", text)
        if m:
            mras[m.group(1).strip()] = path

    # rom basename without .rom -> asset json name
    written = 0
    for asset_path in sorted(glob.glob(os.path.join(ASSET_DIR, "*.json"))):
        asset_name = os.path.basename(asset_path)
        j = json.load(open(asset_path))
        rom = next(
            (s["filename"] for s in j["instance"]["data_slots"] if s.get("id") == 1),
            None,
        )
        if not rom or not rom.endswith(".rom"):
            continue
        setname = rom[:-4]
        mra = mras.get(setname)
        if not mra:
            print(f"skip {asset_name}: no MRA for {setname}")
            continue
        sn, entries, dsw0, dsw1 = parse_mra_switches(mra)
        # Prefer JSON memory_writes defaults when present
        for mw in j["instance"].get("memory_writes", []):
            if mw["address"] == "0x20000000":
                dsw0 = int(mw["data"], 16) & 0xFF
            elif mw["address"] == "0x30000000":
                dsw1 = int(mw["data"], 16) & 0xFF
        apply_defaults(entries, dsw0, dsw1)
        out = build_interact(entries)
        out_path = os.path.join(OUT_DIR, asset_name)
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(out, f, indent=2)
            f.write("\n")
        written += 1
        print(f"wrote {asset_name}: {len(entries)} DIP lists (defaults {dsw0:02X},{dsw1:02X})")

    print(f"done: {written} preset interact files -> {OUT_DIR}")


if __name__ == "__main__":
    main()
