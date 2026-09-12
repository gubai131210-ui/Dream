extends SceneTree

## C62 secret chain: forest_deep secret portal has façade cues + enters cave.
## godot --path dream --headless -s res://tools/g8_c62_secret_smoke.gd

const FOREST := "res://scenes/areas/forest_deep/forest_deep.tscn"
const CAVE_NEEDLE := "c16_cave_entry"

var _failures: PackedStringArray = []


func _initialize() -> void:
	print("G8_C62: start")
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
		_probe(host)
	)


func _probe(host: Node2D) -> void:
	var portal := _find_secret_portal(host)
	if portal == null:
		_fail("secret portal missing")
		_finish(1)
		return
	if not bool(portal.get_meta("secret_chain", false)):
		_fail("secret_chain meta missing")
	var path := str(portal.get_meta("scene_path", ""))
	if path.findn(CAVE_NEEDLE) < 0:
		_fail("secret path=%s" % path)
		_finish(1)
		return
	for cue in ["DoorFacade", "DoorstepCue", "DoorArchCue"]:
		var node := portal.get_node_or_null(cue)
		if node == null:
			_fail("missing cue %s" % cue)
		elif not (node is Sprite2D):
			_fail("cue %s is %s not Sprite2D" % [cue, node.get_class()])
	var facade := portal.get_node_or_null("DoorFacade") as Sprite2D
	if facade == null or facade.texture == null:
		_fail("DoorFacade texture null")
	else:
		var tex_path := str(facade.texture.resource_path)
		if tex_path.is_empty() and facade.has_meta("facade_path"):
			tex_path = str(facade.get_meta("facade_path"))
		print("G8_C62: facade=", tex_path)
		# Forest hop must use CHAIN_A ruin_arch — not default door_facade.
		if tex_path.findn("ruin_arch") < 0:
			_fail("expected ruin_arch facade, got %s" % tex_path)
	print("G8_C62: path=", path)
	SceneRouter.change_to(self, path)
	create_timer(0.8).timeout.connect(func() -> void:
		var cur := current_scene
		var cur_path := ""
		if cur != null:
			cur_path = str(cur.scene_file_path)
		var ok := cur_path.findn(CAVE_NEEDLE) >= 0
		if not ok and cur != null and str(cur.name).findn("Cave") >= 0:
			ok = true
		if not ok:
			_fail("after change_to current=%s name=%s" % [cur_path, cur.name if cur else "?"])
			_finish(1)
			return
		print("G8_C62: entered ", cur_path if not cur_path.is_empty() else cur.name)
		if _failures.is_empty():
			print("G8_C62: PASS")
			_finish(0)
		else:
			_finish(1)
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
