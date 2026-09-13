extends Node2D

## Runtime inventory: every interior InteractableHotspot has formal Sprite2D/AnimatedSprite2D.
## Does NOT mark user §7.

var _scenes: Array[Dictionary] = []
var _failures: PackedStringArray = []
var _ok_scenes: int = 0
var _hotspots_ok: int = 0
var _idx: int = 0
var _done: bool = false
var _host: Node = null
var _status: Label


func _ready() -> void:
	_scenes = _discover()
	_status = Label.new()
	_status.position = Vector2(24, 24)
	_status.add_theme_font_size_override("font_size", 16)
	_status.text = "Interior hotspot prop smoke…"
	add_child(_status)
	print("G8_INTERIOR_HOTSPOT_PROP: start count=", _scenes.size())
	call_deferred("_step")


func mcp_status() -> Dictionary:
	return {
		"ok": _failures.is_empty() and _done and _ok_scenes == _scenes.size(),
		"done": _done,
		"passed_scenes": _ok_scenes,
		"total_scenes": _scenes.size(),
		"hotspots_ok": _hotspots_ok,
		"fails": _failures.size(),
		"fail_detail": _failures,
	}


func _discover() -> Array[Dictionary]:
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
	var tree := host.get_tree()
	if tree == null:
		_fail("%s no tree" % scene_id)
		return
	var nodes: Array = tree.get_nodes_in_group("interactable_hotspots")
	var local: Array = []
	for n in nodes:
		if host.is_ancestor_of(n) or n == host:
			local.append(n)
	if local.is_empty():
		## Empty interior with only portals is still a failure for "interact-ready".
		_fail("%s zero interactable_hotspots" % scene_id)
		return
	var scene_fails := 0
	for n in local:
		var hs := n as Node
		if hs == null:
			continue
		if hs is PatrolActor:
			continue
		if str(hs.get_script()).contains("ambient_critter"):
			continue
		if not _find_sprite_deep(hs):
			scene_fails += 1
			_fail("%s orphan visual: %s" % [scene_id, hs.name])
			if scene_fails >= 6:
				_fail("%s … truncated" % scene_id)
				break
		else:
			_hotspots_ok += 1
	if scene_fails == 0:
		_ok_scenes += 1
		print("G8_INTERIOR_HOTSPOT_PROP: PASS ", scene_id, " hotspots=", local.size())


func _find_sprite_deep(root: Node) -> bool:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is Sprite2D or n is AnimatedSprite2D:
			return true
		for c in n.get_children():
			stack.append(c)
	return false


func _fail(msg: String) -> void:
	_failures.append(msg)
	print("G8_INTERIOR_HOTSPOT_PROP: FAIL ", msg)


func _finish() -> void:
	_done = true
	var line := "G8_INTERIOR_HOTSPOT_PROP: done scenes=%d/%d hotspots_ok=%d fails=%d" % [
		_ok_scenes, _scenes.size(), _hotspots_ok, _failures.size()
	]
	print(line)
	for f in _failures:
		print("G8_INTERIOR_HOTSPOT_PROP: fail_detail ", f)
	_status.text = line + (" — PASS" if _failures.is_empty() else " — FAIL")
