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
## Phase 5 Wave A interiors (C01–C04)
const C01_HOME_PATH := "res://scenes/interiors/c01_home/c01_home.tscn"
const C02_ELDER_PATH := "res://scenes/interiors/c02_elder/c02_elder.tscn"
const C02_FARMER_PATH := "res://scenes/interiors/c02_farmer/c02_farmer.tscn"
const C02_MERCHANT_PATH := "res://scenes/interiors/c02_merchant/c02_merchant.tscn"
const C02_BLACKSMITH_HOME_PATH := "res://scenes/interiors/c02_blacksmith_home/c02_blacksmith_home.tscn"
const C03_BARN_PATH := "res://scenes/interiors/c03_barn/c03_barn.tscn"
const C03_COOP_PATH := "res://scenes/interiors/c03_coop/c03_coop.tscn"
const C04_GROCERY_PATH := "res://scenes/interiors/c04_grocery/c04_grocery.tscn"
const C04_SMITH_PATH := "res://scenes/interiors/c04_smith/c04_smith.tscn"
const C04_TAVERN_PATH := "res://scenes/interiors/c04_tavern/c04_tavern.tscn"
## Phase 5 Wave A2 (parallel packages — scenes owned by each team)
const C12_LIGHTHOUSE_INT_PATH := "res://scenes/interiors/c12_lighthouse/c12_lighthouse.tscn"
const C14_WELL_PATH := "res://scenes/interiors/c14_well/c14_well.tscn"
const C15_BASEMENT_PATH := "res://scenes/interiors/c15_basement/c15_basement.tscn"
const C17_MINE_PATH := "res://scenes/interiors/c17_mine/c17_mine.tscn"
const C26_WATERFALL_CAVE_PATH := "res://scenes/interiors/c26_waterfall_cave/c26_waterfall_cave.tscn"
const C27_FOREST_HIDE_A_PATH := "res://scenes/interiors/c27_forest_hide_a/c27_forest_hide_a.tscn"
const C27_FOREST_HIDE_B_PATH := "res://scenes/interiors/c27_forest_hide_b/c27_forest_hide_b.tscn"
## Phase 5 Wave B civic interiors (C06–C11)
const C06_TOWN_HALL_PATH := "res://scenes/interiors/c06_town_hall/c06_town_hall.tscn"
const C07_SCHOOL_PATH := "res://scenes/interiors/c07_school/c07_school.tscn"
const C08_CLINIC_PATH := "res://scenes/interiors/c08_clinic/c08_clinic.tscn"
const C09_LIBRARY_PATH := "res://scenes/interiors/c09_library/c09_library.tscn"
const C10_CHURCH_PATH := "res://scenes/interiors/c10_church/c10_church.tscn"
const C11_STATION_INT_PATH := "res://scenes/interiors/c11_station/c11_station.tscn"
## Phase 5 Wave C explore / underground
const C13_MILL_PATH := "res://scenes/interiors/c13_mill/c13_mill.tscn"
const C16_CAVE_ENTRY_PATH := "res://scenes/interiors/c16_cave_entry/c16_cave_entry.tscn"
const C16_CAVE_MID_PATH := "res://scenes/interiors/c16_cave_mid/c16_cave_mid.tscn"
const C24_LAKE_ISLAND_PATH := "res://scenes/interiors/c24_lake_island/c24_lake_island.tscn"
const C25_RIVER_HIDE_PATH := "res://scenes/interiors/c25_river_hide/c25_river_hide.tscn"
const C28_GIANT_TREE_PATH := "res://scenes/interiors/c28_giant_tree/c28_giant_tree.tscn"
const C29_RUINS_PATH := "res://scenes/interiors/c29_ruins/c29_ruins.tscn"
const C30_CEMETERY_PATH := "res://scenes/interiors/c30_cemetery/c30_cemetery.tscn"
const C31_SEWER_PATH := "res://scenes/interiors/c31_sewer/c31_sewer.tscn"
## Phase 5 Wave D agro / market expand
const C32_MARKET_BACK_PATH := "res://scenes/interiors/c32_market_back/c32_market_back.tscn"
const C33_NIGHT_MARKET_PATH := "res://scenes/interiors/c33_night_market/c33_night_market.tscn"
const C37_WAREHOUSE_PATH := "res://scenes/interiors/c37_warehouse/c37_warehouse.tscn"
const C38_WORKSHOP_PATH := "res://scenes/interiors/c38_workshop/c38_workshop.tscn"
const C39_PROCESSING_PATH := "res://scenes/interiors/c39_processing/c39_processing.tscn"
const C51_APIARY_PATH := "res://scenes/interiors/c51_apiary/c51_apiary.tscn"
const C52_ORCHARD_STORE_PATH := "res://scenes/interiors/c52_orchard_store/c52_orchard_store.tscn"
## Phase 5 Wave E vertical / yard expand
const C46_SECOND_FLOOR_PATH := "res://scenes/interiors/c46_second_floor/c46_second_floor.tscn"
const C47_ATTIC_PATH := "res://scenes/interiors/c47_attic/c47_attic.tscn"
const C48_ROOF_PATH := "res://scenes/interiors/c48_roof/c48_roof.tscn"
const C49_BACKYARD_PATH := "res://scenes/interiors/c49_backyard/c49_backyard.tscn"
const C50_FARM_CELLAR_PATH := "res://scenes/interiors/c50_farm_cellar/c50_farm_cellar.tscn"


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


func go_c01_home() -> void:
	get_tree().change_scene_to_file(C01_HOME_PATH)


static func change_to(tree: SceneTree, path: String) -> void:
	if path.is_empty():
		return
	tree.change_scene_to_file(path)
