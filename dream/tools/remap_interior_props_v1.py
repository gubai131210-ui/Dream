#!/usr/bin/env python3
"""Path-preserving interior prop remap (v1). See docs/INTERIOR_ASSET_AUDIT.md."""
from __future__ import annotations

import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "interior" / "props"
ARCHIVE = PROPS / "_misnamed_archive"
MARKER = PROPS / ".remap_v1_done"
TMP = PROPS / "_remap_tmp_v1"


def move_pair(src: Path, dst: Path) -> None:
    if not src.exists():
        raise FileNotFoundError(src)
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists():
        raise FileExistsError(dst)
    shutil.move(str(src), str(dst))
    imp_src = Path(str(src) + ".import")
    imp_dst = Path(str(dst) + ".import")
    if imp_src.exists():
        if imp_dst.exists():
            imp_dst.unlink()
        shutil.move(str(imp_src), str(imp_dst))


def copy_to_tmp(name: str) -> Path:
    src = PROPS / name
    dst = TMP / name
    shutil.copy2(src, dst)
    imp = Path(str(src) + ".import")
    if imp.exists():
        shutil.copy2(imp, Path(str(dst) + ".import"))
    return dst


def place_from_tmp(name: str, dest_name: str) -> None:
    src = TMP / name
    dst = PROPS / dest_name
    if dst.exists():
        dst.unlink()
    shutil.copy2(src, dst)
    imp_src = Path(str(src) + ".import")
    imp_dst = Path(str(dst) + ".import")
    if imp_src.exists():
        if imp_dst.exists():
            imp_dst.unlink()
        # Godot will regenerate .import; keep sidecar only if basenames match tooling expectations
        text = imp_src.read_text(encoding="utf-8", errors="ignore")
        text = text.replace(name, dest_name)
        imp_dst.write_text(text, encoding="utf-8")


def archive(name: str, archive_name: str) -> None:
    ARCHIVE.mkdir(parents=True, exist_ok=True)
    src = PROPS / name
    if not src.exists():
        return
    dst = ARCHIVE / archive_name
    if dst.exists():
        dst.unlink()
    shutil.move(str(src), str(dst))
    imp = Path(str(src) + ".import")
    if imp.exists():
        shutil.move(str(imp), str(dst) + ".import")


def main() -> None:
    if MARKER.exists():
        print("remap_v1 already done")
        return
    if not PROPS.is_dir():
        raise SystemExit(f"missing {PROPS}")

    TMP.mkdir(parents=True, exist_ok=True)
    ARCHIVE.mkdir(parents=True, exist_ok=True)

    # Snapshot all involved live files into TMP first.
    needed = [
        "dresser_00.png",
        "bed_single_00.png",
        "stool_bar_00.png",
        "nest_00.png",
        "ledger_00.png",
        "notice_00.png",
        "hay_00.png",
        "medicine_00.png",
        "tool_rack_00.png",
        "counter_00.png",
        "table_pub_00.png",
        "trough_00.png",
        "basket_00.png",
        "roost_00.png",
        "coin_chest_00.png",
        "mug_shelf_00.png",
        "shelf_grocery_00.png",
        "extra_10.png",
        "shelf_pantry_00.png",
        "table_indoor_00.png",
    ]
    for n in needed:
        p = PROPS / n
        if p.exists():
            copy_to_tmp(n)

    # 1) dresser ↔ bed_single
    place_from_tmp("dresser_00.png", "bed_single_00.png")  # was bed art
    place_from_tmp("bed_single_00.png", "dresser_00.png")  # was dresser art

    # 2) nest/ledger/notice/hay/medicine/tool_rack/counter chain
    place_from_tmp("stool_bar_00.png", "nest_00.png")
    place_from_tmp("nest_00.png", "ledger_00.png")  # desk
    place_from_tmp("ledger_00.png", "notice_00.png")  # notice board
    place_from_tmp("notice_00.png", "hay_00.png")  # hay bale
    place_from_tmp("hay_00.png", "medicine_00.png")  # med chest
    place_from_tmp("medicine_00.png", "tool_rack_00.png")  # hammers
    place_from_tmp("tool_rack_00.png", "counter_00.png")  # short counter (temp until long gen)
    archive_from = TMP / "counter_00.png"
    if archive_from.exists():
        dst = ARCHIVE / "misnamed_counter_was_jar_shelf_00.png"
        shutil.copy2(archive_from, dst)

    # 3) trough / basket
    place_from_tmp("table_pub_00.png", "trough_00.png")
    place_from_tmp("trough_00.png", "basket_00.png")
    if (TMP / "basket_00.png").exists():
        shutil.copy2(TMP / "basket_00.png", ARCHIVE / "stool_from_basket_00.png")

    # 4) roost / coin / mug
    place_from_tmp("roost_00.png", "coin_chest_00.png")
    place_from_tmp("coin_chest_00.png", "mug_shelf_00.png")
    place_from_tmp("mug_shelf_00.png", "roost_00.png")  # T-post temp roost

    # 5) archive wrong grocery (round table)
    if (TMP / "shelf_grocery_00.png").exists():
        shutil.copy2(TMP / "shelf_grocery_00.png", ARCHIVE / "misnamed_grocery_was_round_table.png")
        # leave shelf_grocery for generator overwrite; remove live wrong art
        live = PROPS / "shelf_grocery_00.png"
        if live.exists():
            live.unlink()
        imp = Path(str(live) + ".import")
        if imp.exists():
            imp.unlink()

    # 6) archive byte-dup orphans from live props
    for n, an in [
        ("extra_10.png", "dup_extra_10_was_shelf.png"),
        ("shelf_pantry_00.png", "dup_shelf_pantry_00.png"),
        ("table_indoor_00.png", "dup_table_indoor_00.png"),
        ("stool_bar_00.png", "src_stool_bar_was_nest.png"),
        ("table_pub_00.png", "src_table_pub_was_trough.png"),
    ]:
        archive(n, an)

    shutil.rmtree(TMP, ignore_errors=True)
    MARKER.write_text("remap_v1 complete\n", encoding="utf-8")
    print("OK remap_v1")


if __name__ == "__main__":
    main()
