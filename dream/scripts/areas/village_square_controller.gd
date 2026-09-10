class_name VillageSquareController
extends Node2D

@onready var camera: CameraController = $CameraController
@onready var info: InfoPanel = $InfoPanel
@onready var ysort_root: Node2D = $YSortRoot
@onready var btn_hub: Button = $UI/TopBar/BackHub
@onready var btn_conn: Button = $UI/TopBar/BackConnections
@onready var grid_overlay: Node2D = $DebugGrid


func _ready() -> void:
	var assembler := get_node_or_null("Assembler") as VillageSquareAssembler
	if assembler:
		assembler.assemble(self)
	btn_hub.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.HUB_PATH))
	btn_conn.pressed.connect(func(): get_tree().change_scene_to_file(SceneRouter.CONNECTION_PATH))
	for child in ysort_root.get_children():
		_wire_hotspots(child)
	camera.bounds = Rect2(-80, -80, 1400, 1100)
	camera.position = Vector2(640, 480)
	camera.zoom = Vector2(1.0, 1.0)
	if grid_overlay:
		grid_overlay.visible = false


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
