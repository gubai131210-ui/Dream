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
		existing.host_key = key
		existing.bind_host(host)
		if top_bar:
			existing.mount_top_bar(top_bar)
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


## QA / MCP: force a life pose by id and hold cue (no auto fade) for screenshots.
func mcp_force_life_pose(life_id: String) -> Dictionary:
	var states := NpcRoutineRings.life_demo_states(host_key)
	if states.is_empty():
		return {"ok": false, "reason": "no_life_states"}
	var idx := -1
	for i in range(states.size()):
		if str(states[i].get("id", "")) == life_id:
			idx = i
			break
	if idx < 0:
		return {"ok": false, "reason": "unknown_id", "id": life_id}
	_showing_life = true
	_life_idx = idx
	var entry: Dictionary = states[idx]
	_spawn_or_replace_actor(entry)
	_spawn_work_pose_cue("life", entry, true)
	_update_status("life", entry)
	_refresh_button_labels()
	var cue := _ysort.get_node_or_null("WorkPoseCue") if _ysort else null
	var prop := cue.get_node_or_null("PropSprite") as Sprite2D if cue else null
	var tex_path := ""
	if prop and prop.texture:
		tex_path = str(prop.texture.resource_path)
	return {
		"ok": cue != null,
		"id": life_id,
		"cue": cue != null,
		"prop": prop != null,
		"prop_path": tex_path,
		"prop_scale": prop.scale.x if prop else 0.0,
		"cue_pos": cue.global_position if cue else Vector2.ZERO,
		"dying": 0,
	}


## QA / MCP: force spawn pose cue and report id + presence.
func debug_force_work_pose() -> String:
	var rings := NpcRoutineRings.work_demo_waypoints(host_key)
	if rings.is_empty():
		return "no_rings"
	_showing_life = false
	_work_idx = clampi(_work_idx, 0, rings.size() - 1)
	var entry: Dictionary = rings[_work_idx]
	_spawn_work_pose_cue("work", entry)
	var cue := _ysort.get_node_or_null("WorkPoseCue") if _ysort else null
	var dying := 0
	if _ysort:
		for c in _ysort.get_children():
			if str(c.name).begins_with("WorkPoseCue_dying"):
				dying += 1
	return "id=%s ysort=%s cue=%s dying=%d names=%s" % [
		str(entry.get("id", "")),
		_ysort != null,
		cue != null,
		dying,
		",".join(debug_work_pose_names()),
	]


## QA / MCP: names under YSort that look like work-pose demo nodes.
func debug_work_pose_names() -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	if _ysort == null:
		out.append("_ysort_null")
		return out
	out.append("ysort=%s" % _ysort.get_path())
	for c in _ysort.get_children():
		var n := str(c.name)
		if n.contains("Pose") or n.contains("NpcRing") or n.begins_with("Work"):
			out.append(n)
	return out


## QA / MCP: cycle every wired life state and report pose anim presence.
func mcp_probe_life_poses() -> Dictionary:
	var states := NpcRoutineRings.life_demo_states(host_key)
	if states.is_empty():
		return {"ok": false, "reason": "no_life_states"}
	var probed: Array = []
	_showing_life = true
	for i in range(states.size()):
		_life_idx = i
		apply_current()
		var entry: Dictionary = states[i]
		var cue := _ysort.get_node_or_null("WorkPoseCue") if _ysort else null
		var anim: AnimatedSprite2D = null
		if cue:
			anim = cue.get_node_or_null("WorkPoseAnim") as AnimatedSprite2D
		var frames := 0
		if anim != null and anim.sprite_frames != null and anim.sprite_frames.has_animation("pose"):
			frames = anim.sprite_frames.get_frame_count("pose")
		probed.append({
			"id": str(entry.get("id", "")),
			"cue": cue != null,
			"anim": anim != null,
			"frames": frames,
			"playing": anim.is_playing() if anim != null else false,
		})
	var ok := true
	for row in probed:
		if not bool(row.get("cue", false)) or int(row.get("frames", 0)) < 4:
			ok = false
			break
	return {"ok": ok, "count": probed.size(), "states": probed}


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
	_clear_demo_actors()
	_demo_actor = null

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
	# PatrolActor.setup renames to actor_title — keep a stable name so K-cycle can find/replace.
	actor.name = DEMO_ACTOR_NAME
	if actor.has_signal("activated") and _info != null and _info.has_method("show_info"):
		actor.activated.connect(func(h: InteractableHotspot) -> void:
			_info.call("show_info", h.title, h.description)
		)
	_demo_actor = actor


func _clear_demo_actors() -> void:
	## Immediate free so rapid K/L never leaves NpcRingDemoActor_dying stubs.
	if _ysort == null:
		return
	var doomed: Array[Node] = []
	for child in _ysort.get_children():
		var n := str(child.name)
		if n == DEMO_ACTOR_NAME or n.begins_with("NpcRingDemoActor_dying"):
			doomed.append(child)
	for node in doomed:
		node.free()


func _spawn_work_pose_cue(kind: String, entry: Dictionary, hold_for_mcp: bool = false) -> void:
	## G7/G8: occupational or life pose sheet flash (4 frames) + prop cue near demo actor.
	if _ysort == null:
		return
	if kind != "work" and kind != "life":
		return
	_clear_work_pose_cues()
	var ring_id := str(entry.get("id", ""))
	var prop_path := ""
	var pose_dir := ""
	if kind == "work":
		pose_dir = "res://assets/sprites/npc/work_poses/%s" % ring_id
		match ring_id:
			"sow":
				prop_path = "res://assets/sprites/props/hay_00.png"
			"smith":
				prop_path = "res://assets/sprites/props/anvil_00.png"
			"stall":
				prop_path = "res://assets/sprites/props/sack_0.png"
			"cook":
				prop_path = "res://assets/sprites/props/stove_00.png"
			_:
				return
	else:
		pose_dir = "res://assets/sprites/npc/life_poses/%s" % ring_id
		match ring_id:
			"eat":
				prop_path = "res://assets/sprites/props/bowl_00.png"
			"sleep":
				prop_path = "res://assets/sprites/props/pillow_00.png"
			"read":
				prop_path = "res://assets/sprites/props/book_open_00.png"
			"laundry":
				prop_path = "res://assets/sprites/props/trough_00.png"
			"idle_sit":
				prop_path = "res://assets/sprites/props/bench_0.png"
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
	_attach_pose_anim(cue, pose_dir)
	if not prop_path.is_empty():
		var prop_scale := 0.28
		if kind == "life" and ring_id == "sleep":
			prop_scale = 0.55  # pillow must read at §7 zoom
		elif kind == "life" and ring_id in ["eat", "read"]:
			prop_scale = 0.42
		WorldSpawnUtil.attach_prop_sprite(cue, prop_path, prop_scale)
	if hold_for_mcp:
		return
	# Hold long enough for player QA / MCP round-trips; next cycle replaces this node.
	var tw := cue.create_tween()
	tw.tween_property(cue, "modulate:a", 0.35, 0.12)
	tw.tween_property(cue, "modulate:a", 1.0, 0.18)
	tw.tween_interval(12.0)
	tw.tween_property(cue, "modulate:a", 0.0, 0.45)
	tw.tween_callback(cue.queue_free)


func _clear_work_pose_cues() -> void:
	## Immediate free (not queue_free rename) so rapid K/L cycles never leave WorkPoseCue_dying stubs.
	if _ysort == null:
		return
	var doomed: Array[Node] = []
	for child in _ysort.get_children():
		var n := str(child.name)
		if n == "WorkPoseCue" or n.begins_with("WorkPoseCue_dying"):
			doomed.append(child)
	for node in doomed:
		node.free()


func _attach_pose_anim(parent: Node2D, dir: String) -> void:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("pose")
	frames.set_animation_loop("pose", true)
	frames.set_animation_speed("pose", 6.0)
	var n := 0
	for i in range(4):
		var path := "%s/pose_%02d.png" % [dir, i]
		var tex := WorldSpawnUtil.load_prop_texture(path)
		if tex == null:
			continue
		frames.add_frame("pose", tex)
		n += 1
	if n == 0:
		return
	var anim := AnimatedSprite2D.new()
	anim.name = "WorkPoseAnim"
	anim.sprite_frames = frames
	anim.centered = true
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.position = Vector2(-22, -6)
	# Pose sheets are 32×48; scale toward walk NPC read height (~56).
	anim.scale = Vector2(1.45, 1.45)
	anim.z_index = 2
	parent.add_child(anim)
	anim.play("pose")


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
