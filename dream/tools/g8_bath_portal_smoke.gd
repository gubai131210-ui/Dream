extends SceneTree

## Assert square bath portal has facade cues and SceneRouter can enter C43.
## godot --path dream --headless -s res://tools/g8_bath_portal_smoke.gd

const SQUARE := "res://scenes/areas/village_square/village_square.tscn"
const BATH_NEEDLE := "c43_bathhouse"

var _failures: PackedStringArray = []


func _initialize() -> void:
	print("G8_BATH_PORTAL: start")
	call_deferred("_boot")


func _boot() -> void:
	var packed := load(SQUARE) as PackedScene
	if packed == null:
		_fail("load square")
		_finish(1)
		return
	var host := packed.instantiate() as Node2D
	root.add_child(host)
	create_timer(1.1).timeout.connect(func() -> void:
		_probe(host)
	)


func _probe(host: Node2D) -> void:
	var portal := _find_bath_portal(host)
	if portal == null:
		_fail("bath portal missing")
		_finish(1)
		return
	var path := str(portal.get_meta("scene_path", ""))
	if path.findn(BATH_NEEDLE) < 0:
		_fail("bath portal scene_path=%s" % path)
		_finish(1)
		return
	for cue in ["DoorFacade", "DoorstepCue", "DoorArchCue"]:
		if portal.get_node_or_null(cue) == null:
			_fail("missing cue %s" % cue)
	var facade := portal.get_node_or_null("DoorFacade") as Sprite2D
	if facade == null or facade.texture == null:
		_fail("DoorFacade texture null")
	else:
		var tex_path := str(facade.texture.resource_path)
		if tex_path.is_empty() and facade.has_meta("facade_path"):
			tex_path = str(facade.get_meta("facade_path"))
		if tex_path.findn("facade_bath") < 0 and tex_path.findn("door_facade") < 0:
			_fail("unexpected facade texture %s" % tex_path)
		else:
			print("G8_BATH_PORTAL: facade=", tex_path)
	print("G8_BATH_PORTAL: path=", path)
	# Enter interior via the same router players use.
	SceneRouter.change_to(self, path)
	create_timer(0.8).timeout.connect(func() -> void:
		var cur := current_scene
		var cur_path := ""
		if cur != null:
			cur_path = str(cur.scene_file_path)
		if cur_path.findn(BATH_NEEDLE) < 0:
			# SceneTree.change_scene may replace current_scene asynchronously.
			var ok_name := false
			if cur != null and str(cur.name).findn("Bath") >= 0:
				ok_name = true
			if not ok_name:
				_fail("after change_to current=%s name=%s" % [cur_path, cur.name if cur else "?"])
				_finish(1)
				return
		print("G8_BATH_PORTAL: entered ", cur_path if not cur_path.is_empty() else cur.name)
		if _failures.is_empty():
			print("G8_BATH_PORTAL: PASS")
			_finish(0)
		else:
			_finish(1)
	)


func _find_bath_portal(n: Node) -> Node:
	if n is Area2D and n.has_meta("scene_path"):
		var p := str(n.get_meta("scene_path"))
		if p.findn(BATH_NEEDLE) >= 0:
			return n
	for c in n.get_children():
		var hit := _find_bath_portal(c)
		if hit != null:
			return hit
	return null


func _fail(msg: String) -> void:
	_failures.append(msg)
	push_error("G8_BATH_PORTAL: FAIL %s" % msg)
	print("G8_BATH_PORTAL: FAIL %s" % msg)


func _finish(code: int) -> void:
	quit(1 if not _failures.is_empty() else code)
