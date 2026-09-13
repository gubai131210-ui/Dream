class_name DayNightWeather
extends Node

## Env-H / C56–C57 outdoor night grade + weather overlay (scene-local Node).
## Not an Autoload — mount per outdoor scene so interiors stay untouched.
## Forest_deep: apply-if-present on existing CanvasModulate; never free CanopyTint.

const NODE_NAME := "DayNightWeather"
const OWNED_MODULATE_NAME := "EnvDayNightModulate"
const RAIN_LAYER_NAME := "EnvWeatherOverlay"

enum TimeGrade { DAY, NIGHT }
enum WeatherKind { CLEAR, RAIN, FOG }

signal state_changed(time_grade: int, weather: int)

@export var night_color: Color = Color(0.30, 0.36, 0.58, 1.0)
@export var rain_veil_color: Color = Color(0.42, 0.52, 0.70, 0.22)
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
var _btn_night: Button
var _btn_weather: Button
var _dusk_pulse_token: int = 0
var _dusk_pulse_tween: Tween
var _dusk_hold_until_msec: int = 0
var _dusk_hold_color: Color = Color(0.50, 0.54, 0.68, 1.0)
var _restore_timer: Timer


static func find_on(host: Node) -> DayNightWeather:
	if host == null:
		return null
	return host.get_node_or_null(NODE_NAME) as DayNightWeather


static func attach_to(host: Node2D, top_bar: Control = null) -> DayNightWeather:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as DayNightWeather
	if existing:
		return existing
	var env := DayNightWeather.new()
	env.name = NODE_NAME
	host.add_child(env)
	env.bind_host(host)
	if top_bar:
		env.mount_top_bar(top_bar)
	return env


func bind_host(host: Node2D) -> void:
	_host = host
	_resolve_modulate()
	_ensure_weather_overlay()
	_apply_visuals()


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
	_cancel_dusk_pulse()
	time_grade = TimeGrade.DAY if time_grade == TimeGrade.NIGHT else TimeGrade.NIGHT
	_apply_visuals()
	state_changed.emit(time_grade, weather)


func cycle_weather() -> void:
	match weather:
		WeatherKind.CLEAR:
			weather = WeatherKind.RAIN
		WeatherKind.RAIN:
			weather = WeatherKind.FOG
		_:
			weather = WeatherKind.CLEAR
	_apply_visuals()
	state_changed.emit(time_grade, weather)


func set_time_grade(grade: TimeGrade) -> void:
	_cancel_dusk_pulse()
	time_grade = grade
	_apply_visuals()
	state_changed.emit(time_grade, weather)


func set_weather(kind: WeatherKind) -> void:
	weather = kind
	_apply_visuals()
	state_changed.emit(time_grade, weather)


func mcp_set_night(on: bool) -> Dictionary:
	## Sync MCP probe: force day/night grade for lamp-glow / Env-H evidence.
	_cancel_dusk_pulse()
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
	## Daytime lamp-on: switch to sticky night grade (same path as mcp_set_night).
	## Player returns to day with N / 白天 button — no auto-restore timer (was racing).
	if time_grade == TimeGrade.NIGHT:
		return {"ok": true, "pulsed": false, "reason": "already_night"}
	set_time_grade(TimeGrade.NIGHT)
	var after_r := -1.0
	var mod := _live_modulate()
	if mod:
		after_r = mod.color.r
	return {
		"ok": true,
		"pulsed": true,
		"mode": "sticky_night",
		"night": true,
		"after_r": after_r,
		"hint": "press_N_for_day",
	}


func _live_modulate() -> CanvasModulate:
	if _host != null:
		var named := _host.get_node_or_null(OWNED_MODULATE_NAME) as CanvasModulate
		if named:
			return named
		for child in _host.get_children():
			if child is CanvasModulate:
				return child as CanvasModulate
	return _modulate


func _cancel_dusk_pulse() -> void:
	_dusk_pulse_token += 1
	_dusk_hold_until_msec = 0
	set_process(false)
	if _restore_timer != null and is_instance_valid(_restore_timer):
		_restore_timer.stop()
		_restore_timer.queue_free()
	_restore_timer = null
	if _dusk_pulse_tween and _dusk_pulse_tween.is_valid():
		_dusk_pulse_tween.kill()
	_dusk_pulse_tween = null


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
	# Prefer an existing scene modulate (e.g. forest_deep CanopyTint) — apply-if-present.
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


func _make_streak_texture() -> ImageTexture:
	var img := Image.create(2, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0.85))
	return ImageTexture.create_from_image(img)


func _apply_visuals() -> void:
	var mod := _live_modulate()
	if mod:
		_modulate = mod
		if time_grade == TimeGrade.NIGHT:
			# Night grade over baseline (keeps forest canopy relative cool if present).
			mod.color = _day_baseline * night_color
		elif Time.get_ticks_msec() < _dusk_hold_until_msec:
			# Keep lamp dusk preview even if something re-applies day visuals.
			mod.color = _day_baseline * _dusk_hold_color
		else:
			mod.color = _day_baseline
	if _veil:
		match weather:
			WeatherKind.RAIN:
				_veil.color = rain_veil_color
			WeatherKind.FOG:
				_veil.color = fog_veil_color
			_:
				_veil.color = Color(1, 1, 1, 0)
	if _rain:
		_rain.emitting = weather == WeatherKind.RAIN
	_refresh_button_labels()


func _refresh_button_labels() -> void:
	if _btn_night:
		_btn_night.text = "夜间" if time_grade == TimeGrade.NIGHT else "白天"
		_btn_night.tooltip_text = "切换昼夜 (N)"
	if _btn_weather:
		match weather:
			WeatherKind.RAIN:
				_btn_weather.text = "雨"
			WeatherKind.FOG:
				_btn_weather.text = "雾"
			_:
				_btn_weather.text = "晴"
		_btn_weather.tooltip_text = "循环天气 (R)：晴→雨→雾"
