extends SceneTree

## Outdoor lamp night glow smoke.
## godot --path dream --headless -s res://tools/g8_outdoor_lamp_smoke.gd

const SQUARE := "res://scenes/areas/village_square/village_square.tscn"


func _initialize() -> void:
	call_deferred("_boot")


func _boot() -> void:
	change_scene_to_file(SQUARE)
	for _i in 12:
		await process_frame
	var host := current_scene as Node2D
	if host == null:
		push_error("G8_LAMP FAIL: no scene")
		quit(1)
		return
	var env := host.get_node_or_null("DayNightWeather")
	if env == null:
		push_error("G8_LAMP FAIL: no DayNightWeather")
		quit(1)
		return
	env.call("mcp_set_night", true)
	await process_frame
	await process_frame
	var kit := host.get_node_or_null("OutdoorLampKit")
	if kit == null:
		push_error("G8_LAMP FAIL: no OutdoorLampKit")
		quit(1)
		return
	kit.call("refresh")
	await process_frame
	var lights: Array = kit.get("_lights")
	var lit := 0
	var max_e := 0.0
	for L in lights:
		if L == null:
			continue
		if bool(L.enabled) and float(L.energy) > 0.8:
			lit += 1
			max_e = maxf(max_e, float(L.energy))
	print("G8_LAMP: lights=", lights.size(), " lit_night=", lit, " max_energy=", max_e)
	if lights.size() < 1:
		push_error("G8_LAMP FAIL: expected ≥1 street lamp light")
		quit(1)
		return
	if lit < 1 or max_e < 1.2:
		push_error("G8_LAMP FAIL: night energy too weak (CanvasModulate compensation missing?)")
		quit(1)
		return
	if max_e > 2.4:
		push_error("G8_LAMP FAIL: night energy too harsh (blown-out pool)")
		quit(1)
		return
	print("G8_LAMP: GREEN")
	quit(0)
