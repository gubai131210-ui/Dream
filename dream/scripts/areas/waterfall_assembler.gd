class_name WaterfallAssembler
extends Node

## Waterfall (A07) — vertical fall mass + mist pool (not a flat lake).
## Silhouette: tall pale fall column at north cliff + churning pool south.

const MAP_W := 40
const MAP_H := 30

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
	_spawn_fall_column(ysort)
	_spawn_props(ysort)
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


func _spawn_fall_column(ysort: Node2D) -> void:
	# Pale vertical mass — silhouette cue (not a flat pond).
	var fall := ColorRect.new()
	fall.name = "FallColumn"
	fall.color = Color(0.72, 0.86, 0.92, 0.78)
	fall.size = Vector2(72, 220)
	fall.position = Vector2(608, 40)
	fall.z_index = 3
	ysort.add_child(fall)
	var mist := ColorRect.new()
	mist.name = "FallMist"
	mist.color = Color(0.85, 0.92, 0.95, 0.35)
	mist.size = Vector2(160, 48)
	mist.position = Vector2(560, 250)
	mist.z_index = 3
	ysort.add_child(mist)
	# Cliff band hint.
	var cliff := ColorRect.new()
	cliff.name = "CliffBand"
	cliff.color = Color(0.35, 0.38, 0.42, 0.85)
	cliff.size = Vector2(420, 56)
	cliff.position = Vector2(430, 20)
	cliff.z_index = 2
	ysort.add_child(cliff)


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/rock_0.png", "pos": Vector2(520, 420), "title": "湿岩", "desc": "瀑雾打湿的岩石。", "scale": 0.7},
		{"path": "res://assets/sprites/props/rock_1.png", "pos": Vector2(780, 460), "title": "观瀑石", "desc": "可站立观瀑的石台。", "scale": 0.65},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			# Fallback crates if rocks missing.
			s["path"] = "res://assets/sprites/props/crate_1.png"
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 6, true)
		if cleared != Vector2.ZERO:
			pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(14, 6))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		if s.has("scale"):
			spr.scale = Vector2(float(s["scale"]), float(s["scale"]))
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	var ideals: Array[Vector2] = [
		Vector2(80, 200), Vector2(120, 480), Vector2(100, 800),
		Vector2(1180, 220), Vector2(1200, 560), Vector2(1160, 820),
		Vector2(300, 880), Vector2(900, 880), Vector2(200, 100), Vector2(1000, 80),
	]
	for i in ideals.size():
		var pos := craft.find_clear_near(ideals[i], 1, 1, 5, false)
		if pos == Vector2.ZERO:
			continue
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(20, 8))
		var spr := craft.spawn_sprite(ysort, path, pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)
		spr.modulate = Color(0.75, 0.82, 0.78)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "farmer", "观瀑旅人", "在观瀑土径与南口之间踱步。",
		[Vector2(480, 400), Vector2(640, 400), Vector2(640, 780), Vector2(520, 760)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→河流", SceneRouter.RIVER_PATH, Vector2(200, 800), Vector2(96, 56))
	craft.make_portal(ysort, "→深林", SceneRouter.FOREST_DEEP_PATH, Vector2(80, 400), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 900), Vector2(96, 48))
