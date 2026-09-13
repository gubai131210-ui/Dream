class_name FarmlandController
extends Node2D

@onready var camera: CameraController = $CameraController
@onready var info: InfoPanel = $InfoPanel
@onready var ysort_root: Node2D = $YSortRoot
@onready var btn_hub: Button = $UI/TopBar/BackHub
@onready var btn_conn: Button = $UI/TopBar/BackConnections
@onready var btn_farm_home: Button = $UI/TopBar/ToFarmHome
@onready var btn_square: Button = $UI/TopBar/ToSquare
@onready var grid_overlay: Node2D = $DebugGrid


func _ready() -> void:
	var assembler := get_node_or_null("Assembler") as FarmlandAssembler
	if assembler:
		assembler.assemble(self)
	btn_hub.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.HUB_PATH))
	btn_conn.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.CONNECTION_PATH))
	if btn_farm_home:
		btn_farm_home.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.FARM_HOME_PATH))
	if btn_square:
		btn_square.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.SQUARE_PATH))
	for child in ysort_root.get_children():
		_wire_hotspots(child)
		_wire_portals(child)
	camera.bounds = Rect2(-80, -80, 1400, 1100)
	camera.position = Vector2(640, 480)
	camera.zoom = Vector2(1.0, 1.0)
	camera.min_zoom = 1.0
	camera.max_zoom = 3.0
	if grid_overlay:
		grid_overlay.visible = false
	# Wave F NpcRing: farmland sow work ring demo (TopBar + K/L).
	var top_bar := get_node_or_null("UI/TopBar") as Control
	DayNightWeather.attach_to(self, top_bar)
	NpcRoutineDemo.attach_to(self, top_bar, NpcRoutineRings.HOST_FARMLAND)
	# G4 — district prop interacts.
	var _dik = load("res://scripts/world/district_interact_kit.gd")
	_dik.attach_to(self, "farmland", top_bar)
	# Spine B — turnip crop vertical slice (new stage art → InventoryService).
	FarmCropKit.attach_to(self, ysort_root, info)
	if not bool(ProjectSettings.get_setting("debug/show_demo_overlays", false)):
		var routine_status := get_node_or_null("NpcRingDemoStatus") as CanvasLayer
		if routine_status:
			routine_status.visible = false
		var info_panel := get_node_or_null("InfoPanel") as InfoPanel
		if info_panel:
			info_panel.hide_info()
	# Outdoor proximity 「互动」parity with interiors.
	AreaInteractHost.attach_to(self, ysort_root, camera)

func _wire_portals(node: Node) -> void:
	if node is Area2D and (node as Area2D).has_meta("scene_path"):
		WorldSpawnUtil.wire_portal_click(node as Area2D, get_tree())
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
	var host := get_node_or_null(AreaInteractHost.NODE_NAME) as AreaInteractHost
	if host:
		host.sync_click(hotspot)
	info.show_info(hotspot.title, hotspot.description)
