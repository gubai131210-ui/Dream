class_name RiverController
extends Node2D

@onready var camera: CameraController = $CameraController
@onready var info: InfoPanel = $InfoPanel
@onready var ysort_root: Node2D = $YSortRoot
@onready var btn_hub: Button = $UI/TopBar/BackHub
@onready var btn_conn: Button = $UI/TopBar/BackConnections
@onready var btn_deep: Button = $UI/TopBar/ToDeep
@onready var btn_fall: Button = $UI/TopBar/ToFall
@onready var btn_lake: Button = $UI/TopBar/ToLake
@onready var grid_overlay: Node2D = $DebugGrid


func _ready() -> void:
	var assembler := get_node_or_null("Assembler") as RiverAssembler
	if assembler:
		assembler.assemble(self)
	btn_hub.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.HUB_PATH))
	btn_conn.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.CONNECTION_PATH))
	if btn_deep:
		btn_deep.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.FOREST_DEEP_PATH))
	if btn_fall:
		btn_fall.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.WATERFALL_PATH))
	if btn_lake:
		btn_lake.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.LAKE_PATH))
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
	var top_bar := get_node_or_null("UI/TopBar") as Control
	DayNightWeather.attach_to(self, top_bar)
	var _dik = load("res://scripts/world/district_interact_kit.gd")
	_dik.attach_to(self, "river", top_bar)
	# Outdoor proximity 「互动」parity with interiors.
	AreaInteractHost.attach_to(self, ysort_root, camera)

func _wire_portals(node: Node) -> void:
	if node is Area2D and (node as Area2D).has_meta("scene_path"):
		var area := node as Area2D
		area.input_event.connect(func(_vp: Node, event: InputEvent, _si: int) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				var path: String = str(area.get_meta("scene_path"))
				if not path.is_empty():
					SceneRouter.change_to(get_tree(), path)
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
	var host := get_node_or_null(AreaInteractHost.NODE_NAME) as AreaInteractHost
	if host:
		host.sync_click(hotspot)
	if hotspot is FishingSpot:
		# Session self-starts on activated; refresh panel with live copy.
		info.show_info(hotspot.title, hotspot.description)
		return
	info.show_info(hotspot.title, hotspot.description)
