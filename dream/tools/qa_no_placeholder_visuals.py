"""Static regression check for production scenes leaking development markers."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def require(text: str, needle: str, label: str) -> None:
    if needle not in text:
        raise AssertionError(f"{label}: missing {needle!r}")


def main() -> None:
    spawn = read("scripts/world/world_spawn_util.gd")
    require(spawn, 'debug/show_interaction_markers', "world marker setting")
    require(spawn, 'poly.visible = show_debug_markers()', "hotspot marker visibility")
    require(spawn, 'tag.visible = show_debug_markers()', "hotspot tag visibility")
    require(spawn, 'hint.visible = show_debug_markers()', "portal marker visibility")
    require(spawn, 'label.visible = show_debug_markers()', "portal label visibility")

    area_craft = read("scripts/areas/area_craft.gd")
    require(area_craft, 'debug/show_interaction_markers', "area portal marker setting")
    require(area_craft, 'hint.visible = show_marker', "area portal marker visibility")
    require(area_craft, 'label.visible = show_marker', "area portal label visibility")
    require(area_craft, 'if show_marker:', "area portal pulse guard")
    require(area_craft, 'area.mouse_entered.connect', "area portal hover label")

    interior = read("scripts/interiors/interior_craft.gd")
    require(interior, 'marker.visible = show_marker', "interior return marker visibility")
    require(interior, 'label.visible = show_marker', "interior return label visibility")
    require(interior, 'lbl.visible = show_marker', "interior extra label visibility")
    require(interior, "window_light_shaft_00.png", "interior window light shaft sprite")

    square = read("scripts/areas/village_square_assembler.gd")
    if 'rock_g := "res://assets/sprites/props/rock_02.png"' in square:
        raise AssertionError("village square still spawns a standalone rock")
    require(square, "facade_museum_00.png", "museum civic façade")
    require(square, "facade_bath_00.png", "bath civic façade")

    controller = read("scripts/areas/village_square_controller.gd")
    require(controller, 'debug/show_demo_overlays', "NPC demo setting")
    require(controller, 'NpcRingDemoStatus', "NPC status visibility")
    require(controller, 'info.hide_info()', "initial NPC demo dialog suppression")
    # C53/C54 are player-facing — must not be hidden with the demo status strip.
    hide_loop = 'for control_name in ["CycleWorkRing", "CycleLifeState"]'
    for rel in (
        "scripts/areas/village_square_controller.gd",
        "scripts/areas/market_street_controller.gd",
        "scripts/areas/farmland_controller.gd",
    ):
        if hide_loop in read(rel):
            raise AssertionError(f"{rel}: CycleWorkRing/CycleLifeState must stay visible (player-facing C53/C54)")
    routine = read("scripts/npc/npc_routine_demo.gd")
    require(routine, "CycleWorkRing", "work button mount")
    require(routine, "CycleLifeState", "life button mount")
    require(routine, "work_poses", "C53 work pose sheet path")
    require(routine, "life_poses", "C54 life pose sheet path")
    require(routine, "WorkPoseAnim", "C53 work pose AnimatedSprite")

    seasonal = read("scripts/env/seasonal_decor.gd")
    require(seasonal, '_layer.visible = true', "seasonal layer always visible (G3)")
    require(seasonal, 'Season props are gameplay art', "seasonal not demo-gated")

    interact = read("scripts/world/world_interact_kit.gd")
    require(interact, "trees/grounded/tree_00.png", "shake_tree uses real tree sprite")

    require(spawn, "door_facade_00.png", "portal door façade sprite")
    require(spawn, 'DoorFacade', "portal DoorFacade node")

    hotspot = read("scripts/interact/interactable_hotspot.gd")
    require(hotspot, "focus_corners_00.png", "hover focus corner sprite")
    require(hotspot, "queue_redraw()", "hover redraw for focus frame")
    require(hotspot, "_ensure_focus_corners", "pixel focus corner helper")

    stall = read("scripts/market/market_stall.gd")
    require(stall, "stall_open_wood_00.png", "C05 default stall body PNG")
    require(stall, "DEFAULT_BODY", "C05 body default constant")
    require(stall, "stall_awning_00.png", "C05 awning PNG preferred over ColorRect")
    require(stall, "stall_pole_00.png", "C05 stall pole PNG preferred over ColorRect")
    require(stall, "POLE_TEX", "C05 pole constant")
    if "ColorRect.new()" in stall:
        raise AssertionError("C05 market_stall still has ColorRect production fallback")
    if "_add_board" in stall or "_add_bay_mark" in stall:
        raise AssertionError("C05 market_stall still has ColorRect board/bay helpers")
    if not (ROOT / "assets/sprites/market/stall_pole_00.png").is_file():
        raise AssertionError("C05 stall pole asset missing")

    fishing = read("scripts/fishing/fishing_spot.gd")
    require(fishing, "fish_bubble_00.png", "fishing bubble sprite")
    require(fishing, "fish_splash_00.png", "fishing splash sprite")
    require(fishing, "fish_ring_00.png", "fishing water ring sprite")
    require(fishing, "_add_water_ring", "fishing ring helper prefers sprite")
    if "ColorRect.new()" in fishing:
        raise AssertionError("fishing_spot still has ColorRect production FX/buoy")
    if "Polygon2D.new()" in fishing:
        raise AssertionError("fishing_spot still has Polygon2D water ring fallback")

    cage = read("scripts/fishing/fish_cage.gd")
    require(cage, "fish_ring_00.png", "C22 cage water ring sprite")
    require(cage, "_add_water_ring", "C22 cage ring helper")
    if "Polygon2D.new()" in cage:
        raise AssertionError("fish_cage still has Polygon2D water ring fallback")

    gates = read("scripts/world/progress_gates.gd")
    require(gates, "gate_log_00.png", "C60 fallen log sprite")
    require(gates, "gate_locked_door_00.png", "C60 dedicated locked door sprite")
    if "door_facade_00.png" in gates:
        raise AssertionError("C60 locked_door still reuses generic door_facade_00")
    if not (ROOT / "assets/sprites/props/gate_locked_door_00.png").is_file():
        raise AssertionError("C60 gate_locked_door_00.png missing")

    breakables = read("scripts/world/breakables_kit.gd")
    require(breakables, "breakable_stake_00.png", "C59 stake sprite")
    require(breakables, "breakable_weed_00.png", "C59 weed sprite")

    spawn = read("scripts/world/world_spawn_util.gd")
    if 'poly.name = "DoorstepCue"' in spawn or 'poly_a.name = "DoorArchCue"' in spawn:
        raise AssertionError("portal doorstep/arch still has Polygon2D production fallback")
    require(spawn, "doorstep_mat", "portal doorstep sprite path")

    area_craft = read("scripts/areas/area_craft.gd")
    if "ColorRect.new()" in area_craft and "furrow" in area_craft.lower():
        # Furrow ColorRect path must be gone; other ColorRects (if any) checked loosely.
        pass
    if 'line := ColorRect.new()' in area_craft:
        raise AssertionError("area_craft still has ColorRect furrow rows")

    dik = read("scripts/world/district_interact_kit.gd")
    for host in (
        "waterfall",
        "lighthouse",
        "hill_farm",
        "forest_entrance",
        "farm_residential",
        "lake_house",
    ):
        require(dik, f'"{host}"', f"DistrictInteractKit host {host}")
    if "interior/props" in dik:
        raise AssertionError("DistrictInteractKit must use outdoor props/ paths (Genre cohesion)")
    if "interior/props" in routine:
        raise AssertionError("npc_routine_demo work cues must use outdoor props/ paths (Genre cohesion)")
    if "interior/props" in seasonal:
        raise AssertionError("seasonal_decor must use outdoor props/ paths (Genre cohesion)")
    chests = read("scripts/world/hidden_chests.gd")
    if "interior/props" in chests:
        raise AssertionError("hidden_chests must use outdoor props/ coin_chest (Genre cohesion)")

    forest = read("scripts/areas/forest_deep_assembler.gd")
    require(forest, "ruin_arch_00.png", "C29 ruins landmark prop")
    require(forest, "tree_04.png", "C28 giant-tree landmark prop")
    require(forest, "attach_hotspot_prop", "forest landmarks use attach_hotspot_prop")
    river = read("scripts/areas/river_assembler.gd")
    require(river, "reed_clump_00.png", "C25 reed landmark prop")
    market_dress = read("scripts/areas/market_street_dressing.gd")
    require(market_dress, "bridge_plank_00.png", "market bridge plank prop")
    square = read("scripts/areas/village_square_assembler.gd")
    require(square, "grave_marker_00.png", "C30 cemetery landmark prop")
    station = read("scripts/areas/station_assembler.gd")
    require(station, "站台轨道", "station band hotspot")
    require(station, "attach_hotspot_prop(hs_band", "station band owns rail prop")
    lake_house = read("scripts/areas/lake_house_assembler.gd")
    require(lake_house, 'spr.reparent(hs_house.get_node("Visual"))', "lake house sprite on hotspot Visual")
    lake = read("scripts/areas/lake_assembler.gd")
    require(lake, "boat_skiff_00.png", "C24 ferry boat landmark prop")

    print("GREEN production-placeholder QA (facades, poses, gates, breakables, stall, districts)")


if __name__ == "__main__":
    main()
