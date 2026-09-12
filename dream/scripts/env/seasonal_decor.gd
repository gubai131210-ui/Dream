class_name SeasonalDecor
extends Node

## C55 — plaza seasonal decoration layer on A09 village_square (Env-H attach pattern).
## Not Autoload. Cycles 春/夏/秋/冬 via TopBar + key S. No new festival megamap.

const NODE_NAME := "SeasonalDecor"
const DEMO_OVERLAY_SETTING := "debug/show_demo_overlays"

enum Season { SPRING, SUMMER, AUTUMN, WINTER }

const SEASON_LABELS: Array[String] = ["春花", "夏海", "秋收", "冬雪"]

signal season_changed(season: int)

var _season: int = Season.SPRING
var _host: Node2D
var _layer: Node2D
var _grade: CanvasItem
var _particles: CPUParticles2D
var _btn_season: Button
var _status: Label


static func show_demo_overlay() -> bool:
	return bool(ProjectSettings.get_setting(DEMO_OVERLAY_SETTING, false))


static func attach_to(host: Node2D, top_bar: Control = null) -> SeasonalDecor:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as SeasonalDecor
	if existing:
		return existing
	var node := SeasonalDecor.new()
	node.name = NODE_NAME
	host.add_child(node)
	node.setup(host, top_bar)
	return node


func setup(host: Node2D, top_bar: Control = null) -> void:
	_host = host
	_layer = Node2D.new()
	_layer.name = "SeasonalDecorLayer"
	_layer.z_index = 3
	_layer.y_sort_enabled = true
	host.add_child(_layer)
	# Season props are gameplay art — always visible (S / TopBar still cycle).
	_layer.visible = true
	_ensure_grade_overlay()
	_ensure_particles()
	_rebuild()
	if top_bar:
		_mount_top_bar(top_bar)


func get_season() -> int:
	return _season


func set_season(season: int) -> void:
	_season = clampi(season, 0, 3)
	_rebuild()
	season_changed.emit(_season)


func cycle_season() -> void:
	_season = (_season + 1) % 4
	_rebuild()
	season_changed.emit(_season)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_S:
			cycle_season()
			get_viewport().set_input_as_handled()


func _mount_top_bar(top_bar: Control) -> void:
	_btn_season = top_bar.get_node_or_null("ToggleSeason") as Button
	if _btn_season == null:
		_btn_season = Button.new()
		_btn_season.name = "ToggleSeason"
		top_bar.add_child(_btn_season)
	if not _btn_season.pressed.is_connected(cycle_season):
		_btn_season.pressed.connect(cycle_season)
	_status = top_bar.get_node_or_null("SeasonStatus") as Label
	if _status == null:
		_status = Label.new()
		_status.name = "SeasonStatus"
		_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top_bar.add_child(_status)
	_refresh_button_labels()


func _ensure_grade_overlay() -> void:
	# Soft ColorRect grade — never add a second CanvasModulate (Env-H owns that).
	var layer := _host.get_node_or_null("SeasonalGradeLayer") as CanvasLayer
	if layer == null:
		layer = CanvasLayer.new()
		layer.name = "SeasonalGradeLayer"
		layer.layer = 7
		_host.add_child(layer)
	var rect := layer.get_node_or_null("Grade") as ColorRect
	if rect == null:
		rect = ColorRect.new()
		rect.name = "Grade"
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		rect.color = Color(1, 1, 1, 0)
		layer.add_child(rect)
	_grade = rect


func _ensure_particles() -> void:
	_particles = _layer.get_node_or_null("SeasonParticles") as CPUParticles2D
	if _particles:
		return
	_particles = CPUParticles2D.new()
	_particles.name = "SeasonParticles"
	_particles.emitting = false
	_particles.amount = 48
	_particles.lifetime = 3.2
	_particles.preprocess = 0.6
	_particles.explosiveness = 0.0
	_particles.randomness = 0.7
	_particles.texture = _make_flake_texture()
	_particles.direction = Vector2(0.1, 1.0)
	_particles.spread = 18.0
	_particles.gravity = Vector2(0, 28)
	_particles.initial_velocity_min = 12.0
	_particles.initial_velocity_max = 36.0
	_particles.scale_amount_min = 0.5
	_particles.scale_amount_max = 1.2
	_particles.position = Vector2(640, -20)
	_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_particles.emission_rect_extents = Vector2(700, 16)
	_layer.add_child(_particles)


func _make_flake_texture() -> ImageTexture:
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0.9))
	return ImageTexture.create_from_image(img)


func _rebuild() -> void:
	for c in _layer.get_children():
		if c == _particles:
			continue
		c.queue_free()
	_spawn_season_props()
	_apply_veil_and_particles()
	_refresh_button_labels()


func _spawn_season_props() -> void:
	match _season:
		Season.SPRING:
			_add_prop_cluster([
				{"path": "res://assets/sprites/props/flower_bed_00.png", "pos": Vector2(180, 360), "scale": 0.5},
				{"path": "res://assets/sprites/props/flower_bed_00.png", "pos": Vector2(240, 420), "scale": 0.45},
				{"path": "res://assets/sprites/props/herbs_00.png", "pos": Vector2(980, 340), "scale": 0.5},
				{"path": "res://assets/sprites/props/herbs_00.png", "pos": Vector2(1080, 400), "scale": 0.45},
			])
			_add_prop_banner(
				"res://assets/sprites/props/lantern_string_00.png",
				"春灯",
				Vector2(640, 220),
				0.55,
			)
		Season.SUMMER:
			_add_prop_cluster([
				{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(200, 520), "scale": 0.5},
				{"path": "res://assets/sprites/props/fountain_small.png", "pos": Vector2(320, 560), "scale": 0.45},
				{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(960, 540), "scale": 0.5},
				{"path": "res://assets/sprites/props/lantern_string_00.png", "pos": Vector2(1100, 500), "scale": 0.5},
			])
			_add_prop_banner(
				"res://assets/sprites/props/lantern_string_00.png",
				"夏浪饰",
				Vector2(640, 240),
				0.55,
			)
		Season.AUTUMN:
			_add_prop_cluster([
				{"path": "res://assets/sprites/props/grain_stack_00.png", "pos": Vector2(220, 380), "scale": 0.5},
				{"path": "res://assets/sprites/props/hay_stack_00.png", "pos": Vector2(300, 440), "scale": 0.5},
				{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(1000, 360), "scale": 0.5},
				{"path": "res://assets/sprites/props/fruit_crate_stack_00.png", "pos": Vector2(1120, 430), "scale": 0.45},
			])
			_add_prop_banner(
				"res://assets/sprites/props/grain_stack_00.png",
				"秋穗挂",
				Vector2(640, 230),
				0.5,
			)
		_:
			_add_prop_cluster([
				{"path": "res://assets/sprites/props/rock_01.png", "pos": Vector2(190, 400), "scale": 0.5, "mod": Color(0.85, 0.92, 1.0)},
				{"path": "res://assets/sprites/props/rock_03.png", "pos": Vector2(280, 460), "scale": 0.45, "mod": Color(0.88, 0.94, 1.0)},
				{"path": "res://assets/sprites/props/lamp_1.png", "pos": Vector2(990, 380), "scale": 0.5},
				{"path": "res://assets/sprites/props/lantern_string_00.png", "pos": Vector2(1090, 450), "scale": 0.5},
			])
			_add_prop_banner(
				"res://assets/sprites/props/lamp_2.png",
				"冬灯笼",
				Vector2(640, 220),
				0.55,
			)


func _add_prop_cluster(entries: Array) -> void:
	for i in entries.size():
		var e: Dictionary = entries[i]
		var path := str(e.get("path", ""))
		var pos: Vector2 = e.get("pos", Vector2.ZERO)
		var scale_f := float(e.get("scale", 0.5))
		var holder := Node2D.new()
		holder.name = "SeasonProp_%d" % i
		holder.position = pos
		_layer.add_child(holder)
		var spr := WorldSpawnUtil.attach_prop_sprite(holder, path, scale_f)
		if spr != null and e.has("mod"):
			spr.modulate = e["mod"] as Color


func _add_prop_banner(path: String, title: String, pos: Vector2, scale_f: float) -> void:
	var holder := Node2D.new()
	holder.name = "SeasonBanner"
	holder.position = pos
	_layer.add_child(holder)
	WorldSpawnUtil.attach_prop_sprite(holder, path, scale_f)
	var label := Label.new()
	label.text = "%s · %s" % [SEASON_LABELS[_season], title]
	label.position = Vector2(-70, -42)
	label.size = Vector2(140, 22)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color("#fff8e8"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(label)


func _add_cluster(_title: String, _color: Color, _positions: Array) -> void:
	## Legacy polygon clusters removed — use _add_prop_cluster.
	pass


func _add_banner(_title: String, _color: Color, _pos: Vector2) -> void:
	pass


func _apply_veil_and_particles() -> void:
	if _grade is ColorRect:
		var rect := _grade as ColorRect
		match _season:
			Season.SPRING:
				rect.color = Color(1.0, 0.78, 0.88, 0.08)
			Season.SUMMER:
				rect.color = Color(0.55, 0.82, 1.0, 0.07)
			Season.AUTUMN:
				rect.color = Color(1.0, 0.7, 0.35, 0.09)
			_:
				rect.color = Color(0.75, 0.88, 1.0, 0.12)
	if _particles:
		match _season:
			Season.SPRING:
				_particles.emitting = true
				_particles.color = Color(1.0, 0.72, 0.86, 0.75)
				_particles.gravity = Vector2(8, 22)
			Season.SUMMER:
				_particles.emitting = false
			Season.AUTUMN:
				_particles.emitting = true
				_particles.color = Color(0.95, 0.55, 0.2, 0.7)
				_particles.gravity = Vector2(20, 40)
			_:
				_particles.emitting = true
				_particles.color = Color(0.92, 0.96, 1.0, 0.85)
				_particles.gravity = Vector2(4, 55)


func _refresh_button_labels() -> void:
	var label: String = SEASON_LABELS[_season]
	if _btn_season:
		_btn_season.visible = true
		_btn_season.text = label
		_btn_season.tooltip_text = "循环季节 (S)：春花→夏海→秋收→冬雪"
	if _status:
		_status.visible = true
		_status.text = "季节·%s" % label
