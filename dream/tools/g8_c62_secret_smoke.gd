extends SceneTree

## C62 secret chain full hop: forest → cave → waterfall → lake.
## Each hop: secret_chain portal, Sprite2D DoorFacade/step/arch, SceneRouter enter.
## godot --path dream --headless -s res://tools/g8_c62_secret_smoke.gd

const FOREST := "res://scenes/areas/forest_deep/forest_deep.tscn"

const HOPS := [
	{
		"expect_facade": "ruin_arch",
		"to_needle": "c16_cave_entry",
		"name_alt": "Cave",
	},
	{
		"expect_facade": "door_facade",
		"to_needle": "waterfall",
		"name_alt": "Waterfall",
	},
	{
		"expect_facade": "door_facade",
		"to_needle": "lake",
		"name_alt": "Lake",
	},
]

var _failures: PackedStringArray = []
var _hop_i: int = 0


func _initialize() -> void:
	print("G8_C62: start full chain")
	call_deferred("_boot")


func _boot() -> void:
	var packed := load(FOREST) as PackedScene
	if packed == null:
		_fail("load forest_deep")
		_finish(1)
		return
	var host := packed.instantiate() as Node2D
	root.add_child(host)
	create_timer(1.1).timeout.connect(func() -> void:
		_probe_hop(host)
	)


func _probe_hop(host: Node) -> void:
	if _hop_i >= HOPS.size():
		if _failures.is_empty():
			print("G8_C62: PASS full chain")
			_finish(0)
		else:
			_finish(1)
		return
	var hop: Dictionary = HOPS[_hop_i]
	var portal := _find_secret_portal(host)
	if portal == null:
		_fail("hop%d secret portal missing on %s" % [_hop_i, host.name if host else "?"])
		_finish(1)
		return
	if not bool(portal.get_meta("secret_chain", false)):
		_fail("hop%d secret_chain meta missing" % _hop_i)
	var path := str(portal.get_meta("scene_path", ""))
	var needle := str(hop["to_needle"])
	if path.findn(needle) < 0:
		_fail("hop%d path=%s expected %s" % [_hop_i, path, needle])
		_finish(1)
		return
	for cue in ["DoorFacade", "DoorstepCue", "DoorArchCue"]:
		var node := portal.get_node_or_null(cue)
		if node == null:
			_fail("hop%d missing cue %s" % [_hop_i, cue])
		elif not (node is Sprite2D):
			_fail("hop%d cue %s is %s not Sprite2D" % [_hop_i, cue, node.get_class()])
	var facade := portal.get_node_or_null("DoorFacade") as Sprite2D
	if facade == null or facade.texture == null:
		_fail("hop%d DoorFacade texture null" % _hop_i)
	else:
		var tex_path := str(facade.texture.resource_path)
		if tex_path.is_empty() and facade.has_meta("facade_path"):
			tex_path = str(facade.get_meta("facade_path"))
		print("G8_C62: hop%d facade=%s" % [_hop_i, tex_path])
		var expect_facade := str(hop["expect_facade"])
		if tex_path.findn(expect_facade) < 0:
			_fail("hop%d expected facade %s, got %s" % [_hop_i, expect_facade, tex_path])
	print("G8_C62: hop%d path=%s" % [_hop_i, path])
	SceneRouter.change_to(self, path)
	create_timer(0.9).timeout.connect(func() -> void:
		var cur := current_scene
		var cur_path := ""
		if cur != null:
			cur_path = str(cur.scene_file_path)
		var ok := cur_path.findn(needle) >= 0
		var alt := str(hop.get("name_alt", ""))
		if not ok and cur != null and not alt.is_empty() and str(cur.name).findn(alt) >= 0:
			ok = true
		if not ok:
			_fail("hop%d after change_to current=%s name=%s" % [
				_hop_i, cur_path, cur.name if cur else "?"
			])
			_finish(1)
			return
		print("G8_C62: hop%d entered %s" % [
			_hop_i, cur_path if not cur_path.is_empty() else str(cur.name)
		])
		_hop_i += 1
		_probe_hop(cur)
	)


func _find_secret_portal(n: Node) -> Node:
	if n is Area2D and n.has_meta("secret_chain") and bool(n.get_meta("secret_chain")):
		return n
	for c in n.get_children():
		var hit := _find_secret_portal(c)
		if hit != null:
			return hit
	return null


func _fail(msg: String) -> void:
	_failures.append(msg)
	push_error("G8_C62: FAIL %s" % msg)
	print("G8_C62: FAIL %s" % msg)


func _finish(code: int) -> void:
	quit(1 if not _failures.is_empty() else code)
