class_name PatrolActor
extends InteractableHotspot

## Directional walk-cycle patrol using sliced NPC frames under assets/sprites/npc/{id}/.

const DIRS: Array[String] = ["down", "left", "right", "up"]
## One 32px tile per second keeps an 8fps / 4-frame walk cycle at 4px per frame.
## This avoids the fractional 4.5px stride that made the old cycle read as sliding.
const SPEED_PX := 32.0
const PAUSE_SEC := 0.35
const AVOID_PAUSE_SEC := 0.45
const FRAME_FPS := 8.0
const SNAP_MAX_R := 8
const FOOT_CONTACT_Y := 0.0

var _anim: AnimatedSprite2D
var _route: Array[Vector2] = []
var _idx: int = 0
var _dir: int = 1
var _pause_left: float = 0.0
var _facing: String = "down"
var _moving: bool = false
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
	_route = route.duplicate()
	set_area_craft(craft)
	if _route.is_empty():
		push_warning("PatrolActor: empty route for %s" % character_id)
		return
	_snap_blocked_waypoints()
	position = _route[0]
	_idx = 1 % maxi(_route.size(), 1)
	_dir = 1

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 56)
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
	_set_anim(false)


## Optional post-setup bind so assemblers that call setup without craft stay compiling.
func set_area_craft(craft: AreaCraft) -> void:
	_craft_ref = weakref(craft) if craft != null else null


func _craft() -> AreaCraft:
	if _craft_ref == null:
		return null
	var c: Variant = _craft_ref.get_ref()
	return c as AreaCraft


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
	if _route.size() < 2 or _anim == null:
		return
	if _pause_left > 0.0:
		_pause_left -= delta
		_moving = false
		_set_anim(false)
		return

	var target: Vector2 = _route[_idx]
	var to: Vector2 = target - position
	var dist: float = to.length()
	if dist <= 2.0:
		position = target
		_advance_idx()
		_pause_left = PAUSE_SEC
		_moving = false
		_set_anim(false)
		return

	var step: float = SPEED_PX * delta
	var dir: Vector2 = to / dist
	var move_len: float = minf(step, dist)
	var next_pos: Vector2 = position + dir * move_len

	var craft := _craft()
	if craft != null:
		var nt: Vector2i = craft.world_to_tile(next_pos)
		if not craft.is_npc_walkable(nt.x, nt.y):
			_turn_back()
			return

	position = next_pos
	_update_facing(dir)
	_moving = true
	_set_anim(true)


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
