class_name LighthouseAssembler
extends Node

## Lighthouse (A14) — coast rock + tall tower landmark (not a village house row).

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
	_spawn_coast_rock(ysort)
	_spawn_tower(ysort)
	_spawn_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _coast_water(x, y)
	_paint_approach()
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_dirt(x, y) or craft.is_path(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _coast_water(tx: int, ty: int) -> bool:
	# East / SE open water — coast on west-center peninsula.
	var edge := 24.0 + sin(float(ty) * 0.33) * 2.5 + cos(float(ty) * 0.17) * 1.2
	if float(tx) >= edge:
		return true
	# Small cove south.
	if ty > 22 and tx > 18:
		return true
	return false


func _set_dirt(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	craft.dirt_mask[ty][tx] = true
	craft.water_mask[ty][tx] = false


func _paint_approach() -> void:
	# Dirt from west (lake) to tower pad.
	for tx in range(2, 22):
		_set_dirt(tx, 14)
		_set_dirt(tx, 15)
	for ty in range(10, 18):
		for tx in range(16, 22):
			_set_dirt(tx, ty)
	# Door dirt south of tower foot.
	for tx in range(16, 23):
		_set_dirt(tx, 17)
		_set_dirt(tx, 18)


func _spawn_coast_rock(ysort: Node2D) -> void:
	var rock := ColorRect.new()
	rock.name = "CoastRock"
	rock.color = Color(0.42, 0.44, 0.48, 0.9)
	rock.size = Vector2(280, 120)
	rock.position = Vector2(480, 280)
	rock.z_index = 1
	ysort.add_child(rock)


func _spawn_tower(ysort: Node2D) -> void:
	# Tall landmark stack: building base + vertical ColorRect shaft for silhouette.
	var zone := craft.map_play_rect(1.5)
	var path := "res://assets/sprites/buildings/building_03.png"
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/buildings/building_00.png"
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		var offset := craft.building_offset_for(tex)
		var ideal := Vector2(600, 360)
		var cleared := craft.find_building_inside(ideal, tex, offset, zone, 2, 1, 16, true)
		if cleared != Vector2.ZERO:
			craft.add_contact_shadow(ysort, cleared, Vector2(40, 14))
			var spr := craft.spawn_sprite(ysort, path, cleared)
			spr.offset = offset
	var shaft := ColorRect.new()
	shaft.name = "TowerShaft"
	shaft.color = Color(0.86, 0.78, 0.62, 0.95)
	shaft.size = Vector2(48, 200)
	shaft.position = Vector2(576, 120)
	shaft.z_index = 4
	ysort.add_child(shaft)
	var lantern := ColorRect.new()
	lantern.name = "TowerLantern"
	lantern.color = Color(1.0, 0.92, 0.55, 0.95)
	lantern.size = Vector2(56, 28)
	lantern.position = Vector2(572, 100)
	lantern.z_index = 5
	ysort.add_child(lantern)


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(480, 560), "title": "补给箱", "desc": "灯塔补给木箱。", "scale": 0.55},
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(700, 580), "title": "油桶", "desc": "灯油空桶。", "scale": 0.5},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 6, true)
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
	var ideals: Array[Vector2] = [
		Vector2(80, 200), Vector2(120, 500), Vector2(100, 800),
		Vector2(360, 120), Vector2(400, 780),
	]
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
		ysort, "station_master", "守塔人", "在灯塔基座与西侧湖路之间巡视。",
		[Vector2(520, 500), Vector2(640, 560), Vector2(400, 480), Vector2(520, 500)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
