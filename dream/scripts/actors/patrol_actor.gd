class_name PatrolActor
extends InteractableHotspot

## Directional walk-cycle patrol using sliced NPC frames under assets/sprites/npc/{id}/.

const DIRS: Array[String] = ["down", "left", "right", "up"]
const SPEED_PX := 42.0
const PAUSE_SEC := 0.35
const FRAME_FPS := 7.0

var _anim: AnimatedSprite2D
var _route: Array[Vector2] = []
var _idx: int = 0
var _pause_left: float = 0.0
var _facing: String = "down"
var _moving: bool = false


func setup(character_id: String, actor_title: String, actor_desc: String, route: Array[Vector2]) -> void:
	title = actor_title
	description = actor_desc
	name = actor_title.replace(" ", "")
	_route = route.duplicate()
	if _route.is_empty():
		push_warning("PatrolActor: empty route for %s" % character_id)
		return
	position = _route[0]
	_idx = 1 % maxi(_route.size(), 1)

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
	shadow.position = Vector2(0, 10)
	shadow.z_index = -1
	visual.add_child(shadow)

	_anim = AnimatedSprite2D.new()
	_anim.name = "Anim"
	_anim.centered = true
	_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_anim.sprite_frames = _build_frames(character_id)
	_anim.offset = Vector2(0, -28)
	visual.add_child(_anim)
	_set_anim(false)


func _build_frames(character_id: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	# Remove default empty anim if present.
	if frames.has_animation("default"):
		frames.remove_animation("default")
	var base := "res://assets/sprites/npc/%s" % character_id
	var loaded_any := false
	for d in DIRS:
		var walk_name := "walk_%s" % d
		var idle_name := "idle_%s" % d
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, FRAME_FPS)
		frames.set_animation_loop(walk_name, true)
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, 1.0)
		frames.set_animation_loop(idle_name, true)
		for i in range(4):
			var path := "%s/walk_%s_%d.png" % [base, d, i]
			if not ResourceLoader.exists(path):
				continue
			var tex := load(path) as Texture2D
			if tex == null:
				continue
			frames.add_frame(walk_name, tex)
			if i == 0:
				frames.add_frame(idle_name, tex)
			loaded_any = true
	if not loaded_any:
		push_warning("PatrolActor: no walk frames for '%s'" % character_id)
	return frames


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
		_idx = (_idx + 1) % _route.size()
		_pause_left = PAUSE_SEC
		_moving = false
		_set_anim(false)
		return

	var step: float = SPEED_PX * delta
	var dir: Vector2 = to / dist
	position += dir * minf(step, dist)
	_update_facing(dir)
	_moving = true
	_set_anim(true)


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
