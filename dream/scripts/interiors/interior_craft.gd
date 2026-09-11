class_name InteriorCraft
extends Node

## Profile-driven interior assembler (PHASE5 / INTERIOR_FOUNDATION / INTERIOR_ROOM_BRIEFS).
## Pass: floor → walls/door/window → rug → props → FX → ambient → lights → actor → portal.
## 32px grid. Distinct floor sets + specialty props. Local lights only.

const TILE := 32
const ORIGIN := Vector2i(4, 4)
const WALL_THICK := 2
const TILE_DIR := "res://assets/sprites/interior/tiles"
const FX_DIR := "res://assets/sprites/interior/fx"
const PROP_SCALE := 0.9
## Feet origin for Y-sort: hotspot sits at tile ground contact; sprite offset lifts so
## the sprite bottom rests near ground (same contract for furniture + fence segments).
## Formula: offset_y = -tex_height * scale * 0.5 + PROP_FOOT_NUDGE
const PROP_FOOT_NUDGE := 4.0

@export var profile_id: String = "c01_home"

var _profile: Dictionary = {}
var _room_w: int = 32
var _room_h: int = 20
var _door_tx0: int = 14
var _door_tx1: int = 17
var _floor_kind: String = "plank"


func assemble(root: Node2D, override_profile: String = "", profile_override: Dictionary = {}) -> void:
	var pid := override_profile if not override_profile.is_empty() else profile_id
	if root.has_meta("profile_id"):
		pid = str(root.get_meta("profile_id"))
	if not profile_override.is_empty():
		_profile = profile_override
	else:
		_profile = InteriorProfiles.get_profile(pid)
	profile_id = pid
	_room_w = int(_profile.get("room_w", 32))
	_room_h = int(_profile.get("room_h", 20))
	_door_tx0 = int(_profile.get("door_tx0", 14))
	_door_tx1 = int(_profile.get("door_tx1", 17))
	_floor_kind = str(_profile.get("floor", "plank"))

	var world := root.get_node_or_null("InteriorWorld") as Node2D
	if world == null:
		world = Node2D.new()
		world.name = "InteriorWorld"
		world.y_sort_enabled = true
		world.z_index = 2
		root.add_child(world)
	else:
		for c in world.get_children():
			c.free()

	var foundation := Node2D.new()
	foundation.name = "Foundation"
	foundation.z_index = -20
	world.add_child(foundation)
	_paint_floor(foundation)
	_paint_walls(foundation)
	_paint_door_and_window(foundation)
	_paint_rug(foundation)

	_spawn_furniture(world)
	_spawn_territory(world)
	_spawn_fx(world)
	_spawn_ambient(world)
	_spawn_local_lights(world)
	_spawn_actor(world)
	_spawn_return_portal(world)
	_spawn_extra_portals(world)
	_apply_topbar_hint(root)


func room_rect() -> Rect2:
	return Rect2(
		float(ORIGIN.x * TILE),
		float(ORIGIN.y * TILE),
		float(_room_w * TILE),
		float(_room_h * TILE),
	)


func _tile_center(tx: int, ty: int) -> Vector2:
	return Vector2((ORIGIN.x + tx) * TILE + TILE * 0.5, (ORIGIN.y + ty) * TILE + TILE * 0.5)


## Load a texture without spamming errors when `.import` points at a missing `.ctex`
## (common after hand-authored sidecars). Falls back to raw PNG via ImageTexture.
func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	var abs_path := ProjectSettings.globalize_path(path)
	var import_path := abs_path + ".import"
	var can_use_import := false
	if FileAccess.file_exists(import_path):
		var cfg := ConfigFile.new()
		if cfg.load(import_path) == OK:
			var dest_var: Variant = cfg.get_value("remap", "path", "")
			var dest := str(dest_var)
			if not dest.is_empty():
				can_use_import = FileAccess.file_exists(ProjectSettings.globalize_path(dest))
	if can_use_import:
		var imported := load(path) as Texture2D
		if imported != null:
			return imported
	if not FileAccess.file_exists(abs_path):
		push_warning("InteriorCraft: missing texture %s" % path)
		return null
	var img := Image.load_from_file(abs_path)
	if img == null:
		push_warning("InteriorCraft: raw load failed %s" % path)
		return null
	return ImageTexture.create_from_image(img)


func _spawn_tile(parent: Node2D, path: String, tx: int, ty: int, z: int = 0) -> void:
	var tex := _load_texture(path)
	if tex == null:
		return
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.centered = true
	spr.position = _tile_center(tx, ty)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = z
	parent.add_child(spr)


func _floor_path(tx: int, ty: int) -> String:
	var idx := (tx + ty * 3) % 4
	match _floor_kind:
		"straw":
			return "%s/floor_straw_%02d.png" % [TILE_DIR, idx]
		"stone":
			return "%s/floor_stone_%02d.png" % [TILE_DIR, idx]
		"dark":
			return "%s/floor_dark_%02d.png" % [TILE_DIR, idx]
		_:
			return "%s/floor_%02d.png" % [TILE_DIR, idx]


func _paint_floor(parent: Node2D) -> void:
	for ty in range(WALL_THICK, _room_h):
		for tx in range(_room_w):
			_spawn_tile(parent, _floor_path(tx, ty), tx, ty, -5)


func _paint_walls(parent: Node2D) -> void:
	for tx in range(_room_w):
		_spawn_tile(parent, "%s/wall_upper_%02d.png" % [TILE_DIR, tx % 4], tx, 0, -2)
		_spawn_tile(parent, "%s/wall_lower_%02d.png" % [TILE_DIR, tx % 4], tx, 1, -1)
	var third := int(floor(float(_room_w) / 3.0))
	var two_thirds := int(floor(float(_room_w) * 2.0 / 3.0))
	for tx in [0, maxi(1, third), maxi(2, two_thirds), _room_w - 1]:
		_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, tx, 0, 0)
		_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, tx, 1, 0)
	for ty in range(WALL_THICK, _room_h):
		_spawn_tile(parent, "%s/wall_lower_%02d.png" % [TILE_DIR, ty % 4], 0, ty, -1)
		_spawn_tile(parent, "%s/wall_lower_%02d.png" % [TILE_DIR, (ty + 1) % 4], _room_w - 1, ty, -1)


func _paint_door_and_window(parent: Node2D) -> void:
	for tx in range(_door_tx0, _door_tx1 + 1):
		_spawn_tile(parent, "%s/doorstep_00.png" % TILE_DIR, tx, _room_h - 1, 1)
	_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, _door_tx0 - 1, _room_h - 1, 2)
	_spawn_tile(parent, "%s/pillar_00.png" % TILE_DIR, _door_tx1 + 1, _room_h - 1, 2)
	# door_frame is required exit kit (not optional garnish) — always spawn both sides.
	var door_frame := "%s/door_frame_00.png" % TILE_DIR
	var door_frame_tex := _load_texture(door_frame)
	if door_frame_tex == null:
		push_warning(
			"InteriorCraft: REQUIRED door kit missing: %s — exit must have door_frame on both door tiles"
			% door_frame
		)
	for tx in [_door_tx0 - 1, _door_tx1 + 1]:
		if door_frame_tex == null:
			continue
		var spr := Sprite2D.new()
		spr.texture = door_frame_tex
		spr.centered = true
		spr.position = _tile_center(tx, _room_h - 2)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.z_index = 2
		parent.add_child(spr)
	if bool(_profile.get("window", true)):
		var win_path := "%s/window_00.png" % TILE_DIR
		var win_tex := _load_texture(win_path)
		if win_tex != null:
			var spr := Sprite2D.new()
			spr.texture = win_tex
			spr.centered = true
			spr.position = _tile_center(int(_room_w / 2.0), 0) + Vector2(16, 16)
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.z_index = 3
			parent.add_child(spr)
		var mid := int(_room_w / 2.0)
		var shaft := Polygon2D.new()
		shaft.name = "WindowLightShaft"
		shaft.color = Color(1.0, 0.92, 0.65, 0.12)
		shaft.polygon = PackedVector2Array([
			_tile_center(mid - 2, 2) + Vector2(-16, -8),
			_tile_center(mid + 2, 2) + Vector2(16, -8),
			_tile_center(mid + 3, 7) + Vector2(8, 0),
			_tile_center(mid - 3, 7) + Vector2(-8, 0),
		])
		shaft.z_index = -3
		parent.add_child(shaft)


func _paint_rug(parent: Node2D) -> void:
	if not _profile.has("rug") or _profile["rug"] == null:
		return
	var rug: Dictionary = _profile.get("rug", {})
	if rug.is_empty():
		return
	var ox: int = int(rug.get("ox", 14))
	var oy: int = int(rug.get("oy", 12))
	for qy in range(2):
		for qx in range(2):
			_spawn_tile(parent, "%s/rug_%d_%d.png" % [TILE_DIR, qy, qx], ox + qx, oy + qy, 0)


func _spawn_furniture(parent: Node2D) -> void:
	var clusters: Array = _profile.get("clusters", [])
	if not clusters.is_empty():
		for cluster in clusters:
			var anchor: Array = cluster.get("anchor", [0, 0])
			var ax := int(anchor[0])
			var ay := int(anchor[1])
			for m in cluster.get("members", []):
				var path: String = str(m.get("path", ""))
				var tx := ax + int(m.get("dx", 0))
				var ty := ay + int(m.get("dy", 0))
				_spawn_prop(
					parent,
					path,
					_tile_center(tx, ty),
					float(m.get("scale", PROP_SCALE)),
					str(m.get("title", "物件")),
					str(m.get("desc", "")),
				)
		return
	# Legacy flat props (avoid in new rooms — see INTERIOR_COMPOSITION.md).
	var props: Array = _profile.get("props", [])
	for p in props:
		_spawn_prop(
			parent,
			str(p.get("path", "")),
			_tile_center(int(p.get("tx", 0)), int(p.get("ty", 0))),
			float(p.get("scale", PROP_SCALE)),
			str(p.get("title", "物件")),
			str(p.get("desc", "")),
		)


func _cluster_anchor(cluster_id: String) -> Vector2i:
	for cluster in _profile.get("clusters", []):
		if str(cluster.get("id", "")) == cluster_id:
			var a: Array = cluster.get("anchor", [0, 0])
			return Vector2i(int(a[0]), int(a[1]))
	return Vector2i(-1, -1)

func _spawn_prop(parent: Node2D, path: String, pos: Vector2, scale_f: float, title: String, desc: String) -> void:
	var tex := _load_texture(path)
	if tex == null:
		return
	var hs := _make_hotspot(parent, title, desc, pos, Vector2(56, 48))
	var shadow := Polygon2D.new()
	shadow.color = Color(0, 0, 0, 0.22)
	shadow.polygon = PackedVector2Array([
		Vector2(-14, 0), Vector2(0, -5), Vector2(14, 0), Vector2(0, 5),
	])
	shadow.position = Vector2(0, 10)
	shadow.z_index = -1
	hs.get_node("Visual").add_child(shadow)
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.centered = true
	spr.position = _feet_sprite_offset(float(tex.get_height()), scale_f)
	spr.scale = Vector2(scale_f, scale_f)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hs.get_node("Visual").add_child(spr)


## Territory grammar (INTERIOR_TERRITORY.md): enclosure rings + aisle rails.
## Profiles may declare:
##   enclosures: [{
##     rect:[x0,y0,x1,y1], prop_h, prop_v,
##     corners:{nw,ne,sw,se},  # required for clean joins
##     scale?, title, desc, gaps:[[tx,ty],...]
##   }]
##   rails: [{axis:"v"|"h", tx|ty, a0, a1, prop, scale?, title, desc, step?}]
## Fence tiles are 32px; default step=1 scale=1. Corners replace raw H∩V butts.
func _spawn_territory(parent: Node2D) -> void:
	for enc in _profile.get("enclosures", []):
		_spawn_enclosure_ring(parent, enc)
	for rail in _profile.get("rails", []):
		_spawn_rail_line(parent, rail)


func _spawn_enclosure_ring(parent: Node2D, enc: Dictionary) -> void:
	var rect: Array = enc.get("rect", [])
	if rect.size() < 4:
		return
	var x0 := int(rect[0])
	var y0 := int(rect[1])
	var x1 := int(rect[2])
	var y1 := int(rect[3])
	var prop_fallback := str(enc.get("prop", ""))
	var prop_h := str(enc.get("prop_h", prop_fallback))
	var prop_v := str(enc.get("prop_v", prop_fallback))
	var corners: Dictionary = enc.get("corners", {})
	var scale_f := float(enc.get("scale", 1.0))
	var title := str(enc.get("title", "围栏"))
	var desc := str(enc.get("desc", ""))
	var gap_set: Dictionary = {}
	for g in enc.get("gaps", []):
		if g is Array and g.size() >= 2:
			gap_set["%d,%d" % [int(g[0]), int(g[1])]] = true

	var corner_cells := {
		"nw": Vector2i(x0, y0),
		"ne": Vector2i(x1, y0),
		"sw": Vector2i(x0, y1),
		"se": Vector2i(x1, y1),
	}
	for cname in corner_cells.keys():
		var cell: Vector2i = corner_cells[cname]
		var key := "%d,%d" % [cell.x, cell.y]
		if gap_set.has(key):
			continue
		var cpath := str(corners.get(cname, ""))
		if cpath.is_empty():
			# Fallback: prefer H on corners if corner art missing
			cpath = prop_h
		_spawn_fence_segment(parent, cpath, cell.x, cell.y, scale_f, title, desc)

	# North / south edges — exclude corners
	for tx in range(x0 + 1, x1):
		for ty in [y0, y1]:
			var key_ns := "%d,%d" % [tx, ty]
			if gap_set.has(key_ns):
				continue
			_spawn_fence_segment(parent, prop_h, tx, ty, scale_f, title, desc)
	# East / west edges — exclude corners
	for ty in range(y0 + 1, y1):
		for tx in [x0, x1]:
			var key_ew := "%d,%d" % [tx, ty]
			if gap_set.has(key_ew):
				continue
			_spawn_fence_segment(parent, prop_v, tx, ty, scale_f, title, desc)


func _spawn_rail_line(parent: Node2D, rail: Dictionary) -> void:
	var axis := str(rail.get("axis", "v"))
	var path := str(rail.get("prop", ""))
	var scale_f := float(rail.get("scale", 1.0))
	var title := str(rail.get("title", "隔栏"))
	var desc := str(rail.get("desc", ""))
	var step := maxi(1, int(rail.get("step", 1)))
	var a0 := int(rail.get("a0", 0))
	var a1 := int(rail.get("a1", 0))
	if a1 < a0:
		var tmp := a0
		a0 = a1
		a1 = tmp
	if axis == "h":
		var ty := int(rail.get("ty", 0))
		var tx := a0
		while tx <= a1:
			_spawn_fence_segment(parent, path, tx, ty, scale_f, title, desc)
			tx += step
	else:
		var tx2 := int(rail.get("tx", 0))
		var ty2 := a0
		while ty2 <= a1:
			_spawn_fence_segment(parent, path, tx2, ty2, scale_f, title, desc)
			ty2 += step


func _spawn_fence_segment(parent: Node2D, path: String, tx: int, ty: int, scale_f: float, title: String, desc: String) -> void:
	## Feet-anchored fence tile (32px art → 1 world tile) so H/V runs seal without gaps.
	var tex := _load_texture(path)
	if tex == null:
		return
	var pos := _tile_center(tx, ty)
	var hs := _make_hotspot(parent, title, desc, pos, Vector2(36, 40))
	var spr := Sprite2D.new()
	spr.texture = tex
	spr.centered = true
	spr.position = _feet_sprite_offset(float(tex.get_height()), scale_f)
	spr.scale = Vector2(scale_f, scale_f)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hs.get_node("Visual").add_child(spr)


func _spawn_fx(parent: Node2D) -> void:
	var fx_list: Array = _profile.get("fx", [])
	for fx in fx_list:
		var kind := str(fx.get("kind", ""))
		var tx := int(fx.get("tx", 0))
		var ty := int(fx.get("ty", 0))
		var pos := _tile_center(tx, ty) + Vector2(float(fx.get("ox", 0)), float(fx.get("oy", -8)))
		match kind:
			"fire":
				_spawn_anim_fx(parent, "fire", pos, 6.0)
				_add_point_light(parent, pos + Vector2(0, -6), Color(1.0, 0.55, 0.25), 1.25, 2.4)
			"forge":
				_spawn_anim_fx(parent, "forge", pos, 8.0)
				_add_point_light(parent, pos + Vector2(0, -4), Color(1.0, 0.45, 0.2), 1.45, 2.6)
			_:
				pass


func _spawn_anim_fx(parent: Node2D, prefix: String, pos: Vector2, fps: float) -> void:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("loop")
	frames.set_animation_speed("loop", fps)
	frames.set_animation_loop("loop", true)
	var n := 0
	for i in range(4):
		var path := "%s/%s_%02d.png" % [FX_DIR, prefix, i]
		var frame_tex := _load_texture(path)
		if frame_tex == null:
			continue
		frames.add_frame("loop", frame_tex)
		n += 1
	if n == 0:
		return
	var anim := AnimatedSprite2D.new()
	anim.name = "FX_%s" % prefix
	anim.sprite_frames = frames
	anim.position = pos
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.z_index = 6
	anim.play("loop")
	parent.add_child(anim)


func _spawn_local_lights(parent: Node2D) -> void:
	## Diegetic lights only: every PointLight here is anchored to profile lights[]
	## (hearth / lamp / forge tiles). FX fire/forge may add matching source lights;
	## do not flood unbound room-wide lights.
	var mod := CanvasModulate.new()
	mod.name = "InteriorModulate"
	mod.color = _profile.get("modulate", Color(0.82, 0.78, 0.72, 1.0))
	parent.add_child(mod)
	var lights: Array = _profile.get("lights", [])
	for L in lights:
		var pos := _tile_center(int(L.get("tx", 0)), int(L.get("ty", 0))) + Vector2(0, float(L.get("oy", 0)))
		_add_point_light(
			parent,
			pos,
			L.get("color", Color(1.0, 0.85, 0.55)),
			float(L.get("energy", 1.0)),
			float(L.get("scale", 2.0)),
		)


func _feet_sprite_offset(tex_height: float, scale_f: float) -> Vector2:
	## Shared feet contract: centered sprite, bottom ≈ ground at hotspot.
	return Vector2(0.0, -tex_height * scale_f * 0.5 + PROP_FOOT_NUDGE)


func _add_point_light(parent: Node2D, pos: Vector2, color: Color, energy: float, tex_scale: float) -> void:
	var light := PointLight2D.new()
	light.position = pos
	light.color = color
	light.energy = energy
	light.texture_scale = tex_scale
	light.texture = _radial_light_texture()
	light.z_index = 8
	parent.add_child(light)


func _radial_light_texture() -> GradientTexture2D:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	grad.offsets = PackedFloat32Array([0.0, 1.0])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 192
	tex.height = 192
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	return tex


func _spawn_ambient(parent: Node2D) -> void:
	var list: Array = _profile.get("ambient", [])
	for a in list:
		var species := str(a.get("species", ""))
		if species.is_empty():
			continue
		var tx := int(a.get("tx", -1))
		var ty := int(a.get("ty", -1))
		if a.has("cluster") and (tx < 0 or ty < 0):
			var anch := _cluster_anchor(str(a.get("cluster")))
			if anch.x >= 0:
				tx = anch.x + int(a.get("dx", 1))
				ty = anch.y + int(a.get("dy", 1))
		if tx < 0 or ty < 0:
			continue
		var critter := AmbientCritter.new()
		parent.add_child(critter)
		critter.setup(species, _tile_center(tx, ty), null, -1.0)


func _spawn_actor(parent: Node2D) -> void:
	var a: Dictionary = _profile.get("actor", {})
	if a.is_empty():
		return
	var route: Array[Vector2] = []
	# Prefer named cluster anchors so NPCs visit work stations (smart-object style).
	var via: Array = a.get("via_clusters", [])
	var stands: Dictionary = a.get("via_stands", {})
	if not via.is_empty():
		for cid in via:
			var anch := _cluster_anchor(str(cid))
			if anch.x < 0:
				continue
			var stand_dx := 0
			var stand_dy := 2  # default: south of anchor (approach tile, not on prop at 0,0)
			if stands.has(cid):
				var s: Array = stands[cid]
				if s.size() >= 2:
					stand_dx = int(s[0])
					stand_dy = int(s[1])
			route.append(_tile_center(anch.x + stand_dx, anch.y + stand_dy))
	if route.size() < 2:
		for pt in a.get("route", []):
			route.append(_tile_center(int(pt[0]), int(pt[1])))
	if route.size() < 2:
		return
	var actor := PatrolActor.new()
	parent.add_child(actor)
	actor.setup(str(a.get("id", "farmer")), str(a.get("title", "居民")), str(a.get("desc", "")), route, null)


func _spawn_return_portal(parent: Node2D) -> void:
	var portal := Area2D.new()
	portal.name = "Portal_Return"
	portal.position = _tile_center(int((_door_tx0 + _door_tx1) * 0.5), _room_h - 1) + Vector2(0, 28)
	portal.input_pickable = true
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(128, 56)
	shape.shape = rect
	portal.add_child(shape)
	var marker := Polygon2D.new()
	marker.color = Color(0.95, 0.72, 0.28, 0.75)
	marker.polygon = PackedVector2Array([Vector2(0, -8), Vector2(10, 0), Vector2(0, 8), Vector2(-10, 0)])
	marker.position = Vector2(0, -18)
	portal.add_child(marker)
	var label := Label.new()
	label.text = "← 返回"
	label.position = Vector2(-64, -44)
	label.size = Vector2(128, 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color("#fff4c7"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portal.add_child(label)
	portal.set_meta("scene_path", str(_profile.get("return_path", SceneRouter.RESIDENTIAL_PATH)))
	parent.add_child(portal)


func _spawn_extra_portals(parent: Node2D) -> void:
	## Append-only: profile may list extra_portals [{tx, ty, label, path}] for stairs / side exits.
	var extras: Array = _profile.get("extra_portals", [])
	if extras.is_empty():
		return
	for i in extras.size():
		var ep: Dictionary = extras[i]
		var path := str(ep.get("path", ""))
		if path.is_empty():
			continue
		var tx := int(ep.get("tx", int((_door_tx0 + _door_tx1) * 0.5)))
		var ty := int(ep.get("ty", _room_h - 2))
		var label := str(ep.get("label", "→"))
		var portal := Area2D.new()
		portal.name = "Portal_Extra_%d" % i
		portal.position = _tile_center(tx, ty)
		portal.input_pickable = true
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(96, 48)
		shape.shape = rect
		portal.add_child(shape)
		var marker := Polygon2D.new()
		marker.color = Color(0.55, 0.78, 0.95, 0.8)
		marker.polygon = PackedVector2Array([Vector2(0, -8), Vector2(10, 0), Vector2(0, 8), Vector2(-10, 0)])
		marker.position = Vector2(0, -16)
		portal.add_child(marker)
		var lbl := Label.new()
		lbl.text = label
		lbl.position = Vector2(-56, -40)
		lbl.size = Vector2(112, 24)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color("#dcefff"))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
		lbl.add_theme_constant_override("shadow_offset_x", 1)
		lbl.add_theme_constant_override("shadow_offset_y", 1)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		portal.add_child(lbl)
		portal.set_meta("scene_path", path)
		parent.add_child(portal)


func _apply_topbar_hint(root: Node2D) -> void:
	var hint := root.get_node_or_null("UI/TopBar/Hint") as Label
	if hint:
		hint.text = str(_profile.get("hint", _profile.get("title", "室内")))


func _make_hotspot(parent: Node2D, title: String, desc: String, pos: Vector2, size: Vector2) -> InteractableHotspot:
	## Collision doubles as mouse pick + CharacterBody2D/"player" proximity (Wave D prompt).
	var hs := InteractableHotspot.new()
	hs.name = title.replace(" ", "")
	hs.title = title
	hs.description = desc
	hs.position = pos
	hs.monitoring = true
	hs.monitorable = true
	hs.collision_layer = 1
	hs.collision_mask = 1
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
