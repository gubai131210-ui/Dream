extends SceneTree

## Interior interact target sync: hover wins over nearest for proximity prompt.
## godot --path dream --headless -s res://tools/g8_interact_target_smoke.gd

const HOME := "res://scenes/interiors/c01_home/c01_home.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	print("G8_TARGET: start")
	call_deferred("_boot")


func _boot() -> void:
	var packed := load(HOME) as PackedScene
	if packed == null:
		_fail("load c01_home")
		_finish(1)
		return
	var host := packed.instantiate() as Node2D
	root.add_child(host)
	create_timer(1.0).timeout.connect(func() -> void:
		_probe(host)
	)


func _probe(host: Node2D) -> void:
	var ctrl := host as InteriorRoomController
	if ctrl == null:
		# Scene root may be the controller itself.
		ctrl = host.get_node_or_null(".") as InteriorRoomController
	if ctrl == null and host.get_script() != null:
		ctrl = host
	if not (host is InteriorRoomController):
		# Controllers are typically the scene root Node2D with the script.
		pass
	var room := host
	if not room.has_method("get_executable_interact_target"):
		_fail("host missing get_executable_interact_target")
		_finish(1)
		return
	var hotspots: Array = []
	_collect_hotspots(room, hotspots)
	if hotspots.size() < 2:
		_fail("need ≥2 hotspots, got %d" % hotspots.size())
		_finish(1)
		return
	# Force process once for proximity pick.
	if room.has_method("_update_nearest_proximity_prompt"):
		room.call("_update_nearest_proximity_prompt")
	var nearest_first: InteractableHotspot = room.call("get_executable_interact_target")
	print("G8_TARGET: nearest_or_none=", nearest_first.title if nearest_first else "null")
	# Simulate hover on a hotspot that is NOT the current prompt (if possible).
	var hover_target: InteractableHotspot = null
	for hs in hotspots:
		if hs != nearest_first:
			hover_target = hs
			break
	if hover_target == null:
		hover_target = hotspots[0] as InteractableHotspot
	# Drive mouse_entered path.
	hover_target.call("_on_mouse_entered")
	if room.has_method("_update_nearest_proximity_prompt"):
		room.call("_update_nearest_proximity_prompt")
	var after: InteractableHotspot = room.call("get_executable_interact_target")
	if after != hover_target:
		_fail("hover did not win prompt: got %s expected %s" % [
			after.title if after else "null",
			hover_target.title,
		])
		_finish(1)
		return
	print("G8_TARGET: hover_wins=", after.title)
	# Click sync: activate another hotspot → executable becomes that one.
	var other: InteractableHotspot = null
	for hs in hotspots:
		if hs != hover_target:
			other = hs
			break
	if other != null:
		room.call("_on_hotspot", other)
		var synced: InteractableHotspot = room.call("get_executable_interact_target")
		if synced != other:
			_fail("click did not sync prompt to %s" % other.title)
			_finish(1)
			return
		print("G8_TARGET: click_sync=", synced.title)
	if _failures.is_empty():
		print("G8_TARGET: PASS")
		_finish(0)
	else:
		_finish(1)


func _collect_hotspots(n: Node, out: Array) -> void:
	if n is InteractableHotspot:
		out.append(n)
	for c in n.get_children():
		_collect_hotspots(c, out)


func _fail(msg: String) -> void:
	_failures.append(msg)
	push_error("G8_TARGET: FAIL %s" % msg)
	print("G8_TARGET: FAIL %s" % msg)


func _finish(code: int) -> void:
	quit(1 if not _failures.is_empty() else code)
