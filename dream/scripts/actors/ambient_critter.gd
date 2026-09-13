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
const FOOT_CONTACT_Y := 0.0

## Display height in pixels (must stay clearly below NPC ~56px except cow/deer slightly under).
const TARGET_HEIGHT_PX := {
	"cat": 20.0,
	"dog": 28.0,
	"sheep": 32.0,
	"cow": 42.0,
	"deer": 40.0,
	"chicken": 16.0,
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
	add_to_group("ambient_critters")
	set_meta("schedule_role", "critter")

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
	shadow.position = Vector2(0, FOOT_CONTACT_Y + 3.0)
	shadow.z_index = -1
	add_child(shadow)

	_anim = AnimatedSprite2D.new()
	_anim.name = "Anim"
	_anim.centered = true
	_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_anim.scale = Vector2(scale_f, scale_f)
	# The normalized canvas is bottom-anchored. Keep the visible contact line
	# four pixels above the actor root so the shadow and Y-sort stay stable.
	var anchor_height := 56.0
	if frames.has_animation("idle") and frames.get_frame_count("idle") > 0:
		var anchor_texture := frames.get_frame_texture("idle", 0)
		if anchor_texture:
			anchor_height = float(anchor_texture.get_height())
	_anim.offset = Vector2(0, -(anchor_height * scale_f * 0.5) + FOOT_CONTACT_Y)
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
	var raw := target / maxf(native_h, 1.0)
	# Authored near-target sprites (chicken etc.) must not use the B13 downscale band.
	if native_h <= 48.0:
		return clampf(raw, 0.5, 1.25)
	return clampf(raw, 0.06, 0.35)


func _build_frames(species: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	var base := "res://assets/sprites/animals/%s" % species
	var sources: Array[Dictionary] = []
	var canvas_size := Vector2i(1, 1)
	var anchor_y := 1
	# Source animals were exported with slightly different canvas sizes per
	# frame. Normalize them to one bottom-aligned canvas so AnimatedSprite2D
	# cannot jump or appear to blink when an idle/walk frame changes.
	for anim_name in ["idle", "walk"]:
		var count := 4 if anim_name == "idle" else 8
		for i in range(count):
			var path := "%s/%s_%d.png" % [base, anim_name, i]
			if not ResourceLoader.exists(path):
				continue
			var tex := load(path) as Texture2D
			if tex == null:
				continue
			var image := tex.get_image()
			if image == null:
				continue
			var used := image.get_used_rect()
			if used.size == Vector2i.ZERO:
				continue
			sources.append({"animation": anim_name, "image": image, "used": used})
			canvas_size.x = maxi(canvas_size.x, image.get_width())
			anchor_y = maxi(anchor_y, used.position.y + used.size.y)

	for source in sources:
		var source_image: Image = source["image"]
		var source_used: Rect2i = source["used"]
		canvas_size.y = maxi(canvas_size.y, source_image.get_height() + anchor_y - (source_used.position.y + source_used.size.y))

	frames.add_animation("idle")
	frames.set_animation_speed("idle", IDLE_FPS)
	frames.set_animation_loop("idle", true)
	var idle_n := 0

	frames.add_animation("walk")
	frames.set_animation_speed("walk", WALK_FPS)
	frames.set_animation_loop("walk", true)
	var walk_n := 0
	for source in sources:
		var image: Image = source["image"]
		var used: Rect2i = source["used"]
		var normalized := Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
		normalized.fill(Color(0, 0, 0, 0))
		var dst := Vector2i(
			floori(float(canvas_size.x - image.get_width()) / 2.0),
			anchor_y - (used.position.y + used.size.y)
		)
		normalized.blend_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), dst)
		var texture := ImageTexture.create_from_image(normalized)
		var animation: String = source["animation"]
		frames.add_frame(animation, texture)
		if animation == "idle":
			idle_n += 1
		else:
			walk_n += 1

	if idle_n == 0 and walk_n > 0:
		frames.add_frame("idle", frames.get_frame_texture("walk", 0))
	if walk_n == 0 and idle_n > 0:
		frames.add_frame("walk", frames.get_frame_texture("idle", 0))
	if idle_n == 0 and walk_n == 0:
		push_warning("AmbientCritter: no frames for '%s'" % species)
	return frames


func _physics_process(delta: float) -> void:
	if bool(get_meta("schedule_patrol_paused", false)):
		return
	if not visible:
		return

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
