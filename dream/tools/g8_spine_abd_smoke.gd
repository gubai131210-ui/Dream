extends SceneTree

## Spine A/B/D runtime smoke — till/plant/water/morning/harvest + C29 moss/urn + inventory.
## Uses change_scene_to_file so .tscn scripts attach (PackedScene.instantiate can drop scripts headless).
## godot --path dream --headless -s res://tools/g8_spine_abd_smoke.gd

const FARMLAND := "res://scenes/areas/farmland/farmland.tscn"
const C29 := "res://scenes/interiors/c29_ruins/c29_ruins.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	print("G8_SPINE_ABD: start")
	call_deferred("_boot")


func _boot() -> void:
	var inv := root.get_node_or_null("InventoryService")
	var sr := root.get_node_or_null("SpawnRegistry")
	if inv == null:
		_fail("InventoryService autoload missing")
	if sr == null:
		_fail("SpawnRegistry autoload missing")
	if not _failures.is_empty():
		_finish(1)
		return
	inv.call("clear")
	await _probe_farm(inv)
	if not _failures.is_empty():
		_finish(1)
		return
	await _probe_c29(inv)
	if not _failures.is_empty():
		_finish(1)
		return
	_probe_zone_safety()
	_probe_spawn_grace(sr)
	if _failures.is_empty():
		print("G8_SPINE_ABD: GREEN")
		_finish(0)
	else:
		_finish(1)


func _wait_frames(n: int) -> void:
	for _i in n:
		await process_frame


func _probe_farm(inv: Node) -> void:
	change_scene_to_file(FARMLAND)
	await _wait_frames(8)
	var host := current_scene as Node2D
	if host == null:
		_fail("farmland current_scene null")
		return
	print("G8_SPINE_ABD: farmland script=", host.get_script())
	var kit := host.get_node_or_null("FarmCropKit")
	if kit == null:
		var kit_script = load("res://scripts/farm/farm_crop_kit.gd")
		var ysort := host.get_node_or_null("YSortRoot") as Node2D
		if kit_script and ysort:
			kit = kit_script.attach_to(host, ysort, host.get_node_or_null("InfoPanel"))
	if kit == null:
		_fail("FarmCropKit not attached on farmland")
		return
	var plots: Array = kit.get("_plots")
	print("G8_SPINE_ABD: plots=", plots.size())
	if plots.size() < 3 or plots.size() > 5:
		_fail("plot count %d not in 3–5" % plots.size())
		return
	var p0: Dictionary = plots[0]
	var hs: InteractableHotspot = p0["hs"]
	kit.call("_on_plot_activated", hs, 0)
	p0 = kit.get("_plots")[0]
	if not bool(p0["tilled"]):
		_fail("till did not set tilled")
		return
	kit.call("_on_plot_activated", hs, 0)
	p0 = kit.get("_plots")[0]
	if int(p0["stage"]) != 0:
		_fail("plant did not reach stage 0 (stage=%d)" % int(p0["stage"]))
		return
	kit.call("_on_plot_activated", hs, 0)
	p0 = kit.get("_plots")[0]
	if not bool(p0["watered"]):
		_fail("water flag missing")
		return
	for _i in 3:
		# Each morning consumes water — re-water before next Night→Day.
		kit.call("_on_env", 1, 0)
		kit.call("_on_env", 0, 0)
		p0 = kit.get("_plots")[0]
		if int(p0["stage"]) < 3:
			kit.call("_on_plot_activated", hs, 0)
	p0 = kit.get("_plots")[0]
	if int(p0["stage"]) < 3:
		_fail("after 3 mornings stage=%d expected ≥3" % int(p0["stage"]))
		return
	var before := int(inv.call("count", "crop_turnip"))
	kit.call("_on_plot_activated", hs, 0)
	var after := int(inv.call("count", "crop_turnip"))
	if after != before + 1:
		_fail("harvest did not add crop_turnip (%d→%d)" % [before, after])
		return
	print("G8_SPINE_ABD: farm till/plant/water/grow/harvest OK qty=", after)


func _probe_c29(inv: Node) -> void:
	change_scene_to_file(C29)
	await _wait_frames(8)
	var host := current_scene as Node2D
	if host == null:
		_fail("c29 current_scene null")
		return
	print("G8_SPINE_ABD: c29 script=", host.get_script(), " profile=", host.get("profile_id"))
	var kit := host.get_node_or_null("EncounterPocketKit")
	if kit == null:
		var enc = load("res://scripts/world/encounter_pocket_kit.gd")
		var world := host.get_node_or_null("InteriorWorld") as Node2D
		if enc and world:
			kit = enc.attach_to(host, world, host.get_node_or_null("InfoLayer"))
	if kit == null:
		_fail("EncounterPocketKit not on c29")
		return
	var before_r := int(inv.call("count", "loot_moss_resin"))
	for _i in 3:
		kit.call("_on_hit", null)
	var after_r := int(inv.call("count", "loot_moss_resin"))
	if after_r < before_r + 1:
		_fail("moss clear did not add resin (%d→%d)" % [before_r, after_r])
		return
	print("G8_SPINE_ABD: moss clear OK resin=", after_r)
	kit.call("_on_urn", null)
	print("G8_SPINE_ABD: urn activate OK")


func _probe_zone_safety() -> void:
	for rel in [
		"res://scripts/areas/village_square_controller.gd",
		"res://scripts/areas/station_controller.gd",
		"res://scripts/areas/farmland_controller.gd",
	]:
		var txt := FileAccess.get_file_as_string(rel)
		if "EncounterPocketKit" in txt:
			_fail("%s must not reference EncounterPocketKit" % rel)


func _probe_spawn_grace(sr: Node) -> void:
	sr.call("arm_portal_grace", 0.5)
	if not bool(sr.call("portal_grace_active")):
		_fail("portal grace not active after arm")
	else:
		print("G8_SPINE_ABD: portal grace OK")
	sr.call("set_pending", "entrance")
	var pending: Dictionary = sr.call("take_pending")
	if str(pending.get("id", "")) != "entrance":
		_fail("SpawnRegistry pending id roundtrip")
	else:
		print("G8_SPINE_ABD: spawn pending OK")


func _fail(msg: String) -> void:
	_failures.append(msg)
	push_error("G8_SPINE_ABD FAIL: " + msg)
	print("G8_SPINE_ABD FAIL: ", msg)


func _finish(code: int) -> void:
	for f in _failures:
		print(" - ", f)
	quit(code)
