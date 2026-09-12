class_name AreaCraft
extends RefCounted

## Shared village/farm area craft helpers (realistic-scene-craft skill).
## Hold masks + paint/spawn utilities. Assemblers own layout policy.
## District ecology: docs/AREA_FRAMEWORK.md + reference-formulas.md zone profiles.

const GRASS_ATLAS := "res://assets/tilesets/grass_seamless_atlas.png"
const STONE_ATLAS := "res://assets/tilesets/stone_seamless_atlas.png"
const DIRT_ATLAS := "res://assets/tilesets/dirt_seamless_atlas.png"
const WATER_ATLAS := "res://assets/tilesets/water_seamless_atlas.png"

## Ecology thresholds per district (mowed_max / tall_dpath / edge_tall / weed_p).
## Keep in sync with docs/AREA_FRAMEWORK.md and realistic-scene-craft/reference-formulas.md.
const ECO_PROFILES := {
	"plaza": {"mowed_max": 2, "tall_dpath": 8, "edge_tall": 2, "weed_p": 0.05},
	"residential": {"mowed_max": 1, "tall_dpath": 999, "edge_tall": 2, "weed_p": 0.03},
	"farm_home": {"mowed_max": 1, "tall_dpath": 14, "edge_tall": 1, "weed_p": 0.08},
	"farmland": {"mowed_max": 1, "tall_dpath": 12, "edge_tall": 2, "weed_p": 0.04},
	"market": {"mowed_max": 2, "tall_dpath": 14, "edge_tall": 1, "weed_p": 0.03},
	## Outdoor shells (forest / river / lake / station edges): tall-biased, little mow.
	"wild": {"mowed_max": 0, "tall_dpath": 4, "edge_tall": 3, "weed_p": 0.06},
	"transit": {"mowed_max": 1, "tall_dpath": 10, "edge_tall": 2, "weed_p": 0.04},
}

var map_w: int = 40
var map_h: int = 30
var tile: int = Scale.BASE_TILE
## AREA_FRAMEWORK district id — must be set by assembler before paint_ecological_grass.
var district: String = "plaza"

var water_mask: Array = []
var bank_mask: Array = []
var path_mask: Array = []
var dirt_mask: Array = []
var blocked_mask: Array = []


func setup(width: int, height: int, district_id: String = "plaza") -> void:
	map_w = width
	map_h = height
	tile = Scale.BASE_TILE
	set_district(district_id)
	clear_masks()


func set_district(district_id: String) -> void:
	if ECO_PROFILES.has(district_id):
		district = district_id
	else:
		push_warning("AreaCraft: unknown district '%s', falling back to plaza" % district_id)
		district = "plaza"


static func eco_kind(dpath: int, edge: int, damp: bool, weed_roll: float, district_id: String) -> String:
	## Shared ecology classifier so non-AreaCraft assemblers (e.g. village square) stay in sync.
	if damp:
		return "damp"
	var profile: Dictionary = ECO_PROFILES.get(district_id, ECO_PROFILES["plaza"])
	var mowed_max: int = int(profile.get("mowed_max", 2))
	var tall_dpath: int = int(profile.get("tall_dpath", 8))
	var edge_tall: int = int(profile.get("edge_tall", 2))
	var weed_p: float = float(profile.get("weed_p", 0.05))
	if dpath <= mowed_max:
		return "mowed"
	if edge <= edge_tall or dpath >= tall_dpath:
		return "tall"
	if weed_roll < weed_p:
		return "weed"
	return "meadow"


func clear_masks() -> void:
	water_mask.clear()
	bank_mask.clear()
	path_mask.clear()
	dirt_mask.clear()
	blocked_mask.clear()
	for y in range(map_h):
		var wrow: Array = []
		var brow: Array = []
		var prow: Array = []
		var drow: Array = []
		var blkrow: Array = []
		wrow.resize(map_w)
		brow.resize(map_w)
		prow.resize(map_w)
		drow.resize(map_w)
		blkrow.resize(map_w)
		for x in range(map_w):
			wrow[x] = false
			brow[x] = false
			prow[x] = false
			drow[x] = false
			blkrow[x] = false
		water_mask.append(wrow)
		bank_mask.append(brow)
		path_mask.append(prow)
		dirt_mask.append(drow)
		blocked_mask.append(blkrow)


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


func _in_bounds(tx: int, ty: int) -> bool:
	return tx >= 0 and ty >= 0 and tx < map_w and ty < map_h


func is_water(tx: int, ty: int) -> bool:
	if not _in_bounds(tx, ty):
		return false
	return bool(water_mask[ty][tx])


func is_path(tx: int, ty: int) -> bool:
	if not _in_bounds(tx, ty):
		return false
	return bool(path_mask[ty][tx])


func is_dirt(tx: int, ty: int) -> bool:
	if not _in_bounds(tx, ty):
		return false
	return bool(dirt_mask[ty][tx])


func is_bank(tx: int, ty: int) -> bool:
	if not _in_bounds(tx, ty):
		return false
	return bool(bank_mask[ty][tx])


func is_blocked(tx: int, ty: int) -> bool:
	if not _in_bounds(tx, ty):
		return false
	return bool(blocked_mask[ty][tx])


func mark_blocked(tx: int, ty: int) -> void:
	if not _in_bounds(tx, ty):
		return
	blocked_mask[ty][tx] = true


## Mark building foot / tree trunk tiles around a world-space center.
func mark_blocked_footprint(world_pos: Vector2, half_w: int, half_h: int) -> void:
	var t := world_to_tile(world_pos)
	for oy in range(-half_h, half_h + 1):
		for ox in range(-half_w, half_w + 1):
			mark_blocked(t.x + ox, t.y + oy)


## NPC walk: grass/dirt/path OK; water and building/tree blocked tiles are not.
func is_npc_walkable(tx: int, ty: int) -> bool:
	if not _in_bounds(tx, ty):
		return false
	if is_water(tx, ty) or is_blocked(tx, ty):
		return false
	return true


func is_walk(tx: int, ty: int) -> bool:
	return is_path(tx, ty) or is_dirt(tx, ty)


func is_plantable(tx: int, ty: int) -> bool:
	if not _in_bounds(tx, ty):
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
			var dpath: int = dist[ty][tx]
			var edge := mini(tx, mini(ty, mini(map_w - 1 - tx, map_h - 1 - ty)))
			var damp := is_water(tx, ty) or is_bank(tx, ty)
			var kind := eco_kind(dpath, edge, damp, rng.randf(), district)
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


## Crop bed marker: hotspot + furrow sprites (G8 — no ColorRect soil lines).
func spawn_crop_rows(
	parent: Node2D,
	bed: Rect2,
	title: String,
	desc: String,
	row_color: Color = Color(0.45, 0.72, 0.28, 0.9),
	rows: int = 4
) -> void:
	var hs := make_hotspot(parent, repair_user_text(title), repair_user_text(desc), bed.get_center(), bed.size)
	var visual: Node2D = hs.get_node("Visual")
	var inset := 8.0
	var inner := Rect2(bed.position + Vector2(inset, inset), bed.size - Vector2(inset, inset) * 2.0)
	if inner.size.x <= 4.0 or inner.size.y <= 4.0:
		return
	const FURROW := "res://assets/sprites/props/furrow_line_00.png"
	var furrow_tex := WorldSpawnUtil.load_prop_texture(FURROW)
	var row_h: float = inner.size.y / float(maxi(rows, 1))
	var tint := Color(
		lerpf(0.85, row_color.r, 0.2),
		lerpf(0.75, row_color.g, 0.15),
		lerpf(0.55, row_color.b, 0.1),
		0.85
	)
	for i in range(rows):
		var y_off := row_h * (float(i) + 0.5)
		var pos := inner.position - bed.get_center() + Vector2(inner.size.x * 0.5, y_off)
		if furrow_tex != null:
			var spr := Sprite2D.new()
			spr.name = "Furrow_%d" % i
			spr.texture = furrow_tex
			spr.centered = true
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = pos
			spr.scale = Vector2(inner.size.x / float(furrow_tex.get_width()), 1.0)
			spr.modulate = tint.darkened(0.04 * float(i % 2))
			visual.add_child(spr)
		else:
			var line := ColorRect.new()
			line.color = Color(0.42, 0.32, 0.18, 0.35).darkened(0.04 * float(i % 2))
			line.size = Vector2(inner.size.x, 2.0)
			line.position = pos - Vector2(inner.size.x * 0.5, 1.0)
			line.mouse_filter = Control.MOUSE_FILTER_IGNORE
			visual.add_child(line)


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
## Trees / tall props: trunk at foot, crown mostly above (assemblers used 0.4).
const TREE_Y_OFFSET_FACTOR := 0.40


func building_offset_for(tex: Texture2D) -> Vector2:
	return Vector2(0.0, -float(tex.get_height()) * BUILDING_Y_OFFSET_FACTOR)


func tree_offset_for(tex: Texture2D) -> Vector2:
	return Vector2(0.0, -float(tex.get_height()) * TREE_Y_OFFSET_FACTOR)


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


## Alias for trees / tall props — same search as find_building_inside with a custom draw offset.
func find_sprite_inside(
	ideal: Vector2,
	tex: Texture2D,
	offset: Vector2,
	zone: Rect2,
	half_w: int,
	half_h: int,
	max_r: int = 14,
	allow_path: bool = false
) -> Vector2:
	return find_building_inside(ideal, tex, offset, zone, half_w, half_h, max_r, allow_path)


## Place a tree fully inside zone (footprint clear + crown AABB). Returns null if impossible.
func spawn_tree(
	parent: Node2D,
	path: String,
	ideal: Vector2,
	zone: Rect2,
	half_w: int = 1,
	half_h: int = 1,
	max_r: int = 8,
	allow_path: bool = false,
	z: int = 0,
	with_shadow: bool = true
) -> Sprite2D:
	if not ResourceLoader.exists(path):
		return null
	var tex := load(path) as Texture2D
	if tex == null:
		return null
	var offset := tree_offset_for(tex)
	var cleared := find_sprite_inside(ideal, tex, offset, zone, half_w, half_h, max_r, allow_path)
	if cleared == Vector2.ZERO:
		return null
	if with_shadow:
		add_contact_shadow(parent, cleared, Vector2(22, 8))
	var spr := spawn_sprite(parent, path, cleared, z)
	spr.offset = offset
	mark_blocked_footprint(cleared, half_w, half_h)
	return spr


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


## Repair legacy labels that were saved after UTF-8 was decoded as Latin-1.
## Keep this at the presentation boundary so old scene assembly data remains
## usable while the player still sees readable Chinese labels.
static func repair_user_text(value: String) -> String:
	var looks_mojibake := false
	for ch in value:
		var probe := ch.unicode_at(0)
		if probe >= 128 and probe <= 255:
			looks_mojibake = true
			break
	if not looks_mojibake:
		return value
	var bytes := PackedByteArray()
	for ch in value:
		var code := ch.unicode_at(0)
		if code > 255:
			return value
		bytes.append(code)
	var repaired := bytes.get_string_from_utf8()
	return repaired if not repaired.is_empty() else value


func make_hotspot(parent: Node2D, title: String, desc: String, pos: Vector2, size: Vector2) -> InteractableHotspot:
	title = repair_user_text(title)
	desc = repair_user_text(desc)
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


func make_portal(
	parent: Node2D,
	title: String,
	scene_path: String,
	pos: Vector2,
	size: Vector2 = Vector2(80, 48),
	facade_path: String = "",
) -> Area2D:
	title = repair_user_text(title)
	var show_marker := bool(ProjectSettings.get_setting("debug/show_interaction_markers", false))
	var area := Area2D.new()
	area.name = "Portal_" + title
	area.position = pos
	area.input_pickable = true
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	area.add_child(shape)
	var facade := facade_path if not facade_path.is_empty() else WorldSpawnUtil.DOOR_FACADE
	var cues := WorldSpawnUtil.attach_portal_cues(area, size, facade)
	var cue: CanvasItem = cues.get("cue")
	var arch: CanvasItem = cues.get("arch")
	var facade_node: CanvasItem = cues.get("facade")
	var hint := Polygon2D.new()
	hint.name = "PortalMarker"
	hint.color = Color(0.95, 0.72, 0.28, 0.86)
	hint.polygon = PackedVector2Array([
		Vector2(0, -9),
		Vector2(11, 0),
		Vector2(0, 9),
		Vector2(-11, 0),
	])
	hint.position = Vector2(0, -size.y * 0.26)
	hint.visible = show_marker
	area.add_child(hint)
	var label := Label.new()
	label.name = "PortalLabel"
	label.text = title
	label.position = Vector2(-size.x * 0.5, -size.y * 0.5 - 8)
	label.size = Vector2(size.x, 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color("#fff4c7"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_font_size_override("font_size", 13)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.visible = show_marker
	area.add_child(label)
	area.mouse_entered.connect(func():
		label.visible = true
		if cue:
			cue.modulate = Color(1.2, 1.15, 0.9, 1.0)
		if arch:
			arch.modulate = Color(1.25, 1.2, 0.95, 1.0)
		if facade_node:
			facade_node.modulate = Color(1.1, 1.08, 0.95, 1.0)
	)
	area.mouse_exited.connect(func():
		label.visible = show_marker
		if cue:
			cue.modulate = Color.WHITE
		if arch:
			arch.modulate = Color.WHITE
		if facade_node:
			facade_node.modulate = Color.WHITE
	)
	if arch:
		var pulse := arch.create_tween().set_loops()
		pulse.tween_property(arch, "modulate:a", 0.22, 0.85).set_trans(Tween.TRANS_SINE)
		pulse.tween_property(arch, "modulate:a", 0.55, 0.85).set_trans(Tween.TRANS_SINE)
	if show_marker:
		var pulse_m := hint.create_tween().set_loops()
		pulse_m.tween_property(hint, "modulate:a", 0.45, 0.65).set_trans(Tween.TRANS_SINE)
		pulse_m.tween_property(hint, "modulate:a", 1.0, 0.65).set_trans(Tween.TRANS_SINE)
	area.set_meta("scene_path", scene_path)
	parent.add_child(area)
	return area


func snap_patrol_route(waypoints: Array) -> Array[Vector2]:
	var route: Array[Vector2] = []
	for wp in waypoints:
		var ideal: Vector2 = wp
		var candidate := find_walk_near(ideal, 6)
		if candidate == Vector2.ZERO:
			continue
		if route.size() > 0 and route[route.size() - 1].distance_to(candidate) < 4.0:
			continue
		route.append(candidate)
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


## Prefer this over animate_patrol — directional walk frames under sprites/npc/{id}/.
func spawn_patrol_actor(
	parent: Node2D,
	character_id: String,
	title: String,
	desc: String,
	waypoints: Array
) -> PatrolActor:
	title = repair_user_text(title)
	desc = repair_user_text(desc)
	var route: Array[Vector2] = snap_patrol_route(waypoints)
	if route.is_empty():
		push_warning("AreaCraft: no walk route for %s" % title)
		return null
	var actor := PatrolActor.new()
	parent.add_child(actor)
	actor.setup(character_id, title, desc, route, self)
	return actor


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
			# One shared Timer below owns water animation timing. A per-sprite
			# alpha Tween here used to create a second clock, so texture changes
			# and brightness changes could disagree and make adjacent water flicker.
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
	_spawn_shoreline_overlay(parent)


func _spawn_shoreline_overlay(parent: Node2D) -> void:
	## Draw only along exposed water-cell edges so ponds and pools do not read as
	## raw blue rectangles. The line follows the same mask as collision/painting.
	var shore := Node2D.new()
	shore.name = "ShorelineOverlay"
	shore.z_index = 2
	parent.add_child(shore)
	var edge_color := Color(0.20, 0.60, 0.58, 0.48)
	var foam_color := Color(0.74, 0.87, 0.67, 0.42)
	for ty in range(map_h):
		for tx in range(map_w):
			if not is_water(tx, ty) or is_path(tx, ty):
				continue
			var left := float(tx * tile)
			var top := float(ty * tile)
			var right := left + float(tile)
			var bottom := top + float(tile)
			if not is_water(tx, ty - 1):
				_add_shore_segment(shore, Vector2(left + 2.0, top + 2.0), Vector2(right - 2.0, top + 2.0), edge_color, 2.0)
				if (tx + ty) % 3 == 0:
					_add_shore_segment(shore, Vector2(left + 7.0, top + 3.0), Vector2(minf(right - 6.0, left + 15.0), top + 3.0), foam_color, 1.0)
			if not is_water(tx, ty + 1):
				_add_shore_segment(shore, Vector2(left + 2.0, bottom - 2.0), Vector2(right - 2.0, bottom - 2.0), edge_color, 2.0)
			if not is_water(tx - 1, ty):
				_add_shore_segment(shore, Vector2(left + 2.0, top + 2.0), Vector2(left + 2.0, bottom - 2.0), edge_color, 2.0)
			if not is_water(tx + 1, ty):
				_add_shore_segment(shore, Vector2(right - 2.0, top + 2.0), Vector2(right - 2.0, bottom - 2.0), edge_color, 2.0)


func _add_shore_segment(parent: Node2D, from: Vector2, to: Vector2, color: Color, width: float) -> void:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.antialiased = false
	line.points = PackedVector2Array([from, to])
	parent.add_child(line)


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
