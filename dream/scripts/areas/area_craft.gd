class_name AreaCraft
extends RefCounted

## Shared village/farm area craft helpers (realistic-scene-craft skill).
## Hold masks + paint/spawn utilities. Assemblers own layout policy.

const GRASS_ATLAS := "res://assets/tilesets/grass_seamless_atlas.png"
const STONE_ATLAS := "res://assets/tilesets/stone_seamless_atlas.png"
const DIRT_ATLAS := "res://assets/tilesets/dirt_seamless_atlas.png"
const WATER_ATLAS := "res://assets/tilesets/water_seamless_atlas.png"

var map_w: int = 40
var map_h: int = 30
var tile: int = Scale.BASE_TILE

var water_mask: Array = []
var bank_mask: Array = []
var path_mask: Array = []
var dirt_mask: Array = []


func setup(width: int, height: int) -> void:
	map_w = width
	map_h = height
	tile = Scale.BASE_TILE
	clear_masks()


func clear_masks() -> void:
	water_mask.clear()
	bank_mask.clear()
	path_mask.clear()
	dirt_mask.clear()
	for y in range(map_h):
		var wrow: Array = []
		var brow: Array = []
		var prow: Array = []
		var drow: Array = []
		wrow.resize(map_w)
		brow.resize(map_w)
		prow.resize(map_w)
		drow.resize(map_w)
		for x in range(map_w):
			wrow[x] = false
			brow[x] = false
			prow[x] = false
			drow[x] = false
		water_mask.append(wrow)
		bank_mask.append(brow)
		path_mask.append(prow)
		dirt_mask.append(drow)


func rebuild_banks() -> void:
	for y in range(map_h):
		for x in range(map_w):
			bank_mask[y][x] = false
			if water_mask[y][x] or path_mask[y][x] or dirt_mask[y][x]:
				continue
			if touches_water(x, y):
				bank_mask[y][x] = true


func touches_water(tx: int, ty: int) -> bool:
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			if ox == 0 and oy == 0:
				continue
			var nx := tx + ox
			var ny := ty + oy
			if nx < 0 or ny < 0 or nx >= map_w or ny >= map_h:
				continue
			if bool(water_mask[ny][nx]):
				return true
	return false


func is_water(tx: int, ty: int) -> bool:
	return bool(water_mask[ty][tx])


func is_path(tx: int, ty: int) -> bool:
	return bool(path_mask[ty][tx])


func is_dirt(tx: int, ty: int) -> bool:
	return bool(dirt_mask[ty][tx])


func is_bank(tx: int, ty: int) -> bool:
	return bool(bank_mask[ty][tx])


func is_walk(tx: int, ty: int) -> bool:
	return is_path(tx, ty) or is_dirt(tx, ty)


func is_plantable(tx: int, ty: int) -> bool:
	if tx < 0 or ty < 0 or tx >= map_w or ty >= map_h:
		return false
	if is_water(tx, ty) or is_path(tx, ty) or is_dirt(tx, ty):
		return false
	return true


func world_to_tile(pos: Vector2) -> Vector2i:
	return Vector2i(int(floor(pos.x / float(tile))), int(floor(pos.y / float(tile))))


func tile_center(tx: int, ty: int) -> Vector2:
	return Vector2((tx + 0.5) * tile, (ty + 0.5) * tile)


func footprint_ok(center: Vector2, half_w: int, half_h: int, allow_path: bool = false) -> bool:
	var t := world_to_tile(center)
	for oy in range(-half_h, half_h + 1):
		for ox in range(-half_w, half_w + 1):
			var nx := t.x + ox
			var ny := t.y + oy
			if nx < 0 or ny < 0 or nx >= map_w or ny >= map_h:
				return false
			if is_water(nx, ny):
				return false
			if not allow_path and (is_path(nx, ny) or is_dirt(nx, ny)):
				return false
	return true


func find_clear_near(ideal: Vector2, half_w: int, half_h: int, max_r: int = 8, allow_path: bool = false) -> Vector2:
	if footprint_ok(ideal, half_w, half_h, allow_path):
		return ideal
	var t := world_to_tile(ideal)
	for r in range(1, max_r + 1):
		for oy in range(-r, r + 1):
			for ox in range(-r, r + 1):
				if maxi(absi(ox), absi(oy)) != r:
					continue
				var cand := tile_center(t.x + ox, t.y + oy)
				if footprint_ok(cand, half_w, half_h, allow_path):
					return cand
	return Vector2.ZERO


func find_walk_near(ideal: Vector2, max_r: int = 6) -> Vector2:
	var t := world_to_tile(ideal)
	if is_walk(t.x, t.y):
		return tile_center(t.x, t.y)
	for r in range(1, max_r + 1):
		for oy in range(-r, r + 1):
			for ox in range(-r, r + 1):
				if maxi(absi(ox), absi(oy)) != r:
					continue
				var nx := t.x + ox
				var ny := t.y + oy
				if nx < 0 or ny < 0 or nx >= map_w or ny >= map_h:
					continue
				if is_walk(nx, ny):
					return tile_center(nx, ny)
	return Vector2.ZERO


func prepare_layers(ground: TileMapLayer, path: TileMapLayer, water: TileMapLayer) -> void:
	TileSetFactory.clear_layer(ground)
	TileSetFactory.clear_layer(path)
	TileSetFactory.clear_layer(water)
	ground.tile_set = TileSetFactory.from_atlas(load(GRASS_ATLAS) as Texture2D)
	path.tile_set = TileSetFactory.from_atlas(load(STONE_ATLAS) as Texture2D)
	water.tile_set = TileSetFactory.from_atlas(load(WATER_ATLAS) as Texture2D)
	TileSetFactory.configure_layer(ground)
	TileSetFactory.configure_layer(path)
	TileSetFactory.configure_layer(water)


func paint_ecological_grass(ground: TileMapLayer) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var dist := _path_distance_field()
	for ty in range(map_h):
		for tx in range(map_w):
			if is_path(tx, ty) or is_dirt(tx, ty):
				continue
			var kind := "meadow"
			if is_water(tx, ty) or is_bank(tx, ty):
				kind = "damp"
			else:
				var dpath: int = dist[ty][tx]
				var edge := mini(tx, mini(ty, mini(map_w - 1 - tx, map_h - 1 - ty)))
				if dpath <= 2:
					kind = "mowed"
				elif edge <= 2 or dpath >= 8:
					kind = "tall"
				elif rng.randf() < 0.05:
					kind = "weed"
			var variants := TileSetFactory.grass_coords(kind)
			ground.set_cell(Vector2i(tx, ty), 0, variants[rng.randi_range(0, variants.size() - 1)])


func paint_dirt_spurs(ground: TileMapLayer) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var dirt_tex: Texture2D = null
	if ResourceLoader.exists(DIRT_ATLAS):
		dirt_tex = load(DIRT_ATLAS) as Texture2D
	if dirt_tex != null:
		ground.tile_set = _grass_with_dirt(ground.tile_set, dirt_tex)
	var mowed := TileSetFactory.grass_coords("mowed")
	for ty in range(map_h):
		for tx in range(map_w):
			if not is_dirt(tx, ty):
				continue
			if dirt_tex != null:
				ground.set_cell(Vector2i(tx, ty), 1, Vector2i(rng.randi_range(0, 1), 0))
			else:
				ground.set_cell(Vector2i(tx, ty), 0, mowed[rng.randi_range(0, mowed.size() - 1)])


func paint_paths(path: TileMapLayer) -> void:
	var stone: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0)]
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	for ty in range(map_h):
		for tx in range(map_w):
			if not is_path(tx, ty):
				continue
			path.set_cell(Vector2i(tx, ty), 0, stone[rng.randi_range(0, stone.size() - 1)])


func paint_water(water: TileMapLayer, ground: TileMapLayer) -> void:
	var water_vars: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	var damp := TileSetFactory.grass_coords("damp")
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for ty in range(map_h):
		for tx in range(map_w):
			if is_water(tx, ty):
				if is_path(tx, ty):
					continue
				water.set_cell(Vector2i(tx, ty), 0, water_vars[rng.randi_range(0, water_vars.size() - 1)])
			elif is_bank(tx, ty):
				ground.set_cell(Vector2i(tx, ty), 0, damp[rng.randi_range(0, damp.size() - 1)])


## Mark a rectangular dirt crop bed in the dirt mask (assembler paints via paint_dirt_spurs).
func mark_dirt_rect(x0: int, y0: int, x1: int, y1: int, force: bool = false) -> void:
	for ty in range(mini(y0, y1), maxi(y0, y1) + 1):
		for tx in range(mini(x0, x1), maxi(x0, x1) + 1):
			if tx < 0 or ty < 0 or tx >= map_w or ty >= map_h:
				continue
			if not force and (is_water(tx, ty) or is_path(tx, ty)):
				continue
			dirt_mask[ty][tx] = true


## Visual crop rows inside a world-space bed rect (placeholder until B12 slices exist).
func spawn_crop_rows(
	parent: Node2D,
	bed: Rect2,
	title: String,
	desc: String,
	row_color: Color = Color(0.45, 0.72, 0.28, 0.9),
	rows: int = 4
) -> void:
	var hs := make_hotspot(parent, title, desc, bed.get_center(), bed.size)
	var visual: Node2D = hs.get_node("Visual")
	var inset := 6.0
	var inner := Rect2(bed.position + Vector2(inset, inset), bed.size - Vector2(inset, inset) * 2.0)
	if inner.size.x <= 4.0 or inner.size.y <= 4.0:
		return
	var row_h: float = inner.size.y / float(maxi(rows, 1))
	for i in range(rows):
		var strip := ColorRect.new()
		strip.color = row_color.darkened(0.05 * float(i % 3))
		strip.size = Vector2(inner.size.x, maxf(4.0, row_h - 3.0))
		strip.position = inner.position - bed.get_center() + Vector2(0.0, row_h * float(i) + 1.0)
		visual.add_child(strip)


func spawn_sprite(parent: Node2D, path: String, pos: Vector2, z: int = 0) -> Sprite2D:
	var spr := Sprite2D.new()
	spr.texture = load(path) as Texture2D
	spr.position = pos
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = z
	parent.add_child(spr)
	return spr


## Buildings use this Y offset so the door reads near the foot tile.
const BUILDING_Y_OFFSET_FACTOR := 0.35


func building_offset_for(tex: Texture2D) -> Vector2:
	return Vector2(0.0, -float(tex.get_height()) * BUILDING_Y_OFFSET_FACTOR)


func sprite_world_rect(pos: Vector2, tex: Texture2D, offset: Vector2) -> Rect2:
	var size := Vector2(float(tex.get_width()), float(tex.get_height()))
	var top_left := pos + offset - size * 0.5
	return Rect2(top_left, size)


func map_play_rect(margin_tiles: float = 1.0) -> Rect2:
	var m: float = margin_tiles * float(tile)
	return Rect2(m, m, float(map_w) * float(tile) - m * 2.0, float(map_h) * float(tile) - m * 2.0)


func sprite_fully_inside(pos: Vector2, tex: Texture2D, offset: Vector2, zone: Rect2) -> bool:
	var r := sprite_world_rect(pos, tex, offset)
	return (
		r.position.x >= zone.position.x
		and r.position.y >= zone.position.y
		and r.end.x <= zone.end.x
		and r.end.y <= zone.end.y
	)


## Prefer ideal, else search so the full sprite AABB stays inside zone AND tile footprint is clear.
func find_building_inside(
	ideal: Vector2,
	tex: Texture2D,
	offset: Vector2,
	zone: Rect2,
	half_w: int,
	half_h: int,
	max_r: int = 14,
	allow_path: bool = false
) -> Vector2:
	if footprint_ok(ideal, half_w, half_h, allow_path) and sprite_fully_inside(ideal, tex, offset, zone):
		return ideal
	var t := world_to_tile(ideal)
	for r in range(0, max_r + 1):
		for oy in range(-r, r + 1):
			for ox in range(-r, r + 1):
				if r > 0 and maxi(absi(ox), absi(oy)) != r:
					continue
				var cand := tile_center(t.x + ox, t.y + oy)
				if not footprint_ok(cand, half_w, half_h, allow_path):
					continue
				if sprite_fully_inside(cand, tex, offset, zone):
					return cand
	return Vector2.ZERO


func add_contact_shadow(parent: Node2D, at: Vector2, radius: Vector2 = Vector2(18, 8)) -> void:
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


func make_hotspot(parent: Node2D, title: String, desc: String, pos: Vector2, size: Vector2) -> InteractableHotspot:
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


func make_portal(parent: Node2D, title: String, scene_path: String, pos: Vector2, size: Vector2 = Vector2(80, 48)) -> Area2D:
	var area := Area2D.new()
	area.name = "Portal_" + title
	area.position = pos
	area.input_pickable = true
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	area.add_child(shape)
	var hint := Polygon2D.new()
	hint.color = Color(0.3, 0.7, 1.0, 0.25)
	hint.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5),
		Vector2(-size.x * 0.5, size.y * 0.5),
	])
	area.add_child(hint)
	var label := Label.new()
	label.text = title
	label.position = Vector2(-36, -10)
	area.add_child(label)
	area.set_meta("scene_path", scene_path)
	parent.add_child(area)
	return area


func snap_patrol_route(waypoints: Array) -> Array[Vector2]:
	var route: Array[Vector2] = []
	for wp in waypoints:
		var ideal: Vector2 = wp
		var snapped := find_walk_near(ideal, 6)
		if snapped == Vector2.ZERO:
			continue
		if route.size() > 0 and route[route.size() - 1].distance_to(snapped) < 4.0:
			continue
		route.append(snapped)
	if route.size() == 1:
		var t: Vector2i = world_to_tile(route[0])
		var dirs: Array[Vector2i] = [Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]
		for d: Vector2i in dirs:
			var n: Vector2i = t + d
			if n.x < 0 or n.y < 0 or n.x >= map_w or n.y >= map_h:
				continue
			if is_walk(n.x, n.y):
				route.append(tile_center(n.x, n.y))
				route.append(route[0])
				break
	elif route.size() >= 2 and route[0].distance_to(route[route.size() - 1]) > 4.0:
		route.append(route[0])
	return route


func animate_patrol(node: Node2D, waypoints: Array[Vector2]) -> void:
	if waypoints.size() < 2:
		return
	var tw := node.create_tween().set_loops()
	var prev: Vector2 = waypoints[0]
	for i in range(1, waypoints.size()):
		var target: Vector2 = waypoints[i]
		var t := world_to_tile(target)
		if not is_walk(t.x, t.y):
			continue
		var dist: float = prev.distance_to(target)
		var dur: float = clampf(dist / 40.0, 1.2, 4.0)
		tw.tween_property(node, "position", target, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_interval(0.35)
		prev = target


func spawn_water_overlay(parent: Node2D) -> void:
	if not ResourceLoader.exists(WATER_ATLAS):
		return
	var atlas := load(WATER_ATLAS) as Texture2D
	if atlas == null:
		return
	var overlay := Node2D.new()
	overlay.name = "WaterOverlay"
	overlay.z_index = 1
	parent.add_child(overlay)
	var frames: Array[AtlasTexture] = []
	for i in range(3):
		var at := AtlasTexture.new()
		at.atlas = atlas
		at.region = Rect2(i * tile, 0, tile, tile)
		frames.append(at)
	const OVERLAY_CAP := 80
	var idx := 0
	for ty in range(map_h):
		for tx in range(map_w):
			if not is_water(tx, ty) or is_path(tx, ty):
				continue
			if idx >= OVERLAY_CAP:
				break
			var spr := Sprite2D.new()
			spr.texture = frames[(tx + ty) % frames.size()]
			spr.position = tile_center(tx, ty)
			spr.modulate = Color(1, 1, 1, 0.42)
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			overlay.add_child(spr)
			var phase: float = 0.2 * float((tx + ty) % 4)
			var tw := spr.create_tween().set_loops()
			tw.tween_interval(phase)
			tw.tween_property(spr, "modulate:a", 0.22, 0.9).set_trans(Tween.TRANS_SINE)
			tw.tween_property(spr, "modulate:a", 0.5, 0.9).set_trans(Tween.TRANS_SINE)
			spr.set_meta("frame_i", (tx + ty) % frames.size())
			spr.set_meta("frames", frames)
			idx += 1
		if idx >= OVERLAY_CAP:
			break
	if idx > 0:
		var timer := Timer.new()
		timer.wait_time = 0.2
		timer.autostart = true
		overlay.add_child(timer)
		timer.timeout.connect(func():
			for c in overlay.get_children():
				if c is Sprite2D and c.has_meta("frames"):
					var fr: Array = c.get_meta("frames")
					var fi: int = int(c.get_meta("frame_i"))
					fi = (fi + 1) % fr.size()
					c.set_meta("frame_i", fi)
					(c as Sprite2D).texture = fr[fi]
		)


func _path_distance_field() -> Array:
	var dist: Array = []
	var queue: Array[Vector2i] = []
	for y in range(map_h):
		var row: Array = []
		row.resize(map_w)
		for x in range(map_w):
			if is_walk(x, y):
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
			if n.x < 0 or n.y < 0 or n.x >= map_w or n.y >= map_h:
				continue
			var nd: int = int(dist[p.y][p.x]) + 1
			if nd < int(dist[n.y][n.x]):
				dist[n.y][n.x] = nd
				queue.append(n)
	return dist


func _grass_with_dirt(grass_ts: TileSet, dirt_tex: Texture2D) -> TileSet:
	var ts: TileSet = grass_ts.duplicate() as TileSet
	if ts.get_source_count() >= 2:
		return ts
	var src := TileSetAtlasSource.new()
	src.texture = dirt_tex
	src.texture_region_size = Vector2i(tile, tile)
	src.use_texture_padding = true
	@warning_ignore("integer_division")
	var cols: int = maxi(1, int(dirt_tex.get_width()) / tile)
	@warning_ignore("integer_division")
	var rows: int = maxi(1, int(dirt_tex.get_height()) / tile)
	for y in range(rows):
		for x in range(cols):
			src.create_tile(Vector2i(x, y))
	ts.add_source(src, 1)
	return ts
