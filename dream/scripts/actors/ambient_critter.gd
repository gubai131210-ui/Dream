class_name AmbientCritter
extends Node2D

## Ambient farm animal: idle stand + short wander. Skips water/blocked tiles via AreaCraft.

const IDLE_FPS := 2.0
const WALK_FPS := 6.0
const SPEED_PX := 26.0
const WANDER_RADIUS := 56.0
const PAUSE_MIN := 1.4
const PAUSE_MAX := 3.8
const PICK_TRIES := 10

var species_id: String = ""
var craft: AreaCraft = null

var _anim: AnimatedSprite2D
var _home: Vector2 = Vector2.ZERO
var _target: Vector2 = Vector2.ZERO
var _pause_left: float = 0.0
var _facing_right: bool = true


func setup(
	species: String,
	at: Vector2,
	area_craft: AreaCraft = null,
	draw_scale: float = 0.45
) -> void:
	species_id = species
	craft = area_craft
	_home = at
	position = at
	_target = at
	_pause_left = randf_range(0.4, 1.6)
	name = "Critter_%s" % species

	var shadow := Polygon2D.new()
	shadow.color = Color(0, 0, 0, 0.22)
	shadow.polygon = PackedVector2Array([
		Vector2(-10, 0), Vector2(0, -4), Vector2(10, 0), Vector2(0, 4),
	])
	shadow.position = Vector2(0, 6)
	shadow.z_index = -1
	add_child(shadow)

	_anim = AnimatedSprite2D.new()
	_anim.name = "Anim"
	_anim.centered = true
	_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_anim.scale = Vector2(draw_scale, draw_scale)
	_anim.offset = Vector2(0, -12)
	_anim.sprite_frames = _build_frames(species)
	add_child(_anim)
	_play_idle()


func _build_frames(species: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	var base := "res://assets/sprites/animals/%s" % species

	frames.add_animation("idle")
	frames.set_animation_speed("idle", IDLE_FPS)
	frames.set_animation_loop("idle", true)
	var idle_n := 0
	for i in range(4):
		var path := "%s/idle_%d.png" % [base, i]
		if not ResourceLoader.exists(path):
			continue
		var tex := load(path) as Texture2D
		if tex == null:
			continue
		frames.add_frame("idle", tex)
		idle_n += 1

	frames.add_animation("walk")
	frames.set_animation_speed("walk", WALK_FPS)
	frames.set_animation_loop("walk", true)
	var walk_n := 0
	for i in range(8):
		var path := "%s/walk_%d.png" % [base, i]
		if not ResourceLoader.exists(path):
			continue
		var tex := load(path) as Texture2D
		if tex == null:
			continue
		frames.add_frame("walk", tex)
		walk_n += 1

	if idle_n == 0 and walk_n > 0:
		frames.add_frame("idle", frames.get_frame_texture("walk", 0))
	if walk_n == 0 and idle_n > 0:
		frames.add_frame("walk", frames.get_frame_texture("idle", 0))
	if idle_n == 0 and walk_n == 0:
		push_warning("AmbientCritter: no frames for '%s'" % species)
	return frames


func _physics_process(delta: float) -> void:
	if _anim == null:
		return
	if _pause_left > 0.0:
		_pause_left -= delta
		_play_idle()
		if _pause_left <= 0.0:
			_pick_target()
		return

	var to: Vector2 = _target - position
	if to.length() <= 3.0:
		_pause_left = randf_range(PAUSE_MIN, PAUSE_MAX)
		_play_idle()
		return

	var step: Vector2 = to.normalized() * SPEED_PX * delta
	if step.length() > to.length():
		step = to
	var next: Vector2 = position + step
	if not _pos_ok(next):
		_pause_left = randf_range(PAUSE_MIN * 0.5, PAUSE_MAX * 0.7)
		_play_idle()
		return
	position = next
	_facing_right = step.x >= 0.0
	_anim.flip_h = not _facing_right
	_play_walk()


func _pick_target() -> void:
	for _i in range(PICK_TRIES):
		var ang := randf() * TAU
		var dist := randf_range(12.0, WANDER_RADIUS)
		var cand := _home + Vector2(cos(ang), sin(ang)) * dist
		if _pos_ok(cand):
			_target = cand
			return
	_target = _home
	_pause_left = randf_range(PAUSE_MIN, PAUSE_MAX)


func _pos_ok(pos: Vector2) -> bool:
	if craft == null:
		return true
	var t: Vector2i = craft.world_to_tile(pos)
	if craft.has_method("is_water") and craft.is_water(t.x, t.y):
		return false
	if craft.has_method("is_blocked") and craft.is_blocked(t.x, t.y):
		return false
	# Prefer grass / dirt / path — reject only when clearly off-map.
	if t.x < 0 or t.y < 0 or t.x >= craft.map_w or t.y >= craft.map_h:
		return false
	return true


func _play_idle() -> void:
	if _anim == null or not _anim.sprite_frames:
		return
	if _anim.sprite_frames.has_animation("idle") and _anim.animation != "idle":
		_anim.play("idle")


func _play_walk() -> void:
	if _anim == null or not _anim.sprite_frames:
		return
	if _anim.sprite_frames.has_animation("walk") and _anim.animation != "walk":
		_anim.play("walk")
