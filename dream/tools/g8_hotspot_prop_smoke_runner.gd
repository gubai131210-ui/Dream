extends Node2D

## Runtime: every outdoor InteractableHotspot must have formal pixel visual
## (PropSprite / reparented Sprite2D / AnimatedSprite). Not user §7.

const SCENES := [
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

var _failures: PackedStringArray = []
var _ok_scenes: int = 0
var _hotspots_ok: int = 0
var _idx: int = 0
var _done: bool = false
var _host: Node = null
var _status: Label


func _ready() -> void:
	_status = Label.new()
	_status.position = Vector2(24, 24)
	_status.add_theme_font_size_override("font_size", 16)
	_status.text = "Hotspot prop smoke…"
	add_child(_status)
	print("G8_HOTSPOT_PROP: start count=", SCENES.size())
	call_deferred("_step")


func mcp_status() -> Dictionary:
	return {
		"ok": _failures.is_empty() and _done and _ok_scenes == SCENES.size(),
		"done": _done,
		"passed_scenes": _ok_scenes,
		"total_scenes": SCENES.size(),
		"hotspots_ok": _hotspots_ok,
		"fails": _failures.size(),
		"fail_detail": _failures,
	}


func _step() -> void:
	if _idx >= SCENES.size():
		_finish()
		return
	var item: Dictionary = SCENES[_idx]
	_idx += 1
	var id := str(item["id"])
	var path := str(item["path"])
	_status.text = "Probing %d/%d: %s" % [_idx, SCENES.size(), id]
	if not ResourceLoader.exists(path):
		_fail("%s missing %s" % [id, path])
		call_deferred("_step")
		return
	var packed := load(path) as PackedScene
	if packed == null:
		_fail("%s load null" % id)
		call_deferred("_step")
		return
	_host = packed.instantiate()
	add_child(_host)
	await get_tree().create_timer(0.45).timeout
	_probe(id, _host)
	if is_instance_valid(_host):
		_host.queue_free()
		_host = null
	await get_tree().create_timer(0.05).timeout
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
		_fail("%s zero interactable_hotspots" % scene_id)
		return
	var scene_fails := 0
	for n in local:
		var hs := n as Node
		if hs == null:
			continue
		if _is_exempt(hs):
			continue
		if not _has_formal_visual(hs):
			scene_fails += 1
			_fail("%s orphan visual: %s" % [scene_id, hs.name])
			if scene_fails >= 8:
				_fail("%s … truncated after 8 orphans" % scene_id)
				break
		else:
			_hotspots_ok += 1
	if scene_fails == 0:
		_ok_scenes += 1
		print("G8_HOTSPOT_PROP: PASS ", scene_id, " hotspots=", local.size())


func _is_exempt(hs: Node) -> bool:
	## Actors / critters use walk sheets, not PropSprite.
	if hs is PatrolActor:
		return true
	if hs.get_class() == "AmbientCritter" or str(hs.get_script()).contains("ambient_critter"):
		return true
	var title := ""
	if hs.get("title") != null:
		title = str(hs.get("title"))
	var nm := str(hs.name)
	if "围栏" in title or "围栏" in nm or "田埂" in title or "田埂" in nm:
		## Fence posts still require PropSprite — do NOT exempt.
		pass
	return false


func _has_formal_visual(hs: Node) -> bool:
	## Formal pixels may nest (MarketStall StallLayers, FishingSpot Bobber, etc.).
	if _find_sprite_deep(hs):
		return true
	return false


func _find_sprite_deep(root: Node) -> bool:
	if root == null:
		return false
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is Sprite2D or n is AnimatedSprite2D:
			## Skip debug-only ContactShadow polygons; sprites count.
			return true
		for c in n.get_children():
			stack.append(c)
	return false


func _fail(msg: String) -> void:
	_failures.append(msg)
	print("G8_HOTSPOT_PROP: FAIL ", msg)


func _finish() -> void:
	_done = true
	var line := "G8_HOTSPOT_PROP: done scenes=%d/%d hotspots_ok=%d fails=%d" % [
		_ok_scenes, SCENES.size(), _hotspots_ok, _failures.size()
	]
	print(line)
	for f in _failures:
		print("G8_HOTSPOT_PROP: fail_detail ", f)
	_status.text = line + (" — PASS" if _failures.is_empty() else " — FAIL")
