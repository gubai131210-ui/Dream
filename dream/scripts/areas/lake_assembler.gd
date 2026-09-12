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
	_spawn_fishing_spots(ysort)
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
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(980, 460), "title": "码头桶", "desc": "系缆用空桶。", "scale": 0.5},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(360, 700), "title": "渔获箱", "desc": "湖岸临时货箱。", "scale": 0.55},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(640, 780), "title": "湖灯", "desc": "南岸小径灯。", "scale": 0.55},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 7, true)
		if cleared != Vector2.ZERO:
			pos = cleared
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		var sc := float(s.get("scale", 0.55))
		spr.scale = Vector2(sc, sc)
		var title := str(s.get("title", ""))
		if title == "":
			continue
		var hs := craft.make_hotspot(ysort, title, s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	var ideals: Array[Vector2] = []
	# Shore ring — wider angle step, radius inset so AABB fits play rect.
	for a in range(20, 340, 40):
		var rad := deg_to_rad(float(a))
		ideals.append(Vector2(640 + cos(rad) * 460, 480 + sin(rad) * 320))
	for i in ideals.size():
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 5, false)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "merchant", "湖畔商贩", "沿南岸环路叫卖干货。",
		[Vector2(400, 720), Vector2(640, 780), Vector2(900, 720), Vector2(640, 700)],
	)
	craft.spawn_patrol_actor(
		ysort, "farmer", "垂钓客", "在东码头附近踱步。",
		[Vector2(980, 420), Vector2(1040, 480), Vector2(980, 540), Vector2(940, 480)],
	)


func _spawn_fishing_spots(ysort: Node2D) -> void:
	## Fish-E append-only: shore / dock cast points.
	var spots := [
		{
			"spot_id": "east_dock",
			"pos": Vector2(1000, 480),
			"title": "东码头钓点",
			"desc": "湖东系缆处，鲈鱼出没。",
		},
		{
			"spot_id": "south_shore",
			"pos": Vector2(640, 760),
			"title": "南岸钓点",
			"desc": "开阔湖面，偶遇锦鲤。",
		},
	]
	for s in spots:
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 6, true)
		if cleared != Vector2.ZERO:
			pos = cleared
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(14, 5))
		FishingSpot.spawn(ysort, pos, Vector2(56, 48), {
			"site_id": "lake",
			"spot_id": s["spot_id"],
			"title": s["title"],
			"desc": s["desc"],
		})
	_spawn_fish_cages(ysort)


func _spawn_fish_cages(ysort: Node2D) -> void:
	## C22 append-only: one dock cage near east_dock.
	var pos := Vector2(1040, 520)
	var cleared := craft.find_clear_near(pos, 1, 1, 6, true)
	if cleared != Vector2.ZERO:
		pos = cleared
	var t := craft.world_to_tile(pos)
	if craft.is_water(t.x, t.y):
		return
	craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
	const FishCageScript := preload("res://scripts/fishing/fish_cage.gd")
	FishCageScript.spawn(ysort, pos, Vector2(52, 48), {
		"site_id": "lake",
		"cage_id": "east_dock_cage",
		"title": "东码头渔笼",
		"desc": "系缆旁的竹笼，可下放隔潮收货。",
	})


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→河流", SceneRouter.RIVER_PATH, Vector2(80, 400), Vector2(96, 56))
	craft.make_portal(ysort, "→山坡农田", SceneRouter.HILL_FARM_PATH, Vector2(200, 80), Vector2(110, 56))
	craft.make_portal(ysort, "→灯塔", SceneRouter.LIGHTHOUSE_PATH, Vector2(1200, 200), Vector2(96, 56))
	craft.make_portal(ysort, "→湖畔小屋", SceneRouter.LAKE_HOUSE_PATH, Vector2(1200, 560), Vector2(110, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
	# Wave C C24 — south-shore boat/island embark (append-only).
	var isle := Vector2(640, 520)
	var hs_isle := craft.make_hotspot(ysort, "登岛渡口", "南岸小舟可渡湖心岛。", isle, Vector2(72, 56))
	craft.attach_hotspot_prop(hs_isle, "res://assets/sprites/props/rock_02.png", 0.55)
	craft.make_portal(ysort, "登湖心岛", SceneRouter.C24_LAKE_ISLAND_PATH, isle + Vector2(0, 14), Vector2(100, 52))
	# Wave F transit / dive
	craft.make_portal(ysort, "进入水族馆", SceneRouter.C41_AQUARIUM_PATH, Vector2(420, 480), Vector2(100, 52))
	craft.make_portal(ysort, "进入渔码头", SceneRouter.C34_DOCK_FISH_PATH, Vector2(280, 620), Vector2(100, 52))
	craft.make_portal(ysort, "半沉船", SceneRouter.C35_BOAT_WRECK_PATH, Vector2(900, 640), Vector2(100, 52))
	craft.make_portal(ysort, "↓潜水", SceneRouter.C23_UNDERWATER_PATH, Vector2(640, 700), Vector2(100, 52))
