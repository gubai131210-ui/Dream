class_name LighthouseAssembler
extends Node

## Lighthouse (A14) — sliced B08-05 lighthouse + coastal rocks.
## Full sprite AABB inside play zone. No ColorRect tower/cliff hacks.

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
	_spawn_lighthouse(ysort)
	_spawn_rocks(ysort)
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
	var edge := 24.0 + sin(float(ty) * 0.33) * 2.5 + cos(float(ty) * 0.17) * 1.2
	if float(tx) >= edge:
		return true
	if ty > 22 and tx > 18:
		return true
	return false


func _set_dirt(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	craft.dirt_mask[ty][tx] = true
	craft.water_mask[ty][tx] = false


func _paint_approach() -> void:
	for tx in range(2, 22):
		_set_dirt(tx, 16)
		_set_dirt(tx, 17)
	for ty in range(12, 20):
		for tx in range(14, 22):
			_set_dirt(tx, ty)
	for tx in range(14, 24):
		_set_dirt(tx, 19)
		_set_dirt(tx, 20)


func _spawn_lighthouse(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	var path := "res://assets/sprites/buildings/lighthouse_00.png"
	if not ResourceLoader.exists(path):
		path = "res://assets/sprites/buildings/building_03.png"
	if not ResourceLoader.exists(path):
		return
	var tex := load(path) as Texture2D
	# Tall landmark: use tree-like offset so lantern sits above foot pad.
	var offset := craft.tree_offset_for(tex)
	# Prefer a southern ideal so the tall AABB clears the top margin.
	var ideal := Vector2(560, 520)
	var cleared := craft.find_building_inside(ideal, tex, offset, zone, 2, 1, 22, true)
	if cleared == Vector2.ZERO:
		# Scale-down fallback for oversized lighthouse sheet.
		var spr_try := craft.spawn_sprite(ysort, path, ideal)
		spr_try.scale = Vector2(0.55, 0.55)
		spr_try.offset = offset
		var size := Vector2(float(tex.get_width()), float(tex.get_height())) * 0.55
		var top_left := ideal + offset * 0.55 - size * 0.5
		if top_left.y < zone.position.y:
			ideal.y += zone.position.y - top_left.y + 12.0
			spr_try.position = ideal
		craft.add_contact_shadow(ysort, ideal, Vector2(36, 12))
		craft.make_hotspot(ysort, "灯塔", "红白条纹灯塔立于海岸礁岩之上。", ideal + Vector2(0, 28), Vector2(120, 90))
		return
	craft.add_contact_shadow(ysort, cleared, Vector2(40, 14))
	var spr := craft.spawn_sprite(ysort, path, cleared)
	spr.offset = offset
	# If unscaled height still huge, shrink while keeping foot.
	if float(tex.get_height()) > 420.0:
		spr.scale = Vector2(0.58, 0.58)
	craft.make_hotspot(ysort, "灯塔", "红白条纹灯塔立于海岸礁岩之上。", cleared + Vector2(0, 28), Vector2(120, 90))


func _spawn_rocks(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	var specs := [
		{"i": 0, "pos": Vector2(720, 560), "s": 0.36},
		{"i": 1, "pos": Vector2(780, 620), "s": 0.34},
		{"i": 2, "pos": Vector2(420, 600), "s": 0.32},
	]
	for s in specs:
		var path := "res://assets/sprites/props/rock_%02d.png" % int(s["i"])
		if not ResourceLoader.exists(path):
			continue
		var tex := load(path) as Texture2D
		var offset := craft.tree_offset_for(tex)
		var cleared := craft.find_sprite_inside(s["pos"], tex, offset, zone, 1, 1, 10, true)
		if cleared == Vector2.ZERO:
			continue
		craft.add_contact_shadow(ysort, cleared, Vector2(14, 6))
		var spr := craft.spawn_sprite(ysort, path, cleared)
		spr.offset = offset
		spr.scale = Vector2(float(s["s"]), float(s["s"]))


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(400, 560), "title": "补给箱", "desc": "灯塔补给木箱。", "scale": 0.55},
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(480, 600), "title": "油桶", "desc": "灯油空桶。", "scale": 0.5},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 6, true)
		if cleared != Vector2.ZERO:
			pos = cleared
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		spr.scale = Vector2(float(s["scale"]), float(s["scale"]))
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	var ideals: Array[Vector2] = [
		Vector2(120, 280), Vector2(160, 520), Vector2(140, 780),
		Vector2(360, 260), Vector2(300, 800),
	]
	for i in ideals.size():
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 8, false)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "station_master", "守塔人", "在灯塔基座与西侧湖路之间巡视。",
		[Vector2(400, 560), Vector2(520, 600), Vector2(360, 520), Vector2(440, 560)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(80, 520), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
