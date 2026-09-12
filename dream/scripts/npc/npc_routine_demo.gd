class_name NpcRoutineDemo
extends Node

## C53/C54 demo mount — scene-local Node (Env-H / DayNightWeather pattern).
## TopBar: 工作环 / 生活态. Keys: K cycle work, L cycle life.

const NODE_NAME := "NpcRoutineDemo"
const DEMO_ACTOR_NAME := "NpcRingDemoActor"
const STATUS_LAYER_NAME := "NpcRingDemoStatus"

signal ring_changed(kind: String, id: String, title: String)

var host_key: String = NpcRoutineRings.HOST_SQUARE
var _host: Node2D
var _ysort: Node2D
var _work_idx: int = 0
var _life_idx: int = 0
var _showing_life: bool = false
var _demo_actor: PatrolActor
var _status_label: Label
var _btn_work: Button
var _btn_life: Button
var _info: Node


static func attach_to(host: Node2D, top_bar: Control = null, key: String = NpcRoutineRings.HOST_SQUARE) -> NpcRoutineDemo:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as NpcRoutineDemo
	if existing:
		return existing
	var demo := NpcRoutineDemo.new()
	demo.name = NODE_NAME
	demo.host_key = key
	host.add_child(demo)
	demo.bind_host(host)
	if top_bar:
		demo.mount_top_bar(top_bar)
	demo.apply_current()
	return demo


func bind_host(host: Node2D) -> void:
	_host = host
	_ysort = host.get_node_or_null("YSortRoot") as Node2D
	if _ysort == null:
		_ysort = host
	_info = host.get_node_or_null("InfoPanel")
	_ensure_status_label()


func mount_top_bar(top_bar: Control) -> void:
	if top_bar == null:
		return
	_btn_work = top_bar.get_node_or_null("CycleWorkRing") as Button
	if _btn_work == null:
		_btn_work = Button.new()
		_btn_work.name = "CycleWorkRing"
		top_bar.add_child(_btn_work)
	_btn_life = top_bar.get_node_or_null("CycleLifeState") as Button
	if _btn_life == null:
		_btn_life = Button.new()
		_btn_life.name = "CycleLifeState"
		top_bar.add_child(_btn_life)
	if not _btn_work.pressed.is_connected(_on_work_pressed):
		_btn_work.pressed.connect(_on_work_pressed)
	if not _btn_life.pressed.is_connected(_on_life_pressed):
		_btn_life.pressed.connect(_on_life_pressed)
	_refresh_button_labels()


func cycle_work_ring() -> void:
	_showing_life = false
	var rings := NpcRoutineRings.work_demo_waypoints(host_key)
	if rings.is_empty():
		return
	_work_idx = (_work_idx + 1) % rings.size()
	apply_current()


func cycle_life_state() -> void:
	_showing_life = true
	var states := NpcRoutineRings.life_demo_states(host_key)
	if states.is_empty():
		return
	_life_idx = (_life_idx + 1) % states.size()
	apply_current()


func apply_current() -> void:
	var entry: Dictionary
	var kind: String
	if _showing_life:
		var states := NpcRoutineRings.life_demo_states(host_key)
		if states.is_empty():
			return
		_life_idx = clampi(_life_idx, 0, states.size() - 1)
		entry = states[_life_idx]
		kind = "life"
	else:
		var rings := NpcRoutineRings.work_demo_waypoints(host_key)
		if rings.is_empty():
			return
		_work_idx = clampi(_work_idx, 0, rings.size() - 1)
		entry = rings[_work_idx]
		kind = "work"
	_spawn_or_replace_actor(entry)
	_spawn_work_pose_cue(kind, entry)
	_update_status(kind, entry)
	_refresh_button_labels()
	_announce(kind, entry)
	ring_changed.emit(kind, str(entry.get("id", "")), str(entry.get("title", "")))


func current_work_id() -> String:
	var rings := NpcRoutineRings.work_demo_waypoints(host_key)
	if rings.is_empty():
		return ""
	return str(rings[clampi(_work_idx, 0, rings.size() - 1)].get("id", ""))


func current_life_id() -> String:
	var states := NpcRoutineRings.life_demo_states(host_key)
	if states.is_empty():
		return ""
	return str(states[clampi(_life_idx, 0, states.size() - 1)].get("id", ""))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_K:
				cycle_work_ring()
				get_viewport().set_input_as_handled()
			KEY_L:
				cycle_life_state()
				get_viewport().set_input_as_handled()


func _on_work_pressed() -> void:
	cycle_work_ring()


func _on_life_pressed() -> void:
	cycle_life_state()


func _spawn_or_replace_actor(entry: Dictionary) -> void:
	if _ysort == null:
		return
	if _demo_actor != null and is_instance_valid(_demo_actor):
		_demo_actor.queue_free()
		_demo_actor = null
	var old := _ysort.get_node_or_null(DEMO_ACTOR_NAME)
	if old:
		old.queue_free()

	var route: Array[Vector2] = []
	for p in entry.get("waypoints", []):
		route.append(p as Vector2)
	if route.size() < 2:
		return

	var actor := PatrolActor.new()
	actor.name = DEMO_ACTOR_NAME
	_ysort.add_child(actor)
	actor.setup(
		str(entry.get("character", "farmer")),
		str(entry.get("actor_title", entry.get("title", "NPC"))),
		str(entry.get("actor_desc", entry.get("hint", ""))),
		route,
		null
	)
	if actor.has_signal("activated") and _info != null and _info.has_method("show_info"):
		actor.activated.connect(func(h: InteractableHotspot) -> void:
			_info.call("show_info", h.title, h.description)
		)
	_demo_actor = actor


func _spawn_work_pose_cue(kind: String, entry: Dictionary) -> void:
	## G7: short occupational prop flash near demo actor (not full pose sheets yet).
	if _ysort == null or kind != "work":
		return
	var old := _ysort.get_node_or_null("WorkPoseCue")
	if old:
		old.queue_free()
	var work_id := str(entry.get("id", ""))
	var prop_path := ""
	match work_id:
		"sow":
			prop_path = "res://assets/sprites/interior/props/hay_00.png"
		"smith":
			prop_path = "res://assets/sprites/interior/props/anvil_00.png"
		"stall":
			prop_path = "res://assets/sprites/interior/props/basket_00.png"
		"cook":
			prop_path = "res://assets/sprites/interior/props/stove_00.png"
		_:
			return
	var cue := Node2D.new()
	cue.name = "WorkPoseCue"
	var anchor: Vector2 = Vector2(640, 480)
	var wps: Array = entry.get("waypoints", [])
	if not wps.is_empty():
		anchor = wps[0] as Vector2
	cue.position = anchor + Vector2(18, -28)
	cue.z_index = 8
	_ysort.add_child(cue)
	WorldSpawnUtil.attach_prop_sprite(cue, prop_path, 0.35)
	var tw := cue.create_tween()
	tw.tween_property(cue, "modulate:a", 0.35, 0.15)
	tw.tween_property(cue, "modulate:a", 1.0, 0.2)
	tw.tween_interval(1.2)
	tw.tween_property(cue, "modulate:a", 0.0, 0.45)
	tw.tween_callback(cue.queue_free)


func _ensure_status_label() -> void:
	if _host == null:
		return
	var layer := _host.get_node_or_null(STATUS_LAYER_NAME) as CanvasLayer
	if layer == null:
		layer = CanvasLayer.new()
		layer.name = STATUS_LAYER_NAME
		layer.layer = 12
		_host.add_child(layer)
	_status_label = layer.get_node_or_null("Status") as Label
	if _status_label == null:
		_status_label = Label.new()
		_status_label.name = "Status"
		_status_label.position = Vector2(16, 56)
		_status_label.add_theme_color_override("font_color", Color("#fff4c7"))
		_status_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		_status_label.add_theme_constant_override("shadow_offset_x", 1)
		_status_label.add_theme_constant_override("shadow_offset_y", 1)
		_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(_status_label)


func _update_status(kind: String, entry: Dictionary) -> void:
	if _status_label == null:
		return
	var prefix := "生活态" if kind == "life" else "工作环"
	var indoor := str(entry.get("indoor_ref", ""))
	var extra := (" · " + indoor) if not indoor.is_empty() else ""
	_status_label.text = "NPC %s：%s — %s%s  [K工作 / L生活]" % [
		prefix,
		str(entry.get("title", "")),
		str(entry.get("hint", "")),
		extra,
	]


func _refresh_button_labels() -> void:
	var rings := NpcRoutineRings.work_demo_waypoints(host_key)
	var states := NpcRoutineRings.life_demo_states(host_key)
	if _btn_work:
		var wt := "?"
		if not rings.is_empty():
			wt = str(rings[clampi(_work_idx, 0, rings.size() - 1)].get("title", "?"))
		_btn_work.text = "工作:%s" % wt
		_btn_work.tooltip_text = "循环职业工作环 (K) — C53"
	if _btn_life:
		var lt := "?"
		if not states.is_empty():
			lt = str(states[clampi(_life_idx, 0, states.size() - 1)].get("title", "?"))
		_btn_life.text = "生活:%s" % lt
		_btn_life.tooltip_text = "循环私人生活态 (L) — C54"


func _announce(kind: String, entry: Dictionary) -> void:
	if _info == null or not _info.has_method("show_info"):
		return
	var title := "C54 生活态" if kind == "life" else "C53 工作环"
	var body := "%s\n%s" % [str(entry.get("title", "")), str(entry.get("hint", ""))]
	var indoor := str(entry.get("indoor_ref", ""))
	if not indoor.is_empty():
		body += "\n室内锚：" + indoor
	_info.call("show_info", title, body)
