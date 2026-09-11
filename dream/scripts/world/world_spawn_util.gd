class_name WorldSpawnUtil
extends RefCounted

## Shared hotspot / portal makers for WorldSys (C58–C62). Runtime visuals only.


static func make_hotspot(
	parent: Node2D,
	title: String,
	desc: String,
	pos: Vector2,
	size: Vector2,
	marker_color: Color = Color(0.85, 0.75, 0.35, 0.9),
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
	visual.add_child(tag)
	hs.add_child(visual)
	parent.add_child(hs)
	return hs


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
	area.add_child(label)
	var pulse := hint.create_tween().set_loops()
	pulse.tween_property(hint, "modulate:a", 0.4, 0.7).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(hint, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
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
