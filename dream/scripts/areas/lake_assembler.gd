class_name LakeAssembler
extends Node

## Lake (A13) — large open water + shore ring path.
## Silhouette: broad water disk; distinct from river spine / waterfall pool.

const MAP_W := 40
const MAP_H := 30

var craft: AreaCraft = AreaCraft.new()


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	craft.setup(MAP_W, MAP_H)
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
			craft.water_mask[y][x] = _lake_tile(x, y)
	_paint_shore_ring()
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_dirt(x, y) or craft.is_path(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _lake_tile(tx: int, ty: int) -> bool:
	var cx := 20.0
	var cy := 14.5
	var rx := 11.5 + 0.8 * sin(float(ty) * 0.25)
	var ry := 8.5 + 0.5 * cos(float(tx) * 0.2)
	var nx := (float(tx) - cx) / rx
	var ny := (float(ty) - cy) / ry
	return nx * nx + ny * ny <= 1.0


func _set_dirt(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	if _lake_tile(tx, ty) and not _near_shore(tx, ty):
		return
	craft.dirt_mask[ty][tx] = true
	craft.water_mask[ty][tx] = false


func _near_shore(tx: int, ty: int) -> bool:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if not _lake_tile(tx + dx, ty + dy):
				return true
	return false


func _paint_shore_ring() -> void:
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if _lake_tile(tx, ty):
				continue
			# One-tile ring outside water.
			var touch := false
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if _lake_tile(tx + dx, ty + dy):
						touch = true
			if touch:
				_set_dirt(tx, ty)
	# Dock spur east toward lake house / lighthouse approaches.
	for tx in range(30, 38):
		_set_dirt(tx, 14)
		_set_dirt(tx, 15)
	for ty in range(2, 8):
		_set_dirt(20, ty)
		_set_dirt(21, ty)


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(980, 460), "title": "码头桶", "desc": "系缆用空桶。", "scale": 0.5},
		{"path": "res://assets/sprites/props/crate_1.png", "pos": Vector2(360, 700), "title": "渔获箱", "desc": "湖岸临时货箱。", "scale": 0.55},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(640, 780), "title": "湖灯", "desc": "南岸小径灯。"},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 7, true)
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
	var ideals: Array[Vector2] = []
	for a in range(0, 360, 28):
		var rad := deg_to_rad(float(a))
		ideals.append(Vector2(640 + cos(rad) * 520, 460 + sin(rad) * 380))
	for i in ideals.size():
		var pos := craft.find_clear_near(ideals[i], 1, 1, 4, false)
		if pos == Vector2.ZERO:
			continue
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(18, 8))
		var spr := craft.spawn_sprite(ysort, path, pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "merchant", "湖畔商贩", "沿南岸环路叫卖干货。",
		[Vector2(400, 720), Vector2(640, 780), Vector2(900, 720), Vector2(640, 700)],
	)
	craft.spawn_patrol_actor(
		ysort, "farmer", "垂钓客", "在东码头附近踱步。",
		[Vector2(980, 420), Vector2(1040, 480), Vector2(980, 540), Vector2(940, 480)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→河流", SceneRouter.RIVER_PATH, Vector2(80, 400), Vector2(96, 56))
	craft.make_portal(ysort, "→山坡农田", SceneRouter.HILL_FARM_PATH, Vector2(200, 80), Vector2(110, 56))
	craft.make_portal(ysort, "→灯塔", SceneRouter.LIGHTHOUSE_PATH, Vector2(1200, 200), Vector2(96, 56))
	craft.make_portal(ysort, "→湖畔小屋", SceneRouter.LAKE_HOUSE_PATH, Vector2(1200, 560), Vector2(110, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
