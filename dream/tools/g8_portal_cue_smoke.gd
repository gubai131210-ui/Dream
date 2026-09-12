extends SceneTree

## Portal discoverability smoke — square portals must have façade/doorstep sprites (not debug-only).
## godot --path dream --headless -s res://tools/g8_portal_cue_smoke.gd

const SQUARE := "res://scenes/areas/village_square/village_square.tscn"

var _failures: PackedStringArray = []
var _ok: int = 0


func _initialize() -> void:
	print("G8_PORTAL_CUE: start")
	call_deferred("_boot")


func _boot() -> void:
	var packed := load(SQUARE) as PackedScene
	if packed == null:
		_fail("load", "square null")
		_finish(1)
		return
	var host := packed.instantiate() as Node2D
	root.add_child(host)
	create_timer(1.0).timeout.connect(func() -> void:
		_probe(host)
	)


func _probe(host: Node2D) -> void:
	var portals: Array = []
	_find_portals(host, portals)
	print("G8_PORTAL_CUE: portals=", portals.size())
	if portals.size() < 2:
		_fail("count", "want >=2 portals, got %d" % portals.size())
	for area in portals:
		var facade := area.get_node_or_null("DoorFacade") as Sprite2D
		var step := area.get_node_or_null("DoorstepCue") as Sprite2D
		var arch := area.get_node_or_null("DoorArchCue") as Sprite2D
		var ok_visual := facade != null or (step != null and arch != null)
		if not ok_visual:
			_fail(area.name, "missing DoorFacade or Doorstep+Arch sprites")
			continue
		if facade != null and facade.texture == null:
			_fail(area.name, "DoorFacade texture null")
			continue
		_ok += 1
		print("G8_PORTAL_CUE: ok ", area.name, " facade=", facade != null, " step=", step != null, " arch=", arch != null)
	_finish(0 if _failures.is_empty() and _ok >= 2 else 1)


func _find_portals(n: Node, out: Array) -> void:
	if n is Area2D and (str(n.name).begins_with("WorldPortal_") or str(n.name).begins_with("Portal") or n.has_meta("portal_scene") or n.get_node_or_null("DoorFacade") != null or n.get_node_or_null("DoorstepCue") != null):
		if n.get_node_or_null("DoorstepCue") != null or n.get_node_or_null("DoorFacade") != null or str(n.name).begins_with("WorldPortal_"):
			out.append(n)
	for c in n.get_children():
		_find_portals(c, out)


func _fail(key: String, msg: String) -> void:
	_failures.append("%s: %s" % [key, msg])
	print("G8_PORTAL_CUE: FAIL ", key, " — ", msg)


func _finish(code: int) -> void:
	print("G8_PORTAL_CUE: ok=", _ok, " failures=", _failures.size())
	for f in _failures:
		print("G8_PORTAL_CUE: ", f)
	if _failures.is_empty() and _ok >= 2:
		print("G8_PORTAL_CUE: PASS")
		quit(0)
	else:
		print("G8_PORTAL_CUE: FAIL")
		quit(1)
