extends SceneTree

## Interior open-FX activate smoke (C01 dresser/chest).
## godot --path dream --headless -s res://tools/g8_interior_open_fx_smoke.gd

const HOME := "res://scenes/interiors/c01_home/c01_home.tscn"

var _failures: PackedStringArray = []
var _ok: int = 0


func _initialize() -> void:
	print("G8_INTERIOR_FX: start")
	call_deferred("_boot")


func _boot() -> void:
	var packed := load(HOME) as PackedScene
	if packed == null:
		_fail("load", "c01_home null")
		_finish(1)
		return
	var host := packed.instantiate() as Node2D
	if host == null:
		_fail("instantiate", "not Node2D")
		_finish(1)
		return
	root.add_child(host)
	create_timer(1.2).timeout.connect(func() -> void:
		_probe(host)
	)


func _probe(host: Node2D) -> void:
	var targets: Array = []
	for hs in _collect_hotspots(host):
		if hs.has_meta("open_fx"):
			targets.append(hs)
	print("G8_INTERIOR_FX: open_fx_hotspots=", targets.size())
	if targets.is_empty():
		_fail("targets", "no open_fx hotspots in c01_home")
		_finish(1)
		return
	var activated := 0
	for hs in targets:
		var fx_name := str(hs.get_meta("open_fx"))
		var spr: Node = hs.get_node_or_null("Visual/PropSprite")
		if spr == null:
			_fail(fx_name, "PropSprite missing on %s" % hs.name)
			continue
		hs.emit_signal("activated", hs)
		activated += 1
		print("G8_INTERIOR_FX: activated ", hs.name, " fx=", fx_name)
	_ok = activated
	# Also exercise InteriorCraft.mcp_play_open_fx sync probe (MCP parity).
	var craft := host.get_node_or_null("Assembler")
	if craft != null and craft.has_method("mcp_play_open_fx"):
		var first_name := str((targets[0] as Node).name)
		var probe: Dictionary = craft.call("mcp_play_open_fx", first_name)
		print("G8_INTERIOR_FX: mcp_play_open_fx ", probe)
		if not bool(probe.get("ok", false)):
			_fail("mcp_probe", "mcp_play_open_fx failed: %s" % str(probe))
		elif int(probe.get("frames", 0)) < 2:
			_fail("mcp_frames", "expected ≥2 frames, got %s" % str(probe.get("frames")))
		elif not bool(probe.get("playing", false)):
			_fail("mcp_playing", "OpenFX not playing after mcp_play_open_fx")
	else:
		_fail("mcp_probe", "Assembler.mcp_play_open_fx missing")
	create_timer(0.85).timeout.connect(func() -> void:
		var played := 0
		for hs in targets:
			if not is_instance_valid(hs):
				_fail("freed", str(hs))
				continue
			if bool(hs.get_meta("_open_fx_played", false)):
				played += 1
			var visual: Node = hs.get_node_or_null("Visual")
			var has_anim := false
			if visual:
				for c in visual.get_children():
					if c is AnimatedSprite2D:
						has_anim = true
						break
			print("G8_INTERIOR_FX: post ", hs.name, " played=", hs.get_meta("_open_fx_played", false), " anim=", has_anim)
		if played < mini(targets.size(), 1):
			_fail("played", "no _open_fx_played flags set")
		_finish(0 if _failures.is_empty() and _ok > 0 else 1)
	)


func _collect_hotspots(n: Node) -> Array:
	var out: Array = []
	if n is Area2D and n.has_signal("activated"):
		out.append(n)
	for c in n.get_children():
		out.append_array(_collect_hotspots(c))
	return out


func _fail(key: String, msg: String) -> void:
	_failures.append("%s: %s" % [key, msg])
	print("G8_INTERIOR_FX: FAIL ", key, " — ", msg)


func _finish(code: int) -> void:
	print("G8_INTERIOR_FX: ok=", _ok, " failures=", _failures.size())
	for f in _failures:
		print("G8_INTERIOR_FX: ", f)
	if _failures.is_empty() and _ok > 0:
		print("G8_INTERIOR_FX: PASS")
		quit(0)
	else:
		print("G8_INTERIOR_FX: FAIL")
		quit(1)
