extends SceneTree

## Activate C58 + C59 + C60 on square; assert PropSprites; no SCRIPT ERROR.
## godot --path dream --headless -s res://tools/g8_worldsys_activate_smoke.gd

const SQUARE := "res://scenes/areas/village_square/village_square.tscn"
const C58 := [
	"sit_bench", "well_water", "shake_tree", "notice_board",
	"crate_search", "lamp_toggle", "feed_critter", "read_sign",
]

var _failures: PackedStringArray = []
var _ok: int = 0


func _initialize() -> void:
	print("G8_WORLDSYS: start")
	call_deferred("_boot")


func _boot() -> void:
	var packed := load(SQUARE) as PackedScene
	if packed == null:
		_fail("load", "square null")
		_finish(1)
		return
	var host := packed.instantiate() as Node2D
	root.add_child(host)
	create_timer(1.1).timeout.connect(func() -> void:
		_probe(host)
	)


func _probe(host: Node2D) -> void:
	var by_id: Dictionary = {}
	for hs in _collect_hotspots(host):
		if hs.has_meta("interact_id"):
			by_id[str(hs.get_meta("interact_id"))] = hs
		elif hs.has_meta("gate_id"):
			by_id["gate:" + str(hs.get_meta("gate_id"))] = hs
		elif hs.has_meta("breakable_id"):
			by_id["brk:" + str(hs.get_meta("breakable_id"))] = hs
	for id in C58:
		if not by_id.has(id):
			_fail(id, "C58 missing")
			continue
		_activate(by_id[id], id)
	var gates := 0
	var brks := 0
	for k in by_id.keys():
		var key := str(k)
		if key.begins_with("gate:"):
			_activate(by_id[k], key)
			gates += 1
		elif key.begins_with("brk:"):
			_activate(by_id[k], key)
			brks += 1
	print("G8_WORLDSYS: gates=", gates, " breakables=", brks)
	if gates < 3:
		_fail("gates", "want >=3 got %d" % gates)
	if brks < 2:
		_fail("breakables", "want >=2 got %d" % brks)
	create_timer(0.7).timeout.connect(func() -> void:
		_finish(0 if _failures.is_empty() and _ok >= C58.size() else 1)
	)


func _activate(hs: Node, label: String) -> void:
	if hs.get_node_or_null("Visual/PropSprite") == null:
		_fail(label, "PropSprite missing")
		return
	hs.emit_signal("activated", hs)
	_ok += 1
	print("G8_WORLDSYS: activated ", label)


func _collect_hotspots(n: Node) -> Array:
	var out: Array = []
	if n is Area2D and n.has_signal("activated"):
		out.append(n)
	for c in n.get_children():
		out.append_array(_collect_hotspots(c))
	return out


func _fail(key: String, msg: String) -> void:
	_failures.append("%s: %s" % [key, msg])
	print("G8_WORLDSYS: FAIL ", key, " — ", msg)


func _finish(code: int) -> void:
	print("G8_WORLDSYS: ok=", _ok, " failures=", _failures.size())
	for f in _failures:
		print("G8_WORLDSYS: ", f)
	if _failures.is_empty():
		print("G8_WORLDSYS: PASS")
		quit(0)
	else:
		print("G8_WORLDSYS: FAIL")
		quit(1)
