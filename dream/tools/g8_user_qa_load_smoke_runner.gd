extends Node2D

## MCP-runnable §7 load smoke (21 checklist scenes). Does NOT mark user checks.
## Run: res://tools/g8_user_qa_load_smoke.tscn via editor/MCP.

const SCENES := [
	{"id": "square", "path": "res://scenes/areas/village_square/village_square.tscn", "outdoor": true},
	{"id": "market", "path": "res://scenes/areas/market_street/market_street.tscn", "outdoor": true},
	{"id": "farmland", "path": "res://scenes/areas/farmland/farmland.tscn", "outdoor": true},
	{"id": "residential", "path": "res://scenes/areas/village_residential/village_residential.tscn", "outdoor": true},
	{"id": "farm_home", "path": "res://scenes/areas/farm_residential/farm_residential.tscn", "outdoor": true},
	{"id": "forest_entrance", "path": "res://scenes/areas/forest_entrance/forest_entrance.tscn", "outdoor": true},
	{"id": "forest", "path": "res://scenes/areas/forest_deep/forest_deep.tscn", "outdoor": true},
	{"id": "river", "path": "res://scenes/areas/river/river.tscn", "outdoor": true},
	{"id": "lake", "path": "res://scenes/areas/lake/lake.tscn", "outdoor": true},
	{"id": "waterfall", "path": "res://scenes/areas/waterfall/waterfall.tscn", "outdoor": true},
	{"id": "lighthouse", "path": "res://scenes/areas/lighthouse/lighthouse.tscn", "outdoor": true},
	{"id": "hill_farm", "path": "res://scenes/areas/hill_farm/hill_farm.tscn", "outdoor": true},
	{"id": "station", "path": "res://scenes/areas/station/station.tscn", "outdoor": true},
	{"id": "lake_house", "path": "res://scenes/areas/lake_house/lake_house.tscn", "outdoor": true},
	{"id": "c01", "path": "res://scenes/interiors/c01_home/c01_home.tscn", "outdoor": false},
	{"id": "c02", "path": "res://scenes/interiors/c02_merchant/c02_merchant.tscn", "outdoor": false},
	{"id": "c06", "path": "res://scenes/interiors/c06_town_hall/c06_town_hall.tscn", "outdoor": false},
	{"id": "c40", "path": "res://scenes/interiors/c40_museum/c40_museum.tscn", "outdoor": false},
	{"id": "c43", "path": "res://scenes/interiors/c43_bathhouse/c43_bathhouse.tscn", "outdoor": false},
	{"id": "wave_d", "path": "res://scenes/interiors/c32_market_back/c32_market_back.tscn", "outdoor": false},
	{"id": "wave_e", "path": "res://scenes/interiors/c46_second_floor/c46_second_floor.tscn", "outdoor": false},
]

var _failures: PackedStringArray = []
var _ok: int = 0
var _idx: int = 0
var _done: bool = false
var _host: Node = null
var _status: Label


func _ready() -> void:
	_status = Label.new()
	_status.position = Vector2(24, 24)
	_status.add_theme_font_size_override("font_size", 18)
	_status.text = "§7 load smoke starting…"
	add_child(_status)
	print("G8_USER_QA_LOAD: start count=", SCENES.size())
	call_deferred("_step")


func mcp_status() -> Dictionary:
	return {
		"ok": _failures.is_empty() and _done and _ok == SCENES.size(),
		"done": _done,
		"passed": _ok,
		"total": SCENES.size(),
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
	var outdoor := bool(item.get("outdoor", false))
	_status.text = "Probing %d/%d: %s" % [_idx, SCENES.size(), id]
	if not ResourceLoader.exists(path):
		_fail("%s missing file %s" % [id, path])
		call_deferred("_step")
		return
	var packed := load(path) as PackedScene
	if packed == null:
		_fail("%s load null %s" % [id, path])
		call_deferred("_step")
		return
	_host = packed.instantiate()
	if _host == null:
		_fail("%s instantiate null" % id)
		call_deferred("_step")
		return
	add_child(_host)
	await get_tree().create_timer(0.4).timeout
	_probe(id, _host, outdoor)
	if is_instance_valid(_host):
		_host.queue_free()
		_host = null
	await get_tree().create_timer(0.05).timeout
	call_deferred("_step")


func _probe(id: String, host: Node, outdoor: bool) -> void:
	if outdoor:
		if host.get_node_or_null("DayNightWeather") == null:
			_fail("%s missing DayNightWeather" % id)
			return
		if host.get_node_or_null("AreaInteractHost") == null:
			_fail("%s missing AreaInteractHost" % id)
			return
		match id:
			"square":
				if host.get_node_or_null("WorldInteractKit") == null:
					_fail("%s missing WorldInteractKit" % id)
					return
				if host.get_node_or_null("BreakablesKit") == null:
					_fail("%s missing BreakablesKit" % id)
					return
				if host.get_node_or_null("ProgressGates") == null:
					_fail("%s missing ProgressGates" % id)
					return
			"market":
				if not _has_named_prefix(host, "MarketStall_"):
					_fail("%s missing MarketStall_*" % id)
					return
				if host.get_node_or_null("DistrictInteractKit") == null:
					_fail("%s missing DistrictInteractKit" % id)
					return
			"river", "lake":
				if not _has_named_prefix(host, "FishCage_") and not _has_named_prefix(host, "FishingSpot_"):
					_fail("%s missing FishCage_/FishingSpot_" % id)
					return
				if host.get_node_or_null("DistrictInteractKit") == null:
					_fail("%s missing DistrictInteractKit" % id)
					return
			"waterfall":
				if not _has_named_exact(host, "WaterfallAnim"):
					_fail("%s missing WaterfallAnim" % id)
					return
				if host.get_node_or_null("DistrictInteractKit") == null:
					_fail("%s missing DistrictInteractKit" % id)
					return
				## C62 hop also attaches here.
				if not _has_named_prefix(host, "SecretPassageChain_"):
					_fail("%s missing SecretPassageChain_*" % id)
					return
			"forest":
				## attach_for_host names kit SecretPassageChain_<host_key>
				if not _has_named_prefix(host, "SecretPassageChain_"):
					_fail("%s missing SecretPassageChain_*" % id)
					return
				if not _has_secret_chain_portal(host):
					_fail("%s missing secret_chain portal" % id)
					return
			"farmland", "residential", "farm_home", "forest_entrance", "lighthouse", "hill_farm", "station", "lake_house":
				if host.get_node_or_null("DistrictInteractKit") == null:
					_fail("%s missing DistrictInteractKit" % id)
					return
	else:
		if host.get_child_count() < 1:
			_fail("%s empty tree" % id)
			return
		## Interiors use Portal_Return / Portal_Extra_* (not outdoor WorldPortal_*).
		if not _has_named_prefix(host, "Portal_"):
			_fail("%s missing Portal_Return/Extra" % id)
			return
	_ok += 1
	print("G8_USER_QA_LOAD: PASS ", id)


func _has_named_exact(root: Node, needle: String) -> bool:
	return _scan_names(root, needle, true)


func _has_named_prefix(root: Node, prefix: String) -> bool:
	return _scan_names(root, prefix, false)


func _scan_names(root: Node, needle: String, exact: bool) -> bool:
	if root == null or needle.is_empty():
		return false
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		var nm := str(n.name)
		if exact:
			if nm == needle:
				return true
		elif nm.begins_with(needle):
			return true
		for c in n.get_children():
			stack.append(c)
	return false


func _has_secret_chain_portal(root: Node) -> bool:
	if root == null:
		return false
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n.has_meta("secret_chain") and bool(n.get_meta("secret_chain")):
			return true
		## Fallback: C62 outdoor labels use WorldPortal_树洞密道 etc.
		var nm := str(n.name)
		if nm.begins_with("WorldPortal_") and (nm.contains("密道") or nm.contains("暗河") or nm.contains("瀑后")):
			return true
		for c in n.get_children():
			stack.append(c)
	return false


func _fail(msg: String) -> void:
	_failures.append(msg)
	print("G8_USER_QA_LOAD: FAIL ", msg)


func _finish() -> void:
	_done = true
	var line := "G8_USER_QA_LOAD: done ok=%d fails=%d" % [_ok, _failures.size()]
	print(line)
	for f in _failures:
		print("G8_USER_QA_LOAD: fail_detail ", f)
	_status.text = line + (" — PASS" if _failures.is_empty() else " — FAIL")
