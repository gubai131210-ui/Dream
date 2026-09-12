extends SceneTree

## Headless smoke: C53 work pose flash + C58 shake_tree leaf_fall FX.
## godot --path dream --headless -s res://tools/g8_anim_fx_smoke.gd

const SQUARE := "res://scenes/areas/village_square/village_square.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	print("G8_ANIM_FX: start")
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
	var demo := host.get_node_or_null("NpcRoutineDemo")
	if demo == null or not demo.has_method("cycle_work_ring"):
		_fail("NpcRoutineDemo missing")
		_finish(1)
		return
	demo.call("cycle_work_ring")
	create_timer(0.15).timeout.connect(func() -> void:
		_check_pose_then_tree(host)
	)


func _check_pose_then_tree(host: Node2D) -> void:
	var ysort := host.get_node_or_null("YSortRoot") as Node2D
	if ysort == null:
		_fail("YSortRoot missing")
		_finish(1)
		return
	var cue := ysort.get_node_or_null("WorkPoseCue") as Node2D
	if cue == null:
		_fail("WorkPoseCue not spawned")
		_finish(1)
		return
	var anim := cue.get_node_or_null("WorkPoseAnim") as AnimatedSprite2D
	if anim == null or anim.sprite_frames == null:
		_fail("WorkPoseAnim missing frames")
		_finish(1)
		return
	var frame_n := anim.sprite_frames.get_frame_count("pose")
	if frame_n < 4:
		_fail("WorkPoseAnim frame_count=%d want>=4" % frame_n)
		_finish(1)
		return
	print("G8_ANIM_FX: work_pose frames=%d" % frame_n)

	var tree_hs := _find_named(ysort, "WorldHS_摇树")
	if tree_hs == null:
		_fail("shake_tree hotspot missing")
		_finish(1)
		return
	if tree_hs.has_signal("activated"):
		tree_hs.emit_signal("activated", tree_hs)
	create_timer(0.12).timeout.connect(func() -> void:
		if not _has_temp_fx(tree_hs):
			_fail("leaf_fall FX not observed after shake_tree activate")
			_finish(1)
			return
		print("G8_ANIM_FX: shake_tree leaf FX ok")
		if _failures.is_empty():
			print("G8_ANIM_FX: PASS")
			_finish(0)
		else:
			_finish(1)
	)


func _has_temp_fx(n: Node) -> bool:
	for c in n.get_children():
		var nm := str(c.name)
		if nm.begins_with("Fx_") or nm.begins_with("FX_") or nm.contains("leaf_fall"):
			return true
		if c is AnimatedSprite2D and nm != "Anim":
			return true
		if _has_temp_fx(c):
			return true
	return false


func _find_named(root_n: Node, want: String) -> Node:
	if root_n.name == want:
		return root_n
	for c in root_n.get_children():
		var hit := _find_named(c, want)
		if hit != null:
			return hit
	return null


func _fail(msg: String) -> void:
	_failures.append(msg)
	push_error("G8_ANIM_FX: FAIL %s" % msg)
	print("G8_ANIM_FX: FAIL %s" % msg)


func _finish(code: int) -> void:
	quit(1 if not _failures.is_empty() else code)
