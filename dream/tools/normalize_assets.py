# -*- coding: utf-8 -*-
"""Normalize Dream source PNGs into ASCII-named copies under dream/assets/raw/.

SCALE lock: BASE_TILE=32 (see dream/docs/SCALE.md).
Chinese paths: pathlib Path only (no shell cd into Chinese directories).
"""
from __future__ import annotations

import re
import shutil
import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

REPO = Path(__file__).resolve().parents[2]
SOURCE_ROOT = REPO / "素材" / "素材文件"
RAW_DIR = REPO / "dream" / "assets" / "raw"
REF_DIR = RAW_DIR / "references"
MANIFEST = REPO / "dream" / "assets" / "MANIFEST.md"

A_MAP: dict[str, str] = {
    "A01": "A01_world_overview",
    "A02": "A02_farm_home",
    "A03": "A03_farmland",
    "A04": "A04_forest_entrance",
    "A05": "A05_forest_deep",
    "A06": "A06_river",
    "A07": "A07_waterfall",
    "A08": "A08_village_homes",
    "A09": "A09_village_square",
    "A10": "A10_market_street",
    "A11": "A11_station",
    "A12": "A12_hill_farm",
    "A13": "A13_lake",
    "A14": "A14_lighthouse",
    "A15": "A15_lake_house",
    "A16": "A16_scene_connections",
}

B01_MAP: dict[str, str] = {
    "B01-01": "B01-01_grass",
    "B01-02": "B01-02_dirt",
    "B01-03": "B01-03_mud",
    "B01-04": "B01-04_sand",
    "B01-05": "B01-05_stone",
    "B01-06": "B01-06_stone_path",
    "B01-07": "B01-07_mountain",
    "B01-08": "B01-08_wetland",
    "B01-09": "B01-09_snow",
    "B01-10": "B01-10_grass_dirt_trans",
    "B01-11": "B01-11_dirt_stone_trans",
    "B01-12": "B01-12_grass_water_trans",
    "B01-13": "B01-13_cliff_top",
    "B01-14": "B01-14_cliff_edge",
    "B01-15": "B01-15_cliff_corner",
}

B08_MAP: dict[str, str] = {
    "B08-01": "B08-01_agriculture",
    "B08-02": "B08-02_houses",
    "B08-03": "B08-03_shops",
    "B08-04": "B08-04_public",
    "B08-05": "B08-05_special",
}

B09_MAP: dict[str, str] = {
    "B09-01": "B09-01_doors",
    "B09-02": "B09-02_windows_shutters",
    "B09-03": "B09-03_chimneys",
    "B09-04": "B09-04_awnings",
    "B09-05": "B09-05_signs",
    "B09-06": "B09-06_planters_roofs",
    "B09-07": "B09-07_doors_porches",
    "B09-08": "B09-08_roof_trim",
    "B09-09": "B09-09_stairs",
    "B09-10": "B09-10_building_details",
}

B11_MAP: dict[str, str] = {
    "B11-01": "B11-01_barrels",
    "B11-02": "B11-02_crates_boxes",
    "B11-03": "B11-03_well",
    "B11-04": "B11-04_benches_tables",
    "B11-05": "B11-05_fountain",
    "B11-06": "B11-06_mailbox_board",
    "B11-07": "B11-07_carts",
    "B11-08": "B11-08_pots_lamps",
}

B12_MAP: dict[str, str] = {
    "B12-11": "B12-11_chili",
}

FOLDER_SLUG: dict[str, str] = {
    "A": "A_scene",
    "B01": "B01_terrain",
    "B02": "B02_path",
    "B03": "B03_water",
    "B04": "B04_waterfall",
    "B05": "B05_trees",
    "B06": "B06_flora",
    "B07": "B07_rocks",
    "B08": "B08_buildings",
    "B09": "B09_building_details",
    "B10": "B10_structures",
    "B11": "B11_props",
    "B12": "B12_crops",
    "B13": "B13_animals",
    "B14": "B14_npc",
    "B15": "B15_effects",
}

CODE_RE = re.compile(r"^(A\d{2}|B\d{2}-\d{2}|B\d{2})", re.IGNORECASE)


def try_recover_zh(name: str) -> str:
    stem = Path(name).stem
    for enc in ("gbk", "gb2312", "cp936"):
        try:
            return stem.encode(enc).decode("utf-8")
        except Exception:
            continue
    try:
        return stem.encode("latin1").decode("utf-8")
    except Exception:
        return stem


def folder_category(rel: Path) -> str | None:
    for part in rel.parts:
        if part.startswith("A类") or (part.startswith("A") and "场景" in part):
            return "A"
        m = re.match(r"^(B\d{2})", part, re.IGNORECASE)
        if m:
            return m.group(1).upper()
    return None


def extract_code(name: str) -> str | None:
    m = CODE_RE.match(Path(name).stem)
    return m.group(1).upper() if m else None


def resolve_dest_stem(src: Path, folder_counters: dict[str, int]) -> str:
    code = extract_code(src.name)
    if code:
        for table in (A_MAP, B01_MAP, B08_MAP, B09_MAP, B11_MAP, B12_MAP):
            if code in table:
                return table[code]
        if not re.fullmatch(r"B\d{2}", code):
            return code.replace(" ", "_")

    cat = folder_category(src.relative_to(SOURCE_ROOT)) or "misc"
    slug = FOLDER_SLUG.get(cat, f"{cat}_asset")
    zh = try_recover_zh(src.name)
    stem_l = src.stem.lower()

    semantic = [
        ("B03", "湖", "B03_water_lake"),
        ("B03", "河", "B03_water_river"),
        ("B03", "海", "B03_water_ocean"),
        ("B03", "溪", "B03_water_stream"),
        ("B02", "小径", "B02_path_dirt_trail"),
        ("B02", "十字", "B02_path_crossroad"),
        ("B02", "铁轨", "B02_path_railside"),
        ("B02", "码头", "B02_path_dock"),
        ("B02", "破损", "B02_path_broken"),
        ("B02", "石板", "B02_path_stone"),
        ("B12", "wheat", "B12_crops_wheat_corn_tomato"),
    ]
    for need_cat, token, dest in semantic:
        if cat == need_cat and (token in zh or token.lower() in stem_l):
            return dest

    folder_counters[slug] = folder_counters.get(slug, 0) + 1
    return f"{slug}_{folder_counters[slug]:02d}"


def iter_pngs(root: Path) -> list[Path]:
    return sorted(
        (p for p in root.rglob("*") if p.is_file() and p.suffix.lower() == ".png"),
        key=lambda p: p.as_posix().lower(),
    )


def unique_dest(stem: str, used: set[str]) -> str:
    name = f"{stem}.png"
    if name not in used:
        used.add(name)
        return name
    n = 2
    while True:
        alt = f"{stem}_{n:02d}.png"
        if alt not in used:
            used.add(alt)
            return alt
        n += 1


def wipe_raw_except_keep() -> None:
    """Reset raw/ to a clean flat layout (+ empty references/)."""
    if RAW_DIR.exists():
        for child in RAW_DIR.iterdir():
            if child.is_file():
                child.unlink()
            elif child.is_dir():
                shutil.rmtree(child)
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    REF_DIR.mkdir(parents=True, exist_ok=True)


def main() -> int:
    if not SOURCE_ROOT.is_dir():
        print(f"ERROR: source root missing: {SOURCE_ROOT}")
        return 1

    wipe_raw_except_keep()
    pngs = iter_pngs(SOURCE_ROOT)
    print(f"Found {len(pngs)} PNG under {SOURCE_ROOT}")

    folder_counters: dict[str, int] = {}
    used: set[str] = set()
    rows: list[tuple[str, str, int]] = []
    failures: list[str] = []
    copied = 0

    for src in pngs:
        try:
            rel = src.relative_to(SOURCE_ROOT).as_posix()
        except ValueError:
            rel = src.as_posix()
        try:
            dest_name = unique_dest(resolve_dest_stem(src, folder_counters), used)
            dest = RAW_DIR / dest_name
            shutil.copy2(src, dest)
            size = dest.stat().st_size
            rows.append((rel, dest_name, size))
            copied += 1
            print(f"OK  {dest_name}  <-  {rel}")
        except Exception as e:
            failures.append(f"{src}: {e}")
            print(f"FAIL {src}: {e}")

    ref_names = (
        "A01_world_overview.png",
        "A09_village_square.png",
        "A16_scene_connections.png",
    )
    ref_copied = 0
    for name in ref_names:
        src_ref = RAW_DIR / name
        if src_ref.is_file():
            shutil.copy2(src_ref, REF_DIR / name)
            ref_copied += 1
            print(f"REF {name}")
        else:
            failures.append(f"missing reference source: {name}")

    lines = [
        "# Dream Asset Manifest",
        "",
        f"Source: `{SOURCE_ROOT.as_posix()}`",
        f"Destination: `{RAW_DIR.as_posix()}`",
        "BASE_TILE: 32 (see dream/docs/SCALE.md)",
        "",
        f"Total mapped: **{len(rows)}**",
        f"References copied: **{ref_copied}** → `dream/assets/raw/references/`",
        "",
        "| Dest | Size (bytes) | Source (best-effort) |",
        "|---|---:|---|",
    ]
    for rel, dest_name, size in rows:
        lines.append(f"| `{dest_name}` | {size} | `{rel.replace('|', '\\|')}` |")
    if failures:
        lines.extend(["", "## Failures", ""])
        for f in failures:
            lines.append(f"- {f}")
    MANIFEST.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {MANIFEST}")
    print(f"SUMMARY copied={copied} refs={ref_copied} failures={len(failures)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
