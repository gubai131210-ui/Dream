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

    square = read("scripts/areas/village_square_assembler.gd")
    if 'rock_g := "res://assets/sprites/props/rock_02.png"' in square:
        raise AssertionError("village square still spawns a standalone rock")
    require(square, "facade_museum_00.png", "museum civic façade")
    require(square, "facade_bath_00.png", "bath civic façade")

    controller = read("scripts/areas/village_square_controller.gd")
    require(controller, 'debug/show_demo_overlays', "NPC demo setting")
    require(controller, 'NpcRingDemoStatus', "NPC status visibility")
    require(controller, 'CycleWorkRing', "work button visibility")
    require(controller, 'CycleLifeState', "life button visibility")
    require(controller, 'info.hide_info()', "initial NPC demo dialog suppression")

    seasonal = read("scripts/env/seasonal_decor.gd")
    require(seasonal, '_layer.visible = true', "seasonal layer always visible (G3)")
    require(seasonal, 'Season props are gameplay art', "seasonal not demo-gated")

    interact = read("scripts/world/world_interact_kit.gd")
    require(interact, "trees/grounded/tree_00.png", "shake_tree uses real tree sprite")

    require(spawn, "door_facade_00.png", "portal door façade sprite")
    require(spawn, 'DoorFacade', "portal DoorFacade node")

    fishing = read("scripts/fishing/fishing_spot.gd")
    require(fishing, "fish_bubble_00.png", "fishing bubble sprite")
    require(fishing, "fish_splash_00.png", "fishing splash sprite")

    gates = read("scripts/world/progress_gates.gd")
    require(gates, "gate_log_00.png", "C60 fallen log sprite")
    require(gates, "door_facade_00.png", "C60 locked door facade")

    routine = read("scripts/npc/npc_routine_demo.gd")
    require(routine, "work_poses", "C53 work pose sheet path")
    require(routine, "WorkPoseAnim", "C53 work pose AnimatedSprite")

    print("GREEN production-placeholder QA (markers, facades, tree, fish FX, poses, gates)")


if __name__ == "__main__":
    main()
