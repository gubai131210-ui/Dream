extends Node2D

## Runtime: every outdoor/interior portal Area2D has DoorFacade Sprite2D with texture.
## Does NOT mark user §7.

const OUTDOOR := [
	{"id": "square", "path": "res://scenes/areas/village_square/village_square.tscn"},
	{"id": "market", "path": "res://scenes/areas/market_street/market_street.tscn"},
	{"id": "farmland", "path": "res://scenes/areas/farmland/farmland.tscn"},
	{"id": "residential", "path": "res://scenes/areas/village_residential/village_residential.tscn"},
	{"id": "farm_home", "path": "res://scenes/areas/farm_residential/farm_residential.tscn"},
	{"id": "forest_entrance", "path": "res://scenes/areas/forest_entrance/forest_entrance.tscn"},
	{"id": "forest", "path": "res://scenes/areas/forest_deep/forest_deep.tscn"},
	{"id": "river", "path": "res://scenes/areas/river/river.tscn"},
	{"id": "lake", "path": "res://scenes/areas/lake/lake.tscn"},
	{"id": "waterfall", "path": "res://scenes/areas/waterfall/waterfall.tscn"},
	{"id": "lighthouse", "path": "res://scenes/areas/lighthouse/lighthouse.tscn"},
	{"id": "hill_farm", "path": "res://scenes/areas/hill_farm/hill_farm.tscn"},
	{"id": "station", "path": "res://scenes/areas/station/station.tscn"},
	{"id": "lake_house", "path": "res://scenes/areas/lake_house/lake_house.tscn"},
]

var _scenes: Array[Dictionary] = []
var _failures: PackedStringArray = []
var _ok_scenes: int = 0
var _portals_ok: int = 0
var _idx: int = 0
var _done: bool = false
var _host: Node = null
var _status: Label


func _ready() -> void:
	_scenes.clear()
	for item in OUTDOOR:
		_scenes.append(item)
	for item in _discover_interiors():
		_scenes.append(item)
	_status = Label.new()
	_status.position = Vector2(24, 24)
	_status.add_theme_font_size_override("font_size", 15)
	_status.text = "Portal façade smoke…"
	add_child(_status)
	print("G8_PORTAL_FACADE: start count=", _scenes.size())
	call_deferred("_step")


func mcp_status() -> Dictionary:
	return {
		"ok": _failures.is_empty() and _done and _ok_scenes == _scenes.size(),
		"done": _done,
		"passed_scenes": _ok_scenes,
		"total_scenes": _scenes.size(),
		"portals_ok": _portals_ok,
		"fails": _failures.size(),
		"fail_detail": _failures,
	}


func _discover_interiors() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var dir := DirAccess.open("res://scenes/interiors")
	if dir == null:
		return out
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if dir.current_is_dir() and not name.begins_with("."):
			var path := "res://scenes/interiors/%s/%s.tscn" % [name, name]
			if ResourceLoader.exists(path):
				out.append({"id": name, "path": path})
		name = dir.get_next()
	dir.list_dir_end()
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a["id"]) < str(b["id"]))
	return out


func _step() -> void:
	if _idx >= _scenes.size():
		_finish()
		return
	var item: Dictionary = _scenes[_idx]
	_idx += 1
	var id := str(item["id"])
	var path := str(item["path"])
	_status.text = "Probing %d/%d: %s" % [_idx, _scenes.size(), id]
	var packed := load(path) as PackedScene
	if packed == null:
		_fail("%s load null" % id)
		call_deferred("_step")
		return
	_host = packed.instantiate()
	add_child(_host)
	await get_tree().create_timer(0.28).timeout
	_probe(id, _host)
	if is_instance_valid(_host):
		_host.queue_free()
		_host = null
	await get_tree().create_timer(0.03).timeout
	call_deferred("_step")


func _probe(scene_id: String, host: Node) -> void:
	var portals: Array[Node] = []
	_collect_portals(host, portals)
	if portals.is_empty():
		_fail("%s zero portals" % scene_id)
		return
	var scene_fails := 0
	for p in portals:
		if not _has_facade(p):
			scene_fails += 1
			_fail("%s missing DoorFacade: %s" % [scene_id, p.name])
			if scene_fails >= 6:
				_fail("%s … truncated" % scene_id)
				break
		else:
			_portals_ok += 1
	if scene_fails == 0:
		_ok_scenes += 1
		print("G8_PORTAL_FACADE: PASS ", scene_id, " portals=", portals.size())


func _collect_portals(n: Node, out: Array[Node]) -> void:
	var nm := str(n.name)
	if n is Area2D and (
		nm.begins_with("WorldPortal_")
		or nm.begins_with("Portal_")
		or nm == "Portal_Return"
		or nm.begins_with("Portal_Extra")
	):
		out.append(n)
	for c in n.get_children():
		_collect_portals(c, out)


func _has_facade(portal: Node) -> bool:
	var facade := portal.get_node_or_null("DoorFacade") as Sprite2D
	if facade == null:
		## Sometimes nested under a cue root.
		facade = _find_named_sprite(portal, "DoorFacade")
	if facade == null:
		return false
	return facade.texture != null


func _find_named_sprite(root: Node, want: String) -> Sprite2D:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is Sprite2D and str(n.name) == want:
			return n as Sprite2D
		for c in n.get_children():
			stack.append(c)
	return null


func _fail(msg: String) -> void:
	_failures.append(msg)
	print("G8_PORTAL_FACADE: FAIL ", msg)


func _finish() -> void:
	_done = true
	var line := "G8_PORTAL_FACADE: done scenes=%d/%d portals_ok=%d fails=%d" % [
		_ok_scenes, _scenes.size(), _portals_ok, _failures.size()
	]
	print(line)
	for f in _failures:
		print("G8_PORTAL_FACADE: fail_detail ", f)
	_status.text = line + (" — PASS" if _failures.is_empty() else " — FAIL")
