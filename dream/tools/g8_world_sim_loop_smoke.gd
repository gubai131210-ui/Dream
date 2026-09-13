extends SceneTree

## Global env persists across outdoor map change + immersive kits present.
## godot --path dream --headless -s res://tools/g8_world_sim_loop_smoke.gd

const SQUARE := "res://scenes/areas/village_square/village_square.tscn"
const FARMLAND := "res://scenes/areas/farmland/farmland.tscn"


func _initialize() -> void:
	call_deferred("_boot")


func _boot() -> void:
	var wes := root.get_node_or_null("WorldEnvState")
	if wes == null:
		push_error("G8_SIM FAIL: no WorldEnvState autoload")
		quit(1)
		return
	wes.call("set_time_grade", 1)  # NIGHT
	wes.call("set_weather", 1)  # RAIN
	change_scene_to_file(SQUARE)
	for _i in 14:
		await process_frame
	var host := current_scene as Node2D
	if host == null:
		push_error("G8_SIM FAIL: no square")
		quit(1)
		return
	var env := host.get_node_or_null("DayNightWeather")
	if env == null:
		push_error("G8_SIM FAIL: no DayNightWeather on square")
		quit(1)
		return
	if not bool(env.call("is_night")):
		push_error("G8_SIM FAIL: square not night after global set")
		quit(1)
		return
	if int(env.get("weather")) != 1:
		push_error("G8_SIM FAIL: square weather not rain")
		quit(1)
		return
	if host.get_node_or_null("MapTravelKit") == null:
		push_error("G8_SIM FAIL: MapTravelKit missing")
		quit(1)
		return
	if host.get_node_or_null("WeatherBuildingFx") == null:
		push_error("G8_SIM FAIL: WeatherBuildingFx missing")
		quit(1)
		return
	var top := host.get_node_or_null("UI/TopBar") as CanvasItem
	if top != null and top.visible:
		push_error("G8_SIM FAIL: TopBar still visible (immersive chrome)")
		quit(1)
		return
	# Persist across map change
	change_scene_to_file(FARMLAND)
	for _i in 14:
		await process_frame
	host = current_scene as Node2D
	env = host.get_node_or_null("DayNightWeather") if host else null
	if env == null:
		push_error("G8_SIM FAIL: no DayNightWeather on farmland")
		quit(1)
		return
	if not bool(env.call("is_night")):
		push_error("G8_SIM FAIL: farmland lost night after travel")
		quit(1)
		return
	if int(env.get("weather")) != 1:
		push_error("G8_SIM FAIL: farmland lost rain after travel")
		quit(1)
		return
	var sd := root.get_node_or_null("ScheduleDirector")
	if sd:
		sd.call("apply_to_current_scene")
	print("G8_SIM: night+rain persisted square→farmland; chrome hidden")
	print("G8_SIM: GREEN")
	quit(0)
