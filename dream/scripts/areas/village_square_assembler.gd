class_name VillageSquareAssembler
extends Node

## Builds layered village square content with realistic placement rules.
## Reference mood: A09 village square (meandering west river, plaza-centered facades).
## Art assumption: building sprites face south (door toward +Y). Prefer north-of-plaza lots.

const GRASS_ATLAS := "res://assets/tilesets/grass_seamless_atlas.png"
const STONE_ATLAS := "res://assets/tilesets/stone_seamless_atlas.png"
const WATER_ATLAS := "res://assets/tilesets/water_seamless_atlas.png"

const MAP_W := 40
const MAP_H := 30
const TILE := Scale.BASE_TILE

## Cached masks rebuilt each assemble().
var _water_mask: Array = [] # Array of Array[bool]
var _bank_mask: Array = []
var _path_mask: Array = []


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	TileSetFactory.clear_layer(ground)
	TileSetFactory.clear_layer(path)
	TileSetFactory.clear_layer(water)

	_rebuild_masks()

	ground.tile_set = TileSetFactory.from_atlas(load(GRASS_ATLAS) as Texture2D)
	path.tile_set = TileSetFactory.from_atlas(load(STONE_ATLAS) as Texture2D)
	water.tile_set = TileSetFactory.from_atlas(load(WATER_ATLAS) as Texture2D)
	TileSetFactory.configure_layer(ground)
	TileSetFactory.configure_layer(path)
	TileSetFactory.configure_layer(water)

	_paint_ecological_grass(ground)
	_paint_meandering_river(water, ground)
	_paint_paths(path)

	_spawn_buildings(ysort)
	_spawn_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	_spawn_water_fx(ysort)
	_spawn_fx(ysort)


func _rebuild_masks() -> void:
	_water_mask.clear()
	_bank_mask.clear()
	_path_mask.clear()
	for y in range(MAP_H):
		var wrow: Array = []
		var brow: Array = []
		var prow: Array = []
		wrow.resize(MAP_W)
		brow.resize(MAP_W)
		prow.resize(MAP_W)
		for x in range(MAP_W):
			wrow[x] = _compute_river_tile(x, y)
			prow[x] = false
			brow[x] = false
		_water_mask.append(wrow)
		_path_mask.append(prow)
		_bank_mask.append(brow)
	# Paths depend on water (bridge / stop-before-bank).
	for y in range(MAP_H):
		for x in range(MAP_W):
			_path_mask[y][x] = _compute_path_tile(x, y)
	# Banks = land cells adjacent to water (8-neighborhood), not path.
	for y in range(MAP_H):
		for x in range(MAP_W):
			if _water_mask[y][x] or _path_mask[y][x]:
				continue
			if _touches_water(x, y):
				_bank_mask[y][x] = true


func _river_center_x(ty: float) -> float:
	# Stronger A09-like meander along the west edge.
	return 4.0 + sin(ty * 0.36) * 2.4 + cos(ty * 0.17 + 0.9) * 1.35 + sin(ty * 0.09) * 0.7


func _river_half_width(ty: float) -> float:
	return 1.7 + 1.0 * sin(ty * 0.24 + 1.1) + 0.35 * cos(ty * 0.51)


func _compute_river_tile(tx: int, ty: int) -> bool:
	# Continuous west watercourse through the map height.
	var cx := _river_center_x(float(ty))
	var hw := _river_half_width(float(ty))
	var dx := abs(float(tx) - cx)
	if dx <= hw:
		return true
	# Soft cove / spit on the east bank for less canal look.
	if dx <= hw + 1.1 and sin(ty * 0.85 + tx * 0.4) > 0.55:
		return true
	return false


func _compute_path_tile(tx: int, ty: int) -> bool:
	# Plaza core (civic stone).
	if tx >= 14 and tx < 26 and ty >= 10 and ty < 20:
		return true
	# North approach spur only — leaves room for town hall yard north of plaza.
	if tx >= 18 and tx < 22 and ty >= 8 and ty < 10:
		return true
	# South arm
	if tx >= 18 and tx < 22 and ty >= 20 and ty < 28:
		return true
	# East arm
	if tx >= 26 and tx < 38 and ty >= 13 and ty < 17:
		return true
	# West arm stops before bank; bridge band crosses water at ty 14–15.
	if ty >= 13 and ty < 17:
		if tx >= 9 and tx < 14 and not _water_mask[ty][tx]:
			return true
		if (ty == 14 or ty == 15) and tx >= 2 and tx <= 8:
			return true
	return false


func _touches_water(tx: int, ty: int) -> bool:
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			if ox == 0 and oy == 0:
				continue
			var nx := tx + ox
			var ny := ty + oy
			if nx < 0 or ny < 0 or nx >= MAP_W or ny >= MAP_H:
				continue
			if _water_mask[ny][nx]:
				return true
	return false


func _is_path_tile(tx: int, ty: int) -> bool:
	return bool(_path_mask[ty][tx])


func _is_river_tile(tx: int, ty: int) -> bool:
	return bool(_water_mask[ty][tx])


func _is_bank_tile(tx: int, ty: int) -> bool:
	return bool(_bank_mask[ty][tx])


func _is_plantable_land(tx: int, ty: int) -> bool:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return false
	if _is_river_tile(tx, ty):
		return false
	if _is_path_tile(tx, ty):
		return false
	return true


func _footprint_ok(center: Vector2, half_w_tiles: int, half_h_tiles: int, allow_path: bool = false) -> bool:
	var t := _world_to_tile(center)
	for oy in range(-half_h_tiles, half_h_tiles + 1):
		for ox in range(-half_w_tiles, half_w_tiles + 1):
			var nx := t.x + ox
			var ny := t.y + oy
			if nx < 0 or ny < 0 or nx >= MAP_W or ny >= MAP_H:
				return false
			if _is_river_tile(nx, ny):
				return false
			if not allow_path and _is_path_tile(nx, ny):
				return false
	return true


func _find_clear_near(ideal: Vector2, half_w: int, half_h: int, max_r: int = 8, allow_path: bool = false) -> Vector2:
	if _footprint_ok(ideal, half_w, half_h, allow_path):
		return ideal
	var t := _world_to_tile(ideal)
	for r in range(1, max_r + 1):
		for oy in range(-r, r + 1):
			for ox in range(-r, r + 1):
				if maxi(abs(ox), abs(oy)) != r:
					continue
				var cand := _tile_center(t.x + ox, t.y + oy)
				if _footprint_ok(cand, half_w, half_h, allow_path):
					return cand
	return Vector2.ZERO


func _world_to_tile(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / float(TILE))), int(floor(pos.y / float(TILE))))


func _tile_center(tx: int, ty: int) -> Vector2:
	return Vector2((tx + 0.5) * TILE, (ty + 0.5) * TILE)


func _paint_ecological_grass(ground: TileMapLayer) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var dist := _build_path_distance_field()
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if _is_path_tile(tx, ty):
				continue
			var kind := "meadow"
			if _is_river_tile(tx, ty) or _is_bank_tile(tx, ty):
				kind = "damp"
			else:
				var dpath: int = dist[ty][tx]
				var edge := mini(tx, mini(ty, mini(MAP_W - 1 - tx, MAP_H - 1 - ty)))
				if dpath <= 2:
					kind = "mowed"
				elif edge <= 2 or dpath >= 8:
					kind = "tall"
				elif rng.randf() < 0.05:
					kind = "weed"
			var variants := TileSetFactory.grass_coords(kind)
			ground.set_cell(Vector2i(tx, ty), 0, variants[rng.randi_range(0, variants.size() - 1)])


func _build_path_distance_field() -> Array:
	var dist: Array = []
	var queue: Array[Vector2i] = []
	for y in range(MAP_H):
		var row: Array = []
		row.resize(MAP_W)
		for x in range(MAP_W):
			if _is_path_tile(x, y):
				row[x] = 0
				queue.append(Vector2i(x, y))
			else:
				row[x] = 999
		dist.append(row)
	var head := 0
	while head < queue.size():
		var p: Vector2i = queue[head]
		head += 1
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = p + d
			if n.x < 0 or n.y < 0 or n.x >= MAP_W or n.y >= MAP_H:
				continue
			var nd: int = int(dist[p.y][p.x]) + 1
			if nd < int(dist[n.y][n.x]):
				dist[n.y][n.x] = nd
				queue.append(n)
	return dist


func _paint_paths(path: TileMapLayer) -> void:
	var stone: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0)]
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if not _is_path_tile(tx, ty):
				continue
			path.set_cell(Vector2i(tx, ty), 0, stone[rng.randi_range(0, stone.size() - 1)])


func _paint_meandering_river(water: TileMapLayer, ground: TileMapLayer) -> void:
	var water_vars: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	var damp := TileSetFactory.grass_coords("damp")
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if _is_river_tile(tx, ty):
				if _is_path_tile(tx, ty):
					continue # bridge deck
				water.set_cell(Vector2i(tx, ty), 0, water_vars[rng.randi_range(0, water_vars.size() - 1)])
			elif _is_bank_tile(tx, ty):
				ground.set_cell(Vector2i(tx, ty), 0, damp[rng.randi_range(0, damp.size() - 1)])


func _spawn_sprite(parent: Node2D, path: String, pos: Vector2, z: int = 0) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.texture = load(path) as Texture2D
	spr.position = pos
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = z
	parent.add_child(spr)
	return spr


func _make_hotspot(parent: Node2D, title: String, desc: String, pos: Vector2, size: Vector2) -> InteractableHotspot:
	var hs := InteractableHotspot.new()
	hs.name = title.replace(" ", "")
	hs.title = title
	hs.description = desc
	hs.position = pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	hs.add_child(shape)
	var visual := Node2D.new()
	visual.name = "Visual"
	hs.add_child(visual)
	parent.add_child(hs)
	return hs


func _spawn_buildings(ysort: Node2D) -> void:
	# South-facing art → prefer lots NORTH of plaza so doors face the square.
	# West/east lots sit slightly north so façades still read toward civic space.
	# Avoid south lots for main houses (would face away from plaza).
	var specs := [
		{
			"path": "res://assets/sprites/buildings/building_00.png",
			"pos": Vector2(640, 150),
			"hw": 3, "hh": 2,
			"title": "村公所",
			"desc": "广场北侧主建筑：门脸朝南对着广场，屋前留院子（参考 A09）。",
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(1000, 220),
			"hw": 3, "hh": 2,
			"title": "教堂",
			"desc": "广场东北公共建筑，靠近东向道路入口。",
		},
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(300, 220),
			"hw": 3, "hh": 2,
			"title": "西侧住宅",
			"desc": "河东岸、广场西北民居；门口朝南，院落在建筑与广场之间。",
		},
		{
			"path": "res://assets/sprites/buildings/building_03.png",
			"pos": Vector2(1080, 560),
			"hw": 3, "hh": 2,
			"title": "东侧住宅",
			"desc": "东路南侧住宅（仍偏北朝向，避免把门背对广场）。",
		},
		{
			"path": "res://assets/sprites/buildings/building_04.png",
			"pos": Vector2(420, 220),
			"hw": 2, "hh": 2,
			"title": "北侧小屋",
			"desc": "村公所旁附属小屋，同朝南。",
		},
	]
	for s in specs:
		var pos: Vector2 = s["pos"]
		var cleared := _find_clear_near(pos, int(s["hw"]), int(s["hh"]), 10, false)
		if cleared == Vector2.ZERO:
			continue
		pos = cleared
		var spr := _spawn_sprite(ysort, s["path"], pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.35)
		var hs := _make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 24), Vector2(120, 80))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_props(ysort: Node2D) -> void:
	var well_path := "res://assets/sprites/props/plaza_fountain.png"
	if not ResourceLoader.exists(well_path):
		well_path = "res://assets/sprites/props/fountain.png"
	if ResourceLoader.exists(well_path):
		var f := _spawn_sprite(ysort, well_path, Vector2(640, 480))
		var hs := _make_hotspot(ysort, "水井", "广场中央石井（参考 A09 喷泉区位）。", Vector2(640, 500), Vector2(96, 64))
		f.reparent(hs.get_node("Visual"))
		f.position = Vector2.ZERO

	var samples := [
		{"path": "res://assets/sprites/props/barrel_0.png", "pos": Vector2(500, 430), "title": "木桶", "desc": "摊位旁的木桶。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(780, 430), "title": "货箱", "desc": "市场货箱。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/bench_0.png", "pos": Vector2(560, 540), "title": "长椅", "desc": "广场长椅，面向井。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(720, 540), "title": "路灯", "desc": "广场路灯。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(360, 300), "title": "麻袋", "desc": "西侧屋前草地上的麻袋。", "on_path_ok": false, "hw": 1, "hh": 1},
	]
	for s in samples:
		var pos: Vector2 = s["pos"]
		if s["on_path_ok"]:
			# Plaza furniture: keep off water only.
			if _is_river_tile(_world_to_tile(pos).x, _world_to_tile(pos).y):
				continue
		else:
			var cleared := _find_clear_near(pos, int(s["hw"]), int(s["hh"]), 6, false)
			if cleared == Vector2.ZERO:
				continue
			pos = cleared
		if not ResourceLoader.exists(s["path"]):
			continue
		var spr := _spawn_sprite(ysort, s["path"], pos)
		var hs := _make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	# Grove edges + bank willows. Stem + small ground footprint must be plantable.
	var ideals := [
		Vector2(220, 120),
		Vector2(380, 100),
		Vector2(240, 400),
		Vector2(260, 700),
		Vector2(1100, 120),
		Vector2(1140, 400),
		Vector2(1100, 700),
		Vector2(860, 760),
		Vector2(180, 560),
		Vector2(200, 300),
	]
	for i in ideals.size():
		var pos := _find_clear_near(ideals[i], 1, 1, 8, false)
		if pos == Vector2.ZERO:
			continue
		var t := _world_to_tile(pos)
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			continue
		var spr := _spawn_sprite(ysort, path, pos)
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)
		# Mirror bank trees for variety without inventing facing art.
		if _is_bank_tile(t.x, t.y) or _touches_water(t.x, t.y):
			spr.flip_h = (i % 2 == 0)


func _spawn_actors(ysort: Node2D) -> void:
	var actors := [
		{"path": "res://assets/sprites/npc/npc_00.png", "pos": Vector2(600, 520), "title": "村民", "desc": "在井边休息。"},
		{"path": "res://assets/sprites/npc/npc_01.png", "pos": Vector2(720, 500), "title": "摊主", "desc": "照看摊位。"},
		{"path": "res://assets/sprites/npc/npc_02.png", "pos": Vector2(540, 540), "title": "访客", "desc": "路过广场。"},
	]
	for a in actors:
		if not ResourceLoader.exists(a["path"]):
			continue
		var hs := _make_hotspot(ysort, a["title"], a["desc"], a["pos"], Vector2(40, 56))
		var visual: Node2D = hs.get_node("Visual")
		var spr := _spawn_sprite(visual, a["path"], Vector2.ZERO)
		var tw := spr.create_tween().set_loops()
		tw.tween_property(spr, "position:y", -1.5, 1.1).as_relative().set_trans(Tween.TRANS_SINE)
		tw.tween_property(spr, "position:y", 1.5, 1.1).as_relative().set_trans(Tween.TRANS_SINE)


func _spawn_water_fx(ysort: Node2D) -> void:
	if not ResourceLoader.exists(WATER_ATLAS):
		return
	var atlas := load(WATER_ATLAS) as Texture2D
	if atlas == null:
		return
	var region := AtlasTexture.new()
	region.atlas = atlas
	region.region = Rect2(0, 0, TILE, TILE)
	for ty in range(2, MAP_H - 2, 5):
		for tx in range(MAP_W):
			if not _is_river_tile(tx, ty):
				continue
			if _is_path_tile(tx, ty):
				continue
			var spr := Sprite2D.new()
			spr.texture = region
			spr.position = _tile_center(tx, ty)
			spr.scale = Vector2(1.6, 1.6)
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.modulate = Color(1, 1, 1, 0.55)
			spr.z_index = 1
			ysort.add_child(spr)
			var tw := spr.create_tween().set_loops()
			tw.tween_property(spr, "modulate:a", 0.3, 1.5).set_trans(Tween.TRANS_SINE)
			tw.tween_property(spr, "modulate:a", 0.65, 1.5).set_trans(Tween.TRANS_SINE)
			break


func _spawn_fx(_ysort: Node2D) -> void:
	pass
