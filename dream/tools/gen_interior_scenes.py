#!/usr/bin/env python3
"""Generate Wave A interior .tscn shells sharing InteriorRoomController + InteriorCraft."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCENES = ROOT / "scenes" / "interiors"

ROOMS = [
    ("c01_home", "c01_home", "C01HomeInterior"),
    ("c02_elder", "c02_elder", "C02ElderInterior"),
    ("c02_farmer", "c02_farmer", "C02FarmerInterior"),
    ("c02_merchant", "c02_merchant", "C02MerchantInterior"),
    ("c02_blacksmith_home", "c02_blacksmith_home", "C02BlacksmithHomeInterior"),
    ("c03_barn", "c03_barn", "C03BarnInterior"),
    ("c03_coop", "c03_coop", "C03CoopInterior"),
    ("c04_grocery", "c04_grocery", "C04GroceryInterior"),
    ("c04_smith", "c04_smith", "C04SmithInterior"),
    ("c04_tavern", "c04_tavern", "C04TavernInterior"),
]

TEMPLATE = """[gd_scene load_steps=6 format=3]

[ext_resource type="Script" path="res://scripts/interiors/interior_room_controller.gd" id="1"]
[ext_resource type="Script" path="res://scripts/interiors/interior_craft.gd" id="2"]
[ext_resource type="Script" path="res://scripts/core/camera_controller.gd" id="3"]
[ext_resource type="PackedScene" path="res://scenes/ui/info_panel.tscn" id="4"]

[node name="{node}" type="Node2D"]
y_sort_enabled = true
script = ExtResource("1")
profile_id = "{profile}"

[node name="Assembler" type="Node" parent="."]
script = ExtResource("2")
profile_id = "{profile}"

[node name="InteriorWorld" type="Node2D" parent="."]
y_sort_enabled = true
z_index = 2

[node name="CameraController" type="Camera2D" parent="."]
position = Vector2(640, 480)
script = ExtResource("3")
min_zoom = 1.0
max_zoom = 2.0

[node name="InfoLayer" parent="." instance=ExtResource("4")]

[node name="UI" type="CanvasLayer" parent="."]

[node name="TopBar" type="HBoxContainer" parent="UI"]
offset_left = 18.0
offset_top = 16.0
offset_right = 700.0
offset_bottom = 60.0
theme_override_constants/separation = 10

[node name="Hint" type="Label" parent="UI/TopBar"]
layout_mode = 2
size_flags_horizontal = 3
text = "室内"

[node name="BackOutside" type="Button" parent="UI/TopBar"]
layout_mode = 2
text = "返回室外"

[node name="BackHub" type="Button" parent="UI/TopBar"]
layout_mode = 2
text = "世界总览"
"""


def main() -> None:
    for folder, profile, node in ROOMS:
        d = SCENES / folder
        d.mkdir(parents=True, exist_ok=True)
        path = d / f"{folder}.tscn"
        path.write_text(TEMPLATE.format(node=node, profile=profile), encoding="utf-8")
        print("wrote", path.relative_to(ROOT))


if __name__ == "__main__":
    main()
