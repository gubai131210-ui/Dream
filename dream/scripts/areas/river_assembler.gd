class_name RiverAssembler
extends Node

## River (A06) — wide meander water spine + both banks + shore dirt path.
## Silhouette: water dominates the center; not plaza west-river wall.

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
	_spawn_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _river_tile(x, y)
	_paint_shore_paths()
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_path(x, y) or craft.is_dirt(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _river_cx(ty: float) -> float:
	return 19.5 + sin(ty * 0.28) * 4.5 + cos(ty * 0.13 + 1.1) * 2.2


func _river_hw(ty: float) -> float:
	return 3.4 + 0.9 * sin(ty * 0.41 + 0.5)


func _river_tile(tx: int, ty: int) -> bool:
	var cx := _river_cx(float(ty))
	var hw := _river_hw(float(ty))
	var dx := absf(float(tx) - cx)
	if dx <= hw:
		return true
	if dx <= hw + 1.1 and sin(float(ty) * 0.7 + float(tx) * 0.3) > 0.45:
		return true
	return false


func _set_dirt(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	craft.dirt_mask[ty][tx] = true
	craft.path_mask[ty][tx] = false
	craft.water_mask[ty][tx] = false


func _paint_shore_paths() -> void:
	# Twin dirt banks following the meander (not a stone plaza).
	for ty in range(1, MAP_H - 1):
		var cx := _river_cx(float(ty))
		var hw := _river_hw(float(ty))
		var left := int(round(cx - hw - 1.5))
		var right := int(round(cx + hw + 1.5))
		_set_dirt(left, ty)
		_set_dirt(left - 1, ty)
		_set_dirt(right, ty)
		_set_dirt(right + 1, ty)
	# Bridges across bends.
	for ty in [8, 9, 20, 21]:
		var cx := int(round(_river_cx(float(ty))))
		for tx in range(cx - 4, cx + 5):
			_set_dirt(tx, ty)


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(280, 320), "title": "岸边木箱", "desc": "渔民用的湿木箱。", "scale": 0.55},
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(980, 560), "title": "浮桶", "desc": "系在岸桩旁的空桶。", "scale": 0.5},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(360, 700), "title": "河岸灯", "desc": "桥头微光。"},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 8, true)
		if cleared != Vector2.ZERO:
			pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		if s.has("scale"):
			spr.scale = Vector2(float(s["scale"]), float(s["scale"]))
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	var ideals: Array[Vector2] = []
	for gy in range(3, MAP_H - 3, 4):
		for gx in [2, 4, 35, 37]:
			ideals.append(craft.tile_center(gx, gy))
	for i in ideals.size():
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 6, false)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "farmer", "巡河人", "沿两岸土径来回查看水位。",
		[Vector2(260, 280), Vector2(280, 480), Vector2(300, 720), Vector2(260, 480)],
	)
	craft.spawn_patrol_actor(
		ysort, "elder_woman", "浣衣妇", "在下游缓滩边停留片刻。",
		[Vector2(1000, 400), Vector2(980, 560), Vector2(1020, 700), Vector2(1000, 520)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→深林", SceneRouter.FOREST_DEEP_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→瀑布", SceneRouter.WATERFALL_PATH, Vector2(640, 60), Vector2(96, 56))
	craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(1200, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 900), Vector2(96, 48))
