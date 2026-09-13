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

	# Terraced plots → farmland eco weights (closer to A03 farmland than farm_home yard).
	craft.setup(MAP_W, MAP_H, "farmland")
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
		craft.mark_blocked_footprint(cleared, 2, 1)


func _spawn_terrace_markers(ysort: Node2D) -> void:
	# Dry sandstone terrace lips — RockCatalog.terrace (not forest moss pack).
	var rocks := [
		{"i": 0, "pos": Vector2(300, 310)},
		{"i": 1, "pos": Vector2(400, 310)},
		{"i": 2, "pos": Vector2(740, 315)},
		{"i": 0, "pos": Vector2(260, 500)},
		{"i": 1, "pos": Vector2(480, 495)},
		{"i": 2, "pos": Vector2(700, 505)},
		{"i": 0, "pos": Vector2(220, 690)},
		{"i": 1, "pos": Vector2(440, 685)},
		{"i": 2, "pos": Vector2(660, 695)},
	]
	for r in rocks:
		var path := RockCatalog.path(RockCatalog.FAMILY_TERRACE, int(r["i"]))
		if not ResourceLoader.exists(path):
			continue
		var tex := RockCatalog.load_tex(RockCatalog.FAMILY_TERRACE, int(r["i"]))
		var pos: Vector2 = r["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 5, true)
		if cleared != Vector2.ZERO:
			pos = cleared
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y) or craft.is_blocked(t.x, t.y):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(10, 4))
		var spr := craft.spawn_sprite(ysort, path, pos)
		var sc := RockCatalog.scale_for_target_h(tex, RockCatalog.TARGET_H_TERRACE) if tex else 0.3
		sc = clampf(sc, 0.28, 0.36)
		spr.scale = Vector2(sc, sc)


func _spawn_props(ysort: Node2D) -> void:
	var samples := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(420, 520), "title": "坡地筐", "desc": "梯田收获用的竹筐。", "scale": 0.55},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(640, 680), "title": "粮袋", "desc": "晒在下层台地的粮袋。", "scale": 0.55},
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(540, 360), "title": "水桶", "desc": "台地边取水用桶。", "scale": 0.5},
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
		var sc := float(s.get("scale", 0.55))
		spr.scale = Vector2(sc, sc)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	var zone := craft.map_play_rect(2.0)
	var ideals: Array[Vector2] = [
		Vector2(100, 200), Vector2(120, 480), Vector2(140, 760),
		Vector2(1140, 220), Vector2(1160, 500), Vector2(1120, 780),
	]
	for i in ideals.size():
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		if not ResourceLoader.exists(path):
			path = "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		craft.spawn_tree(ysort, path, ideals[i], zone, 1, 1, 5, false)


func _spawn_actors(ysort: Node2D) -> void:
	craft.spawn_patrol_actor(
		ysort, "farmer", "梯田农人", "沿之字土径上下台地。",
		[Vector2(480, 240), Vector2(520, 420), Vector2(500, 640), Vector2(460, 420)],
	)


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→农田", SceneRouter.FARMLAND_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(1200, 560), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
	# C17 mine mouth — NW hillside cut (append-only; no layout rewrite).
	var mine_mouth := Vector2(180, 200)
	var rock_path := "res://assets/sprites/props/rock_02.png"
	var hs_mine := craft.make_hotspot(
		ysort, "矿洞口", "山坡切入的矿洞入口，通向入口层。", mine_mouth, Vector2(80, 64)
	)
	craft.attach_hotspot_prop(hs_mine, rock_path, 0.35)
	craft.make_portal(
		ysort, "进入矿洞", SceneRouter.C17_MINE_PATH, mine_mouth + Vector2(0, 12), Vector2(96, 52)
	)
	# Wave C C16 — ordinary cave mouth (east hillside; not the NW mine).
	var cave_mouth := Vector2(1000, 240)
	var hs_cave := craft.make_hotspot(
		ysort, "山洞口", "东坡普通洞穴入口，通向入口层。", cave_mouth, Vector2(80, 64)
	)
	craft.attach_hotspot_prop(hs_cave, rock_path, 0.35)
	craft.make_portal(
		ysort, "进入洞穴", SceneRouter.C16_CAVE_ENTRY_PATH, cave_mouth + Vector2(0, 12), Vector2(96, 52)
	)
	# Wave F
	craft.make_portal(ysort, "进入温泉", SceneRouter.C42_HOTSPRING_PATH, Vector2(640, 360), Vector2(100, 52))
