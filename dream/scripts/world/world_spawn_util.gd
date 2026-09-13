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


## Prefer imported texture only when `.ctex` exists; else raw PNG (avoids import ERROR spam).
static func load_prop_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	var abs_path := ProjectSettings.globalize_path(path)
	var can_use_import := false
	var import_path := abs_path + ".import"
	if FileAccess.file_exists(import_path):
		var cfg := ConfigFile.new()
		if cfg.load(import_path) == OK:
			var dest := str(cfg.get_value("remap", "path", ""))
			if not dest.is_empty():
				can_use_import = FileAccess.file_exists(ProjectSettings.globalize_path(dest))
	var tex: Texture2D = null
	if can_use_import:
		tex = load(path) as Texture2D
	if tex == null and FileAccess.file_exists(abs_path):
		var img := Image.load_from_file(abs_path)
		if img != null:
			tex = ImageTexture.create_from_image(img)
			# Preserve path for QA/smokes when import cache is stale after art regen.
			if tex != null:
				tex.take_over_path(path)
	return tex


## Feet-anchored outdoor prop (Nearest). Skips quietly if path missing.
static func attach_prop_sprite(visual: Node2D, path: String, scale_f: float = 0.55) -> Sprite2D:
	if visual == null or path.is_empty():
		return null
	var tex := load_prop_texture(path)
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
	var sway_kind := WindSway.kind_for_path(path)
	if not sway_kind.is_empty():
		WindSway.attach(spr, sway_kind)
	return spr


const DOORSTEP_MAT := "res://assets/sprites/props/doorstep_mat_00.png"
const DOOR_ARCH_CUE := "res://assets/sprites/props/door_arch_cue_00.png"
const DOOR_FACADE := "res://assets/sprites/props/door_facade_00.png"


## Always-visible portal doorstep + arch + façade sprites (G8).
## Returns { "cue": CanvasItem, "arch": CanvasItem, "facade": CanvasItem }.
static func attach_portal_cues(area: Area2D, size: Vector2, facade_path: String = DOOR_FACADE) -> Dictionary:
	var out := {"cue": null, "arch": null, "facade": null}
	if area == null:
		return out
	var facade_tex := load_prop_texture(facade_path if not facade_path.is_empty() else DOOR_FACADE)
	if facade_tex != null:
		var spr_f := Sprite2D.new()
		spr_f.name = "DoorFacade"
		spr_f.texture = facade_tex
		spr_f.set_meta("facade_path", facade_path if not facade_path.is_empty() else DOOR_FACADE)
		spr_f.centered = true
		spr_f.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var target_h := maxf(size.y * 0.95, 36.0)
		var sy := target_h / float(facade_tex.get_height())
		spr_f.scale = Vector2(sy, sy)
		spr_f.position = Vector2(0, -size.y * 0.12)
		spr_f.z_index = -2
		area.add_child(spr_f)
		out["facade"] = spr_f
	var mat_tex := load_prop_texture(DOORSTEP_MAT)
	var arch_tex := load_prop_texture(DOOR_ARCH_CUE)
	var cue: CanvasItem
	if mat_tex != null:
		var spr := Sprite2D.new()
		spr.name = "DoorstepCue"
		spr.texture = mat_tex
		spr.centered = true
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var target_w := maxf(size.x * 0.55, 28.0)
		var sx := target_w / float(mat_tex.get_width())
		spr.scale = Vector2(sx, sx)
		spr.position = Vector2(0, size.y * 0.22)
		spr.z_index = -1
		area.add_child(spr)
		cue = spr
	else:
		push_error("WorldSpawnUtil: missing doorstep_mat (Polygon2D doorstep forbidden)")
		cue = null
	var arch: CanvasItem
	if arch_tex != null:
		var spr_a := Sprite2D.new()
		spr_a.name = "DoorArchCue"
		spr_a.texture = arch_tex
		spr_a.centered = true
		spr_a.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var target_ha := maxf(size.y * 0.55, 22.0)
		var sya := target_ha / float(arch_tex.get_height())
		spr_a.scale = Vector2(sya, sya)
		spr_a.position = Vector2(0, -size.y * 0.28)
		spr_a.z_index = 1
		area.add_child(spr_a)
		arch = spr_a
	else:
		push_error("WorldSpawnUtil: missing door_arch_cue (Polygon2D arch forbidden)")
		arch = null
	out["cue"] = cue
	out["arch"] = arch
	return out


static func make_portal(
	parent: Node2D,
	title: String,
	scene_path: String,
	pos: Vector2,
	size: Vector2 = Vector2(88, 52),
	marker_color: Color = Color(0.55, 0.82, 0.95, 0.9),
	facade_path: String = "",
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
	var cues := attach_portal_cues(area, size, facade_path if not facade_path.is_empty() else DOOR_FACADE)
	var cue: CanvasItem = cues.get("cue")
	var arch: CanvasItem = cues.get("arch")
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
		if cue:
			cue.modulate = Color(1.15, 1.2, 1.25, 1.0)
		if arch:
			arch.modulate = Color(1.2, 1.25, 1.3, 1.0)
	)
	area.mouse_exited.connect(func():
		label.visible = show_debug_markers()
		if cue:
			cue.modulate = Color.WHITE
		if arch:
			arch.modulate = Color.WHITE
	)
	# No always-on arch pulse — hover brighten above is the only door affordance pulse.
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
			var sr := tree.root.get_node_or_null("SpawnRegistry")
			if sr and bool(sr.call("portal_grace_active")):
				return
			var path := str(area.get_meta("scene_path", ""))
			if path.is_empty():
				return
			var sid := str(area.get_meta("spawn_id", ""))
			SceneRouter.change_to(tree, path, sid)
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


static func radial_light_texture(size_px: int = 256) -> GradientTexture2D:
	## Soft radial falloff — cozy pool, not a blown-out stage spotlight.
	var grad := Gradient.new()
	# Peak quickly then fall off; avoid a large flat white core.
	grad.colors = PackedColorArray([
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0.32),
		Color(1, 1, 1, 0),
	])
	grad.offsets = PackedFloat32Array([0.0, 0.18, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = size_px
	tex.height = size_px
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	return tex


static func configure_lamp_light(
	light: PointLight2D,
	color: Color = Color(1.0, 0.82, 0.52, 1.0),
	energy: float = 1.55,
	tex_scale: float = 1.05,
	size_px: int = 256,
) -> void:
	if light == null:
		return
	light.color = color
	light.energy = energy
	light.texture_scale = tex_scale
	light.texture = radial_light_texture(size_px)
	light.range_item_cull_mask = 1
	light.shadow_enabled = false


## Outdoor street-lamp defaults (CanvasModulate multiplies light — compensate, but keep cozy).
## Target: readable warm pool around the post, not a washed-out half-screen spotlight.
const LAMP_ENERGY_NIGHT := 1.55
const LAMP_ENERGY_DAY := 0.18
const LAMP_TEX_SCALE := 1.05
const LAMP_TEX_SIZE := 256
const LAMP_SPRITE_SCALE := 1.15
const LAMP_LIGHT_OFFSET := Vector2(8, -40)
