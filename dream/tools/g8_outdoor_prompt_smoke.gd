extends SceneTree

## Outdoor proximity 「互动」parity: AreaInteractHost hover wins.
## godot --path dream --headless -s res://tools/g8_outdoor_prompt_smoke.gd

const SQUARE := "res://scenes/areas/village_square/village_square.tscn"

var _failures: PackedStringArray = []


func _initialize() -> void:
	print("G8_OUTDOOR_PROMPT: start")
	call_deferred("_boot")


func _boot() -> void:
	var packed := load(SQUARE) as PackedScene
	if packed == null:
		_fail("load village_square")
		_finish(1)
		return
	var host := packed.instantiate() as Node2D
	root.add_child(host)
	create_timer(1.2).timeout.connect(func() -> void:
		_probe(host)
	)


func _probe(host: Node2D) -> void:
	var area_host := host.get_node_or_null(AreaInteractHost.NODE_NAME) as AreaInteractHost
	if area_host == null:
		_fail("AreaInteractHost missing on square")
		_finish(1)
		return
	if not area_host.has_method("get_executable_interact_target"):
		_fail("host missing get_executable_interact_target")
		_finish(1)
		return
	var hotspots: Array = []
	_collect_hotspots(host, hotspots)
	if hotspots.size() < 2:
		_fail("need ≥2 hotspots, got %d" % hotspots.size())
		_finish(1)
		return
	# Drive one process tick via director update path.
	area_host._process(0.0)
	var before: InteractableHotspot = area_host.get_executable_interact_target()
	print("G8_OUTDOOR_PROMPT: before=", before.title if before else "null")
	var hover_target: InteractableHotspot = null
	for hs in hotspots:
		if hs != before:
			hover_target = hs
			break
	if hover_target == null:
		hover_target = hotspots[0] as InteractableHotspot
	hover_target.call("_on_mouse_entered")
	area_host._process(0.0)
	var after: InteractableHotspot = area_host.get_executable_interact_target()
	if after != hover_target:
		_fail("hover did not win outdoor prompt: got %s expected %s" % [
			after.title if after else "null",
			hover_target.title,
		])
		_finish(1)
		return
	if not after.is_mouse_hovered():
		_fail("hover flag not set")
		_finish(1)
		return
	# Prompt label should be visible on winner.
	var prompt := after.get_node_or_null("ProximityPrompt") as Label
	if prompt == null or not prompt.visible:
		_fail("ProximityPrompt not shown on outdoor hover target")
		_finish(1)
		return
	print("G8_OUTDOOR_PROMPT: hover_wins=", after.title, " prompt=", prompt.text)
	_finish(0)


func _collect_hotspots(node: Node, out: Array) -> void:
	if node is InteractableHotspot:
		out.append(node)
	for c in node.get_children():
		_collect_hotspots(c, out)


func _fail(msg: String) -> void:
	_failures.append(msg)
	push_error("G8_OUTDOOR_PROMPT FAIL: " + msg)


func _finish(code: int) -> void:
	if code == 0 and _failures.is_empty():
		print("G8_OUTDOOR_PROMPT: PASS")
	else:
		for f in _failures:
			print("G8_OUTDOOR_PROMPT FAIL: ", f)
	quit(code)
