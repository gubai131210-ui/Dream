extends SceneTree

## Headless C58 activate smoke.
## godot --path dream --headless -s res://tools/g8_interact_activate_smoke.gd

const SQUARE := "res://scenes/areas/village_square/village_square.tscn"
const EXPECTED_IDS := [
	"sit_bench", "well_water", "shake_tree", "notice_board",
	"crate_search", "lamp_toggle", "feed_critter", "read_sign",
]

var _failures: PackedStringArray = []
var _ok: int = 0


func _initialize() -> void:
	print("G8_INTERACT_SMOKE: start")
	call_deferred("_boot")


func _boot() -> void:
	var packed := load(SQUARE) as PackedScene
	if packed == null:
		_fail("load", "square PackedScene null")
		_finish(1)
		return
	var host := packed.instantiate() as Node2D
	if host == null:
		_fail("instantiate", "not Node2D")
		_finish(1)
		return
	root.add_child(host)
	create_timer(1.0).timeout.connect(func() -> void:
		_probe(host)
	)


func _probe(host: Node2D) -> void:
	var kit := _find_named(host, "WorldInteractKit")
	if kit == null:
		_fail("kit", "WorldInteractKit missing")
		_finish(1)
		return
	var live := int(kit.call("live_count"))
	print("G8_INTERACT_SMOKE: live_count=", live)
	if live < EXPECTED_IDS.size():
		_fail("live_count", "got %d want >= %d" % [live, EXPECTED_IDS.size()])
	var found: Dictionary = {}
	for hs in _collect_hotspots(host):
		if not hs.has_meta("interact_id"):
			continue
		found[str(hs.get_meta("interact_id"))] = hs
	for id in EXPECTED_IDS:
		if not found.has(id):
			_fail(id, "hotspot missing")
			continue
		var hs: Node = found[id]
		var spr := hs.get_node_or_null("Visual/PropSprite")
		if spr == null:
			_fail(id, "PropSprite missing")
			continue
		hs.emit_signal("activated", hs)
		_ok += 1
		print("G8_INTERACT_SMOKE: activated ", id)
	create_timer(0.9).timeout.connect(func() -> void:
		for id in ["shake_tree", "well_water", "crate_search", "feed_critter", "lamp_toggle"]:
			if not found.has(id):
				continue
			var hs2: Node = found[id]
			if not is_instance_valid(hs2):
				_fail(id, "freed after activate")
				continue
			print("G8_INTERACT_SMOKE: post-ok ", id)
			if id == "lamp_toggle":
				continue
			# Action FX should leave an AnimatedSprite2D child or have already played.
			var visual: Node = hs2.get_node_or_null("Visual")
			var has_fx := false
			if visual:
				for c in visual.get_children():
					if c is AnimatedSprite2D:
						has_fx = true
						break
			if has_fx:
				print("G8_INTERACT_SMOKE: fx-present ", id)
			else:
				# Soft: FX may free before this timer; require PropSprite still valid.
				if hs2.get_node_or_null("Visual/PropSprite") == null:
					_fail(id, "PropSprite lost after activate")
				else:
					print("G8_INTERACT_SMOKE: fx-cleared-ok ", id)
		_finish(0 if _failures.is_empty() else 1)
	)


func _collect_hotspots(n: Node) -> Array:
	var out: Array = []
	if n is Area2D and n.has_signal("activated"):
		out.append(n)
	for c in n.get_children():
		out.append_array(_collect_hotspots(c))
	return out


func _find_named(n: Node, want: String) -> Node:
	if n.name == want:
		return n
	for c in n.get_children():
		var f := _find_named(c, want)
		if f:
			return f
	return null


func _fail(key: String, msg: String) -> void:
	_failures.append("%s: %s" % [key, msg])
	print("G8_INTERACT_SMOKE: FAIL ", key, " — ", msg)


func _finish(code: int) -> void:
	print("G8_INTERACT_SMOKE: ok=", _ok, " failures=", _failures.size())
	for f in _failures:
		print("G8_INTERACT_SMOKE: ", f)
	if _failures.is_empty() and _ok >= EXPECTED_IDS.size():
		print("G8_INTERACT_SMOKE: PASS")
		quit(0)
	else:
		print("G8_INTERACT_SMOKE: FAIL")
		quit(1)
