class_name AmbientCritter
extends Node2D

## Ambient farm animal: idle stand + short wander. Skips water/blocked tiles via AreaCraft.
## Native B13 frames are ~150–260px; always normalize to TARGET_HEIGHT_PX vs CHARACTER ~56.

const IDLE_FPS := 2.0
const WALK_FPS := 6.0
const SPEED_PX := 26.0
const WANDER_RADIUS := 56.0
const PAUSE_MIN := 1.4
const PAUSE_MAX := 3.8
const PICK_TRIES := 10

## Display height in pixels (must stay clearly below NPC ~56px except cow/deer slightly under).
const TARGET_HEIGHT_PX := {
	"cat": 20.0,
	"dog": 28.0,
	"sheep": 32.0,
	"cow": 42.0,
	"deer": 40.0,
}

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
	draw_scale: float = -1.0
) -> void:
	species_id = species
	craft = area_craft
	_home = at
	position = at
	_target = at
	_pause_left = randf_range(0.4, 1.6)
	name = "Critter_%s" % species

	var frames := _build_frames(species)
	var scale_f := draw_scale
	if scale_f <= 0.0:
		scale_f = _scale_for_species(species, frames)

	var shadow := Polygon2D.new()
	shadow.color = Color(0, 0, 0, 0.22)
	var sw := clampf(6.0 + scale_f * 40.0, 6.0, 14.0)
	shadow.polygon = PackedVector2Array([
		Vector2(-sw, 0), Vector2(0, -sw * 0.4), Vector2(sw, 0), Vector2(0, sw * 0.4),
	])
	shadow.position = Vector2(0, 4)
	shadow.z_index = -1
	add_child(shadow)

	_anim = AnimatedSprite2D.new()
	_anim.name = "Anim"
	_anim.centered = true
	_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_anim.scale = Vector2(scale_f, scale_f)
	_anim.offset = Vector2(0, -10.0 * scale_f / 0.15)
	_anim.sprite_frames = frames
	add_child(_anim)
	_play_idle()


func _scale_for_species(species: String, frames: SpriteFrames) -> float:
	var target: float = float(TARGET_HEIGHT_PX.get(species, 28.0))
	var native_h := 180.0
	if frames.has_animation("idle") and frames.get_frame_count("idle") > 0:
		var tex := frames.get_frame_texture("idle", 0)
		if tex:
			native_h = float(tex.get_height())
	elif frames.has_animation("walk") and frames.get_frame_count("walk") > 0:
		var tex2 := frames.get_frame_texture("walk", 0)
		if tex2:
			native_h = float(tex2.get_height())
	return clampf(target / maxf(native_h, 1.0), 0.06, 0.35)


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
