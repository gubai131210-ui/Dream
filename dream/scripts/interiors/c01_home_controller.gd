class_name C01HomeController
extends Node2D

@onready var camera: CameraController = $CameraController
@onready var info: InfoPanel = $InfoPanel
@onready var world: Node2D = $InteriorWorld
@onready var btn_outside: Button = $UI/TopBar/BackOutside
@onready var btn_hub: Button = $UI/TopBar/BackHub


func _ready() -> void:
	var assembler := get_node_or_null("Assembler") as InteriorCraft
	if assembler:
		assembler.assemble(self)
	btn_outside.pressed.connect(func(): SceneRouter.change_to(get_tree(), SceneRouter.RESIDENTIAL_PATH))
	btn_hub.pressed.connect(func(): SceneRouter.change_to(get_tree(), SceneRouter.HUB_PATH))
	_wire_hotspots(world)
	_wire_portals(world)
	camera.bounds = Rect2(0, 0, 1280, 960)
	camera.position = Vector2(640, 480)
	camera.zoom = Vector2.ONE
	camera.min_zoom = 1.0
	camera.max_zoom = 2.0


func _wire_hotspots(node: Node) -> void:
	if node is InteractableHotspot:
		(node as InteractableHotspot).activated.connect(_on_hotspot)
	for child in node.get_children():
		_wire_hotspots(child)


func _wire_portals(node: Node) -> void:
	if node is Area2D and (node as Area2D).has_meta("scene_path"):
		var area := node as Area2D
		area.input_event.connect(func(_vp: Node, event: InputEvent, _si: int) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				SceneRouter.change_to(get_tree(), str(area.get_meta("scene_path")))
		)
	for child in node.get_children():
		_wire_portals(child)


func _on_hotspot(hotspot: InteractableHotspot) -> void:
	info.show_info(hotspot.title, hotspot.description)
