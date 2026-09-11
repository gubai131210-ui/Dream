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
	_spawn_cliff_rocks(ysort)
	_spawn_waterfall(ysort)
	_spawn_rim_rocks(ysort)
	_spawn_mist(ysort)
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


func _spawn_cliff_rocks(ysort: Node2D) -> void:
	# North cliff mass behind the fall — rock sheets ~0.35–0.45 (no ColorRect cliff).
	var specs := [
		{"i": 0, "pos": Vector2(520, 220), "s": 0.44, "z": 1},
		{"i": 1, "pos": Vector2(760, 230), "s": 0.42, "z": 1},
		{"i": 2, "pos": Vector2(640, 180), "s": 0.45, "z": 1},
		{"i": 4, "pos": Vector2(440, 280), "s": 0.38, "z": 1},
		{"i": 5, "pos": Vector2(840, 290), "s": 0.38, "z": 1},
	]
	for s in specs:
		var path := "res://assets/sprites/props/rock_%02d.png" % int(s["i"])
		_spawn_scaled_prop(ysort, path, s["pos"], float(s["s"]), int(s["z"]), 1, 1, true, false)


func _spawn_waterfall(ysort: Node2D) -> void:
	var tall := "res://assets/sprites/props/waterfall_tall_00.png"
	var mid := "res://assets/sprites/props/waterfall_mid_00.png"
	# Foot on north pool rim (ty≈11 notch into pool) so cascade reads into the pond.
	# allow_water_foot — never place a dirt road under the fall column.
	var foot := craft.tile_center(int(POOL_CX), 11)
	var fall: Sprite2D = null
	if ResourceLoader.exists(tall):
		fall = _spawn_scaled_prop(ysort, tall, foot, 0.72, 4, 1, 1, true, true)
	if fall == null and ResourceLoader.exists(mid):
		fall = _spawn_scaled_prop(ysort, mid, foot, 0.68, 4, 1, 1, true, true)
	if fall:
		craft.make_hotspot(
			ysort, "瀑布", "岩壁倾泻入潭，水雾弥漫。",
			fall.position + Vector2(0, 28), Vector2(110, 80)
		)


func _spawn_rim_rocks(ysort: Node2D) -> void:
	# Pool rim flanks — land only, never through cascade / fall keep-water.
	var specs := [
		{"i": 0, "pos": Vector2(400, 480), "s": 0.4},
		{"i": 1, "pos": Vector2(880, 500), "s": 0.38},
		{"i": 3, "pos": Vector2(480, 720), "s": 0.36},
		{"i": 4, "pos": Vector2(780, 700), "s": 0.35},
	]
	for s in specs:
		var path := "res://assets/sprites/props/rock_%02d.png" % int(s["i"])
		_spawn_scaled_prop(ysort, path, s["pos"], float(s["s"]), 2, 1, 1, true, false)


func _spawn_mist(ysort: Node2D) -> void:
	var samples: Array[Vector2] = [
		Vector2(600, 360), Vector2(680, 380), Vector2(640, 340), Vector2(620, 420),
	]
	for i in samples.size():
		var mist_path := "res://assets/sprites/fx/waterfall_mist_%02d.png" % (i % 2)
		var path := mist_path if ResourceLoader.exists(mist_path) else ("res://assets/sprites/fx/smoke_%02d.png" % (i % 6))
		if not ResourceLoader.exists(path):
			continue
		var spr := craft.spawn_sprite(ysort, path, samples[i], 5)
		spr.modulate = Color(0.88, 0.94, 0.98, 0.36)
		spr.scale = Vector2(1.8, 1.5)


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
