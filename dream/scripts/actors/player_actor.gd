class_name PlayerActor
extends CharacterBody2D

## Playable protagonist — walk cycle from assets/sprites/npc/player/.

const CHARACTER_ID := "player"
const FOOT_CONTACT_Y := 0.0

var _anim: AnimatedSprite2D
var _facing: String = "down"
var _craft_ref: WeakRef = null
var _speed_px: float = 48.0


func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask = 1
	z_index = 10
	_refresh_motion_policy()

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(28, 20)
	shape.position = Vector2(0, -10)
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
	_anim.sprite_frames = NpcWalkFrames.build(CHARACTER_ID)
	_anim.offset = NpcWalkFrames.foot_offset(_anim.sprite_frames, FOOT_CONTACT_Y)
	visual.add_child(_anim)
	_apply_anim_fps()
	_set_anim(false)


func set_area_craft(craft: AreaCraft) -> void:
	_craft_ref = weakref(craft) if craft != null else null


func _craft() -> AreaCraft:
	if _craft_ref == null:
		return null
	var c: Variant = _craft_ref.get_ref()
	return c as AreaCraft


func _host_scene() -> Node:
	return get_tree().current_scene if get_tree() else null


func _refresh_motion_policy() -> void:
	_speed_px = NpcMotionPolicy.speed_px(NpcMotionPolicy.Role.PLAYER, _host_scene())
	_apply_anim_fps()


func _apply_anim_fps() -> void:
	if _anim == null:
		return
	NpcMotionPolicy.apply_anim_speed(
		_anim,
		NpcMotionPolicy.frame_fps(NpcMotionPolicy.Role.PLAYER, _host_scene())
	)


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		dir.x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		dir.x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		dir.y -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		dir.y += 1.0

	if dir == Vector2.ZERO:
		velocity = Vector2.ZERO
		_set_anim(false)
		return

	_refresh_motion_policy()
	dir = dir.normalized()
	var next_pos := global_position + dir * _speed_px * delta
	var craft := _craft()
	if craft != null:
		var nt: Vector2i = craft.world_to_tile(next_pos)
		if not craft.is_npc_walkable(nt.x, nt.y):
			# Axis-slide: keep the free component (common top-down feel).
			var slide_x := global_position + Vector2(dir.x, 0) * _speed_px * delta
			var slide_y := global_position + Vector2(0, dir.y) * _speed_px * delta
			var tx := craft.world_to_tile(slide_x)
			var ty := craft.world_to_tile(slide_y)
			var moved := false
			if craft.is_npc_walkable(tx.x, tx.y):
				global_position = slide_x
				_update_facing(Vector2(dir.x, 0))
				moved = true
			elif craft.is_npc_walkable(ty.x, ty.y):
				global_position = slide_y
				_update_facing(Vector2(0, dir.y))
				moved = true
			velocity = Vector2.ZERO
			_set_anim(moved)
			return

	global_position = next_pos
	_update_facing(dir)
	_set_anim(true)


func _update_facing(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		return
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
