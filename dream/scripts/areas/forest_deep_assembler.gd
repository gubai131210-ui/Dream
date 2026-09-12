class_name ForestDeepAssembler
extends Node

## Deep forest (A05) — dense canopy, low light, winding dirt only.
## Silhouette: continuous tree mass + serpentine trail (NO large clearing / NO stone plaza).

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
	# Dirt-only walkways — leave Path layer empty (no stone plaza).
	craft.paint_paths(path)

	_apply_canopy_tint(root)
	_spawn_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _apply_canopy_tint(root: Node2D) -> void:
	var mod := CanvasModulate.new()
	mod.name = "CanopyTint"
	# Cooler, dimmer under dense canopy (vs brighter forest entrance clearing).
	mod.color = Color(0.62, 0.70, 0.68, 1.0)
	root.add_child(mod)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _compute_stream_tile(x, y)
	_paint_winding_dirt()
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_dirt(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _stream_cx(ty: float) -> float:
	# East meander — opposite of A04 west brook.
	return 31.5 + sin(ty * 0.42 + 0.8) * 1.6 + cos(ty * 0.19) * 0.7


func _stream_hw(ty: float) -> float:
	return 0.85 + 0.25 * sin(ty * 0.55 + 1.1)


func _compute_stream_tile(tx: int, ty: int) -> bool:
	# Tiny east stream — optional meander, not a wide river.
	if ty < 6 or ty > 24:
		return false
	if tx < 26 or tx > 36:
		return false
	var cx := _stream_cx(float(ty))
	var hw := _stream_hw(float(ty))
	var dx := absf(float(tx) - cx)
	if dx <= hw:
		return true
	if dx <= hw + 0.55 and sin(float(ty) * 0.9 + float(tx) * 0.4) > 0.55:
		return true
	return false


func _set_dirt(tx: int, ty: int, force: bool = false) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	if not force and craft.is_water(tx, ty):
		return
	craft.water_mask[ty][tx] = false
	craft.dirt_mask[ty][tx] = true
	craft.path_mask[ty][tx] = false


func _trail_cx(ty: float) -> float:
	# Serpentine N–S spine that weaves (not a straight clearing corridor).
	return 17.0 + sin(ty * 0.33) * 5.2 + cos(ty * 0.17 + 0.4) * 2.4


func _paint_winding_dirt() -> void:
	# Main winding dirt trail — 1–2 tiles wide, no rectangular clearing apron.
	for ty in range(2, MAP_H - 1):
		var cx := _trail_cx(float(ty))
		var hw := 0.85 + 0.2 * sin(float(ty) * 0.6)
		for tx in range(MAP_W):
			if absf(float(tx) - cx) <= hw:
				_set_dirt(tx, ty)
	# Soft pockets at bends only (tiny, not a plaza).
	_set_dirt(12, 10)
	_set_dirt(13, 10)
	_set_dirt(22, 18)
	_set_dirt(23, 18)
	_set_dirt(15, 22)
	# East spur toward river portal (crosses stream on a short dirt bridge).
	var spur_y := 14
	var spur_cx := int(round(_trail_cx(float(spur_y))))
	for tx in range(spur_cx, MAP_W - 1):
		_set_dirt(tx, spur_y, true)
		_set_dirt(tx, spur_y + 1, true)
	# North fork toward waterfall portal.
	var north_cx := int(round(_trail_cx(4.0)))
	for ty in range(1, 7):
		_set_dirt(north_cx, ty)
		_set_dirt(north_cx + 1, ty)
	# South mouth toward forest entrance.
	var south_cx := int(round(_trail_cx(27.0)))
	for ty in range(25, MAP_H):
		_set_dirt(south_cx - 1, ty)
		_set_dirt(south_cx, ty)
		_set_dirt(south_cx + 1, ty)


func _spawn_props(ysort: Node2D) -> void:
	# Sparse forest litter only — no cabin / no plaza furniture cluster.
	var samples := [
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(420, 340), "title": "苔藓行囊", "desc": "被遗弃在树根旁的行囊。", "scale": 0.55},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(720, 580), "title": "朽木箱", "desc": "深林小径旁潮湿木箱。", "scale": 0.5},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(560, 700), "title": "林灯", "desc": "土径急弯处的微弱路灯。", "scale": 0.55},
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
		spr.modulate = Color(0.78, 0.82, 0.76)
		var sc := float(s.get("scale", 0.55))
		spr.scale = Vector2(sc, sc)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	# Dense canopy — full AABB via spawn_tree; zone inset so crowns never clip map edge.
	var zone := craft.map_play_rect(2.5)
	var ideals: Array[Vector2] = []
	# Tighter step-3 grid, feet start far enough south for tall crowns (AABB ⊆ zone).
	for gy in range(5, MAP_H - 4, 3):
		for gx in range(3, MAP_W - 3, 3):
			var jx := (gy * 17 + gx * 13) % 5 - 2
			var jy := (gx * 11 + gy * 7) % 5 - 2
			ideals.append(craft.tile_center(clampi(gx + jx, 3, MAP_W - 4), clampi(gy + jy, 5, MAP_H - 5)))
	# Soft side mass — south of ~ty 7 so half-trees cannot remain on the north rim.
	ideals.append_array([
		Vector2(140, 260), Vector2(120, 480), Vector2(150, 700),
		Vector2(1120, 280), Vector2(1140, 520), Vector2(1100, 740),
		Vector2(320, 240), Vector2(640, 260), Vector2(900, 250),
		Vector2(280, 800), Vector2(640, 820), Vector2(960, 780),
		Vector2(200, 600), Vector2(1080, 620),
	])
	var placed := 0
	for i in ideals.size():
		var ideal: Vector2 = ideals[i]
		var t0 := craft.world_to_tile(ideal)
		if craft.is_water(t0.x, t0.y) or craft.is_dirt(t0.x, t0.y):
			continue
		# Keep a narrow visual gap along the trail (no plaza clearing).
		var trail := _trail_cx(float(t0.y))
		if absf(float(t0.x) - trail) < 2.4 and t0.y >= 2 and t0.y <= 27:
			continue
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		var spr := craft.spawn_tree(ysort, path, ideal, zone, 1, 1, 4, false, 0, false)
		if spr == null:
			continue
		# Reject if search drifted onto trail corridor (keeps serpentine silhouette).
		var tf := craft.world_to_tile(spr.position)
		var trail_f := _trail_cx(float(tf.y))
		if absf(float(tf.x) - trail_f) < 2.0 and tf.y >= 2 and tf.y <= 27:
			spr.queue_free()
			continue
		craft.add_contact_shadow(ysort, spr.position, Vector2(22, 8))
		spr.flip_h = (i % 2 == 0)
		spr.modulate = Color(0.68, 0.74, 0.66)
		placed += 1
	if placed < 22:
		push_warning("ForestDeep: sparse tree spawn (%d) — check tree assets / AABB zone" % placed)


func _spawn_actors(ysort: Node2D) -> void:
	# Sparse — one patrol on the winding dirt (not A04 dual-NPC clearing walk).
	var mid_a := craft.tile_center(int(round(_trail_cx(20.0))), 20)
	var mid_b := craft.tile_center(int(round(_trail_cx(14.0))), 14)
	var mid_c := craft.tile_center(int(round(_trail_cx(10.0))), 10)
	var mid_d := craft.tile_center(int(round(_trail_cx(18.0))) + 3, 18)
	craft.spawn_patrol_actor(
		ysort,
		"farmer",
		"拾薪人",
		"沿蜿蜒土径在深林中缓慢走动。",
		[mid_a, mid_b, mid_c, mid_d, mid_a],
	)


func _spawn_portals(ysort: Node2D) -> void:
	var south_cx := int(round(_trail_cx(28.0)))
	var north_cx := int(round(_trail_cx(3.0)))
	craft.make_portal(
		ysort, "→森林入口", SceneRouter.FOREST_ENTRANCE_PATH,
		craft.tile_center(south_cx, 28), Vector2(96, 56)
	)
	craft.make_portal(
		ysort, "→河流", SceneRouter.RIVER_PATH,
		Vector2(1200, 464), Vector2(96, 56)
	)
	craft.make_portal(
		ysort, "→瀑布", SceneRouter.WATERFALL_PATH,
		craft.tile_center(north_cx, 2), Vector2(96, 56)
	)
	craft.make_portal(
		ysort, "→总览", SceneRouter.HUB_PATH,
		Vector2(640, 40), Vector2(96, 48)
	)
	# C27 — bend dirt pockets only (append-only; keep canopy / trail silhouette).
	craft.make_portal(
		ysort, "进入猎人隐所", SceneRouter.C27_FOREST_HIDE_A_PATH,
		craft.tile_center(12, 10), Vector2(100, 56)
	)
	craft.make_portal(
		ysort, "进入蘑菇窝棚", SceneRouter.C27_FOREST_HIDE_B_PATH,
		craft.tile_center(22, 18), Vector2(100, 56)
	)
	# Wave C C28 / C29 — append-only landmarks on dirt pockets.
	var giant := craft.tile_center(16, 14)
	var hs_giant := craft.make_hotspot(ysort, "巨树", "深林巨木，树干有洞口。", giant, Vector2(88, 72))
	craft.attach_hotspot_prop(hs_giant, "res://assets/sprites/trees/grounded/tree_04.png", 0.95)
	craft.make_portal(
		ysort, "进入巨树洞", SceneRouter.C28_GIANT_TREE_PATH,
		giant + Vector2(0, 16), Vector2(100, 56)
	)
	var ruins := craft.tile_center(28, 12)
	var hs_ruins := craft.make_hotspot(ysort, "遗迹残垣", "林间石砌遗迹门洞。", ruins, Vector2(88, 64))
	craft.attach_hotspot_prop(hs_ruins, "res://assets/sprites/props/ruin_arch_00.png", 0.7)
	craft.make_portal(
		ysort, "进入遗迹", SceneRouter.C29_RUINS_PATH,
		ruins + Vector2(0, 14), Vector2(100, 56)
	)
