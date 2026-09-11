class_name InteriorRoomController
extends Node2D

## Generic interior controller. Set `profile_id` (or meta) to pick InteriorProfiles entry.
## Wave D: each frame picks the nearest player-near InteractableHotspot and shows a world "互动" cue.

@export var profile_id: String = "c01_home"

@onready var camera: CameraController = $CameraController
@onready var info: InfoPanel = $InfoLayer
@onready var world: Node2D = $InteriorWorld
@onready var btn_outside: Button = $UI/TopBar/BackOutside
@onready var btn_hub: Button = $UI/TopBar/BackHub

var _hotspots: Array[InteractableHotspot] = []
var _prompt_active: InteractableHotspot = null


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
	_hotspots.clear()
	_wire_hotspots(world)
	_wire_portals(world)
	var rr: Rect2 = assembler.room_rect() if assembler else Rect2(0, 0, 1280, 960)
	camera.bounds = Rect2(0, 0, maxf(1280.0, rr.end.x + 64.0), maxf(960.0, rr.end.y + 96.0))
	camera.position = Vector2(640, 480)
	camera.zoom = Vector2.ONE
	camera.min_zoom = 1.0
	camera.max_zoom = 2.0
	# Wave F WorldSys C62 — append-only secret chain hop (e.g. c16_cave_entry → waterfall).
	# Portal click is wired inside SecretPassageChain (avoid double _wire_portals).
	SecretPassageChain.try_attach_interior(self)


func _process(_delta: float) -> void:
	_update_nearest_proximity_prompt()


func _wire_hotspots(node: Node) -> void:
	if node is InteractableHotspot:
		var hs := node as InteractableHotspot
		hs.activated.connect(_on_hotspot)
		_hotspots.append(hs)
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


func _find_player_body() -> Node2D:
	var grouped := get_tree().get_nodes_in_group("player")
	for n in grouped:
		if n is Node2D and is_instance_valid(n):
			return n as Node2D
	if world == null:
		return null
	return _find_character_body(world)


func _find_character_body(node: Node) -> CharacterBody2D:
	if node is CharacterBody2D:
		return node as CharacterBody2D
	for child in node.get_children():
		var found := _find_character_body(child)
		if found:
			return found
	return null


func _update_nearest_proximity_prompt() -> void:
	var player := _find_player_body()
	var has_player_body := player != null
	var anchor: Vector2
	if has_player_body:
		anchor = player.global_position
	elif camera:
		anchor = camera.global_position
	else:
		anchor = global_position

	var best: InteractableHotspot = null
	var best_dist := INF

	for hs in _hotspots:
		if not is_instance_valid(hs):
			continue
		var candidate := false
		if has_player_body:
			candidate = hs.has_player_overlap()
		else:
			# No walkable player yet: camera pan acts as temporary proximity probe.
			candidate = hs.is_point_in_reach(anchor)
		if not candidate:
			continue
		var d := hs.global_position.distance_squared_to(anchor)
		if d < best_dist:
			best_dist = d
			best = hs

	if _prompt_active == best:
		return
	if _prompt_active and is_instance_valid(_prompt_active):
		_prompt_active.set_proximity_prompt_shown(false)
	_prompt_active = best
	if _prompt_active:
		_prompt_active.set_proximity_prompt_shown(true)
