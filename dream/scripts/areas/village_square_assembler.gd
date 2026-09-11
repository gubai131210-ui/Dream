class_name VillageSquareAssembler
extends Node

## Village square assembler — follows realistic-scene-craft skill.
## District: plaza (A09). Ecology via AreaCraft.eco_kind(..., "plaza").
## Pass: masks → ecology → water → path → buildings → props → trees → actors → FX.
## Facing: south-door art → north-of-plaza lots. Reference: A09.

const GRASS_ATLAS := "res://assets/tilesets/grass_seamless_atlas.png"
const STONE_ATLAS := "res://assets/tilesets/stone_seamless_atlas.png"
const DIRT_ATLAS := "res://assets/tilesets/dirt_seamless_atlas.png"
const WATER_ATLAS := "res://assets/tilesets/water_seamless_atlas.png"

const MAP_W := 40
const MAP_H := 30
const TILE := Scale.BASE_TILE

## Bridge band (ACNH-like span rules: prefer 3–5 water tiles).
const BRIDGE_TY0 := 14
const BRIDGE_TY1 := 15

var _water_mask: Array = []
var _bank_mask: Array = []
var _path_mask: Array = []
var _dirt_mask: Array = []


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

	# Optional dirt layer for door yards (same node stack via Ground overwrite after grass).
	_paint_ecological_grass(ground)
	_paint_dirt_spurs(ground)
	_paint_meandering_river(water, ground)
	_paint_paths(path)

	_spawn_buildings(ysort)
	_spawn_props(ysort)
	_spawn_bridge_prop(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	_spawn_water_overlay(ysort)
	_spawn_edge_portals(ysort)


func _spawn_edge_portals(ysort: Node2D) -> void:
	# PHASE2/3/4: east residential+market, south farm, north station.
	var craft := AreaCraft.new()
	craft.setup(MAP_W, MAP_H, "plaza")
	craft.make_portal(
		ysort,
		"→住宅区",
		SceneRouter.RESIDENTIAL_PATH,
		Vector2(1220, 480),
		Vector2(88, 56)
	)
	craft.make_portal(
		ysort,
		"→商业街",
		SceneRouter.MARKET_PATH,
		Vector2(1220, 320),
		Vector2(88, 56)
	)
	craft.make_portal(
		ysort,
		"→农场",
		SceneRouter.FARM_HOME_PATH,
		Vector2(640, 900),
		Vector2(96, 56)
	)
	craft.make_portal(
		ysort,
		"→车站",
		SceneRouter.STATION_PATH,
		Vector2(640, 40),
		Vector2(96, 48)
	)


func _rebuild_masks() -> void:
	_water_mask.clear()
	_bank_mask.clear()
	_path_mask.clear()
	_dirt_mask.clear()
	for y in range(MAP_H):
		var wrow: Array = []
		var brow: Array = []
		var prow: Array = []
		var drow: Array = []
		wrow.resize(MAP_W)
		brow.resize(MAP_W)
		prow.resize(MAP_W)
		drow.resize(MAP_W)
		for x in range(MAP_W):
			wrow[x] = _compute_river_tile(x, y)
			prow[x] = false
			brow[x] = false
			drow[x] = false
		_water_mask.append(wrow)
		_path_mask.append(prow)
		_bank_mask.append(brow)
		_dirt_mask.append(drow)

	# Widen / normalize water across the bridge band so span is 3–5 tiles.
	_normalize_bridge_water()

	for y in range(MAP_H):
		for x in range(MAP_W):
			_path_mask[y][x] = _compute_path_tile(x, y)

	_paint_door_spur_masks()

	for y in range(MAP_H):
		for x in range(MAP_W):
			if _water_mask[y][x] or _path_mask[y][x] or _dirt_mask[y][x]:
				continue
			if _touches_water(x, y):
				_bank_mask[y][x] = true


func _river_center_x(ty: float) -> float:
	# Meander with less pure-period look (skill formula).
	return 4.2 + sin(ty * 0.36) * 2.35 + cos(ty * 0.17 + 0.9) * 1.4 + sin(ty * 0.09 + 0.3) * 0.85


func _river_half_width(ty: float) -> float:
	# Target ~3–5 tile corridor most of the run (ACNH river grammar).
	return 2.15 + 0.85 * sin(ty * 0.24 + 1.1) + 0.4 * cos(ty * 0.51)


func _compute_river_tile(tx: int, ty: int) -> bool:
	var cx: float = _river_center_x(float(ty))
	var hw: float = _river_half_width(float(ty))
	var dx: float = absf(float(tx) - cx)
	if dx <= hw:
		return true
	if dx <= hw + 1.15 and sin(float(ty) * 0.85 + float(tx) * 0.4) > 0.52:
		return true
	return false


func _normalize_bridge_water() -> void:
	# Keep the densest contiguous water run on bridge rows; widen/trim to 3–5 without
	# flooding every gap between distant cove cells.
	for ty in [BRIDGE_TY0, BRIDGE_TY1]:
		var best_lo := -1
		var best_hi := -1
		var best_len := 0
		var run_lo := -1
		for tx in range(MAP_W + 1):
			var wet := tx < MAP_W and bool(_water_mask[ty][tx])
			if wet:
				if run_lo < 0:
					run_lo = tx
			elif run_lo >= 0:
				var run_hi := tx - 1
				var run_len := run_hi - run_lo + 1
				if run_len > best_len:
					best_len = run_len
					best_lo = run_lo
					best_hi = run_hi
				run_lo = -1
		if best_lo < 0:
			continue
		var lo := best_lo
		var hi := best_hi
		var width := hi - lo + 1
		if width < 3:
			var need := 3 - width
			for _i in range(need):
				if hi + 1 < MAP_W:
					hi += 1
					_water_mask[ty][hi] = true
				elif lo - 1 >= 0:
					lo -= 1
					_water_mask[ty][lo] = true
		elif width > 5:
			var excess := width - 5
			for i in range(excess):
				if i % 2 == 0:
					_water_mask[ty][lo] = false
					lo += 1
				else:
					_water_mask[ty][hi] = false
					hi -= 1


func _bridge_water_range() -> Vector2i:
	var lo := MAP_W
	var hi := -1
	for ty in [BRIDGE_TY0, BRIDGE_TY1]:
		for tx in range(MAP_W):
			if _water_mask[ty][tx]:
				lo = mini(lo, tx)
				hi = maxi(hi, tx)
	if hi < 0:
		return Vector2i(3, 7)
	return Vector2i(lo, hi)


func _compute_path_tile(tx: int, ty: int) -> bool:
	# Plaza core.
	if tx >= 14 and tx < 26 and ty >= 10 and ty < 20:
		return true
	# North approach spur (door apron for town hall — stops before building yard).
	if tx >= 18 and tx < 22 and ty >= 8 and ty < 10:
		return true
	# South arm
	if tx >= 18 and tx < 22 and ty >= 20 and ty < 28:
		return true
	# East arm
	if tx >= 26 and tx < 38 and ty >= 13 and ty < 17:
		return true
	# West arm to east bank, then bridge deck over water.
	var br := _bridge_water_range()
	if ty >= 13 and ty < 17:
		# Land approach from plaza to east bank.
		if tx >= br.y + 1 and tx < 14 and not _water_mask[ty][tx]:
			return true
		# Bridge deck exactly over water + one land anchor each side.
		if ty == BRIDGE_TY0 or ty == BRIDGE_TY1:
			if tx >= br.x - 1 and tx <= br.y + 1:
				return true
	return false


func _paint_door_spur_masks() -> void:
	# Dirt spurs: plaza → door apron (ACNH / Spiritfarer walk-line → door).
	# Tile coords match north-of-plaza building slots (south-facing doors).
	var spurs: Array[Array] = [
		# Town hall apron (north of plaza, south of building).
		[Vector2i(19, 7), Vector2i(20, 7), Vector2i(21, 7)],
		# NW house yard path from plaza NW corner.
		[Vector2i(13, 11), Vector2i(12, 11), Vector2i(11, 10), Vector2i(10, 9), Vector2i(10, 8)],
		# Cottage near hall.
		[Vector2i(14, 9), Vector2i(13, 8), Vector2i(13, 7)],
		# Church / NE approach from east arm northward.
		[Vector2i(30, 12), Vector2i(30, 11), Vector2i(30, 10), Vector2i(31, 9)],
		# East house.
		[Vector2i(33, 12), Vector2i(33, 11), Vector2i(33, 10), Vector2i(34, 9)],
	]
	for spur in spurs:
		for cell in spur:
			var c: Vector2i = cell
			if c.x < 0 or c.y < 0 or c.x >= MAP_W or c.y >= MAP_H:
				continue
			if _water_mask[c.y][c.x]:
				continue
			if _path_mask[c.y][c.x]:
				continue
			_dirt_mask[c.y][c.x] = true


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


func _is_dirt_tile(tx: int, ty: int) -> bool:
	return bool(_dirt_mask[ty][tx])


func _is_river_tile(tx: int, ty: int) -> bool:
	return bool(_water_mask[ty][tx])


func _is_bank_tile(tx: int, ty: int) -> bool:
	return bool(_bank_mask[ty][tx])


func _is_walk_surface(tx: int, ty: int) -> bool:
	return _is_path_tile(tx, ty) or _is_dirt_tile(tx, ty)


func _is_plantable_land(tx: int, ty: int) -> bool:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return false
	if _is_river_tile(tx, ty):
		return false
	if _is_path_tile(tx, ty) or _is_dirt_tile(tx, ty):
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
			if not allow_path and (_is_path_tile(nx, ny) or _is_dirt_tile(nx, ny)):
				return false
	return true


func _find_clear_near(ideal: Vector2, half_w: int, half_h: int, max_r: int = 8, allow_path: bool = false) -> Vector2:
	if _footprint_ok(ideal, half_w, half_h, allow_path):
		return ideal
	var t := _world_to_tile(ideal)
	for r in range(1, max_r + 1):
		for oy in range(-r, r + 1):
			for ox in range(-r, r + 1):
				if maxi(absi(ox), absi(oy)) != r:
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
			if _is_path_tile(tx, ty) or _is_dirt_tile(tx, ty):
				continue
			var dpath: int = dist[ty][tx]
			var edge := mini(tx, mini(ty, mini(MAP_W - 1 - tx, MAP_H - 1 - ty)))
			var damp := _is_river_tile(tx, ty) or _is_bank_tile(tx, ty)
			var kind := AreaCraft.eco_kind(dpath, edge, damp, rng.randf(), "plaza")
			var variants := TileSetFactory.grass_coords(kind)
			ground.set_cell(Vector2i(tx, ty), 0, variants[rng.randi_range(0, variants.size() - 1)])


func _paint_dirt_spurs(ground: TileMapLayer) -> void:
	# Door yards: dirt atlas when available; else mowed grass so spurs never leave holes.
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var dirt_tex: Texture2D = null
	if ResourceLoader.exists(DIRT_ATLAS):
		dirt_tex = load(DIRT_ATLAS) as Texture2D
	if dirt_tex != null:
		ground.tile_set = _grass_with_dirt_tileset(ground.tile_set, dirt_tex)
	var mowed := TileSetFactory.grass_coords("mowed")
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if not _is_dirt_tile(tx, ty):
				continue
			if dirt_tex != null:
				ground.set_cell(Vector2i(tx, ty), 1, Vector2i(rng.randi_range(0, 1), 0))
			else:
				ground.set_cell(Vector2i(tx, ty), 0, mowed[rng.randi_range(0, mowed.size() - 1)])


func _grass_with_dirt_tileset(grass_ts: TileSet, dirt_tex: Texture2D) -> TileSet:
	var ts: TileSet = grass_ts.duplicate() as TileSet
	if ts.get_source_count() >= 2:
		return ts
	var src := TileSetAtlasSource.new()
	src.texture = dirt_tex
	src.texture_region_size = Vector2i(TILE, TILE)
	src.use_texture_padding = true
	@warning_ignore("integer_division")
	var cols: int = maxi(1, int(dirt_tex.get_width()) / TILE)
	@warning_ignore("integer_division")
	var rows: int = maxi(1, int(dirt_tex.get_height()) / TILE)
	for y in range(rows):
		for x in range(cols):
			src.create_tile(Vector2i(x, y))
	ts.add_source(src, 1)
	return ts


func _build_path_distance_field() -> Array:
	var dist: Array = []
	var queue: Array[Vector2i] = []
	for y in range(MAP_H):
		var row: Array = []
		row.resize(MAP_W)
		for x in range(MAP_W):
			if _is_walk_surface(x, y):
				row[x] = 0
				queue.append(Vector2i(x, y))
			else:
				row[x] = 999
		dist.append(row)
	var head := 0
	while head < queue.size():
		var p: Vector2i = queue[head]
		head += 1
		var dirs: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
		for d: Vector2i in dirs:
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
					continue
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


func _add_contact_shadow(parent: Node2D, at: Vector2, radius: Vector2 = Vector2(18, 8)) -> void:
	var shadow := Polygon2D.new()
	shadow.color = Color(0, 0, 0, 0.28)
	shadow.polygon = PackedVector2Array([
		Vector2(-radius.x, 0),
		Vector2(0, -radius.y),
		Vector2(radius.x, 0),
		Vector2(0, radius.y),
	])
	shadow.position = at + Vector2(0, 10)
	shadow.z_index = -1
	parent.add_child(shadow)


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
	# Full sprite AABB must stay inside map play rect (tall cottages were clipping the top).
	var craft := AreaCraft.new()
	craft.setup(MAP_W, MAP_H, "plaza")
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _is_river_tile(x, y)
			craft.path_mask[y][x] = _is_path_tile(x, y)
			craft.dirt_mask[y][x] = _is_dirt_tile(x, y)
	var zone := craft.map_play_rect(1.5)
	# Wave B: civic titles on north row (school/clinic/library remapped from old cottages).
	var specs := [
		{
			"path": "res://assets/sprites/buildings/building_00.png",
			"pos": Vector2(640, 280),
			"hw": 2, "hh": 1,
			"title": "村公所",
			"desc": "广场北侧主建筑：整栋在场景内，门脸朝南。",
			"enter_title": "进入村公所",
			"enter_scene": SceneRouter.C06_TOWN_HALL_PATH,
		},
		{
			"path": "res://assets/sprites/buildings/building_01.png",
			"pos": Vector2(1000, 280),
			"hw": 2, "hh": 1,
			"title": "教堂",
			"desc": "广场东北公共建筑，整栋在区内。",
			"enter_title": "进入教堂",
			"enter_scene": SceneRouter.C10_CHURCH_PATH,
		},
		{
			"path": "res://assets/sprites/buildings/building_02.png",
			"pos": Vector2(320, 280),
			"hw": 2, "hh": 1,
			"title": "学校",
			"desc": "广场西北学校：门脸朝南，可进入教室。",
			"enter_title": "进入学校",
			"enter_scene": SceneRouter.C07_SCHOOL_PATH,
		},
		{
			"path": "res://assets/sprites/buildings/building_03.png",
			"pos": Vector2(1080, 300),
			"hw": 2, "hh": 1,
			"title": "图书馆",
			"desc": "广场东侧图书馆，门脸朝南。",
			"enter_title": "进入图书馆",
			"enter_scene": SceneRouter.C09_LIBRARY_PATH,
		},
		{
			"path": "res://assets/sprites/buildings/building_04.png",
			"pos": Vector2(440, 280),
			"hw": 2, "hh": 1,
			"title": "医馆",
			"desc": "村公所西侧医馆，门脸朝南。",
			"enter_title": "进入医馆",
			"enter_scene": SceneRouter.C08_CLINIC_PATH,
		},
	]
	for s in specs:
		if not ResourceLoader.exists(s["path"]):
			continue
		var tex := load(s["path"]) as Texture2D
		var offset := craft.building_offset_for(tex)
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_building_inside(
			pos, tex, offset, zone, int(s["hw"]), int(s["hh"]), 16, false
		)
		if cleared == Vector2.ZERO:
			cleared = craft.find_building_inside(
				pos, tex, offset, zone, int(s["hw"]), int(s["hh"]), 16, true
			)
		if cleared == Vector2.ZERO:
			push_warning("VillageSquare: could not place %s fully inside play zone" % s["title"])
			continue
		pos = cleared
		_add_contact_shadow(ysort, pos, Vector2(36, 12))
		var spr := _spawn_sprite(ysort, s["path"], pos)
		spr.offset = offset
		craft.mark_blocked_footprint(pos, int(s["hw"]), int(s["hh"]))
		var hs := _make_hotspot(ysort, s["title"], s["desc"], pos + Vector2(0, 24), Vector2(120, 80))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO
		# Wave B: enterable civic interiors (scene_path portals — not InfoPanel-only).
		if s.has("enter_scene"):
			craft.make_portal(
				ysort,
				str(s["enter_title"]),
				str(s["enter_scene"]),
				pos + Vector2(0, 28),
				Vector2(100, 52)
			)
	# Wave C C30 — cemetery pocket south of church (append-only).
	var grave := Vector2(1000, 360)
	_add_contact_shadow(ysort, grave, Vector2(20, 8))
	var rock_g := "res://assets/sprites/props/rock_02.png"
	if ResourceLoader.exists(rock_g):
		var gspr := _spawn_sprite(ysort, rock_g, grave)
		gspr.scale = Vector2(0.5, 0.5)
	_make_hotspot(ysort, "教堂墓园", "教堂南侧墓区，可下墓穴。", grave, Vector2(96, 64))
	craft.make_portal(
		ysort, "进入墓园", SceneRouter.C30_CEMETERY_PATH, grave + Vector2(0, 14), Vector2(100, 52)
	)
	# Wave F civic tour
	craft.make_portal(ysort, "进入博物馆", SceneRouter.C40_MUSEUM_PATH, Vector2(220, 280), Vector2(100, 52))
	craft.make_portal(ysort, "进入浴场", SceneRouter.C43_BATHHOUSE_PATH, Vector2(1080, 280), Vector2(100, 52))


func _spawn_props(ysort: Node2D) -> void:
	var well_path := "res://assets/sprites/props/plaza_fountain.png"
	if not ResourceLoader.exists(well_path):
		well_path = "res://assets/sprites/props/fountain.png"
	if ResourceLoader.exists(well_path):
		var well_pos := Vector2(640, 480)
		if not _is_river_tile(_world_to_tile(well_pos).x, _world_to_tile(well_pos).y):
			_add_contact_shadow(ysort, well_pos, Vector2(28, 10))
			var f := _spawn_sprite(ysort, well_path, well_pos)
			f.scale = Vector2(0.55, 0.55)
			var hs := _make_hotspot(ysort, "水井", "广场中央石井（A09 喷泉区位）。", Vector2(640, 500), Vector2(96, 64))
			f.reparent(hs.get_node("Visual"))
			f.position = Vector2.ZERO

	var samples := [
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(500, 430), "title": "木桶", "desc": "摊位旁木桶。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(780, 430), "title": "货箱", "desc": "市场货箱。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/bench_0.png", "pos": Vector2(560, 540), "title": "长椅", "desc": "面向水井的长椅。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(720, 540), "title": "路灯", "desc": "广场路灯。", "on_path_ok": true, "hw": 1, "hh": 1},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(360, 300), "title": "麻袋", "desc": "屋前草地麻袋。", "on_path_ok": false, "hw": 1, "hh": 1},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		if s["on_path_ok"]:
			if _is_river_tile(_world_to_tile(pos).x, _world_to_tile(pos).y):
				continue
		else:
			var cleared := _find_clear_near(pos, int(s["hw"]), int(s["hh"]), 6, false)
			if cleared == Vector2.ZERO:
				continue
			pos = cleared
		if _is_river_tile(_world_to_tile(pos).x, _world_to_tile(pos).y):
			continue
		_add_contact_shadow(ysort, pos, Vector2(14, 6))
		var spr := _spawn_sprite(ysort, s["path"], pos)
		spr.scale = Vector2(0.55, 0.55)
		var hs := _make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_bridge_prop(ysort: Node2D) -> void:
	# Landmark on the authored bridge band (deck is path tiles; prop sells the crossing).
	var br := _bridge_water_range()
	var mid_x := int((br.x + br.y) * 0.5)
	var pos := _tile_center(mid_x, BRIDGE_TY0)
	var hs := _make_hotspot(
		ysort,
		"木桥",
		"西河桥跨：水面宽度约 3–5 格，两岸留锚点，石板铺面跨水。",
		pos,
		Vector2(96, 48)
	)
	# Simple plank readout if no bridge sprite: tinted stone strip already on Path.
	var label_proxy := ColorRect.new()
	label_proxy.size = Vector2(72, 18)
	label_proxy.position = Vector2(-36, -8)
	label_proxy.color = Color(0.45, 0.32, 0.18, 0.55)
	hs.get_node("Visual").add_child(label_proxy)


func _make_craft() -> AreaCraft:
	var craft := AreaCraft.new()
	craft.setup(MAP_W, MAP_H, "plaza")
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _is_river_tile(x, y)
			craft.path_mask[y][x] = _is_path_tile(x, y)
			craft.dirt_mask[y][x] = _is_dirt_tile(x, y)
	craft.rebuild_banks()
	return craft


func _spawn_trees(ysort: Node2D) -> void:
	# Full crown AABB via spawn_tree — no north-edge clip / footprint-only feet.
	var craft := _make_craft()
	var zone := craft.map_play_rect(2.0)
	var ideals := [
		Vector2(220, 200),
		Vector2(380, 180),
		Vector2(240, 400),
		Vector2(260, 700),
		Vector2(1100, 200),
		Vector2(1140, 400),
		Vector2(1100, 700),
		Vector2(860, 760),
		Vector2(180, 560),
		Vector2(200, 300),
	]
	for i in ideals.size():
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		var spr := craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 8, false)
		if spr == null:
			continue
		var t := craft.world_to_tile(spr.position)
		if craft.is_bank(t.x, t.y) or craft.touches_water(t.x, t.y):
			spr.flip_h = (i % 2 == 0)


func _spawn_actors(ysort: Node2D) -> void:
	# PatrolActor walk frames — never tween-slide static sprites.
	var craft := _make_craft()
	var actors := [
		{
			"id": "elder_woman",
			"title": "村民",
			"desc": "在井边与长椅之间走动。",
			"waypoints": [Vector2(600, 520), Vector2(560, 540), Vector2(640, 500), Vector2(600, 520)],
		},
		{
			"id": "merchant",
			"title": "摊主",
			"desc": "守着东侧摊位一带。",
			"waypoints": [Vector2(720, 500), Vector2(780, 430), Vector2(720, 460), Vector2(720, 500)],
		},
		{
			"id": "farmer",
			"title": "访客",
			"desc": "沿广场石路环行。",
			"waypoints": [Vector2(540, 480), Vector2(700, 480), Vector2(700, 560), Vector2(540, 560), Vector2(540, 480)],
		},
	]
	for a in actors:
		craft.spawn_patrol_actor(ysort, a["id"], a["title"], a["desc"], a["waypoints"])


func _spawn_water_overlay(ysort: Node2D) -> void:
	# Stardew-like shared shimmer: cycle atlas frames on water cells (checkerboard phase).
	if not ResourceLoader.exists(WATER_ATLAS):
		return
	var atlas := load(WATER_ATLAS) as Texture2D
	if atlas == null:
		return
	var overlay := Node2D.new()
	overlay.name = "WaterOverlay"
	overlay.z_index = 1
	ysort.add_child(overlay)
	var frames: Array[AtlasTexture] = []
	for i in range(3):
		var at := AtlasTexture.new()
		at.atlas = atlas
		at.region = Rect2(i * TILE, 0, TILE, TILE)
		frames.append(at)
	const OVERLAY_CAP := 80
	var idx := 0
	for ty in range(MAP_H):
		for tx in range(MAP_W):
			if not _is_river_tile(tx, ty):
				continue
			if _is_path_tile(tx, ty):
				continue
			if idx >= OVERLAY_CAP:
				break
			var spr := Sprite2D.new()
			spr.texture = frames[(tx + ty) % frames.size()]
			spr.position = _tile_center(tx, ty)
			spr.modulate = Color(1, 1, 1, 0.42)
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			overlay.add_child(spr)
			var phase: float = 0.2 * float((tx + ty) % 4)
			var tw := spr.create_tween().set_loops()
			tw.tween_interval(phase)
			tw.tween_property(spr, "modulate:a", 0.22, 0.9).set_trans(Tween.TRANS_SINE)
			tw.tween_property(spr, "modulate:a", 0.5, 0.9).set_trans(Tween.TRANS_SINE)
			var frame_i: int = (tx + ty) % frames.size()
			spr.set_meta("frame_i", frame_i)
			spr.set_meta("frames", frames)
			idx += 1
		if idx >= OVERLAY_CAP:
			break
	if idx > 0:
		_start_water_frame_ticker(overlay)


func _start_water_frame_ticker(overlay: Node2D) -> void:
	var timer := Timer.new()
	timer.wait_time = 0.2
	timer.autostart = true
	overlay.add_child(timer)
	timer.timeout.connect(func():
		for c in overlay.get_children():
			if c is Sprite2D and c.has_meta("frames"):
				var frames: Array = c.get_meta("frames")
				var fi: int = int(c.get_meta("frame_i"))
				fi = (fi + 1) % frames.size()
				c.set_meta("frame_i", fi)
				(c as Sprite2D).texture = frames[fi]
	)
