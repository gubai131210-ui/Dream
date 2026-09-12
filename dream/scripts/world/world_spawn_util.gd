class_name WorldSpawnUtil
extends RefCounted

## Shared hotspot / portal makers for WorldSys (C58–C62). Runtime visuals only.

const INTERACTION_MARKERS_SETTING := "debug/show_interaction_markers"


static func show_debug_markers() -> bool:
	# Marker diamonds/tags are editor scaffolding, not part of the game art.
	# Keep the opt-in setting so layout work can still enable them deliberately.
	return bool(ProjectSettings.get_setting(INTERACTION_MARKERS_SETTING, false))


static func make_hotspot(
	parent: Node2D,
	title: String,
	desc: String,
	pos: Vector2,
	size: Vector2,
	marker_color: Color = Color(0.85, 0.75, 0.35, 0.9),
	sprite_path: String = "",
	sprite_scale: float = 0.55,
) -> InteractableHotspot:
	var hs := InteractableHotspot.new()
	hs.name = "WorldHS_%s" % title.replace(" ", "")
	hs.title = title
	hs.description = desc
	hs.position = pos
	hs.prompt_text = "互动"
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	hs.add_child(shape)
	var visual := Node2D.new()
	visual.name = "Visual"
	var poly := Polygon2D.new()
	poly.name = "Marker"
	poly.color = marker_color
	var hx := size.x * 0.28
	var hy := size.y * 0.28
	poly.polygon = PackedVector2Array([
		Vector2(0, -hy),
		Vector2(hx, 0),
		Vector2(0, hy),
		Vector2(-hx, 0),
	])
	poly.visible = show_debug_markers()
	visual.add_child(poly)
	var tag := Label.new()
	tag.name = "Tag"
	tag.text = title
	tag.position = Vector2(-size.x * 0.45, -size.y * 0.55)
	tag.size = Vector2(size.x * 0.9, 18)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 11)
	tag.add_theme_color_override("font_color", Color("#fff8e0"))
	tag.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	tag.add_theme_constant_override("shadow_offset_x", 1)
	tag.add_theme_constant_override("shadow_offset_y", 1)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.visible = show_debug_markers()
	visual.add_child(tag)
	if not sprite_path.is_empty():
		attach_prop_sprite(visual, sprite_path, sprite_scale)
	hs.add_child(visual)
	parent.add_child(hs)
	return hs


## Feet-anchored outdoor prop (Nearest). Skips quietly if path missing.
## Prefer imported texture only when `.ctex` exists; else raw PNG (avoids import ERROR spam).
static func attach_prop_sprite(visual: Node2D, path: String, scale_f: float = 0.55) -> Sprite2D:
	if visual == null or path.is_empty():
		return null
	var abs_path := ProjectSettings.globalize_path(path)
	var tex: Texture2D = null
	var can_use_import := false
	var import_path := abs_path + ".import"
	if FileAccess.file_exists(import_path):
		var cfg := ConfigFile.new()
		if cfg.load(import_path) == OK:
			var dest := str(cfg.get_value("remap", "path", ""))
			if not dest.is_empty():
				can_use_import = FileAccess.file_exists(ProjectSettings.globalize_path(dest))
	if can_use_import:
		tex = load(path) as Texture2D
	if tex == null and FileAccess.file_exists(abs_path):
		var img := Image.load_from_file(abs_path)
		if img != null:
			tex = ImageTexture.create_from_image(img)
	if tex == null:
		push_warning("WorldSpawnUtil: failed load %s" % path)
		return null
	var shadow := Polygon2D.new()
	shadow.name = "ContactShadow"
	shadow.color = Color(0, 0, 0, 0.22)
	shadow.polygon = PackedVector2Array([
		Vector2(-12, 0), Vector2(0, -4), Vector2(12, 0), Vector2(0, 4),
	])
	shadow.position = Vector2(0, 6)
	shadow.z_index = -1
	visual.add_child(shadow)
	var spr := Sprite2D.new()
	spr.name = "PropSprite"
	spr.texture = tex
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.scale = Vector2(scale_f, scale_f)
	var h := float(tex.get_height()) * scale_f
	spr.position = Vector2(0, -h * 0.5 + 4.0)
	spr.z_index = 1
	visual.add_child(spr)
	return spr


static func make_portal(
	parent: Node2D,
	title: String,
	scene_path: String,
	pos: Vector2,
	size: Vector2 = Vector2(88, 52),
	marker_color: Color = Color(0.55, 0.82, 0.95, 0.9),
) -> Area2D:
	var area := Area2D.new()
	area.name = "WorldPortal_%s" % title.replace(" ", "")
	area.position = pos
	area.input_pickable = true
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	area.add_child(shape)
	var cue := Polygon2D.new()
	cue.name = "DoorstepCue"
	cue.color = Color(0.55, 0.85, 0.95, 0.4)
	var hw := size.x * 0.22
	cue.polygon = PackedVector2Array([
		Vector2(-hw, 4), Vector2(hw, 4), Vector2(hw * 0.7, 14), Vector2(-hw * 0.7, 14),
	])
	cue.position = Vector2(0, size.y * 0.12)
	cue.z_index = -1
	area.add_child(cue)
	var arch := Polygon2D.new()
	arch.name = "DoorArchCue"
	arch.color = Color(0.65, 0.9, 1.0, 0.38)
	arch.polygon = PackedVector2Array([
		Vector2(-10, 2), Vector2(10, 2), Vector2(8, -16), Vector2(0, -22), Vector2(-8, -16),
	])
	arch.position = Vector2(0, -size.y * 0.18)
	area.add_child(arch)
	var hint := Polygon2D.new()
	hint.name = "PortalMarker"
	hint.color = marker_color
	hint.polygon = PackedVector2Array([
		Vector2(0, -10),
		Vector2(12, 0),
		Vector2(0, 10),
		Vector2(-12, 0),
	])
	hint.position = Vector2(0, -size.y * 0.22)
	hint.visible = show_debug_markers()
	area.add_child(hint)
	var label := Label.new()
	label.name = "PortalLabel"
	label.text = title
	label.position = Vector2(-size.x * 0.5, -size.y * 0.5 - 10)
	label.size = Vector2(size.x, 22)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color("#e8fbff"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_font_size_override("font_size", 12)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.visible = show_debug_markers()
	area.add_child(label)
	area.mouse_entered.connect(func():
		label.visible = true
		cue.modulate = Color(1.15, 1.2, 1.25, 1.0)
		arch.modulate = Color(1.2, 1.25, 1.3, 1.0)
	)
	area.mouse_exited.connect(func():
		label.visible = show_debug_markers()
		cue.modulate = Color.WHITE
		arch.modulate = Color.WHITE
	)
	var pulse := arch.create_tween().set_loops()
	pulse.tween_property(arch, "modulate:a", 0.22, 0.8).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(arch, "modulate:a", 0.55, 0.8).set_trans(Tween.TRANS_SINE)
	if show_debug_markers():
		var pulse_m := hint.create_tween().set_loops()
		pulse_m.tween_property(hint, "modulate:a", 0.4, 0.7).set_trans(Tween.TRANS_SINE)
		pulse_m.tween_property(hint, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	area.set_meta("scene_path", scene_path)
	area.set_meta("worldsys_secret", true)
	parent.add_child(area)
	return area


static func wire_portal_click(area: Area2D, tree: SceneTree) -> void:
	if area == null or tree == null:
		return
	if area.has_meta("_worldsys_portal_wired"):
		return
	area.set_meta("_worldsys_portal_wired", true)
	area.input_event.connect(func(_vp: Node, event: InputEvent, _si: int) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var path := str(area.get_meta("scene_path", ""))
			if not path.is_empty():
				SceneRouter.change_to(tree, path)
	)


static func resolve_ysort(host: Node2D) -> Node2D:
	if host == null:
		return null
	var ysort := host.get_node_or_null("YSortRoot") as Node2D
	if ysort:
		return ysort
	var world := host.get_node_or_null("InteriorWorld") as Node2D
	if world:
		return world
	return host


static func resolve_info(host: Node) -> InfoPanel:
	if host == null:
		return null
	var info := host.get_node_or_null("InfoPanel") as InfoPanel
	if info:
		return info
	return host.get_node_or_null("InfoLayer") as InfoPanel
