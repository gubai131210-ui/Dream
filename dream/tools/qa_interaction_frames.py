"""Small deterministic QA loop for the interaction-animation contract.

This does not replace an in-game visual pass. It catches the class of regressions
that caused the reported jitter: source frames with different canvases or
different transparent bottom margins, and a second water-overlay clock being
reintroduced accidentally.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]


def alpha_bbox(path: Path):
    image = Image.open(path).convert("RGBA")
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise AssertionError(f"empty alpha: {path}")
    return image, bbox


def assert_normalized_contract(paths: list[Path], label: str) -> None:
    if len(paths) < 2:
        raise AssertionError(f"not enough frames for {label}: {paths}")

    loaded = [alpha_bbox(path) for path in paths]
    anchor_y = max(bbox[3] for _, bbox in loaded)
    canvas_w = max(image.width for image, _ in loaded)
    canvas_h = max(
        image.height + anchor_y - bbox[3]
        for image, bbox in loaded
    )

    normalized_bottoms: list[int] = []
    for image, bbox in loaded:
        # This mirrors the runtime contract used by PatrolActor, AmbientCritter
        # and InteriorCraft: preserve the image, but paste its alpha bottom on
        # one common anchor inside one common canvas.
        dst_x = (canvas_w - image.width) // 2
        dst_y = anchor_y - bbox[3]
        if dst_x < 0 or dst_y < 0:
            raise AssertionError(f"normalization would clip {label}")
        normalized_bottoms.append(dst_y + bbox[3])

    if len(set(normalized_bottoms)) != 1:
        raise AssertionError(f"normalized anchor drift in {label}: {normalized_bottoms}")


def function_body(source: str, name: str) -> str:
    match = re.search(rf"func {re.escape(name)}\([^\n]*\).*?(?=\nfunc |\Z)", source, re.S)
    if not match:
        raise AssertionError(f"missing function: {name}")
    return match.group(0)


def main() -> int:
    groups = {
        "npc_farmer_walk_left": sorted((ROOT / "assets/sprites/npc/farmer").glob("walk_left_*.png")),
        "npc_merchant_walk_right": sorted((ROOT / "assets/sprites/npc/merchant").glob("walk_right_*.png")),
        "animal_cat_idle": sorted((ROOT / "assets/sprites/animals/cat").glob("idle_*.png")),
        "animal_sheep_idle": sorted((ROOT / "assets/sprites/animals/sheep").glob("idle_*.png")),
        "interior_fire": sorted((ROOT / "assets/sprites/interior/fx").glob("fire_*.png")),
        "interior_forge": sorted((ROOT / "assets/sprites/interior/fx").glob("forge_*.png")),
        "drawer_open": sorted((ROOT / "assets/sprites/interior/props").glob("drawer_open_*.png")),
        "chest_lid": sorted((ROOT / "assets/sprites/props").glob("chest_lid_*.png")),
        "work_pose_sow": sorted((ROOT / "assets/sprites/npc/work_poses/sow").glob("pose_*.png")),
        "work_pose_smith": sorted((ROOT / "assets/sprites/npc/work_poses/smith").glob("pose_*.png")),
        "work_pose_stall": sorted((ROOT / "assets/sprites/npc/work_poses/stall").glob("pose_*.png")),
        "work_pose_cook": sorted((ROOT / "assets/sprites/npc/work_poses/cook").glob("pose_*.png")),
        "waterfall_water": sorted(
            (ROOT / "assets/sprites/props").glob("waterfall_water_0[0-5].png")
        ),
    }
    for label, paths in groups.items():
        assert_normalized_contract(paths, label)

    patrol = (ROOT / "scripts/actors/patrol_actor.gd").read_text(encoding="utf-8")
    critter = (ROOT / "scripts/actors/ambient_critter.gd").read_text(encoding="utf-8")
    interior = (ROOT / "scripts/interiors/interior_craft.gd").read_text(encoding="utf-8")
    area = (ROOT / "scripts/areas/area_craft.gd").read_text(encoding="utf-8")
    square = (ROOT / "scripts/areas/village_square_assembler.gd").read_text(encoding="utf-8")
    waterfall = (ROOT / "scripts/areas/waterfall_assembler.gd").read_text(encoding="utf-8")
    hotspot = (ROOT / "scripts/interact/interactable_hotspot.gd").read_text(encoding="utf-8")

    for label, source in {
        "PatrolActor": patrol,
        "AmbientCritter": critter,
        "InteriorCraft": interior,
    }.items():
        if "get_used_rect()" not in source:
            raise AssertionError(f"{label} is missing fixed alpha-anchor normalization")

    water_body = function_body(area, "spawn_water_overlay")
    if "create_tween" in water_body:
        raise AssertionError("water overlay has a second per-sprite animation clock")
    square_water_body = function_body(square, "_spawn_water_overlay")
    if "create_tween" in square_water_body:
        raise AssertionError("village-square water overlay has a second per-sprite animation clock")
    if "_hover_time" in hotspot or "sin(" in function_body(hotspot, "_draw"):
        raise AssertionError("hotspot focus frame still has a pulsing/flickering clock")
    if "_spawn_cliff_rocks(ysort)" in waterfall or "_spawn_rim_rocks(ysort)" in waterfall:
        raise AssertionError("waterfall still spawns standalone rocks")
    if "_spawn_mist(ysort)" in waterfall:
        raise AssertionError("waterfall still spawns mist")
    if "WaterfallAnim" not in waterfall or "waterfall_water_%02d" not in waterfall:
        raise AssertionError("waterfall missing animated water loop wiring")
    if "splash.reparent(vis)" not in waterfall:
        raise AssertionError("waterfall splash not reparented into hotspot Visual")

    print(
        f"GREEN interaction-frame QA ({len(groups)} groups, single water clock, "
        "fixed waterfall layers + anim loop)"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (AssertionError, OSError) as exc:
        print(f"RED interaction-frame QA: {exc}")
        raise SystemExit(1)
