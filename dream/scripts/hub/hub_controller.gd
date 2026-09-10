class_name HubController
extends Node2D

## Hub / connection overview navigation.
## TopBar village buttons + NatureRow (Phase 4B outdoor shell) + map hotspots.
## Missing scenes use _change_if_exists (warn, no crash).

@export var hub_mode: String = "world"

@onready var camera: CameraController = $CameraController
@onready var map_sprite: Sprite2D = $MapSprite
@onready var ui_layer: CanvasLayer = $UI
@onready var status_label: Label = $UI/TopBar/Status
@onready var btn_square: Button = $UI/TopBar/Buttons/EnterSquare
@onready var btn_residential: Button = $UI/TopBar/Buttons/EnterResidential
@onready var btn_farm: Button = $UI/TopBar/Buttons/EnterFarm
@onready var btn_farmland: Button = $UI/TopBar/Buttons/EnterFarmland
@onready var btn_market: Button = $UI/TopBar/Buttons/EnterMarket
@onready var btn_forest: Button = $UI/TopBar/Buttons/EnterForest
@onready var btn_station: Button = $UI/TopBar/Buttons/EnterStation
@onready var btn_other: Button = $UI/TopBar/Buttons/SwitchOverview
@onready var hotspot_square: Area2D = $Hotspots/VillageSquare
@onready var hotspot_residential: Area2D = $Hotspots/VillageResidential
@onready var hotspot_farm: Area2D = $Hotspots/FarmResidential
@onready var hotspot_farmland: Area2D = $Hotspots/Farmland
@onready var hotspot_market: Area2D = $Hotspots/MarketStreet
@onready var hotspot_forest: Area2D = $Hotspots/ForestEntrance
@onready var hotspot_station: Area2D = $Hotspots/Station


func _ready() -> void:
	btn_square.pressed.connect(_enter_square)
	btn_residential.pressed.connect(_enter_residential)
	btn_farm.pressed.connect(_enter_farm)
	btn_farmland.pressed.connect(_enter_farmland)
	btn_market.pressed.connect(_enter_market)
	btn_forest.pressed.connect(_enter_forest)
	btn_station.pressed.connect(_enter_station)
	btn_other.pressed.connect(_switch_overview)
	_wire_nature_row()
	_wire_hotspot(hotspot_square, "村庄广场（可进入）", _enter_square)
	_wire_hotspot(hotspot_residential, "村庄住宅区（可进入）", _enter_residential)
	_wire_hotspot(hotspot_farm, "农场住宅区（可进入）", _enter_farm)
	_wire_hotspot(hotspot_farmland, "农田区（可进入）", _enter_farmland)
	_wire_hotspot(hotspot_market, "商业街（可进入）", _enter_market)
	_wire_hotspot(hotspot_forest, "森林入口（可进入）", _enter_forest)
	_wire_hotspot(hotspot_station, "车站（可进入）", _enter_station)
	_wire_nature_hotspots()
	status_label.text = _default_status()
	_fit_camera_to_map()


func _wire_nature_row() -> void:
	var row := get_node_or_null("UI/NatureRow") as HBoxContainer
	if row == null:
		return
	_bind_btn(row.get_node_or_null("EnterForestDeep"), _enter_forest_deep)
	_bind_btn(row.get_node_or_null("EnterRiver"), _enter_river)
	_bind_btn(row.get_node_or_null("EnterWaterfall"), _enter_waterfall)
	_bind_btn(row.get_node_or_null("EnterHillFarm"), _enter_hill_farm)
	_bind_btn(row.get_node_or_null("EnterLake"), _enter_lake)
	_bind_btn(row.get_node_or_null("EnterLighthouse"), _enter_lighthouse)
	_bind_btn(row.get_node_or_null("EnterLakeHouse"), _enter_lake_house)


func _bind_btn(btn: Button, cb: Callable) -> void:
	if btn:
		btn.pressed.connect(cb)


func _wire_nature_hotspots() -> void:
	var hs := get_node_or_null("Hotspots") as Node2D
	if hs == null:
		return
	_wire_hotspot(hs.get_node_or_null("ForestDeep") as Area2D, "深林（可进入）", _enter_forest_deep)
	_wire_hotspot(hs.get_node_or_null("River") as Area2D, "河流（可进入）", _enter_river)
	_wire_hotspot(hs.get_node_or_null("Waterfall") as Area2D, "瀑布（可进入）", _enter_waterfall)
	_wire_hotspot(hs.get_node_or_null("HillFarm") as Area2D, "山坡农田（可进入）", _enter_hill_farm)
	_wire_hotspot(hs.get_node_or_null("Lake") as Area2D, "湖泊（可进入）", _enter_lake)
	_wire_hotspot(hs.get_node_or_null("Lighthouse") as Area2D, "灯塔（可进入）", _enter_lighthouse)
	_wire_hotspot(hs.get_node_or_null("LakeHouse") as Area2D, "湖畔小屋（可进入）", _enter_lake_house)


func _wire_hotspot(hotspot: Area2D, hint: String, enter_cb: Callable) -> void:
	if hotspot == null:
		return
	hotspot.input_event.connect(
		func(_vp: Node, event: InputEvent, _idx: int) -> void:
			_on_hotspot_click(event, enter_cb)
	)
	hotspot.mouse_entered.connect(func(): status_label.text = hint)
	hotspot.mouse_exited.connect(func(): status_label.text = _default_status())


func _default_status() -> String:
	if hub_mode == "world":
		return "世界总览 — 拖拽/滚轮缩放，点击热点或顶栏进入场景"
	return "场景连接总览 — 点击节点或顶栏进入场景"


func _fit_camera_to_map() -> void:
	if map_sprite.texture == null:
		return
	var size := map_sprite.texture.get_size()
	map_sprite.centered = true
	map_sprite.position = Vector2.ZERO
	camera.bounds = Rect2(-size * 0.6, size * 1.2)
	camera.zoom = Vector2(0.55, 0.55)


func _enter_square() -> void:
	get_tree().change_scene_to_file(SceneRouter.SQUARE_PATH)


func _enter_residential() -> void:
	get_tree().change_scene_to_file(SceneRouter.RESIDENTIAL_PATH)


func _enter_farm() -> void:
	get_tree().change_scene_to_file(SceneRouter.FARM_HOME_PATH)


func _enter_farmland() -> void:
	get_tree().change_scene_to_file(SceneRouter.FARMLAND_PATH)


func _enter_market() -> void:
	get_tree().change_scene_to_file(SceneRouter.MARKET_PATH)


func _enter_forest() -> void:
	_change_if_exists(SceneRouter.FOREST_ENTRANCE_PATH, "森林入口")


func _enter_station() -> void:
	_change_if_exists(SceneRouter.STATION_PATH, "车站")


func _enter_forest_deep() -> void:
	_change_if_exists(SceneRouter.FOREST_DEEP_PATH, "深林")


func _enter_river() -> void:
	_change_if_exists(SceneRouter.RIVER_PATH, "河流")


func _enter_waterfall() -> void:
	_change_if_exists(SceneRouter.WATERFALL_PATH, "瀑布")


func _enter_hill_farm() -> void:
	_change_if_exists(SceneRouter.HILL_FARM_PATH, "山坡农田")


func _enter_lake() -> void:
	_change_if_exists(SceneRouter.LAKE_PATH, "湖泊")


func _enter_lighthouse() -> void:
	_change_if_exists(SceneRouter.LIGHTHOUSE_PATH, "灯塔")


func _enter_lake_house() -> void:
	_change_if_exists(SceneRouter.LAKE_HOUSE_PATH, "湖畔小屋")


func _change_if_exists(path: String, label: String) -> void:
	if not ResourceLoader.exists(path):
		push_warning("Hub: scene missing for %s (%s) — rescan/import project" % [label, path])
		if status_label:
			status_label.text = "%s场景尚未就绪，请稍后重试或刷新文件系统" % label
		return
	get_tree().change_scene_to_file(path)


func _switch_overview() -> void:
	if hub_mode == "world":
		get_tree().change_scene_to_file(SceneRouter.CONNECTION_PATH)
	else:
		get_tree().change_scene_to_file(SceneRouter.HUB_PATH)


func _on_hotspot_click(event: InputEvent, enter_cb: Callable) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			enter_cb.call()
