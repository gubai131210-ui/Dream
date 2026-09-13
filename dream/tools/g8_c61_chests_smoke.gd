extends SceneTree

## C61 hidden chests: open all 5 sites via mcp_open, assert ChestLidFX frames≥4.
## godot --path dream --headless -s res://tools/g8_c61_chests_smoke.gd

const SITES := [
	{"path": "res://scenes/areas/village_square/village_square.tscn", "node": "HiddenChests_well", "id": "well"},
	{"path": "res://scenes/areas/forest_deep/forest_deep.tscn", "node": "HiddenChests_tree_behind", "id": "tree_behind"},
	{"path": "res://scenes/areas/waterfall/waterfall.tscn", "node": "HiddenChests_waterfall", "id": "waterfall"},
	{"path": "res://scenes/areas/hill_farm/hill_farm.tscn", "node": "HiddenChests_cave", "id": "cave"},
	{"path": "res://scenes/areas/lake/lake.tscn", "node": "HiddenChests_island", "id": "island"},
]

var _failures: PackedStringArray = []
var _ok: int = 0
var _pending: int = 0


func _initialize() -> void:
	print("G8_C61: start")
	call_deferred("_boot")


func _boot() -> void:
	_pending = SITES.size()
	for entry in SITES:
		_probe_site(entry as Dictionary)


func _probe_site(entry: Dictionary) -> void:
	var label := str(entry["id"])
	var packed := load(str(entry["path"])) as PackedScene
	if packed == null:
		_fail(label, "load null")
		_done_one()
		return
	var host := packed.instantiate() as Node2D
	host.name = "C61Host_%s" % label
	root.add_child(host)
	create_timer(1.15).timeout.connect(func() -> void:
		var kit := host.get_node_or_null(str(entry["node"]))
		if kit == null or not kit.has_method("mcp_open"):
			_fail(label, "kit missing mcp_open")
			host.queue_free()
			_done_one()
			return
		var report: Dictionary = kit.call("mcp_open")
		print("G8_C61: ", label, " ", report)
		if not bool(report.get("ok", false)):
			_fail(label, "mcp_open failed: %s" % str(report))
		elif int(report.get("frames", 0)) < 4:
			_fail(label, "frames < 4")
		elif not bool(report.get("playing", false)) and str(report.get("fx", "")) == "":
			_fail(label, "no lid FX")
		else:
			_ok += 1
			print("G8_C61: ok ", label)
		host.queue_free()
		_done_one()
	)


func _done_one() -> void:
	_pending -= 1
	if _pending > 0:
		return
	_finish(0 if _failures.is_empty() else 1)


func _fail(label: String, msg: String) -> void:
	_failures.append("%s: %s" % [label, msg])
	push_error("G8_C61 FAIL: %s — %s" % [label, msg])


func _finish(code: int) -> void:
	if code == 0:
		print("G8_C61: PASS ok=%d" % _ok)
	else:
		for f in _failures:
			print("G8_C61 FAIL: ", f)
	quit(code)
