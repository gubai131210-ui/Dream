extends SceneTree

## Wave D/E portal enter: market→C32, C01→C46, farm_home→C50.
## godot --path dream --headless -s res://tools/g8_wave_de_portal_smoke.gd

const CASES := [
	{
		"label": "C32",
		"host": "res://scenes/areas/market_street/market_street.tscn",
		"needle": "c32_market_back",
		"name_hint": "MarketBack",
	},
	{
		"label": "C46",
		"host": "res://scenes/interiors/c01_home/c01_home.tscn",
		"needle": "c46_second_floor",
		"name_hint": "SecondFloor",
	},
	{
		"label": "C50",
		"host": "res://scenes/areas/farm_residential/farm_residential.tscn",
		"needle": "c50_farm_cellar",
		"name_hint": "FarmCellar",
	},
]

var _failures: PackedStringArray = []
var _idx: int = 0
var _ok: int = 0


func _initialize() -> void:
	print("G8_WAVE_DE_PORTAL: start")
	call_deferred("_next")


func _next() -> void:
	if _idx >= CASES.size():
		_finish()
		return
	var case: Dictionary = CASES[_idx]
	_idx += 1
	var packed := load(str(case["host"])) as PackedScene
	if packed == null:
		_fail("%s host load null" % str(case["label"]))
		call_deferred("_next")
		return
	var host := packed.instantiate() as Node2D
	root.add_child(host)
	create_timer(1.0).timeout.connect(func() -> void:
		_probe_case(host, case)
	)


func _probe_case(host: Node2D, case: Dictionary) -> void:
	var label := str(case["label"])
	var needle := str(case["needle"])
	var portal := _find_portal(host, needle)
	if portal == null:
		_fail("%s portal missing" % label)
		host.queue_free()
		call_deferred("_next")
		return
	var path := str(portal.get_meta("scene_path", ""))
	if path.findn(needle) < 0:
		_fail("%s scene_path=%s" % [label, path])
		host.queue_free()
		call_deferred("_next")
		return
	var cues_ok := true
	for cue in ["DoorFacade", "DoorstepCue", "DoorArchCue"]:
		if portal.get_node_or_null(cue) == null:
			_fail("%s missing cue %s" % [label, cue])
			cues_ok = false
	print("G8_WAVE_DE_PORTAL: ", label, " path=", path, " cues=", cues_ok)
	host.queue_free()
	SceneRouter.change_to(self, path)
	create_timer(0.85).timeout.connect(func() -> void:
		var cur := current_scene
		var cur_path := ""
		var cur_name := ""
		if cur != null:
			cur_path = str(cur.scene_file_path)
			cur_name = str(cur.name)
		var ok := cur_path.findn(needle) >= 0 or cur_name.findn(str(case["name_hint"])) >= 0
		if not ok:
			_fail("%s after enter current=%s name=%s" % [label, cur_path, cur_name])
		else:
			_ok += 1
			print("G8_WAVE_DE_PORTAL: entered ", label, " → ", cur_path if not cur_path.is_empty() else cur_name)
		if cur != null:
			cur.queue_free()
		call_deferred("_next")
	)


func _find_portal(n: Node, needle: String) -> Node:
	if n is Area2D and n.has_meta("scene_path"):
		var p := str(n.get_meta("scene_path"))
		if p.findn(needle) >= 0:
			return n
	for c in n.get_children():
		var hit := _find_portal(c, needle)
		if hit != null:
			return hit
	return null


func _fail(msg: String) -> void:
	_failures.append(msg)
	print("G8_WAVE_DE_PORTAL: FAIL ", msg)


func _finish() -> void:
	print("G8_WAVE_DE_PORTAL: ok=", _ok, " fails=", _failures.size())
	for f in _failures:
		print("G8_WAVE_DE_PORTAL FAIL_LIST ", f)
	if _failures.is_empty() and _ok == CASES.size():
		print("G8_WAVE_DE_PORTAL: PASS")
		quit(0)
	else:
		print("G8_WAVE_DE_PORTAL: FAIL")
		quit(1)
