class_name DayNightWeather
extends Node

## Env-H outdoor night grade + weather overlay (scene-local visual).
## Source of truth: Autoload WorldEnvState — survives map changes.

const NODE_NAME := "DayNightWeather"
const OWNED_MODULATE_NAME := "EnvDayNightModulate"
const RAIN_LAYER_NAME := "EnvWeatherOverlay"

enum TimeGrade { DAY, NIGHT }
enum WeatherKind { CLEAR, RAIN, SNOW, FOG }

signal state_changed(time_grade: int, weather: int)

@export var night_color: Color = Color(0.28, 0.32, 0.48, 1.0)
@export var rain_veil_color: Color = Color(0.42, 0.52, 0.70, 0.22)
@export var snow_veil_color: Color = Color(0.78, 0.84, 0.92, 0.28)
@export var fog_veil_color: Color = Color(0.72, 0.76, 0.82, 0.35)

var time_grade: TimeGrade = TimeGrade.DAY
var weather: WeatherKind = WeatherKind.CLEAR

var _host: Node2D
var _modulate: CanvasModulate
var _owns_modulate: bool = false
var _day_baseline: Color = Color.WHITE
var _rain_layer: CanvasLayer
var _veil: ColorRect
var _rain: CPUParticles2D
var _snow: CPUParticles2D
var _btn_night: Button
var _btn_weather: Button
var _lamp_forced_night: bool = false
var _syncing: bool = false


static func find_on(host: Node) -> DayNightWeather:
	if host == null:
		return null
	return host.get_node_or_null(NODE_NAME) as DayNightWeather


static func attach_to(host: Node2D, top_bar: Control = null) -> DayNightWeather:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as DayNightWeather
	if existing:
		existing._pull_global()
		existing._apply_visuals()
		for path in [
			"res://scripts/world/outdoor_lamp_kit.gd",
			"res://scripts/world/weather_building_fx.gd",
			"res://scripts/world/map_travel_kit.gd",
		]:
			var scr = load(path)
			if scr and scr.has_method("attach_to"):
				scr.attach_to(host)
		return existing
	var env := DayNightWeather.new()
	env.name = NODE_NAME
	host.add_child(env)
	env.bind_host(host)
	# Immersive play: no TopBar chrome; keyboard N/R only.
	if top_bar and bool(Engine.get_meta("dream_show_env_buttons", false)):
		env.mount_top_bar(top_bar)
	# Street lamps / weather buildings / keyboard travel — load() to avoid class_cache stalls.
	for path in [
		"res://scripts/world/outdoor_lamp_kit.gd",
		"res://scripts/world/weather_building_fx.gd",
		"res://scripts/world/map_travel_kit.gd",
	]:
		var scr = load(path)
		if scr and scr.has_method("attach_to"):
			scr.attach_to(host)
	return env


func bind_host(host: Node2D) -> void:
	_host = host
	_resolve_modulate()
	_ensure_weather_overlay()
	_pull_global()
	_apply_visuals()
	var st := _global()
	if st and not st.state_changed.is_connected(_on_global):
		st.state_changed.connect(_on_global)
	call_deferred("_kick_schedule")


func _kick_schedule() -> void:
	var sd := get_node_or_null("/root/ScheduleDirector")
	if sd and sd.has_method("apply_to_current_scene"):
		sd.apply_to_current_scene()


func _global() -> Node:
	return get_node_or_null("/root/WorldEnvState")


func _on_global(tg: int, w: int, _season: int) -> void:
	if _syncing:
		return
	_syncing = true
	time_grade = tg as TimeGrade
	weather = w as WeatherKind
	_apply_visuals()
	state_changed.emit(time_grade, weather)
	_broadcast_motion_refresh()
	_syncing = false
	var sd := get_node_or_null("/root/ScheduleDirector")
	if sd and sd.has_method("apply_to_current_scene"):
		sd.apply_to_current_scene()


func _pull_global() -> void:
	var st := _global()
	if st == null:
		return
	time_grade = int(st.time_grade) as TimeGrade
	weather = int(st.weather) as WeatherKind
	_lamp_forced_night = bool(st.lamp_forced_night)


func _push_global() -> void:
	if _syncing:
		return
	var st := _global()
	if st == null:
		return
	_syncing = true
	st.time_grade = time_grade
	st.weather = weather
	st.lamp_forced_night = _lamp_forced_night
	st.state_changed.emit(int(st.time_grade), int(st.weather), int(st.season))
	_syncing = false


func mount_top_bar(top_bar: Control) -> void:
	if top_bar == null:
		return
	_btn_night = top_bar.get_node_or_null("ToggleNight") as Button
	if _btn_night == null:
		_btn_night = Button.new()
		_btn_night.name = "ToggleNight"
		top_bar.add_child(_btn_night)
	_btn_weather = top_bar.get_node_or_null("ToggleWeather") as Button
	if _btn_weather == null:
		_btn_weather = Button.new()
		_btn_weather.name = "ToggleWeather"
		top_bar.add_child(_btn_weather)
	if not _btn_night.pressed.is_connected(_on_night_pressed):
		_btn_night.pressed.connect(_on_night_pressed)
	if not _btn_weather.pressed.is_connected(_on_weather_pressed):
		_btn_weather.pressed.connect(_on_weather_pressed)
	_refresh_button_labels()


func toggle_night() -> void:
	time_grade = TimeGrade.DAY if time_grade == TimeGrade.NIGHT else TimeGrade.NIGHT
	if time_grade == TimeGrade.DAY:
		_lamp_forced_night = false
	_push_global()
	_apply_visuals()
	state_changed.emit(time_grade, weather)
	_broadcast_motion_refresh()


func set_time_grade(grade: TimeGrade) -> void:
	time_grade = grade
	if grade == TimeGrade.DAY:
		_lamp_forced_night = false
	_push_global()
	_apply_visuals()
	state_changed.emit(time_grade, weather)
	_broadcast_motion_refresh()


func cycle_weather() -> void:
	match weather:
		WeatherKind.CLEAR:
			weather = WeatherKind.RAIN
		WeatherKind.RAIN:
			weather = WeatherKind.SNOW
		WeatherKind.SNOW:
			weather = WeatherKind.FOG
		_:
			weather = WeatherKind.CLEAR
	_push_global()
	_apply_visuals()
	state_changed.emit(time_grade, weather)
	_broadcast_motion_refresh()


func set_weather(kind: WeatherKind) -> void:
	weather = kind
	_push_global()
	_apply_visuals()
	state_changed.emit(time_grade, weather)
	_broadcast_motion_refresh()


func _broadcast_motion_refresh() -> void:
	if get_tree() == null:
		return
	for n in get_tree().get_nodes_in_group("patrol_actors"):
		if n != null and n.has_method("refresh_motion_policy"):
			n.refresh_motion_policy()
	for n in get_tree().get_nodes_in_group("player"):
		if n != null and n.has_method("_refresh_motion_policy"):
			n._refresh_motion_policy()


func mcp_set_night(on: bool) -> Dictionary:
	set_time_grade(TimeGrade.NIGHT if on else TimeGrade.DAY)
	return {
		"ok": true,
		"night": time_grade == TimeGrade.NIGHT,
		"time_grade": int(time_grade),
		"weather": int(weather),
		"has_modulate": _modulate != null,
	}


func is_night() -> bool:
	return time_grade == TimeGrade.NIGHT


func pulse_dusk_for_lamps() -> Dictionary:
	if time_grade == TimeGrade.NIGHT:
		return {"ok": true, "pulsed": false, "reason": "already_night", "lamp_forced": _lamp_forced_night}
	set_time_grade(TimeGrade.NIGHT)
	_lamp_forced_night = true
	_push_global()
	var after_r := -1.0
	var mod := _live_modulate()
	if mod:
		after_r = mod.color.r
	return {
		"ok": true,
		"pulsed": true,
		"mode": "sticky_night",
		"night": true,
		"lamp_forced": true,
		"after_r": after_r,
	}


func restore_day_from_lamps() -> Dictionary:
	if not _lamp_forced_night:
		return {"ok": true, "restored": false, "reason": "not_lamp_forced", "night": is_night()}
	_lamp_forced_night = false
	set_time_grade(TimeGrade.DAY)
	return {"ok": true, "restored": true, "night": false, "time_grade": int(time_grade)}


func _live_modulate() -> CanvasModulate:
	if _host != null:
		var named := _host.get_node_or_null(OWNED_MODULATE_NAME) as CanvasModulate
		if named:
			return named
		for child in _host.get_children():
			if child is CanvasModulate:
				return child as CanvasModulate
	return _modulate


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_N:
				toggle_night()
				get_viewport().set_input_as_handled()
			KEY_R:
				cycle_weather()
				get_viewport().set_input_as_handled()


func _on_night_pressed() -> void:
	toggle_night()


func _on_weather_pressed() -> void:
	cycle_weather()


func _resolve_modulate() -> void:
	var found: CanvasModulate = null
	for child in _host.get_children():
		if child is CanvasModulate:
			found = child as CanvasModulate
			break
	if found:
		_modulate = found
		_owns_modulate = false
		_day_baseline = found.color
		return
	_modulate = CanvasModulate.new()
	_modulate.name = OWNED_MODULATE_NAME
	_modulate.color = Color.WHITE
	_host.add_child(_modulate)
	_owns_modulate = true
	_day_baseline = Color.WHITE


func _ensure_weather_overlay() -> void:
	_rain_layer = _host.get_node_or_null(RAIN_LAYER_NAME) as CanvasLayer
	if _rain_layer == null:
		_rain_layer = CanvasLayer.new()
		_rain_layer.name = RAIN_LAYER_NAME
		_rain_layer.layer = 8
		_host.add_child(_rain_layer)
	_veil = _rain_layer.get_node_or_null("Veil") as ColorRect
	if _veil == null:
		_veil = ColorRect.new()
		_veil.name = "Veil"
		_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_veil.color = Color(1, 1, 1, 0)
		_rain_layer.add_child(_veil)
	_rain = _rain_layer.get_node_or_null("Rain") as CPUParticles2D
	if _rain == null:
		_rain = CPUParticles2D.new()
		_rain.name = "Rain"
		_rain.emitting = false
		_rain.amount = 120
		_rain.lifetime = 0.9
		_rain.preprocess = 0.4
		_rain.explosiveness = 0.0
		_rain.randomness = 0.55
		_rain.texture = _make_streak_texture()
		_rain.direction = Vector2(0.15, 1.0)
		_rain.spread = 8.0
		_rain.gravity = Vector2(40.0, 520.0)
		_rain.initial_velocity_min = 220.0
		_rain.initial_velocity_max = 380.0
		_rain.scale_amount_min = 0.6
		_rain.scale_amount_max = 1.3
		_rain.color = Color(0.75, 0.82, 0.95, 0.55)
		_rain.position = Vector2(640, -40)
		_rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		_rain.emission_rect_extents = Vector2(720, 20)
		_rain_layer.add_child(_rain)
	_snow = _rain_layer.get_node_or_null("Snow") as CPUParticles2D
	if _snow == null:
		_snow = CPUParticles2D.new()
		_snow.name = "Snow"
		_snow.emitting = false
		_snow.amount = 90
		_snow.lifetime = 2.4
		_snow.preprocess = 0.8
		_snow.randomness = 0.7
		_snow.texture = _make_flake_texture()
		_snow.direction = Vector2(0.05, 1.0)
		_snow.spread = 18.0
		_snow.gravity = Vector2(12.0, 48.0)
		_snow.initial_velocity_min = 28.0
		_snow.initial_velocity_max = 55.0
		_snow.scale_amount_min = 0.5
		_snow.scale_amount_max = 1.2
		_snow.color = Color(0.95, 0.97, 1.0, 0.75)
		_snow.position = Vector2(640, -40)
		_snow.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		_snow.emission_rect_extents = Vector2(720, 20)
		_rain_layer.add_child(_snow)


func _make_streak_texture() -> ImageTexture:
	var img := Image.create(2, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0.85))
	return ImageTexture.create_from_image(img)


func _make_flake_texture() -> ImageTexture:
	var img := Image.create(3, 3, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0.9))
	return ImageTexture.create_from_image(img)


func _apply_visuals() -> void:
	var mod := _live_modulate()
	if mod:
		_modulate = mod
		if time_grade == TimeGrade.NIGHT:
			mod.color = _day_baseline * night_color
		else:
			mod.color = _day_baseline
	if _veil:
		match weather:
			WeatherKind.RAIN:
				_veil.color = rain_veil_color
			WeatherKind.SNOW:
				_veil.color = snow_veil_color
			WeatherKind.FOG:
				_veil.color = fog_veil_color
			_:
				_veil.color = Color(1, 1, 1, 0)
	if _rain:
		_rain.emitting = weather == WeatherKind.RAIN
	if _snow:
		_snow.emitting = weather == WeatherKind.SNOW
	_refresh_button_labels()


func _refresh_button_labels() -> void:
	if _btn_night:
		_btn_night.text = "夜间" if time_grade == TimeGrade.NIGHT else "白天"
		_btn_night.tooltip_text = "切换昼夜 (N)"
	if _btn_weather:
		match weather:
			WeatherKind.RAIN:
				_btn_weather.text = "雨"
			WeatherKind.SNOW:
				_btn_weather.text = "雪"
			WeatherKind.FOG:
				_btn_weather.text = "雾"
			_:
				_btn_weather.text = "晴"
		_btn_weather.tooltip_text = "循环天气 (R)：晴→雨→雪→雾"
