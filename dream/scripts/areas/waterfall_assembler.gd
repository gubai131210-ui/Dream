class_name WaterfallAssembler
extends Node

## Waterfall (A07) — sliced waterfall + rocks + soft smoke mist.
## No ColorRect landmark hacks. Tall sprites use full AABB in play zone.

const MAP_W := 40
const MAP_H := 30
const TREE_Y := 0.40


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
	_spawn_waterfall_props(ysort)
	_spawn_rocks(ysort)
	_spawn_mist(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _pool_or_stream(x, y)
	_paint_approach_dirt()
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_dirt(x, y) or craft.is_path(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _pool_or_stream(tx: int, ty: int) -> bool:
	# Mist pool under the fall (south of cliff band).
	var pcx := 20.0 + sin(float(ty) * 0.35) * 1.2
	var pr := 5.2 + 0.6 * sin(float(tx) * 0.4)
	if ty >= 12 and ty <= 22:
		var dx := absf(float(tx) - pcx)
		var dy := absf(float(ty) - 16.5) / 1.4
		if dx * dx / (pr * pr) + dy * dy / 16.0 <= 1.0:
			return true
	# Narrow outflow toward river (south-west meander).
	if ty >= 20:
		var cx := 14.0 + sin(float(ty) * 0.5) * 1.8
		if absf(float(tx) - cx) <= 1.6:
			return true
	return false


func _set_dirt(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	craft.dirt_mask[ty][tx] = true
	craft.water_mask[ty][tx] = false


func _paint_approach_dirt() -> void:
	# Path from south / west to pool rim — no stone plaza.
	for ty in range(22, MAP_H):
		_set_dirt(18, ty)
		_set_dirt(19, ty)
		_set_dirt(20, ty)
	for tx in range(6, 18):
		_set_dirt(tx, 24)
		_set_dirt(tx, 25)
	# Viewing ledge north of pool (below cliff).
	for tx in range(14, 27):
		_set_dirt(tx, 11)
		_set_dirt(tx, 12)


## Scaled AABB (Godot applies scale to both size and offset).
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
	allow_path: bool = true
) -> Sprite2D:
	if not ResourceLoader.exists(path):
		return null
	var tex := load(path) as Texture2D
	if tex == null:
		return null
	var zone := craft.map_play_rect(2.0)
	var cleared := _find_scaled_inside(ideal, tex, scale_f, zone, half_w, half_h, 16, allow_path)
	if cleared == Vector2.ZERO:
		# Raise foot / try smaller scale so tall art clears the north margin.
		for s2 in [scale_f * 0.85, scale_f * 0.7, 0.35]:
			cleared = _find_scaled_inside(ideal + Vector2(0, 96), tex, s2, zone, half_w, half_h, 18, allow_path)
			if cleared != Vector2.ZERO:
				scale_f = s2
				break
	if cleared == Vector2.ZERO:
		return null
	craft.add_contact_shadow(ysort, cleared, Vector2(16, 6))
	var spr := craft.spawn_sprite(ysort, path, cleared, z)
	spr.offset = craft.tree_offset_for(tex)
	spr.scale = Vector2(scale_f, scale_f)
	return spr


func _spawn_waterfall_props(ysort: Node2D) -> void:
	var tall := "res://assets/sprites/props/waterfall_tall_00.png"
	var mid := "res://assets/sprites/props/waterfall_mid_00.png"
	var splash := "res://assets/sprites/props/waterfall_splash_00.png"
	# Foot on viewing ledge (dirt ty 11–12); scale so full AABB fits play zone.
	var fall: Sprite2D = null
	if ResourceLoader.exists(tall):
		fall = _spawn_scaled_prop(ysort, tall, Vector2(640, 384), 0.55, 3, 1, 1, true)
	if fall == null and ResourceLoader.exists(mid):
		fall = _spawn_scaled_prop(ysort, mid, Vector2(640, 400), 0.5, 3, 1, 1, true)
	if fall:
		craft.make_hotspot(ysort, "瀑布", "岩壁倾泻而下的水帘与水雾。", fall.position + Vector2(0, 24), Vector2(96, 72))
	if ResourceLoader.exists(splash):
		# Foot on viewing ledge (dirt ty 11–12), not in the pool ellipse.
		_spawn_scaled_prop(ysort, splash, Vector2(640, 400), 0.38, 2, 1, 1, true)


func _spawn_rocks(ysort: Node2D) -> void:
	# 2–3 large B07 rocks on pool rim dirt/bank (must scale — sheets are ~280px).
	var specs := [
		{"i": 0, "pos": Vector2(448, 400), "s": 0.4},
		{"i": 1, "pos": Vector2(848, 400), "s": 0.38},
		{"i": 2, "pos": Vector2(608, 768), "s": 0.36},
	]
	for s in specs:
		var path := "res://assets/sprites/props/rock_%02d.png" % int(s["i"])
		_spawn_scaled_prop(ysort, path, s["pos"], float(s["s"]), 2, 1, 1, true)


func _spawn_mist(ysort: Node2D) -> void:
	# Soft smoke — translucent, low z; never opaque ColorRect slabs.
	var samples: Array[Vector2] = [
		Vector2(600, 320), Vector2(680, 340), Vector2(640, 300),
	]
	for i in samples.size():
		var path := "res://assets/sprites/fx/smoke_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		var spr := craft.spawn_sprite(ysort, path, samples[i], 1)
		spr.modulate = Color(0.85, 0.92, 0.98, 0.28)
		spr.scale = Vector2(2.2, 1.8)


func _spawn_trees(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	var ideals: Array[Vector2] = [
		Vector2(120, 280), Vector2(160, 560), Vector2(140, 780),
		Vector2(1120, 300), Vector2(1160, 580), Vector2(1100, 800),
		Vector2(320, 820), Vector2(960, 820),
	]
	for i in ideals.size():
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		var spr := craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 8, false)
		if spr:
			spr.modulate = Color(0.78, 0.84, 0.80)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "farmer", "观瀑旅人", "在观瀑土径与南口之间踱步。",
		[Vector2(480, 700), Vector2(640, 720), Vector2(640, 820), Vector2(520, 780)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→河流", SceneRouter.RIVER_PATH, Vector2(200, 800), Vector2(96, 56))
	craft.make_portal(ysort, "→深林", SceneRouter.FOREST_DEEP_PATH, Vector2(80, 400), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 900), Vector2(96, 48))
