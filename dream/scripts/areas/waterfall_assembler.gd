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
	_spawn_cliff_frame(ysort)
	_spawn_waterfall(ysort)
	_spawn_cascade_veil(ysort)
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


func _spawn_cliff_frame(ysort: Node2D) -> void:
	## Rock amphitheater + ledge lip so the cascade reads as a cliff-mouth spring,
	## not a free-floating sheet on grass (SLYNYRD grammar: mouth → flow → splash).
	_spawn_cliff_rocks(ysort)
	_spawn_rim_rocks(ysort)
	var lip := "res://assets/sprites/props/waterfall_base_norock_v4.png"
	if not ResourceLoader.exists(lip):
		lip = "res://assets/sprites/props/waterfall_mid_00.png"
	var foot := craft.tile_center(int(POOL_CX), 10)
	var ledge := _spawn_scaled_prop(ysort, lip, foot, 0.62, 3, 2, 1, true, true)
	if ledge:
		ledge.name = "CascadeLedge"
		ledge.modulate = Color(0.82, 0.84, 0.86, 1.0)
		ledge.z_index = 3


func _spawn_waterfall(ysort: Node2D) -> void:
	## Cascade sits in the cliff notch and dumps into the pool notch (ty≈11).
	var foot := craft.tile_center(int(POOL_CX), 11) + Vector2(0, -8)
	var fall: Node2D = _spawn_waterfall_anim(ysort, foot)
	if fall == null:
		var mid := "res://assets/sprites/props/waterfall_mid_00.png"
		if ResourceLoader.exists(mid):
			fall = _spawn_scaled_prop(ysort, mid, foot, 0.48, 4, 1, 1, true, true)
			if fall:
				fall.name = "WaterfallAnim"
	if fall == null:
		return
	if fall is CanvasItem:
		(fall as CanvasItem).modulate = Color(0.92, 0.96, 1.0, 0.4)
		# Soft reveal so the sheet doesn't pop onto grass in one frame.
		var reveal := (fall as CanvasItem).create_tween()
		reveal.tween_property(fall, "modulate:a", 0.92, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	var splash: Node2D = null
	var splash_path := "res://assets/sprites/props/waterfall_splash_00.png"
	if ResourceLoader.exists(splash_path):
		splash = craft.spawn_sprite(ysort, splash_path, foot + Vector2(0, 42), 5)
		splash.scale = Vector2(0.62, 0.5)
		splash.modulate = Color(0.9, 0.95, 1.0, 0.35)
		splash.z_index = 5
		var splash_in := splash.create_tween()
		splash_in.tween_property(splash, "modulate:a", 0.78, 0.8).set_trans(Tween.TRANS_SINE)
		splash_in.tween_callback(func() -> void:
			if not is_instance_valid(splash):
				return
			var pulse := splash.create_tween().set_loops()
			pulse.tween_property(splash, "modulate:a", 0.55, 0.35).set_trans(Tween.TRANS_SINE)
			pulse.tween_property(splash, "modulate:a", 0.85, 0.45).set_trans(Tween.TRANS_SINE)
		)
	var hs_fall := craft.make_hotspot(
		ysort, "山涧飞瀑", "岩壁凹口泄流进潭，水雾沿崖面散开。",
		fall.position + Vector2(0, 36), Vector2(120, 96)
	)
	var vis := hs_fall.get_node_or_null("Visual") as Node2D
	if vis:
		var fall_world := fall.global_position
		fall.reparent(vis)
		fall.global_position = fall_world
		if splash != null:
			var splash_world := splash.global_position
			splash.reparent(vis)
			splash.global_position = splash_world


func _spawn_waterfall_anim(ysort: Node2D, foot: Vector2) -> Node2D:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("fall")
	frames.set_animation_speed("fall", 10.0)
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
	# Narrower column so it sits inside the rock mouth.
	anim.scale = Vector2(0.42, 0.5)
	anim.play("fall")
	ysort.add_child(anim)
	return anim


func _spawn_cascade_veil(ysort: Node2D) -> void:
	## Soft mist veil around mouth + splash — framing, not a second water clock.
	var samples: Array[Dictionary] = [
		{"pos": Vector2(600, 300), "s": 1.6, "a": 0.28},
		{"pos": Vector2(680, 310), "s": 1.5, "a": 0.26},
		{"pos": Vector2(640, 360), "s": 1.9, "a": 0.22},
		{"pos": Vector2(620, 430), "s": 1.4, "a": 0.3},
		{"pos": Vector2(660, 440), "s": 1.35, "a": 0.28},
	]
	for i in samples.size():
		var mist_path := "res://assets/sprites/fx/waterfall_mist_%02d.png" % (i % 2)
		if not ResourceLoader.exists(mist_path):
			continue
		var target_a := float(samples[i]["a"])
		var spr := craft.spawn_sprite(ysort, mist_path, samples[i]["pos"] as Vector2, 6)
		var sc := float(samples[i]["s"])
		spr.scale = Vector2(sc, sc * 0.85)
		spr.modulate = Color(0.88, 0.94, 0.98, 0.0)
		spr.name = "CascadeVeil_%d" % i
		var tw := spr.create_tween()
		tw.tween_interval(0.15 * float(i))
		tw.tween_property(spr, "modulate:a", target_a, 0.9).set_trans(Tween.TRANS_SINE)
		tw.tween_callback(func() -> void:
			if not is_instance_valid(spr):
				return
			var pulse := spr.create_tween().set_loops()
			pulse.tween_property(spr, "modulate:a", target_a * 0.55, 1.1).set_trans(Tween.TRANS_SINE)
			pulse.tween_property(spr, "modulate:a", target_a, 1.3).set_trans(Tween.TRANS_SINE)
		)


func _spawn_cliff_rocks(ysort: Node2D) -> void:
	# North cliff mass behind the fall — denser amphitheater.
	var specs := [
		{"i": 0, "pos": Vector2(520, 200), "s": 0.5, "z": 1},
		{"i": 1, "pos": Vector2(760, 210), "s": 0.48, "z": 1},
		{"i": 2, "pos": Vector2(640, 160), "s": 0.55, "z": 0},
		{"i": 4, "pos": Vector2(430, 260), "s": 0.42, "z": 1},
		{"i": 5, "pos": Vector2(850, 270), "s": 0.42, "z": 1},
		{"i": 3, "pos": Vector2(560, 250), "s": 0.4, "z": 2},
		{"i": 0, "pos": Vector2(720, 255), "s": 0.4, "z": 2},
	]
	for s in specs:
		var path := "res://assets/sprites/props/rock_%02d.png" % int(s["i"])
		var spr := _spawn_scaled_prop(ysort, path, s["pos"], float(s["s"]), int(s["z"]), 1, 1, true, false)
		if spr:
			spr.modulate = Color(0.78, 0.8, 0.82)


func _spawn_rim_rocks(ysort: Node2D) -> void:
	# Pool rim flanks — land only, never through cascade / fall keep-water.
	var specs := [
		{"i": 0, "pos": Vector2(400, 480), "s": 0.4},
		{"i": 1, "pos": Vector2(880, 500), "s": 0.38},
		{"i": 3, "pos": Vector2(480, 700), "s": 0.36},
		{"i": 4, "pos": Vector2(780, 690), "s": 0.35},
		{"i": 2, "pos": Vector2(520, 420), "s": 0.34},
		{"i": 5, "pos": Vector2(760, 410), "s": 0.34},
	]
	for s in specs:
		var path := "res://assets/sprites/props/rock_%02d.png" % int(s["i"])
		_spawn_scaled_prop(ysort, path, s["pos"], float(s["s"]), 2, 1, 1, true, false)


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
