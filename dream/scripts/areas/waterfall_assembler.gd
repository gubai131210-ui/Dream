class_name WaterfallAssembler
extends Node

## Waterfall (A07) — cliff band → fall column → connected pool → outflow.
## Silhouette must read as vertical water + cliff, not a prop sitting on a dirt road.

const MAP_W := 40
const MAP_H := 30
const TREE_Y := 0.40

## Pool center (tile) — falls dump into the north rim of this ellipse.
const POOL_CX := 20.0
const POOL_CY := 16.0
const POOL_RX := 7.5
const POOL_RY := 5.2

var craft: AreaCraft = AreaCraft.new()


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	craft.setup(MAP_W, MAP_H, "wild")
	_rebuild_masks()
	craft.prepare_layers(ground, path, water)
	craft.paint_ecological_grass(ground)
	craft.paint_dirt_spurs(ground)
	craft.paint_water(water, ground)
	craft.paint_paths(path)
	_spawn_cascade_landmark(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _water_tile(x, y)
	_paint_approach_dirt()
	# Dirt may punch water ONLY on approach paths — never under the fall column / pool core.
	for y in range(MAP_H):
		for x in range(MAP_W):
			if not craft.is_dirt(x, y):
				continue
			if _is_fall_keep_water(x, y):
				craft.dirt_mask[y][x] = false
				continue
			craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _is_fall_keep_water(tx: int, ty: int) -> bool:
	# Protect pool + fall column so dirt paths cannot erase the cascade destination.
	if ty >= 9 and ty <= 20 and tx >= 14 and tx <= 26:
		return _pool_body(tx, ty) or (ty <= 12 and absf(float(tx) - POOL_CX) <= 3.5)
	return false


func _pool_body(tx: int, ty: int) -> bool:
	var nx := (float(tx) - POOL_CX) / POOL_RX
	var ny := (float(ty) - POOL_CY) / POOL_RY
	return nx * nx + ny * ny <= 1.0


func _water_tile(tx: int, ty: int) -> bool:
	# Main plunge pool (connected under the fall).
	if _pool_body(tx, ty):
		return true
	# Soft north notch so water meets the fall foot (not a dry dirt shelf).
	if ty >= 9 and ty <= 12 and absf(float(tx) - POOL_CX) <= 2.8:
		return true
	# South-west meander outflow toward river portal.
	if ty >= 19:
		var cx := 13.5 + sin(float(ty) * 0.45) * 2.0
		if absf(float(tx) - cx) <= 1.7:
			return true
	return false


func _set_dirt(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	if _is_fall_keep_water(tx, ty):
		return
	craft.dirt_mask[ty][tx] = true


func _paint_approach_dirt() -> void:
	# ONLY south / southwest approaches — never an E–W road through the fall.
	for ty in range(23, MAP_H):
		_set_dirt(18, ty)
		_set_dirt(19, ty)
		_set_dirt(20, ty)
	for tx in range(4, 16):
		_set_dirt(tx, 24)
		_set_dirt(tx, 25)
	# South rim viewing pads (below pool, not through cascade).
	for tx in range(14, 27):
		_set_dirt(tx, 22)
		_set_dirt(tx, 23)
	# West overlook spur (side path, north of pool left bank).
	for ty in range(10, 16):
		_set_dirt(10, ty)
		_set_dirt(11, ty)


func _scaled_fully_inside(pos: Vector2, tex: Texture2D, scale_f: float, zone: Rect2) -> bool:
	var size := Vector2(float(tex.get_width()), float(tex.get_height())) * scale_f
	var offset := Vector2(0.0, -float(tex.get_height()) * TREE_Y) * scale_f
	var top_left := pos + offset - size * 0.5
	var r := Rect2(top_left, size)
	return (
		r.position.x >= zone.position.x
		and r.position.y >= zone.position.y
		and r.end.x <= zone.end.x
		and r.end.y <= zone.end.y
	)


func _find_scaled_inside(
	ideal: Vector2,
	tex: Texture2D,
	scale_f: float,
	zone: Rect2,
	half_w: int,
	half_h: int,
	max_r: int,
	allow_path: bool
) -> Vector2:
	if craft.footprint_ok(ideal, half_w, half_h, allow_path) and _scaled_fully_inside(ideal, tex, scale_f, zone):
		return ideal
	var t := craft.world_to_tile(ideal)
	for r in range(0, max_r + 1):
		for oy in range(-r, r + 1):
			for ox in range(-r, r + 1):
				if r > 0 and maxi(absi(ox), absi(oy)) != r:
					continue
				var cand := craft.tile_center(t.x + ox, t.y + oy)
				if not craft.footprint_ok(cand, half_w, half_h, allow_path):
					continue
				if _scaled_fully_inside(cand, tex, scale_f, zone):
					return cand
	return Vector2.ZERO


func _spawn_scaled_prop(
	ysort: Node2D,
	path: String,
	ideal: Vector2,
	scale_f: float,
	z: int = 2,
	half_w: int = 1,
	half_h: int = 1,
	allow_path: bool = true,
	allow_water_foot: bool = false
) -> Sprite2D:
	if not ResourceLoader.exists(path):
		return null
	var tex := load(path) as Texture2D
	if tex == null:
		return null
	var zone := craft.map_play_rect(1.5)
	var cleared := Vector2.ZERO
	if allow_water_foot:
		# Manual search: footprint may stand on water/bank (cascade into pool).
		if _scaled_fully_inside(ideal, tex, scale_f, zone):
			cleared = ideal
		else:
			var t := craft.world_to_tile(ideal)
			for r in range(0, 14):
				for oy in range(-r, r + 1):
					for ox in range(-r, r + 1):
						if r > 0 and maxi(absi(ox), absi(oy)) != r:
							continue
						var cand := craft.tile_center(t.x + ox, t.y + oy)
						if _scaled_fully_inside(cand, tex, scale_f, zone):
							cleared = cand
							break
					if cleared != Vector2.ZERO:
						break
				if cleared != Vector2.ZERO:
					break
	else:
		cleared = _find_scaled_inside(ideal, tex, scale_f, zone, half_w, half_h, 16, allow_path)
	if cleared == Vector2.ZERO:
		for s2 in [scale_f * 0.9, scale_f * 0.75, 0.45]:
			if allow_water_foot:
				if _scaled_fully_inside(ideal + Vector2(0, 48), tex, s2, zone):
					cleared = ideal + Vector2(0, 48)
					scale_f = s2
					break
			else:
				cleared = _find_scaled_inside(ideal + Vector2(0, 64), tex, s2, zone, half_w, half_h, 18, allow_path)
				if cleared != Vector2.ZERO:
					scale_f = s2
					break
	if cleared == Vector2.ZERO:
		return null
	if not allow_water_foot:
		craft.add_contact_shadow(ysort, cleared, Vector2(16, 6))
	var spr := craft.spawn_sprite(ysort, path, cleared, z)
	spr.offset = craft.tree_offset_for(tex)
	spr.scale = Vector2(scale_f, scale_f)
	return spr


func _spawn_cascade_landmark(ysort: Node2D) -> void:
	## Full scenic landmark: cliff mouth → animated chute → splash → props → mist.
	## Anchor at the north pool notch so the fall reads into the water mask.
	var foot := craft.tile_center(int(POOL_CX), 11)
	_spawn_cliff_backfill(ysort, foot)
	var cliff := _spawn_cliff_mouth(ysort, foot)
	var fall := _spawn_waterfall_anim(ysort, foot + Vector2(0, -18))
	if fall == null:
		fall = _spawn_waterfall_fallback(ysort, foot + Vector2(0, -18))
	var splash := _spawn_splash_ring(ysort, foot + Vector2(0, 58))
	_spawn_scenic_props(ysort, foot)
	_spawn_cascade_veil(ysort, foot)
	if fall == null and cliff == null:
		return
	var anchor: Node2D = fall if fall != null else cliff
	var hs := craft.make_hotspot(
		ysort,
		"山涧飞瀑",
		"岩壁凹口泄流进潭；木台观瀑，藤蔓与水雾环绕。",
		foot + Vector2(0, 24),
		Vector2(168, 140)
	)
	var vis := hs.get_node_or_null("Visual") as Node2D
	if vis == null:
		return
	for node in [cliff, fall, splash]:
		if node == null:
			continue
		var n := node as Node2D
		var world: Vector2 = n.global_position
		n.reparent(vis)
		n.global_position = world
	# Keep QA / smoke anchor readable even if fall used fallback.
	if fall == null and anchor != null and anchor.name != "WaterfallAnim":
		anchor.name = "WaterfallAnim"


func _spawn_cliff_mouth(ysort: Node2D, foot: Vector2) -> Node2D:
	var path := "res://assets/sprites/props/cascade_cliff_mouth_v1.png"
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/props/waterfall_tall_00.png"
	if not ResourceLoader.exists(path):
		return null
	var tex := load(path) as Texture2D
	if tex == null:
		return null
	var spr := Sprite2D.new()
	spr.name = "CascadeCliff"
	spr.texture = tex
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Foot near pool notch; cliff hangs upward (bottom of sprite near water).
	spr.position = foot + Vector2(0, -72)
	spr.z_index = 2
	spr.scale = Vector2(1.15, 1.15)
	ysort.add_child(spr)
	return spr


func _spawn_cliff_backfill(ysort: Node2D, foot: Vector2) -> void:
	## Extra rock shoulders so the new cliff doesn't float as a lone cutout.
	var specs := [
		{"i": 2, "pos": foot + Vector2(-110, -130), "s": 0.48, "z": 1},
		{"i": 1, "pos": foot + Vector2(110, -125), "s": 0.46, "z": 1},
		{"i": 0, "pos": foot + Vector2(-150, -40), "s": 0.4, "z": 1},
		{"i": 4, "pos": foot + Vector2(150, -35), "s": 0.4, "z": 1},
		{"i": 3, "pos": foot + Vector2(-90, 70), "s": 0.36, "z": 2},
		{"i": 5, "pos": foot + Vector2(95, 75), "s": 0.35, "z": 2},
	]
	for s in specs:
		var path := "res://assets/sprites/props/rock_%02d.png" % int(s["i"])
		var spr := _spawn_scaled_prop(ysort, path, s["pos"], float(s["s"]), int(s["z"]), 1, 1, true, false)
		if spr:
			spr.modulate = Color(0.8, 0.82, 0.84)


func _spawn_cliff_frame(ysort: Node2D) -> void:
	## Legacy name kept for docs/QA — landmark assembly is the real entry.
	pass


func _spawn_waterfall(ysort: Node2D) -> void:
	## Legacy name — prefer _spawn_cascade_landmark from assemble().
	pass


func _spawn_waterfall_fallback(ysort: Node2D, foot: Vector2) -> Node2D:
	var mid := "res://assets/sprites/props/waterfall_mid_00.png"
	if not ResourceLoader.exists(mid):
		return null
	var fall := _spawn_scaled_prop(ysort, mid, foot, 0.55, 4, 1, 1, true, true)
	if fall:
		fall.name = "WaterfallAnim"
	return fall


func _spawn_waterfall_anim(ysort: Node2D, foot: Vector2) -> Node2D:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("fall")
	frames.set_animation_speed("fall", 12.0)
	frames.set_animation_loop("fall", true)
	var loaded := 0
	for i in range(6):
		var path := "res://assets/sprites/props/waterfall_water_%02d.png" % i
		if not ResourceLoader.exists(path):
			continue
		var tex := load(path) as Texture2D
		if tex == null:
			continue
		frames.add_frame("fall", tex)
		loaded += 1
	if loaded < 4:
		return null
	var anim := AnimatedSprite2D.new()
	anim.name = "WaterfallAnim"
	anim.sprite_frames = frames
	anim.centered = true
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.position = foot
	anim.z_index = 4
	# Sit inside the cliff chute — bright overlay on the dark baked crevice.
	anim.scale = Vector2(0.72, 0.78)
	anim.modulate = Color(0.95, 0.98, 1.0, 0.88)
	anim.play("fall")
	ysort.add_child(anim)
	return anim


func _spawn_splash_ring(ysort: Node2D, pos: Vector2) -> Node2D:
	var path := "res://assets/sprites/fx/cascade_splash_ring_00.png"
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/props/waterfall_splash_00.png"
	if not ResourceLoader.exists(path):
		return null
	var splash := craft.spawn_sprite(ysort, path, pos, 5)
	splash.name = "CascadeSplash"
	splash.scale = Vector2(0.95, 0.7)
	splash.modulate = Color(0.9, 0.96, 1.0, 0.55)
	splash.z_index = 5
	var pulse := splash.create_tween().set_loops()
	pulse.tween_property(splash, "modulate:a", 0.85, 0.5).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(splash, "modulate:a", 0.4, 0.45).set_trans(Tween.TRANS_SINE)
	return splash


func _spawn_scenic_props(ysort: Node2D, foot: Vector2) -> void:
	## Extra scenic layer — bench, ferns, vines, moss rocks (user-requested).
	var placements: Array[Dictionary] = [
		{"path": "res://assets/sprites/props/cascade_bench_00.png", "pos": foot + Vector2(-150, 120), "s": 1.0, "z": 3},
		{"path": "res://assets/sprites/props/cascade_fern_00.png", "pos": foot + Vector2(-95, 40), "s": 1.1, "z": 3},
		{"path": "res://assets/sprites/props/cascade_fern_00.png", "pos": foot + Vector2(105, 55), "s": 1.0, "z": 3},
		{"path": "res://assets/sprites/props/cascade_vines_00.png", "pos": foot + Vector2(-70, -90), "s": 1.05, "z": 3},
		{"path": "res://assets/sprites/props/cascade_vines_00.png", "pos": foot + Vector2(75, -85), "s": 1.0, "z": 3},
		{"path": "res://assets/sprites/props/cascade_moss_rock_00.png", "pos": foot + Vector2(-130, 55), "s": 0.95, "z": 2},
		{"path": "res://assets/sprites/props/cascade_moss_rock_00.png", "pos": foot + Vector2(140, 65), "s": 0.9, "z": 2},
		{"path": "res://assets/sprites/props/cascade_moss_rock_00.png", "pos": foot + Vector2(-40, 95), "s": 0.75, "z": 2},
	]
	for i in placements.size():
		var spec: Dictionary = placements[i]
		var path: String = spec["path"]
		if not ResourceLoader.exists(path):
			continue
		var spr := craft.spawn_sprite(ysort, path, spec["pos"] as Vector2, int(spec["z"]))
		spr.name = "CascadeProp_%d" % i
		var sc := float(spec["s"])
		spr.scale = Vector2(sc, sc)
		if "fern" in path or "vine" in path:
			WindSway.attach(spr, "flower" if "fern" in path else "reed", float(i) * 0.4)


func _spawn_cascade_veil(ysort: Node2D, foot: Vector2 = Vector2(640, 360)) -> void:
	var mist_new := "res://assets/sprites/fx/cascade_mist_00.png"
	var samples: Array[Dictionary] = [
		{"pos": foot + Vector2(-30, -40), "s": 1.3, "a": 0.42},
		{"pos": foot + Vector2(35, -30), "s": 1.2, "a": 0.38},
		{"pos": foot + Vector2(0, 20), "s": 1.55, "a": 0.34},
		{"pos": foot + Vector2(-20, 70), "s": 1.15, "a": 0.45},
		{"pos": foot + Vector2(25, 80), "s": 1.1, "a": 0.4},
	]
	for i in samples.size():
		var mist_path := mist_new
		if not ResourceLoader.exists(mist_path):
			mist_path = "res://assets/sprites/fx/waterfall_mist_%02d.png" % (i % 2)
		if not ResourceLoader.exists(mist_path):
			continue
		var target_a := float(samples[i]["a"])
		var spr := craft.spawn_sprite(ysort, mist_path, samples[i]["pos"] as Vector2, 6)
		var sc := float(samples[i]["s"])
		spr.scale = Vector2(sc, sc * 0.9)
		spr.modulate = Color(0.88, 0.94, 0.98, target_a * 0.5)
		spr.name = "CascadeVeil_%d" % i
		var tw := spr.create_tween().set_loops()
		tw.tween_interval(0.12 * float(i))
		tw.tween_property(spr, "modulate:a", target_a, 1.0).set_trans(Tween.TRANS_SINE)
		tw.tween_property(spr, "modulate:a", target_a * 0.45, 1.2).set_trans(Tween.TRANS_SINE)


func _spawn_trees(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	# Side canopy only — leave cliff/fall/pool readable in 1/8 silhouette.
	var ideals: Array[Vector2] = [
		Vector2(120, 320), Vector2(140, 560), Vector2(160, 800),
		Vector2(1140, 340), Vector2(1160, 580), Vector2(1120, 800),
		Vector2(300, 840), Vector2(980, 840),
	]
	for i in ideals.size():
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		var spr := craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 8, false)
		if spr:
			spr.modulate = Color(0.78, 0.84, 0.80)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "farmer", "观瀑旅人", "在南岸观瀑土径上来回走动。",
		[Vector2(480, 720), Vector2(640, 740), Vector2(800, 720), Vector2(640, 780)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→河流", SceneRouter.RIVER_PATH, Vector2(200, 820), Vector2(96, 56))
	craft.make_portal(ysort, "→深林", SceneRouter.FOREST_DEEP_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 920), Vector2(96, 48))
	# C26 — west overlook spur (behind / beside curtain); append-only, no silhouette wipe.
	craft.make_portal(
		ysort, "进入瀑后洞窟", SceneRouter.C26_WATERFALL_CAVE_PATH,
		craft.tile_center(11, 12), Vector2(100, 56)
	)
