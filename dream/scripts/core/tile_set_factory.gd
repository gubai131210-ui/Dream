class_name TileSetFactory
extends RefCounted

const BASE := Scale.BASE_TILE


static func from_atlas(texture: Texture2D, columns: int = 8) -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(BASE, BASE)
	# Helps avoid UV bleed at tile edges when any filtering occurs.
	ts.uv_clipping = true
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(BASE, BASE)
	# Godot extrudes 1px padding internally to prevent seams between atlas cells.
	source.use_texture_padding = true
	var src_id := ts.add_source(source)
	var tex_size := texture.get_size()
	@warning_ignore("integer_division")
	var cols := maxi(1, int(tex_size.x) / BASE)
	@warning_ignore("integer_division")
	var rows := maxi(1, int(tex_size.y) / BASE)
	for y in rows:
		for x in cols:
			var coords := Vector2i(x, y)
			if not source.has_tile(coords):
				source.create_tile(coords)
	var _unused_columns := columns
	var _unused_src := src_id
	return ts


static func paint_rect(layer: TileMapLayer, source_id: int, atlas_coords: Vector2i, rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			layer.set_cell(Vector2i(x, y), source_id, atlas_coords)


static func paint_checker(layer: TileMapLayer, source_id: int, a: Vector2i, b: Vector2i, rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			var coords := a if ((x + y) % 2 == 0) else b
			layer.set_cell(Vector2i(x, y), source_id, coords)


## Paint a rectangle using random seamless variants (atlas coords list).
static func paint_random(layer: TileMapLayer, source_id: int, variants: Array[Vector2i], rect: Rect2i, rng_seed: int = 1) -> void:
	if variants.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			var idx := rng.randi_range(0, variants.size() - 1)
			layer.set_cell(Vector2i(x, y), source_id, variants[idx])


static func atlas_variants(columns: int, count: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for i in count:
		@warning_ignore("integer_division")
		out.append(Vector2i(i % columns, i / columns))
	return out


static func configure_layer(layer: TileMapLayer) -> void:
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


static func clear_layer(layer: TileMapLayer) -> void:
	layer.clear()


## Pick atlas coords for grass type indices in a 4-wide atlas.
static func grass_coords(kind: String) -> Array[Vector2i]:
	# Layout: row0 mow0 mow1 mead0 mead1 | row1 tall0 tall1 weed damp
	match kind:
		"mowed":
			return [Vector2i(0, 0), Vector2i(1, 0)]
		"meadow":
			return [Vector2i(2, 0), Vector2i(3, 0)]
		"tall":
			return [Vector2i(0, 1), Vector2i(1, 1)]
		"weed":
			return [Vector2i(2, 1)]
		"damp":
			return [Vector2i(3, 1)]
		_:
			return [Vector2i(2, 0)]
