class_name SceneRouter
extends Node

## Central scene navigation without gameplay systems.

const HUB_PATH := "res://scenes/hub/world_hub.tscn"
const CONNECTION_PATH := "res://scenes/hub/connection_overview.tscn"
const SQUARE_PATH := "res://scenes/areas/village_square/village_square.tscn"
const RESIDENTIAL_PATH := "res://scenes/areas/village_residential/village_residential.tscn"
const FARM_HOME_PATH := "res://scenes/areas/farm_residential/farm_residential.tscn"
const FARMLAND_PATH := "res://scenes/areas/farmland/farmland.tscn"
const MARKET_PATH := "res://scenes/areas/market_street/market_street.tscn"
const FOREST_ENTRANCE_PATH := "res://scenes/areas/forest_entrance/forest_entrance.tscn"
const STATION_PATH := "res://scenes/areas/station/station.tscn"
const FOREST_DEEP_PATH := "res://scenes/areas/forest_deep/forest_deep.tscn"
const RIVER_PATH := "res://scenes/areas/river/river.tscn"
const WATERFALL_PATH := "res://scenes/areas/waterfall/waterfall.tscn"
const HILL_FARM_PATH := "res://scenes/areas/hill_farm/hill_farm.tscn"
const LAKE_PATH := "res://scenes/areas/lake/lake.tscn"
const LIGHTHOUSE_PATH := "res://scenes/areas/lighthouse/lighthouse.tscn"
const LAKE_HOUSE_PATH := "res://scenes/areas/lake_house/lake_house.tscn"


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


func go_farmland() -> void:
	get_tree().change_scene_to_file(FARMLAND_PATH)


func go_market_street() -> void:
	get_tree().change_scene_to_file(MARKET_PATH)


func go_forest_entrance() -> void:
	get_tree().change_scene_to_file(FOREST_ENTRANCE_PATH)


func go_station() -> void:
	get_tree().change_scene_to_file(STATION_PATH)


func go_forest_deep() -> void:
	get_tree().change_scene_to_file(FOREST_DEEP_PATH)


func go_river() -> void:
	get_tree().change_scene_to_file(RIVER_PATH)


func go_waterfall() -> void:
	get_tree().change_scene_to_file(WATERFALL_PATH)


func go_hill_farm() -> void:
	get_tree().change_scene_to_file(HILL_FARM_PATH)


func go_lake() -> void:
	get_tree().change_scene_to_file(LAKE_PATH)


func go_lighthouse() -> void:
	get_tree().change_scene_to_file(LIGHTHOUSE_PATH)


func go_lake_house() -> void:
	get_tree().change_scene_to_file(LAKE_HOUSE_PATH)


static func change_to(tree: SceneTree, path: String) -> void:
	if path.is_empty():
		return
	tree.change_scene_to_file(path)
