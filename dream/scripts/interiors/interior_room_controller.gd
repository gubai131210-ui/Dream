class_name InteriorRoomController
extends Node2D

## Generic interior controller. Set `profile_id` (or meta) to pick InteriorProfiles entry.

@export var profile_id: String = "c01_home"

@onready var camera: CameraController = $CameraController
@onready var info: InfoPanel = $InfoLayer
@onready var world: Node2D = $InteriorWorld
@onready var btn_outside: Button = $UI/TopBar/BackOutside
@onready var btn_hub: Button = $UI/TopBar/BackHub


func _ready() -> void:
	set_meta("profile_id", profile_id)
	var assembler := get_node_or_null("Assembler") as InteriorCraft
	if assembler:
		assembler.profile_id = profile_id
		assembler.assemble(self, profile_id)
	var prof: Dictionary = InteriorProfiles.get_profile(profile_id)
	var ret_path := str(prof.get("return_path", SceneRouter.RESIDENTIAL_PATH))
	btn_outside.pressed.connect(func(): SceneRouter.change_to(get_tree(), ret_path))
	btn_hub.pressed.connect(func(): SceneRouter.change_to(get_tree(), SceneRouter.HUB_PATH))
	_wire_hotspots(world)
	_wire_portals(world)
	var rr: Rect2 = assembler.room_rect() if assembler else Rect2(0, 0, 1280, 960)
	camera.bounds = Rect2(0, 0, maxf(1280.0, rr.end.x + 64.0), maxf(960.0, rr.end.y + 96.0))
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
