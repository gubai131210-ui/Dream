class_name NpcMotionPolicy
extends RefCounted

## Walk speed / anim FPS policy by role, district, weather, and time-of-day.
## Inspired by farming-sim pacing: elders stroll, workers hustle, rain slows everyone.

enum Role {
	ELDER,
	WORKER,
	MERCHANT,
	VISITOR,
	GUARD,
	PLAYER,
}

## px/s baselines at day + clear weather.
const BASE_SPEED := {
	Role.ELDER: 26.0,
	Role.WORKER: 40.0,
	Role.MERCHANT: 30.0,
	Role.VISITOR: 34.0,
	Role.GUARD: 36.0,
	Role.PLAYER: 48.0,
}

const BASE_FPS := {
	Role.ELDER: 9.0,
	Role.WORKER: 12.0,
	Role.MERCHANT: 10.0,
	Role.VISITOR: 11.0,
	Role.GUARD: 11.0,
	Role.PLAYER: 12.0,
}

const DISTRICT_MULT := {
	"plaza": 1.0,
	"residential": 0.92,
	"farm_home": 0.95,
	"farmland": 1.08,
	"market": 0.88,
	"wild": 0.85,
	"transit": 1.05,
}


static func role_for_character(character_id: String) -> int:
	match character_id:
		"elder_woman", "mayor":
			return Role.ELDER
		"farmer", "miller", "blacksmith":
			return Role.WORKER
		"merchant":
			return Role.MERCHANT
		"station_master":
			return Role.GUARD
		"player":
			return Role.PLAYER
		_:
			return Role.VISITOR


static func role_for_title(title: String) -> int:
	var t := title
	if "老" in t or "长者" in t or "村长" in t:
		return Role.ELDER
	if "商" in t or "摊" in t:
		return Role.MERCHANT
	if "铁" in t or "农" in t or "工" in t or "磨" in t:
		return Role.WORKER
	if "站" in t or "守卫" in t:
		return Role.GUARD
	return Role.VISITOR


static func resolve_env(host: Node) -> Dictionary:
	var weather := DayNightWeather.WeatherKind.CLEAR
	var time_grade := DayNightWeather.TimeGrade.DAY
	var district := "plaza"
	if host == null:
		return {"weather": weather, "time_grade": time_grade, "district": district}
	var env := DayNightWeather.find_on(host)
	if env:
		weather = env.weather
		time_grade = env.time_grade
	var assembler := host.get_node_or_null("Assembler")
	if assembler != null:
		var craft_variant: Variant = assembler.get("craft")
		if craft_variant is AreaCraft:
			district = str((craft_variant as AreaCraft).district)
	return {"weather": weather, "time_grade": time_grade, "district": district}


static func weather_mult(weather: int) -> float:
	match weather:
		DayNightWeather.WeatherKind.RAIN:
			return 0.72
		DayNightWeather.WeatherKind.FOG:
			return 0.80
		_:
			return 1.0


static func time_mult(time_grade: int) -> float:
	if time_grade == DayNightWeather.TimeGrade.NIGHT:
		return 0.78
	return 1.0


static func district_mult(district: String) -> float:
	return float(DISTRICT_MULT.get(district, 1.0))


static func speed_px(role: int, host: Node = null) -> float:
	var env := resolve_env(host)
	var base := float(BASE_SPEED.get(role, 32.0))
	return base * district_mult(str(env["district"])) * weather_mult(int(env["weather"])) * time_mult(int(env["time_grade"]))


static func frame_fps(role: int, host: Node = null) -> float:
	var env := resolve_env(host)
	var base := float(BASE_FPS.get(role, 10.0))
	var mult := weather_mult(int(env["weather"])) * time_mult(int(env["time_grade"]))
	# Keep FPS paired with speed so stride doesn't slide (px/frame stays near 3–4).
	return clampf(base * sqrt(mult), 7.0, 14.0)


static func pause_sec(role: int) -> float:
	match role:
		Role.ELDER:
			return 0.55
		Role.MERCHANT:
			return 0.45
		Role.WORKER:
			return 0.22
		_:
			return 0.32


static func apply_anim_speed(anim: AnimatedSprite2D, fps: float) -> void:
	if anim == null or anim.sprite_frames == null:
		return
	anim.speed_scale = fps / 8.0
