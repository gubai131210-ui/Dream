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

var _director: InteractProximityDirector = InteractProximityDirector.new()


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
	_frame_room(rr)


func _frame_room(room_rect: Rect2) -> void:
	# Interior art is authored from the 32px grid, but room sizes vary from
	# compact 16x14 shops to 36x22 homes. Frame the actual room instead of
	# assuming every scene is a 1280x960 board.
	var framed := room_rect.grow(32.0)
	var viewport_size := get_viewport_rect().size
	var safe_size := Vector2(viewport_size.x, maxf(480.0, viewport_size.y - 112.0))
	var fit_zoom := minf(1.0, minf(safe_size.x / maxf(framed.size.x, 1.0), safe_size.y / maxf(framed.size.y, 1.0)))
	# Quarter-step zoom avoids arbitrary sub-pixel scale while still fitting the
	# two largest rooms inside the 720px presentation area.
	fit_zoom = clampf(floorf(fit_zoom * 4.0) / 4.0, 0.75, 1.0)
	camera.bounds = framed
	var room_center := framed.get_center()
	camera.position = room_center - Vector2(0, 24)
	camera.zoom = Vector2(fit_zoom, fit_zoom)
	camera.min_zoom = 0.75
	camera.max_zoom = 2.0
	# Wave F WorldSys C62 — append-only secret chain hop (e.g. c16_cave_entry → waterfall).
	# Portal click is wired inside SecretPassageChain (avoid double _wire_portals).
	SecretPassageChain.try_attach_interior(self)
	if profile_id == "c36_train_car":
		TrainCarWindowRide.attach_to(self)
		# Auto-depart shortly after boarding with a ticket so the ride is visible.
		if TrainService.can_board_car() or TrainService.has_ticket_for_active():
			var t := get_tree().create_timer(2.8)
			t.timeout.connect(func() -> void:
				if TrainService.get_state() == TrainService.State.DOCKED and TrainService.has_ticket_for_active():
					TrainService.request_early_depart()
			)


func _process(_delta: float) -> void:
	_director.update(self, camera, world)


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
				var path: String = str(area.get_meta("scene_path"))
				if path == SceneRouter.C36_TRAIN_CAR_PATH and not TrainService.can_board_car():
					info.show_info("车厢门", TrainService.board_hint())
					return
				SceneRouter.change_to(get_tree(), path)
		)
	for child in node.get_children():
		_wire_portals(child)


func _on_hotspot(hotspot: InteractableHotspot) -> void:
	_director.sync_click(hotspot)
	var title := hotspot.title
	if profile_id == "c11_station" and ("售票" in title or "时刻表" in title or "行车" in title or "票" in title):
		var buy := TrainService.try_buy_ticket_from_booth()
		info.show_info(title, TrainService.timetable_text() + "\n\n" + str(buy.get("msg", "")))
		return
	if profile_id == "c11_station" and ("站长" in title):
		var favor := TrainService.try_favor_ticket()
		info.show_info(title, hotspot.description + "\n\n" + str(favor.get("msg", "")))
		return
	if profile_id == "c36_train_car":
		info.show_info(title, hotspot.description + "\n\n" + TrainService.board_hint())
		return
	info.show_info(hotspot.title, hotspot.description)


## Current shared target for prompt + click (null if none in reach / hovered).
func get_executable_interact_target() -> InteractableHotspot:
	return _director.get_executable()


## Kept for g8_interact_target_smoke which calls this by name.
func _update_nearest_proximity_prompt() -> void:
	_director.update(self, camera, world)
