extends SceneTree

## C22 fish cage: river + lake place → force ready → collect.
## godot --path dream --headless -s res://tools/g8_c22_fish_cage_smoke.gd

const SCENES := [
	{"path": "res://scenes/areas/river/river.tscn", "label": "river"},
	{"path": "res://scenes/areas/lake/lake.tscn", "label": "lake"},
]
const SPRITE_EMPTY := "res://assets/sprites/fishing/fish_cage_00.png"
const SPRITE_FULL := "res://assets/sprites/fishing/fish_cage_full_00.png"

var _failures: PackedStringArray = []
var _ok: int = 0
var _pending: int = 0


func _initialize() -> void:
	print("G8_C22: start")
	call_deferred("_boot")


func _boot() -> void:
	_pending = SCENES.size()
	for i in range(SCENES.size()):
		var entry: Dictionary = SCENES[i]
		_probe_scene(str(entry["path"]), str(entry["label"]))


func _probe_scene(scene_path: String, label: String) -> void:
	var packed := load(scene_path) as PackedScene
	if packed == null:
		_fail(label, "load null")
		_done_one()
		return
	var host := packed.instantiate() as Node2D
	host.name = "C22Host_%s" % label
	root.add_child(host)
	create_timer(1.1).timeout.connect(func() -> void:
		_probe_host(host, label)
		host.queue_free()
		_done_one()
	)


func _probe_host(host: Node2D, label: String) -> void:
	var cage := _find_cage(host)
	if cage == null:
		_fail(label, "FishCage_* missing")
		return
	if not cage.has_method("mcp_place") or not cage.has_method("mcp_cycle_to_ready") or not cage.has_method("mcp_collect"):
		_fail(label, "mcp_place/cycle/collect missing")
		return
	var place: Dictionary = cage.call("mcp_place")
	print("G8_C22: ", label, " place ", place)
	if not bool(place.get("ok", false)) or str(place.get("phase", "")) != "soaking":
		_fail("%s_place" % label, str(place))
	elif not str(place.get("sprite_path", "")).ends_with("fish_cage_00.png"):
		_fail("%s_place_sprite" % label, str(place.get("sprite_path", "")))
	else:
		_ok += 1
	var ready: Dictionary = cage.call("mcp_cycle_to_ready")
	print("G8_C22: ", label, " ready ", ready)
	if not bool(ready.get("ok", false)) or str(ready.get("phase", "")) != "ready":
		_fail("%s_ready" % label, str(ready))
	elif not str(ready.get("sprite_path", "")).ends_with("fish_cage_full_00.png"):
		_fail("%s_ready_sprite" % label, str(ready.get("sprite_path", "")))
	elif not str(ready.get("title", "")).contains("可收"):
		_fail("%s_ready_title" % label, str(ready.get("title", "")))
	else:
		_ok += 1
	var collect: Dictionary = cage.call("mcp_collect")
	print("G8_C22: ", label, " collect ", collect)
	if not bool(collect.get("ok", false)) or str(collect.get("phase", "")) != "empty":
		_fail("%s_collect" % label, str(collect))
	elif not str(collect.get("sprite_path", "")).ends_with("fish_cage_00.png"):
		_fail("%s_collect_sprite" % label, str(collect.get("sprite_path", "")))
	else:
		_ok += 1


func _done_one() -> void:
	_pending -= 1
	if _pending <= 0:
		_finish(0 if _failures.is_empty() else 1)


func _find_cage(host: Node) -> Node:
	if host.name.begins_with("FishCage_"):
		return host
	for child in host.get_children():
		var hit := _find_cage(child)
		if hit != null:
			return hit
	return null


func _fail(tag: String, detail: String) -> void:
	_failures.append("%s: %s" % [tag, detail])
	print("G8_C22 FAIL ", tag, " ", detail)


func _finish(code: int) -> void:
	print("G8_C22: ok=", _ok, " fails=", _failures.size())
	for f in _failures:
		print("G8_C22 FAIL_LIST ", f)
	if _failures.is_empty():
		print("G8_C22: PASS")
	else:
		print("G8_C22: FAIL")
	quit(code)
