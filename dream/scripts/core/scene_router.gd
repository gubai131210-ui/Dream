class_name SceneRouter
extends Node

## Central scene navigation without gameplay systems.

const HUB_PATH := "res://scenes/hub/world_hub.tscn"
const CONNECTION_PATH := "res://scenes/hub/connection_overview.tscn"
const SQUARE_PATH := "res://scenes/areas/village_square/village_square.tscn"
const RESIDENTIAL_PATH := "res://scenes/areas/village_residential/village_residential.tscn"
const FARM_HOME_PATH := "res://scenes/areas/farm_residential/farm_residential.tscn"


func go_hub() -> void:
	get_tree().change_scene_to_file(HUB_PATH)


func go_connections() -> void:
	get_tree().change_scene_to_file(CONNECTION_PATH)


func go_village_square() -> void:
	get_tree().change_scene_to_file(SQUARE_PATH)


func go_village_residential() -> void:
	get_tree().change_scene_to_file(RESIDENTIAL_PATH)


func go_farm_residential() -> void:
	get_tree().change_scene_to_file(FARM_HOME_PATH)


static func change_to(tree: SceneTree, path: String) -> void:
	if path.is_empty():
		return
	tree.change_scene_to_file(path)
