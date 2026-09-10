class_name VillageSquareAssembler
extends Node

## Builds layered village square content from normalized atlases/sprites.

const GRASS_ATLAS := "res://assets/tilesets/grass_atlas.png"
const STONE_ATLAS := "res://assets/tilesets/stone_atlas.png"
const DIRT_ATLAS := "res://assets/tilesets/dirt_atlas.png"
const WATER_ATLAS := "res://assets/tilesets/water_atlas.png"


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	var grass_tex := load(GRASS_ATLAS) as Texture2D
	var stone_tex := load(STONE_ATLAS) as Texture2D
	var _dirt_tex := load(DIRT_ATLAS) as Texture2D
	var water_tex := load(WATER_ATLAS) as Texture2D

	ground.tile_set = TileSetFactory.from_atlas(grass_tex)
	path.tile_set = TileSetFactory.from_atlas(stone_tex)
	water.tile_set = TileSetFactory.from_atlas(water_tex if water_tex else grass_tex)

	# Base grass field ~40x30 tiles matching A09 plaza scale
	TileSetFactory.paint_checker(ground, 0, Vector2i(0, 0), Vector2i(1, 0), Rect2i(0, 0, 40, 30))

	# Central stone plaza
	TileSetFactory.paint_checker(path, 0, Vector2i(0, 0), Vector2i(1, 0), Rect2i(14, 10, 12, 10))
	# Approach roads (N/S/E/W)
	TileSetFactory.paint_rect(path, 0, Vector2i(2, 0), Rect2i(18, 0, 4, 10))
	TileSetFactory.paint_rect(path, 0, Vector2i(2, 0), Rect2i(18, 20, 4, 10))
	TileSetFactory.paint_rect(path, 0, Vector2i(3, 0), Rect2i(0, 13, 14, 4))
	TileSetFactory.paint_rect(path, 0, Vector2i(3, 0), Rect2i(26, 13, 14, 4))

	# River on west
	TileSetFactory.paint_rect(water, 0, Vector2i(0, 0), Rect2i(1, 2, 4, 26))
	TileSetFactory.paint_rect(water, 0, Vector2i(1, 0), Rect2i(2, 4, 3, 8))

	_spawn_buildings(ysort)
	_spawn_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	_spawn_water_fx(ysort)
	_spawn_fx(ysort)


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
	var specs := [
		{"path": "res://assets/sprites/buildings/building_00.png", "pos": Vector2(640, 220), "title": "村公所", "desc": "广场北侧的公共建筑，红瓦屋顶与旗帜醒目。"},
		{"path": "res://assets/sprites/buildings/building_01.png", "pos": Vector2(900, 260), "title": "教堂", "desc": "石砌教堂与尖塔，右侧有小型纪念园。"},
		{"path": "res://assets/sprites/buildings/building_02.png", "pos": Vector2(280, 240), "title": "蓝顶住宅", "desc": "两层民居，烟囱与花圃细节。"},
		{"path": "res://assets/sprites/buildings/building_03.png", "pos": Vector2(300, 620), "title": "红顶住宅", "desc": "围栏院子与向日葵，生活气息浓。"},
		{"path": "res://assets/sprites/buildings/building_04.png", "pos": Vector2(980, 620), "title": "湖畔风住宅", "desc": "偏南侧住宅，门口有柴堆与水井区。"},
	]
	for s in specs:
		var spr := _spawn_sprite(ysort, s["path"], s["pos"])
		spr.offset = Vector2(0, -spr.texture.get_height() * 0.35)
		var hs := _make_hotspot(ysort, s["title"], s["desc"], s["pos"] + Vector2(0, 20), Vector2(120, 80))
		# reparent visual link
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_props(ysort: Node2D) -> void:
	# Prefer dedicated plaza fountain from ArtPipeline (B11-05).
	var fountain_path := "res://assets/sprites/props/plaza_fountain.png"
	if not ResourceLoader.exists(fountain_path):
		fountain_path = "res://assets/sprites/props/fountain.png"
	if ResourceLoader.exists(fountain_path):
		var f := _spawn_sprite(ysort, fountain_path, Vector2(640, 480))
		var hs := _make_hotspot(ysort, "中央喷泉", "广场核心喷泉，流水使用序列帧表现动态。", Vector2(640, 500), Vector2(96, 64))
		f.reparent(hs.get_node("Visual"))
		f.position = Vector2.ZERO
	# market stalls approx using props
	var samples := [
		"res://assets/sprites/props/barrel_0.png",
		"res://assets/sprites/props/crate_0.png",
		"res://assets/sprites/props/bench_0.png",
		"res://assets/sprites/props/lamp_0.png",
		"res://assets/sprites/props/well_0.png",
	]
	var positions := [
		Vector2(480, 420), Vector2(800, 420), Vector2(520, 560), Vector2(760, 560), Vector2(980, 700),
	]
	var titles := ["木桶", "货箱摊位", "长椅", "路灯", "水井"]
	for i in samples.size():
		var p: String = samples[i]
		if not ResourceLoader.exists(p):
			continue
		var spr := _spawn_sprite(ysort, p, positions[i])
		var hs := _make_hotspot(ysort, titles[i], "广场装饰与可点击热点。", positions[i], Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	var spots := [
		Vector2(120, 180), Vector2(160, 700), Vector2(1100, 200), Vector2(1080, 700),
		Vector2(420, 180), Vector2(860, 720), Vector2(200, 400), Vector2(1050, 450),
	]
	for i in spots.size():
		var path := "res://assets/sprites/trees/tree_%02d.png" % (i % 6)
		if ResourceLoader.exists(path):
			var spr := _spawn_sprite(ysort, path, spots[i])
			spr.offset = Vector2(0, -spr.texture.get_height() * 0.4)


func _spawn_actors(ysort: Node2D) -> void:
	# Use distinct static NPC sprites. Do NOT cycle idle_frame_* — those crops
	# are not a coherent idle strip and cause morphing glitches.
	var actors := [
		{"path": "res://assets/sprites/npc/npc_00.png", "pos": Vector2(600, 520), "title": "村民", "desc": "在喷泉边休息的村民。"},
		{"path": "res://assets/sprites/npc/npc_01.png", "pos": Vector2(720, 500), "title": "摊主", "desc": "照料摊位的村民。"},
		{"path": "res://assets/sprites/npc/npc_02.png", "pos": Vector2(540, 540), "title": "访客", "desc": "路过广场的访客。"},
	]
	for a in actors:
		if not ResourceLoader.exists(a["path"]):
			continue
		var hs := _make_hotspot(ysort, a["title"], a["desc"], a["pos"], Vector2(40, 56))
		var visual: Node2D = hs.get_node("Visual")
		var spr := _spawn_sprite(visual, a["path"], Vector2.ZERO)
		# Subtle bob only — no frame swapping.
		var tw := spr.create_tween().set_loops()
		tw.tween_property(spr, "position:y", -1.5, 1.1).as_relative().set_trans(Tween.TRANS_SINE)
		tw.tween_property(spr, "position:y", 1.5, 1.1).as_relative().set_trans(Tween.TRANS_SINE)


func _spawn_water_fx(ysort: Node2D) -> void:
	# Fake water_frame_* sheets are mismatched tiles (grass/noise), not a flow strip.
	# Keep river as TileMap only; soft pulse on a single static water tile if present.
	var sample := "res://assets/tilesets/water_atlas.png"
	if not ResourceLoader.exists(sample):
		return
	var atlas := load(sample) as Texture2D
	if atlas == null:
		return
	var region := AtlasTexture.new()
	region.atlas = atlas
	region.region = Rect2(0, 0, Scale.BASE_TILE, Scale.BASE_TILE)
	for y in [200, 400, 600]:
		var spr := Sprite2D.new()
		spr.texture = region
		spr.position = Vector2(96, y)
		spr.scale = Vector2(3, 3)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.modulate = Color(1, 1, 1, 0.85)
		ysort.add_child(spr)
		var tw := spr.create_tween().set_loops()
		tw.tween_property(spr, "modulate:a", 0.55, 1.4).set_trans(Tween.TRANS_SINE)
		tw.tween_property(spr, "modulate:a", 0.9, 1.4).set_trans(Tween.TRANS_SINE)


func _spawn_fx(_ysort: Node2D) -> void:
	# Intentionally empty: extracted smoke/leaf/sparkle frames are not coherent
	# animation strips. Re-enable only after real 4/6/8-frame FX sheets exist.
	pass
