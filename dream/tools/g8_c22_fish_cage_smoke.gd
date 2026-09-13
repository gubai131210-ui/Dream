extends SceneTree

## C22 fish cage: place → force ready → collect; assert sprites + phases.
## godot --path dream --headless -s res://tools/g8_c22_fish_cage_smoke.gd

const RIVER := "res://scenes/areas/river/river.tscn"
const SPRITE_EMPTY := "res://assets/sprites/fishing/fish_cage_00.png"
const SPRITE_FULL := "res://assets/sprites/fishing/fish_cage_full_00.png"

var _failures: PackedStringArray = []
var _ok: int = 0


func _initialize() -> void:
	print("G8_C22: start")
	call_deferred("_boot")


func _boot() -> void:
	var packed := load(RIVER) as PackedScene
	if packed == null:
		_fail("load", "river null")
		_finish(1)
		return
	var host := packed.instantiate() as Node2D
	root.add_child(host)
	create_timer(1.1).timeout.connect(func() -> void:
		_probe(host)
	)


func _probe(host: Node2D) -> void:
	var cage := _find_cage(host)
	if cage == null:
		_fail("cage", "FishCage_* missing under river")
		_finish(1)
		return
	if not cage.has_method("mcp_place") or not cage.has_method("mcp_cycle_to_ready") or not cage.has_method("mcp_collect"):
		_fail("api", "mcp_place/cycle/collect missing")
		_finish(1)
		return
	var place: Dictionary = cage.call("mcp_place")
	print("G8_C22: place ", place)
	if not bool(place.get("ok", false)) or str(place.get("phase", "")) != "soaking":
		_fail("place", str(place))
	elif not str(place.get("sprite_path", "")).ends_with("fish_cage_00.png"):
		_fail("place_sprite", str(place.get("sprite_path", "")))
	else:
		_ok += 1
	var ready: Dictionary = cage.call("mcp_cycle_to_ready")
	print("G8_C22: ready ", ready)
	if not bool(ready.get("ok", false)) or str(ready.get("phase", "")) != "ready":
		_fail("ready", str(ready))
	elif str(ready.get("sprite_path", "")) != SPRITE_FULL:
		_fail("ready_sprite", str(ready.get("sprite_path", "")))
	elif not str(ready.get("title", "")).contains("可收"):
		_fail("ready_title", str(ready.get("title", "")))
	else:
		_ok += 1
	var collect: Dictionary = cage.call("mcp_collect")
	print("G8_C22: collect ", collect)
	if not bool(collect.get("ok", false)) or str(collect.get("phase", "")) != "empty":
		_fail("collect", str(collect))
	elif str(collect.get("sprite_path", "")) != SPRITE_EMPTY and not str(collect.get("sprite_path", "")).ends_with("fish_cage_00.png"):
		_fail("collect_sprite", str(collect.get("sprite_path", "")))
	else:
		_ok += 1
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
	quit(code)
