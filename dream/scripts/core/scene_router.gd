class_name SceneRouter
extends Node

## Central scene navigation without gameplay systems.

const HUB_PATH := "res://scenes/hub/world_hub.tscn"
const CONNECTION_PATH := "res://scenes/hub/connection_overview.tscn"
const SQUARE_PATH := "res://scenes/areas/village_square/village_square.tscn"


func go_hub() -> void:
	get_tree().change_scene_to_file(HUB_PATH)


func go_connections() -> void:
	get_tree().change_scene_to_file(CONNECTION_PATH)


func go_village_square() -> void:
	get_tree().change_scene_to_file(SQUARE_PATH)
