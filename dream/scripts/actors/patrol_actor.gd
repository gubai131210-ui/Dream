class_name PatrolActor
extends InteractableHotspot

## Directional walk-cycle patrol using sliced NPC frames under assets/sprites/npc/{id}/.

const DIRS: Array[String] = ["down", "left", "right", "up"]
const SNAP_MAX_R := 8
const FOOT_CONTACT_Y := 0.0
const AVOID_PAUSE_SEC := 0.45

var _anim: AnimatedSprite2D
var _route: Array[Vector2] = []
var _idx: int = 0
var _dir: int = 1
var _pause_left: float = 0.0
var _facing: String = "down"
var _moving: bool = false
var _character_id: String = ""
var _role: int = NpcMotionPolicy.Role.VISITOR
var _speed_px: float = 32.0
var _pause_sec: float = 0.35
## Weak ref so AreaCraft (RefCounted) can be GC'd if scene tears down craft first.
var _craft_ref: WeakRef = null


func setup(
	character_id: String,
	actor_title: String,
	actor_desc: String,
	route: Array[Vector2],
	craft: AreaCraft = null
) -> void:
	title = actor_title
	description = actor_desc
	name = actor_title.replace(" ", "")
	_character_id = character_id
	_role = NpcMotionPolicy.role_for_character(character_id)
	# Title can refine role (e.g. 摊主 / 老妇人).
	var title_role := NpcMotionPolicy.role_for_title(actor_title)
	if title_role != NpcMotionPolicy.Role.VISITOR:
		_role = title_role
	add_to_group("patrol_actors")
	_route = route.duplicate()
	set_area_craft(craft)
	_refresh_motion_policy()
	if _route.is_empty():
		push_warning("PatrolActor: empty route for %s" % character_id)
		return
	_snap_blocked_waypoints()
	position = _route[0]
	_idx = 1 % maxi(_route.size(), 1)
	_dir = 1

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(28, 20)
	shape.position = Vector2(0, -8)
	shape.shape = rect
	add_child(shape)

	var visual := Node2D.new()
	visual.name = "Visual"
	add_child(visual)

	var shadow := Polygon2D.new()
	shadow.color = Color(0, 0, 0, 0.28)
	shadow.polygon = PackedVector2Array([
		Vector2(-12, 0), Vector2(0, -5), Vector2(12, 0), Vector2(0, 5),
	])
	shadow.position = Vector2(0, FOOT_CONTACT_Y + 3.0)
	shadow.z_index = -1
	visual.add_child(shadow)

	_anim = AnimatedSprite2D.new()
	_anim.name = "Anim"
	_anim.centered = true
	_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_anim.sprite_frames = NpcWalkFrames.build(character_id)
	visual.add_child(_anim)
	_anim.offset = NpcWalkFrames.foot_offset(_anim.sprite_frames, FOOT_CONTACT_Y)
	_apply_anim_fps()
	_set_anim(false)


## Optional post-setup bind so assemblers that call setup without craft stay compiling.
func set_area_craft(craft: AreaCraft) -> void:
	_craft_ref = weakref(craft) if craft != null else null


func _craft() -> AreaCraft:
	if _craft_ref == null:
		return null
	var c: Variant = _craft_ref.get_ref()
	return c as AreaCraft


func _host_scene() -> Node:
	return get_tree().current_scene if get_tree() else null


func refresh_motion_policy() -> void:
	_refresh_motion_policy()


func pause_patrol() -> void:
	set_meta("schedule_patrol_paused", true)
	_moving = false
	_set_anim(false)


func resume_patrol() -> void:
	set_meta("schedule_patrol_paused", false)
	set_physics_process(true)
	visible = true
	_refresh_motion_policy()


func _refresh_motion_policy() -> void:
	var host := _host_scene()
	_speed_px = NpcMotionPolicy.speed_px(_role, host)
	_pause_sec = NpcMotionPolicy.pause_sec(_role)
	_apply_anim_fps()


func _apply_anim_fps() -> void:
	if _anim == null:
		return
	NpcMotionPolicy.apply_anim_speed(_anim, NpcMotionPolicy.frame_fps(_role, _host_scene()))


## If a waypoint sits on water/blocked, snap to nearby NPC-walkable tile center (spiral).
func _snap_blocked_waypoints() -> void:
	var craft := _craft()
	if craft == null or _route.is_empty():
		return
	for i in range(_route.size()):
		var t: Vector2i = craft.world_to_tile(_route[i])
		if craft.is_npc_walkable(t.x, t.y):
			continue
		var candidate := _find_npc_walkable_near(craft, t, SNAP_MAX_R)
		if candidate != Vector2.ZERO:
			_route[i] = candidate


func _find_npc_walkable_near(craft: AreaCraft, origin: Vector2i, max_r: int) -> Vector2:
	if craft.is_npc_walkable(origin.x, origin.y):
		return craft.tile_center(origin.x, origin.y)
	for r in range(1, max_r + 1):
		for oy in range(-r, r + 1):
			for ox in range(-r, r + 1):
				if maxi(absi(ox), absi(oy)) != r:
					continue
				var nx := origin.x + ox
				var ny := origin.y + oy
				if craft.is_npc_walkable(nx, ny):
					return craft.tile_center(nx, ny)
	return Vector2.ZERO


func _physics_process(delta: float) -> void:
	if bool(get_meta("schedule_patrol_paused", false)):
		return
	if _route.size() < 2 or _anim == null:
		return
	# Re-sample weather/time occasionally cheaply via pause boundaries.
	if _pause_left > 0.0:
		_pause_left -= delta
		_moving = false
		_set_anim(false)
		if _pause_left <= 0.0:
			_refresh_motion_policy()
		return

	var target: Vector2 = _route[_idx]
	var to: Vector2 = target - position
	var dist: float = to.length()
	if dist <= 2.0:
		position = target
		_advance_idx()
		_pause_left = _pause_sec
		_moving = false
		_set_anim(false)
		return

	var step: float = _speed_px * delta
	var dir: Vector2 = to / dist
	var move_len: float = minf(step, dist)
	var next_pos: Vector2 = position + dir * move_len

	var craft := _craft()
	if craft != null:
		var nt: Vector2i = craft.world_to_tile(next_pos)
		if not craft.is_npc_walkable(nt.x, nt.y):
			# Stardew-like: try a short sidestep onto an adjacent walkable tile before reversing.
			var side := _try_sidestep(craft, dir, move_len)
			if side != Vector2.ZERO:
				var move_dir := side - position
				position = side
				if move_dir != Vector2.ZERO:
					_update_facing(move_dir)
				_moving = true
				_set_anim(true)
				return
			_turn_back()
			return

	position = next_pos
	_update_facing(dir)
	_moving = true
	_set_anim(true)


func _try_sidestep(craft: AreaCraft, forward: Vector2, move_len: float) -> Vector2:
	var perp := Vector2(-forward.y, forward.x)
	var signs: Array[float] = [1.0, -1.0]
	for sign_v in signs:
		var candidate: Vector2 = position + perp * sign_v * move_len
		var t: Vector2i = craft.world_to_tile(candidate)
		if craft.is_npc_walkable(t.x, t.y):
			return candidate
		# Also try a full tile nudge.
		var tile_nudge: Vector2 = position + perp * sign_v * float(craft.tile)
		t = craft.world_to_tile(tile_nudge)
		if craft.is_npc_walkable(t.x, t.y):
			return position.move_toward(tile_nudge, move_len)
	return Vector2.ZERO


func _advance_idx() -> void:
	var n: int = _route.size()
	if n < 1:
		return
	_idx = (_idx + _dir + n * 4) % n


func _turn_back() -> void:
	_dir = -_dir
	_advance_idx()
	_pause_left = AVOID_PAUSE_SEC
	_moving = false
	_set_anim(false)


func _update_facing(dir: Vector2) -> void:
	if absf(dir.x) >= absf(dir.y):
		_facing = "right" if dir.x >= 0.0 else "left"
	else:
		_facing = "down" if dir.y >= 0.0 else "up"


func _set_anim(walking: bool) -> void:
	if _anim == null or _anim.sprite_frames == null:
		return
	var anim_name := ("walk_%s" if walking else "idle_%s") % _facing
	if not _anim.sprite_frames.has_animation(anim_name):
		return
	if _anim.animation != anim_name:
		_anim.play(anim_name)
	elif walking and not _anim.is_playing():
		_anim.play(anim_name)
	elif not walking:
		_anim.pause()
		_anim.frame = 0
