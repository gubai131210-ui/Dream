class_name HillFarmAssembler
extends Node

## Hill farm (A12) — terraced dirt plots on a slope + few sheds.
## Silhouette: stepped bands (not flat A03 farmland grid).

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
	_spawn_sheds(ysort)
	_spawn_terrace_markers(ysort)
	_spawn_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _rill_tile(x, y)
	_paint_terraces_and_path()
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_dirt(x, y) or craft.is_path(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _rill_tile(tx: int, ty: int) -> bool:
	# Thin SE runoff rill (not irrigation grid).
	if ty < 18 or ty > 28:
		return false
	var cx := 28.0 + sin(float(ty) * 0.55) * 1.4
	return absf(float(tx) - cx) <= 1.1


func _set_dirt(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	craft.dirt_mask[ty][tx] = true
	craft.path_mask[ty][tx] = false


func _paint_terraces_and_path() -> void:
	# Three terrace bands (higher north → lower south).
	var bands := [
		{"y0": 6, "y1": 9, "x0": 8, "x1": 30},
		{"y0": 12, "y1": 15, "x0": 6, "x1": 28},
		{"y0": 18, "y1": 21, "x0": 5, "x1": 26},
	]
	for b in bands:
		for ty in range(int(b["y0"]), int(b["y1"]) + 1):
			for tx in range(int(b["x0"]), int(b["x1"]) + 1):
				_set_dirt(tx, ty)
	# Switchback dirt spine climbing the slope.
	for ty in range(4, 26):
		var cx := 16 + int(sin(float(ty) * 0.4) * 3.0)
		_set_dirt(cx, ty)
		_set_dirt(cx + 1, ty)
	# Door dirt south of shed feet (~ty 10–11).
	for tx in range(14, 22):
		_set_dirt(tx, 10)
		_set_dirt(tx, 11)


func _spawn_sheds(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(1.5)
	var specs := [
		{"path": "res://assets/sprites/buildings/building_02.png", "ideal": Vector2(520, 280)},
		{"path": "res://assets/sprites/buildings/building_00.png", "ideal": Vector2(780, 460)},
	]
	for s in specs:
		if not ResourceLoader.exists(s["path"]):
			continue
		var tex := load(s["path"]) as Texture2D
		var offset := craft.building_offset_for(tex)
		var cleared := craft.find_building_inside(s["ideal"], tex, offset, zone, 2, 1, 14, true)
		if cleared == Vector2.ZERO:
			continue
		craft.add_contact_shadow(ysort, cleared, Vector2(36, 12))
		var spr := craft.spawn_sprite(ysort, s["path"], cleared)
		spr.offset = offset


func _spawn_terrace_markers(ysort: Node2D) -> void:
	# Low ColorRect strips to read terraces in 1/8 thumbnails.
	var strips := [
		Rect2(260, 210, 700, 18),
		Rect2(200, 400, 720, 18),
		Rect2(170, 590, 680, 18),
	]
	var i := 0
	for r in strips:
		var bar := ColorRect.new()
		bar.name = "TerraceEdge_%d" % i
		bar.color = Color(0.45, 0.36, 0.22, 0.55)
		bar.position = r.position
		bar.size = r.size
		bar.z_index = 1
		ysort.add_child(bar)
		i += 1


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(420, 520), "title": "坡地筐", "desc": "梯田收获用的竹筐。", "scale": 0.55},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(640, 680), "title": "粮袋", "desc": "晒在下层台地的粮袋。", "scale": 0.6},
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
		Vector2(60, 120), Vector2(80, 400), Vector2(100, 760),
		Vector2(1180, 140), Vector2(1200, 480), Vector2(1160, 800),
	]
	for i in ideals.size():
		var pos := craft.find_clear_near(ideals[i], 1, 1, 4, false)
		if pos == Vector2.ZERO:
			continue
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(18, 8))
		var spr := craft.spawn_sprite(ysort, path, pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "farmer", "梯田农人", "沿之字土径上下台地。",
		[Vector2(480, 240), Vector2(520, 420), Vector2(500, 640), Vector2(460, 420)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→农田", SceneRouter.FARMLAND_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(1200, 560), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
