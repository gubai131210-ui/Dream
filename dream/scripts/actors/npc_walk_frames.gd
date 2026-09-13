class_name NpcWalkFrames
extends RefCounted

## Shared walk-cycle SpriteFrames builder for PatrolActor and PlayerActor.

const DIRS: Array[String] = ["down", "left", "right", "up"]
const FRAME_FPS := 8.0


static func detect_frame_count(base: String) -> int:
	if ResourceLoader.exists("%s/walk_down_4.png" % base):
		return 8
	return 4


static func build(character_id: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	var base := "res://assets/sprites/npc/%s" % character_id
	var sources: Array[Dictionary] = []
	var canvas_w := 1
	var anchor_y := 1
	var frame_count := detect_frame_count(base)
	for d in DIRS:
		var walk_name := "walk_%s" % d
		var idle_name := "idle_%s" % d
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, FRAME_FPS)
		frames.set_animation_loop(walk_name, true)
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, 1.0)
		frames.set_animation_loop(idle_name, true)
		for i in range(frame_count):
			var path := "%s/walk_%s_%d.png" % [base, d, i]
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
			sources.append({
				"dir": d,
				"index": i,
				"image": image,
				"used": used,
			})
			canvas_w = maxi(canvas_w, image.get_width())
			anchor_y = maxi(anchor_y, used.position.y + used.size.y)

	if sources.is_empty():
		push_warning("NpcWalkFrames: no walk frames for '%s'" % character_id)
		return frames

	var canvas_h := 1
	for source in sources:
		var image: Image = source["image"]
		var used: Rect2i = source["used"]
		canvas_h = maxi(canvas_h, image.get_height() + anchor_y - (used.position.y + used.size.y))

	for source in sources:
		var image: Image = source["image"]
		var used: Rect2i = source["used"]
		var normalized := Image.create(canvas_w, canvas_h, false, Image.FORMAT_RGBA8)
		normalized.fill(Color.TRANSPARENT)
		var dst := Vector2i(
			floori(float(canvas_w - image.get_width()) * 0.5),
			anchor_y - (used.position.y + used.size.y)
		)
		normalized.blend_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), dst)
		var texture := ImageTexture.create_from_image(normalized)
		var dir: String = source["dir"]
		var index: int = source["index"]
		var walk_name := "walk_%s" % dir
		var idle_name := "idle_%s" % dir
		frames.add_frame(walk_name, texture)
		if index == 0:
			frames.add_frame(idle_name, texture)
	return frames


static func foot_offset(frames: SpriteFrames, foot_contact_y: float = 0.0) -> Vector2:
	var foot_y := 28.0
	if frames != null and frames.has_animation("idle_down"):
		var anchor_texture := frames.get_frame_texture("idle_down", 0)
		if anchor_texture:
			foot_y = float(anchor_texture.get_height()) * 0.5
	return Vector2(0, -foot_y + foot_contact_y)
