extends Node

## Rain/snow interaction on outdoor buildings — eave drips, ground splash, snow caps.
## Research: roof occlusion + runoff drip (Godot particle collision / PVFX drip runoff).

const NODE_NAME := "WeatherBuildingFx"


static func attach_to(host: Node2D) -> Node:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME)
	if existing:
		if existing.has_method("refresh"):
			existing.call("refresh")
		return existing
	var kit = load("res://scripts/world/weather_building_fx.gd").new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit.call("_boot")
	return kit


var _host: Node2D
var _fx_roots: Array[Node2D] = []


func _boot() -> void:
	_host = get_parent() as Node2D
	call_deferred("refresh")
	var t := get_tree().create_timer(0.2)
	t.timeout.connect(refresh)
	var env_state := _env()
	if env_state and not env_state.state_changed.is_connected(_on_env):
		env_state.state_changed.connect(_on_env)


func _env() -> Node:
	return get_node_or_null("/root/WorldEnvState")


func _on_env(_tg: int, _w: int, _s: int) -> void:
	_apply_weather()


func refresh() -> void:
	_clear_fx()
	if _host == null:
		return
	var ysort := WorldSpawnUtil.resolve_ysort(_host)
	if ysort == null:
		ysort = _host
	_scan(ysort)
	_apply_weather()


func _clear_fx() -> void:
	for n in _fx_roots:
		if n and is_instance_valid(n):
			n.queue_free()
	_fx_roots.clear()


func _scan(node: Node) -> void:
	if node is Sprite2D:
		_maybe_wire(node as Sprite2D)
	for c in node.get_children():
		_scan(c)


func _is_building_path(path: String) -> bool:
	var p := path.replace("\\", "/").to_lower()
	return "/buildings/" in p or p.ends_with("dock_house_00.png") or p.ends_with("lighthouse_00.png")


func _maybe_wire(spr: Sprite2D) -> void:
	if spr == null or spr.texture == null:
		return
	if not _is_building_path(str(spr.texture.resource_path)):
		return
	var parent := spr.get_parent() as Node2D
	if parent == null:
		return
	if parent.get_node_or_null("WeatherBuildingFxRoot") != null:
		return
	var root := Node2D.new()
	root.name = "WeatherBuildingFxRoot"
	parent.add_child(root)
	_fx_roots.append(root)

	var half_h := absf(spr.scale.y) * float(spr.texture.get_height()) * 0.5
	var half_w := absf(spr.scale.x) * float(spr.texture.get_width()) * 0.5
	var eave_y := spr.position.y - half_h * 0.72
	var ground_y := spr.position.y + half_h * 0.42

	var drip := _make_drip(Vector2(spr.position.x, eave_y), half_w * 0.7)
	root.add_child(drip)
	var splash := _make_splash(Vector2(spr.position.x, ground_y), half_w * 0.85)
	root.add_child(splash)
	var snow := _make_snow_cap(spr)
	root.add_child(snow)
	root.set_meta("drip", drip)
	root.set_meta("splash", splash)
	root.set_meta("snow", snow)
	root.set_meta("sprite", spr)


func _make_drip(pos: Vector2, half_w: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.name = "EaveDrip"
	p.emitting = false
	p.amount = 18
	p.lifetime = 0.55
	p.preprocess = 0.2
	p.explosiveness = 0.05
	p.randomness = 0.4
	p.direction = Vector2(0, 1)
	p.spread = 6.0
	p.gravity = Vector2(0, 380)
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 90.0
	p.scale_amount_min = 0.35
	p.scale_amount_max = 0.7
	p.color = Color(0.72, 0.82, 0.95, 0.7)
	p.position = pos
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(maxf(12.0, half_w), 2.0)
	p.texture = _dot_tex(Color(0.85, 0.9, 1.0, 0.9), 2, 4)
	return p


func _make_splash(pos: Vector2, half_w: float) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.name = "GroundSplash"
	p.emitting = false
	p.amount = 22
	p.lifetime = 0.35
	p.preprocess = 0.1
	p.explosiveness = 0.15
	p.randomness = 0.5
	p.direction = Vector2(0, -1)
	p.spread = 55.0
	p.gravity = Vector2(0, 220)
	p.initial_velocity_min = 25.0
	p.initial_velocity_max = 70.0
	p.scale_amount_min = 0.25
	p.scale_amount_max = 0.55
	p.color = Color(0.78, 0.86, 0.96, 0.55)
	p.position = pos
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(maxf(16.0, half_w), 4.0)
	p.texture = _dot_tex(Color(1, 1, 1, 0.85), 3, 3)
	return p


func _make_snow_cap(spr: Sprite2D) -> Sprite2D:
	## Lightweight snow band on building crown (Sprite2D so it lives in world space).
	var half_h := absf(spr.scale.y) * float(spr.texture.get_height()) * 0.5
	var half_w := absf(spr.scale.x) * float(spr.texture.get_width()) * 0.5
	var cap := Sprite2D.new()
	cap.name = "SnowCap"
	cap.texture = _dot_tex(Color(0.94, 0.97, 1.0, 1.0), 32, 8)
	cap.modulate = Color(1, 1, 1, 0)
	cap.centered = true
	cap.scale = Vector2(maxf(0.8, half_w / 16.0), maxf(0.45, half_h * 0.08 / 4.0))
	cap.position = Vector2(spr.position.x, spr.position.y - half_h * 0.78)
	cap.z_index = int(spr.z_index) + 1
	return cap


func _dot_tex(c: Color, w: int, h: int) -> ImageTexture:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(c)
	return ImageTexture.create_from_image(img)


func _apply_weather() -> void:
	var st := _env()
	var rain := false
	var snow := false
	if st:
		rain = int(st.weather) == int(st.WeatherKind.RAIN)
		snow = int(st.weather) == int(st.WeatherKind.SNOW)
	for root in _fx_roots:
		if root == null or not is_instance_valid(root):
			continue
		var drip: CPUParticles2D = root.get_meta("drip")
		var splash: CPUParticles2D = root.get_meta("splash")
		var snow_cap: Sprite2D = root.get_meta("snow")
		var spr: Sprite2D = root.get_meta("sprite")
		if drip:
			drip.emitting = rain
		if splash:
			splash.emitting = rain
		if snow_cap:
			snow_cap.modulate.a = 0.72 if snow else 0.0
		if spr:
			if snow:
				spr.modulate = Color(0.92, 0.95, 1.05)
			elif rain:
				spr.modulate = Color(0.88, 0.9, 0.95)
			else:
				spr.modulate = Color.WHITE
