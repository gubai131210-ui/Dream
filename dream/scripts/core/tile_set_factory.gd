class_name TileSetFactory
extends RefCounted

const BASE := Scale.BASE_TILE


static func from_atlas(texture: Texture2D, columns: int = 8) -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(BASE, BASE)
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(BASE, BASE)
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
