class_name LighthouseAssembler
extends Node

## Lighthouse (A14) — sliced lighthouse + coastal rocks.
## Full sprite AABB inside play zone. No ColorRect tower / coast hacks.

const MAP_W := 40
const MAP_H := 30
const BUILD_Y := 0.35
const TREE_Y := 0.40


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
	_spawn_lighthouse(ysort)
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
	# Dirt from west (lake) to tower pad — foot far enough south for tall AABB.
	for tx in range(2, 22):
		_set_dirt(tx, 16)
		_set_dirt(tx, 17)
	for ty in range(12, 22):
		for tx in range(14, 22):
			_set_dirt(tx, ty)
	for tx in range(14, 24):
		_set_dirt(tx, 19)
		_set_dirt(tx, 20)
		_set_dirt(tx, 21)


func _scaled_fully_inside(pos: Vector2, tex: Texture2D, y_factor: float, scale_f: float, zone: Rect2) -> bool:
	var size := Vector2(float(tex.get_width()), float(tex.get_height())) * scale_f
	var offset := Vector2(0.0, -float(tex.get_height()) * y_factor) * scale_f
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
	y_factor: float,
	scale_f: float,
	zone: Rect2,
	half_w: int,
	half_h: int,
	max_r: int,
	allow_path: bool
) -> Vector2:
	if craft.footprint_ok(ideal, half_w, half_h, allow_path) and _scaled_fully_inside(ideal, tex, y_factor, scale_f, zone):
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
				if _scaled_fully_inside(cand, tex, y_factor, scale_f, zone):
					return cand
	return Vector2.ZERO


func _spawn_lighthouse(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	var path := "res://assets/sprites/buildings/lighthouse_00.png"
	if not ResourceLoader.exists(path):
		return
	var tex := load(path) as Texture2D
	if tex == null:
		return
	# Prefer building offset; fall back to tree offset for very tall sheets.
	var offset := craft.building_offset_for(tex)
	# Southern ideal so the lantern clears the north play-zone margin.
	var ideal := Vector2(560, 640)
	var cleared := craft.find_building_inside(ideal, tex, offset, zone, 2, 1, 22, true)
	var scale_f := 1.0
	if cleared == Vector2.ZERO:
		offset = craft.tree_offset_for(tex)
		cleared = craft.find_building_inside(ideal, tex, offset, zone, 2, 1, 22, true)
	if cleared == Vector2.ZERO:
		# Oversized sheet: scale down while keeping full AABB inside zone.
		for s in [0.7, 0.55, 0.45, 0.38]:
			cleared = _find_scaled_inside(ideal, tex, BUILD_Y, s, zone, 2, 1, 22, true)
			if cleared != Vector2.ZERO:
				offset = craft.building_offset_for(tex)
				scale_f = s
				break
			cleared = _find_scaled_inside(ideal, tex, TREE_Y, s, zone, 2, 1, 22, true)
			if cleared != Vector2.ZERO:
				offset = craft.tree_offset_for(tex)
				scale_f = s
				break
	if cleared == Vector2.ZERO:
		push_warning("Lighthouse: lighthouse_00 could not fit play zone")
		return
	craft.add_contact_shadow(ysort, cleared, Vector2(40, 14))
	var spr := craft.spawn_sprite(ysort, path, cleared)
	spr.offset = offset
	craft.mark_blocked_footprint(cleared, 2, 1)
	if scale_f < 0.999:
		spr.scale = Vector2(scale_f, scale_f)
	# C12 door portal at south foot (replace InfoPanel-only hotspot). Keep lake/hub portals elsewhere.
	craft.make_portal(
		ysort,
		"进入灯塔",
		SceneRouter.C12_LIGHTHOUSE_INT_PATH,
		cleared + Vector2(0, 28),
		Vector2(112, 56)
	)


func _spawn_rocks(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	# Coast rocks — large sheets, must scale ~0.35–0.45; feet on peninsula dirt only.
	var specs := [
		{"i": 0, "pos": Vector2(688, 560), "s": 0.42},
		{"i": 1, "pos": Vector2(704, 672), "s": 0.4},
		{"i": 3, "pos": Vector2(480, 688), "s": 0.38},
		{"i": 5, "pos": Vector2(560, 720), "s": 0.36},
	]
	for s in specs:
		var path := "res://assets/sprites/props/rock_%02d.png" % int(s["i"])
		if not ResourceLoader.exists(path):
			continue
		var tex := load(path) as Texture2D
		if tex == null:
			continue
		var scale_f: float = float(s["s"])
		var cleared := _find_scaled_inside(s["pos"], tex, TREE_Y, scale_f, zone, 1, 1, 12, true)
		if cleared == Vector2.ZERO:
			continue
		var t := craft.world_to_tile(cleared)
		if craft.is_water(t.x, t.y):
			continue
		craft.add_contact_shadow(ysort, cleared, Vector2(14, 6))
		var spr := craft.spawn_sprite(ysort, path, cleared)
		spr.offset = craft.tree_offset_for(tex)
		spr.scale = Vector2(scale_f, scale_f)


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(400, 560), "title": "补给箱", "desc": "灯塔补给木箱。", "scale": 0.55},
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(480, 600), "title": "油桶", "desc": "灯油空桶。", "scale": 0.5},
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
	# Land only (west of coast) — spawn_tree rejects water footprint.
	var ideals: Array[Vector2] = [
		Vector2(120, 280), Vector2(160, 520), Vector2(140, 780),
		Vector2(360, 260), Vector2(300, 800), Vector2(240, 400),
	]
	for i in ideals.size():
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 8, false)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "station_master", "守塔人", "在灯塔基座与西侧湖路之间巡视。",
		[Vector2(400, 560), Vector2(520, 600), Vector2(360, 520), Vector2(440, 560)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(80, 520), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
