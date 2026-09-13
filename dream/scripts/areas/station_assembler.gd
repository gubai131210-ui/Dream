class_name StationAssembler
extends Node

## Station (A11) — north transit spine: E–W stone platform + parallel track band.
## Silhouette: long platform/track strip + one station roof (not a plaza fountain).
## Reference craft: assets/raw/A11_station.png (do not paste as background).
## Buildings: full sprite AABB inside map_play_rect (BUILDING_PLACEMENT).

const MAP_W := 40
const MAP_H := 30

## Platform stone strip (tile Y) — north of tracks.
const PLATFORM_TY0 := 10
const PLATFORM_TY1 := 12
const PLATFORM_TX0 := 6
const PLATFORM_TX1 := 33

## Track ballast / proxy band (tile Y) — parallel south of platform.
const TRACK_TY0 := 13
const TRACK_TY1 := 14
const TRACK_TX0 := 0
const TRACK_TX1 := 39  # MAP_W - 1 — rails reach both map edges

## Door dirt on platform south of station foot (clear of half_h ~ foot ty 8–9).
const DOOR_LANE_TY0 := 10
const DOOR_LANE_TY1 := 11

## Optional south stream band (foreground water role — not a plaza river clone).
const STREAM_TY_MIN := 20
const STREAM_TY_MAX := 26

var craft: AreaCraft = AreaCraft.new()


func assemble(root: Node2D) -> void:
	var ground: TileMapLayer = root.get_node("Ground")
	var path: TileMapLayer = root.get_node("Path")
	var water: TileMapLayer = root.get_node("Water")
	var ysort: Node2D = root.get_node("YSortRoot")

	craft.setup(MAP_W, MAP_H, "transit")
	_rebuild_masks()
	craft.prepare_layers(ground, path, water)

	craft.paint_ecological_grass(ground)
	craft.paint_dirt_spurs(ground)
	craft.paint_water(water, ground)
	craft.paint_paths(path)

	_spawn_track_proxy(ysort)
	_spawn_station_building(ysort)
	_spawn_platform_benches_and_props(ysort)
	_spawn_trees(ysort)
	_spawn_actors(ysort)
	craft.spawn_water_overlay(ysort)
	_spawn_portals(ysort)


func _rebuild_masks() -> void:
	craft.clear_masks()
	for y in range(MAP_H):
		for x in range(MAP_W):
			craft.water_mask[y][x] = _compute_stream_tile(x, y)

	_paint_platform_and_tracks()
	_paint_dirt_approaches()
	# Paths/dirt punch water except we keep stream south of spine.
	for y in range(MAP_H):
		for x in range(MAP_W):
			if craft.is_path(x, y) or craft.is_dirt(x, y):
				craft.water_mask[y][x] = false
	craft.rebuild_banks()


func _stream_center_x(ty: float) -> float:
	# Short SW meander — foreground access water, not west-wall canal.
	return 8.5 + sin(ty * 0.55) * 1.8 + cos(ty * 0.22 + 0.4) * 0.9


func _stream_half_width(ty: float) -> float:
	return 1.35 + 0.4 * sin(ty * 0.4 + 0.5)


func _compute_stream_tile(tx: int, ty: int) -> bool:
	if ty < STREAM_TY_MIN or ty > STREAM_TY_MAX:
		return false
	if tx < 4 or tx > 14:
		return false
	var cx: float = _stream_center_x(float(ty))
	var hw: float = _stream_half_width(float(ty))
	var dx: float = absf(float(tx) - cx)
	if dx <= hw:
		return true
	if dx <= hw + 0.8 and sin(float(ty) * 0.85 + float(tx) * 0.4) > 0.5:
		return true
	return false


func _set_path(tx: int, ty: int) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	craft.path_mask[ty][tx] = true
	craft.dirt_mask[ty][tx] = false


func _set_dirt(tx: int, ty: int, force: bool = false) -> void:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return
	if craft.is_water(tx, ty) and not force:
		return
	if craft.is_path(tx, ty):
		return
	if force:
		craft.water_mask[ty][tx] = false
	craft.dirt_mask[ty][tx] = true


func _fill_path(x0: int, y0: int, x1: int, y1: int) -> void:
	for ty in range(mini(y0, y1), maxi(y0, y1) + 1):
		for tx in range(mini(x0, x1), maxi(x0, x1) + 1):
			_set_path(tx, ty)


func _fill_dirt(x0: int, y0: int, x1: int, y1: int, force: bool = false) -> void:
	for ty in range(mini(y0, y1), maxi(y0, y1) + 1):
		for tx in range(mini(x0, x1), maxi(x0, x1) + 1):
			_set_dirt(tx, ty, force)


func _paint_platform_and_tracks() -> void:
	# Long E–W stone platform (transit spine — not a centered plaza block).
	_fill_path(PLATFORM_TX0, PLATFORM_TY0, PLATFORM_TX1, PLATFORM_TY1)
	# Stairs / mid access from south dirt up onto platform.
	_fill_path(18, 12, 21, 12)
	# Track ballast as dirt band parallel to platform (sprite sleepers on top).
	_fill_dirt(TRACK_TX0, TRACK_TY0, TRACK_TX1, TRACK_TY1, true)


func _paint_dirt_approaches() -> void:
	# Door apron on platform south of building foot only.
	_fill_dirt(17, DOOR_LANE_TY0, 22, DOOR_LANE_TY1)
	# South approach fork toward platform stairs (dirt, not stone plaza).
	_fill_dirt(18, 15, 21, 28)
	_fill_dirt(14, 22, 17, 24)  # west fork toward stream / bridge
	_fill_dirt(22, 22, 26, 24)  # east fork toward market portal
	# Soft ends of platform (boarding dirt).
	_fill_dirt(PLATFORM_TX0 - 1, PLATFORM_TY0, PLATFORM_TX0 - 1, PLATFORM_TY1)
	_fill_dirt(PLATFORM_TX1 + 1, PLATFORM_TY0, PLATFORM_TX1 + 1, PLATFORM_TY1)
	# North hinterland dirt spur behind station (service path, thin).
	_fill_dirt(18, 6, 21, 8)


func _spawn_track_proxy(ysort: Node2D) -> void:
	## Continuous E–W track band (A11 grammar): seamless ballast+rails+sleepers.
	## Old per-sleeper rail stubs left a visual gap mid-platform — tile a full strip instead.
	const BAND := "res://assets/sprites/props/track_band_seamless_00.png"
	if not ResourceLoader.exists(BAND):
		push_warning("Station: missing track_band_seamless_00 — track will look broken")
		return
	var tex := load(BAND) as Texture2D
	if tex == null:
		return
	var band_top := float(TRACK_TY0) * float(craft.tile)
	var band_bottom := float(TRACK_TY1 + 1) * float(craft.tile)
	var mid_y := (band_top + band_bottom) * 0.5
	var left := float(TRACK_TX0) * float(craft.tile)
	var right := float(TRACK_TX1 + 1) * float(craft.tile)
	var scale_f := 1.15
	var piece_w := float(tex.get_width()) * scale_f
	# Overlap 6px so seams never open a hole in the middle.
	var step := maxf(24.0, piece_w - 6.0)
	var layer := Node2D.new()
	layer.name = "TrackBandContinuous"
	layer.z_index = 1
	ysort.add_child(layer)
	var x := left
	var i := 0
	while x < right - 4.0:
		var spr := Sprite2D.new()
		spr.name = "TrackSeg_%d" % i
		spr.texture = tex
		spr.centered = true
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.position = Vector2(x + piece_w * 0.5, mid_y)
		spr.scale = Vector2(scale_f, scale_f)
		layer.add_child(spr)
		x += step
		i += 1
	# Cap the east end so the last meters are covered even if step undershoots.
	if x + 8.0 < right + piece_w:
		var end := Sprite2D.new()
		end.texture = tex
		end.centered = true
		end.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		end.position = Vector2(right - piece_w * 0.5, mid_y)
		end.scale = Vector2(scale_f, scale_f)
		layer.add_child(end)
	# No extra sleeper overlay — band already has sleepers; stacking made the
	# left look like a thick wooden deck while the right stayed thin rails.
	var mid := Vector2((left + right) * 0.5, mid_y)
	var hs_band := craft.make_hotspot(
		ysort,
		"站台轨道",
		"东西贯通轨道：道砟、枕木与双轨从地图西缘铺到东缘，中间不断开。",
		mid,
		Vector2(right - left, 48)
	)
	hs_band.z_index = 2


func _spawn_station_building(ysort: Node2D) -> void:
	# South-facing station house north of platform; prefer wide roof (building_03).
	var zone := craft.map_play_rect(1.5)
	var specs := [
		{
			"path": "res://assets/sprites/buildings/building_03.png",
			"pos": Vector2(640, 272),  # ~tx 20, ty 8.5 — north of platform, door south
			"hw": 3, "hh": 1,
			"title": "车站主楼",
			"desc": "北站台南向站房：整栋 AABB 在 play zone 内，门脸对石台。",
		},
		{
			# Fallback if building_03 missing — still one roof silhouette.
			"path": "res://assets/sprites/buildings/building_00.png",
			"pos": Vector2(640, 288),
			"hw": 2, "hh": 1,
			"title": "车站主楼",
			"desc": "站台南向站房（备用贴图），整栋在区内。",
			"fallback_only": true,
		},
	]
	var placed := false
	for s in specs:
		if s.get("fallback_only", false) and placed:
			continue
		if not ResourceLoader.exists(s["path"]):
			continue
		var tex := load(s["path"]) as Texture2D
		var offset := craft.building_offset_for(tex)
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_building_inside(
			pos, tex, offset, zone, int(s["hw"]), int(s["hh"]), 18, true
		)
		if cleared == Vector2.ZERO:
			push_warning("Station: could not place %s fully inside play zone" % s["title"])
			continue
		pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(40, 14))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		spr.offset = offset
		craft.mark_blocked_footprint(pos, int(s["hw"]), int(s["hh"]))
		var hs := craft.make_hotspot(
			ysort, s["title"], s["desc"], pos + Vector2(0, 24), Vector2(140, 88)
		)
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO
		placed = true
		break
	if not placed:
		push_warning("Station: no station building placed")


func _spawn_platform_benches_and_props(ysort: Node2D) -> void:
	# bench_1 ONLY on platform stone — one zone style.
	var benches := [
		{"pos": Vector2(400, 368), "title": "站台长椅", "desc": "西段站台长椅（站台款）。"},
		{"pos": Vector2(560, 368), "title": "站台长椅", "desc": "中段站台长椅，靠近站房门脸。"},
		{"pos": Vector2(800, 368), "title": "站台长椅", "desc": "东段站台长椅（站台款）。"},
		{"pos": Vector2(960, 368), "title": "站台长椅", "desc": "东端候车长椅。"},
	]
	for b in benches:
		var path := "res://assets/sprites/props/bench_1.png"
		if not ResourceLoader.exists(path):
			continue
		var pos: Vector2 = b["pos"]
		var t := craft.world_to_tile(pos)
		if not craft.is_path(t.x, t.y):
			# Snap onto platform if slightly off.
			var snapped_pos := craft.find_clear_near(pos, 1, 1, 4, true)
			if snapped_pos == Vector2.ZERO:
				continue
			pos = snapped_pos
			t = craft.world_to_tile(pos)
			if not craft.is_path(t.x, t.y):
				continue
		craft.add_contact_shadow(ysort, pos, Vector2(14, 6))
		var spr := craft.spawn_sprite(ysort, path, pos)
		spr.scale = Vector2(0.55, 0.55)
		var hs := craft.make_hotspot(ysort, b["title"], b["desc"], pos, Vector2(48, 40))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO

	var props := [
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(480, 352), "title": "行李箱", "desc": "站台货箱。"},
		{"path": "res://assets/sprites/props/barrel_1.png", "pos": Vector2(720, 360), "title": "站台桶", "desc": "站房旁木桶。"},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(352, 352), "title": "站台灯", "desc": "西站台灯柱。"},
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(1040, 352), "title": "站台灯", "desc": "东站台灯柱。"},
		{"path": "res://assets/sprites/props/sack_0.png", "pos": Vector2(880, 360), "title": "邮包", "desc": "候车邮包堆。"},
	]
	for s in props:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		if not craft.is_path(t.x, t.y) and not craft.is_dirt(t.x, t.y):
			var cleared := craft.find_clear_near(pos, 1, 1, 5, true)
			if cleared == Vector2.ZERO:
				continue
			pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		spr.scale = Vector2(0.55, 0.55)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(40, 40))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO

	# South approach props (real sprites) — no ColorRect fake shelter building.
	var south_props := [
		{"path": "res://assets/sprites/props/bench_1.png", "pos": Vector2(960, 560), "title": "南口长椅", "desc": "轨道南侧歇脚长椅。"},
		{"path": "res://assets/sprites/props/crate_0.png", "pos": Vector2(1000, 580), "title": "南口货箱", "desc": "南土路旁货箱。", "scale": 0.55},
	]
	for s in south_props:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		var cleared := craft.find_clear_near(pos, 1, 1, 5, true)
		if cleared != Vector2.ZERO:
			pos = cleared
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		craft.add_contact_shadow(ysort, pos, Vector2(12, 5))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		var sc := float(s.get("scale", 0.55))
		if sc > 0.55:
			sc = 0.55
		spr.scale = Vector2(sc, sc)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 40))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO


func _spawn_trees(ysort: Node2D) -> void:
	# Edge forest frames the transit spine — full crown AABB via spawn_tree.
	var zone := craft.map_play_rect(2.0)
	var ideals := [
		# North belt behind station (inset south enough for crowns)
		Vector2(200, 200), Vector2(360, 180), Vector2(520, 190), Vector2(760, 180),
		Vector2(920, 200), Vector2(1080, 190), Vector2(1140, 220),
		# West stream / approach
		Vector2(140, 300), Vector2(160, 480), Vector2(150, 700),
		# South framing (not on dirt approach)
		Vector2(320, 800), Vector2(560, 820), Vector2(800, 810), Vector2(1100, 760),
		# East edge
		Vector2(1160, 340), Vector2(1180, 560), Vector2(1140, 700),
	]
	var placed := 0
	for i in ideals.size():
		var ideal: Vector2 = ideals[i]
		var t0 := craft.world_to_tile(ideal)
		if craft.is_water(t0.x, t0.y) or craft.is_path(t0.x, t0.y):
			continue
		# Keep platform / track band clear of trees.
		if t0.y >= PLATFORM_TY0 - 1 and t0.y <= TRACK_TY1 + 1 and t0.x >= TRACK_TX0 and t0.x <= TRACK_TX1:
			continue
		var path := "res://assets/sprites/trees/grounded/tree_%02d.png" % (i % 6)
		var spr := craft.spawn_tree(ysort, path, ideal, zone, 1, 1, 6, false, 0, false)
		if spr == null:
			continue
		var t := craft.world_to_tile(spr.position)
		if craft.is_path(t.x, t.y) or (t.y >= TRACK_TY0 - 1 and t.y <= TRACK_TY1 + 1 and t.x >= TRACK_TX0 and t.x <= TRACK_TX1):
			spr.queue_free()
			continue
		craft.add_contact_shadow(ysort, spr.position, Vector2(22, 8))
		if craft.is_bank(t.x, t.y) or craft.touches_water(t.x, t.y):
			spr.flip_h = (i % 2 == 0)
		placed += 1
	if placed < 10:
		push_warning("Station: sparse tree spawn (%d) — check tree assets / AABB zone" % placed)


func _spawn_actors(ysort: Node2D) -> void:
	# PatrolActor walk cycles — never animate_patrol sliding.
	var actors := [
		{
			"id": "station_master",
			"title": "站长",
			"desc": "沿站台石板巡视候车区与站房门脸。",
			"waypoints": [
				Vector2(400, 368),
				Vector2(560, 352),
				Vector2(720, 368),
				Vector2(880, 352),
				Vector2(720, 368),
				Vector2(560, 368),
				Vector2(400, 368),
			],
		},
		{
			"id": "merchant",
			"title": "旅客商贩",
			"desc": "从南土路走上站台候车。",
			"waypoints": [
				Vector2(640, 800),
				Vector2(640, 640),
				Vector2(640, 480),
				Vector2(720, 368),
				Vector2(640, 480),
				Vector2(640, 700),
			],
		},
		{
			"id": "farmer",
			"title": "赶车农夫",
			"desc": "在东站台与南口长椅之间走动。",
			"waypoints": [
				Vector2(960, 368),
				Vector2(1040, 448),
				Vector2(960, 560),
				Vector2(880, 448),
				Vector2(960, 368),
			],
		},
	]
	for a in actors:
		craft.spawn_patrol_actor(ysort, a["id"], a["title"], a["desc"], a["waypoints"])


func _spawn_portals(ysort: Node2D) -> void:
	craft.make_portal(ysort, "→广场", SceneRouter.SQUARE_PATH, Vector2(80, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→商业街", SceneRouter.MARKET_PATH, Vector2(1200, 480), Vector2(96, 56))
	craft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))
	# Wave B C11: station house south door → interior waiting hall.
	craft.make_portal(
		ysort,
		"进入车站",
		SceneRouter.C11_STATION_INT_PATH,
		Vector2(640, 320),
		Vector2(120, 56)
	)
	# Wave F — enter coach only while docked with a ticket (runtime gates clicks).
	craft.make_portal(ysort, "进入车厢", SceneRouter.C36_TRAIN_CAR_PATH, Vector2(820, 400), Vector2(120, 56))
	# Outdoor ticket booth cue near platform (live TrainService).
	var booth := craft.make_hotspot(
		ysort,
		"站台售票窗",
		"停靠时才卖票；车次少，余座更少。",
		Vector2(560, 360),
		Vector2(80, 56)
	)
	if ResourceLoader.exists("res://assets/sprites/props/train_ticket_00.png"):
		craft.attach_hotspot_prop(booth, "res://assets/sprites/props/train_ticket_00.png", 1.1)
