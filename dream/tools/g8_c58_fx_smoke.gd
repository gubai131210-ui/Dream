extends SceneTree

## C58 multi-frame FX: well_rope / crate_lid / leaf_fall / bird_peck appear on activate.
## Asserts oneshot starts playing, then pauses on last frame (MCP parity).
## godot --path dream --headless -s res://tools/g8_c58_fx_smoke.gd

const SQUARE := "res://scenes/areas/village_square/village_square.tscn"

var _failures: PackedStringArray = []
var _host: Node2D
var _cases: Array = []


func _initialize() -> void:
	print("G8_C58_FX: start")
	call_deferred("_boot")


func _boot() -> void:
	var packed := load(SQUARE) as PackedScene
	if packed == null:
		_fail("load square")
		_finish(1)
		return
	_host = packed.instantiate() as Node2D
	root.add_child(_host)
	create_timer(1.2).timeout.connect(func() -> void:
		_probe_play()
	)


func _probe_play() -> void:
	var kit := _host.get_node_or_null("WorldInteractKit")
	if kit == null or not kit.has_method("_handle_interact"):
		_fail("WorldInteractKit missing")
		_finish(1)
		return
	_cases = [
		{"id": "well_water", "fx": "FX_well_rope", "hs": "WorldHS_井水"},
		{"id": "crate_search", "fx": "FX_crate_lid", "hs": "WorldHS_木箱"},
		{"id": "shake_tree", "fx": "FX_leaf_fall", "hs": "WorldHS_摇树"},
		{"id": "feed_critter", "fx": "FX_bird_peck", "hs": "WorldHS_喂鸟"},
	]
	for c in _cases:
		kit.call("_handle_interact", str(c["id"]), "t", "d")
		var hs_path := "YSortRoot/WorldInteractRoot/%s/Visual/%s" % [str(c["hs"]), str(c["fx"])]
		var fx := _host.get_node_or_null(hs_path)
		if fx == null or not (fx is AnimatedSprite2D):
			_fail("missing %s after %s" % [str(c["fx"]), str(c["id"])])
			continue
		var anim := fx as AnimatedSprite2D
		if not anim.is_playing():
			_fail("%s not playing" % str(c["fx"]))
			continue
		var sf := anim.sprite_frames
		if sf == null or sf.get_frame_count("oneshot") < 2:
			_fail("%s frame_count < 2" % str(c["fx"]))
			continue
		print("G8_C58_FX: ok ", c["id"], " frames=", sf.get_frame_count("oneshot"))
	if not _failures.is_empty():
		_finish(1)
		return
	create_timer(0.85).timeout.connect(func() -> void:
		_probe_held()
	)


func _probe_held() -> void:
	for c in _cases:
		var hs_path := "YSortRoot/WorldInteractRoot/%s/Visual/%s" % [str(c["hs"]), str(c["fx"])]
		var fx := _host.get_node_or_null(hs_path)
		if fx == null or not (fx is AnimatedSprite2D):
			_fail("held missing %s" % str(c["fx"]))
			continue
		var anim := fx as AnimatedSprite2D
		var sf := anim.sprite_frames
		var last := -1
		if sf != null and sf.has_animation("oneshot"):
			last = sf.get_frame_count("oneshot") - 1
		var held_ok := (not anim.is_playing()) and last >= 0 and anim.frame == last
		print(
			"G8_C58_FX: held ",
			c["id"],
			" playing=",
			anim.is_playing(),
			" frame=",
			anim.frame,
			" last=",
			last,
			" held_ok=",
			held_ok,
		)
		if not held_ok:
			_fail("held_frame %s" % str(c["id"]))
	_finish(0 if _failures.is_empty() else 1)


func _fail(msg: String) -> void:
	_failures.append(msg)
	push_error("G8_C58_FX FAIL: " + msg)


func _finish(code: int) -> void:
	if code == 0:
		print("G8_C58_FX: PASS")
	else:
		for f in _failures:
			print("G8_C58_FX FAIL: ", f)
	quit(code)
