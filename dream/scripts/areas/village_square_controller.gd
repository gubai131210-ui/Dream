class_name VillageSquareController
extends Node2D

@onready var camera: CameraController = $CameraController
@onready var info: InfoPanel = $InfoPanel
@onready var ysort_root: Node2D = $YSortRoot
@onready var btn_hub: Button = $UI/TopBar/BackHub
@onready var btn_conn: Button = $UI/TopBar/BackConnections
@onready var btn_residential: Button = $UI/TopBar/ToResidential
@onready var btn_farm: Button = $UI/TopBar/ToFarm
@onready var btn_market: Button = $UI/TopBar/ToMarket
@onready var btn_station: Button = $UI/TopBar/ToStation
@onready var grid_overlay: Node2D = $DebugGrid


func _ready() -> void:
	var assembler := get_node_or_null("Assembler") as VillageSquareAssembler
	if assembler:
		assembler.assemble(self)
	btn_hub.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.HUB_PATH))
	btn_conn.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.CONNECTION_PATH))
	if btn_residential:
		btn_residential.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.RESIDENTIAL_PATH))
	if btn_farm:
		btn_farm.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.FARM_HOME_PATH))
	if btn_market:
		btn_market.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.MARKET_PATH))
	if btn_station:
		btn_station.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.STATION_PATH))
	for child in ysort_root.get_children():
		_wire_hotspots(child)
	_wire_portals(ysort_root)
	camera.bounds = Rect2(-80, -80, 1400, 1100)
	camera.position = Vector2(640, 480)
	# Integer zoom avoids sub-pixel hairline seams between tiles.
	camera.zoom = Vector2(1.0, 1.0)
	camera.min_zoom = 1.0
	camera.max_zoom = 3.0
	if grid_overlay:
		grid_overlay.visible = false
	# Env-H: night grade + weather overlay (TopBar + N/R). Scene-local Node, not Autoload.
	var top_bar := get_node_or_null("UI/TopBar") as Control
	DayNightWeather.attach_to(self, top_bar)


func _wire_portals(node: Node) -> void:
	if node is Area2D and node.has_meta("scene_path"):
		var area := node as Area2D
		area.input_event.connect(func(_vp, event, _i):
			if event is InputEventMouseButton:
				var mb := event as InputEventMouseButton
				if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
					SceneRouter.change_to(get_tree(), str(area.get_meta("scene_path")))
		)
	for c in node.get_children():
		_wire_portals(c)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_G and grid_overlay:
			grid_overlay.visible = not grid_overlay.visible


func _wire_hotspots(node: Node) -> void:
	if node is InteractableHotspot:
		(node as InteractableHotspot).activated.connect(_on_hotspot)
	for c in node.get_children():
		_wire_hotspots(c)


func _on_hotspot(hotspot: InteractableHotspot) -> void:
	info.show_info(hotspot.title, hotspot.description)

# Wave F WorldSys/NpcRing: attach SeasonalDecor + interact kits (team).
