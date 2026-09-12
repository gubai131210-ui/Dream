class_name FishCage
extends InteractableHotspot

## C22 shore cage — place → soak → collect (demo soak timer; run-persisted via FishingCatalog).

const PROMPT_PLACE := "下放渔笼"
const PROMPT_WAIT := "查看渔笼"
const PROMPT_COLLECT := "收取渔获"
const SPRITE_EMPTY := "res://assets/sprites/fishing/fish_cage_00.png"
const SPRITE_FULL := "res://assets/sprites/fishing/fish_cage_full_00.png"
## Demo soak (real overnight would use day cycle). 6s keeps loop playable in QA.
const SOAK_MSEC := 6000
const SCRIPT_PATH := "res://scripts/fishing/fish_cage.gd"

var site_id: String = "lake"
var cage_id: String = "cage"
var base_title: String = "渔笼"
var base_desc: String = "岸边可下放隔潮收货的竹笼。"

var _spr: Sprite2D


static func spawn(parent: Node2D, pos: Vector2, size: Vector2, cfg: Dictionary) -> InteractableHotspot:
	## Avoid FishCage.new() before global class cache warms (first-import compile).
	var hs: InteractableHotspot = (load(SCRIPT_PATH) as GDScript).new() as InteractableHotspot
	hs.position = pos
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	hs.add_child(shape)
	var visual := Node2D.new()
	visual.name = "Visual"
	hs.add_child(visual)
	if hs.has_method("configure"):
		hs.call("configure", cfg)
	parent.add_child(hs)
	return hs


func configure(cfg: Dictionary) -> void:
	site_id = str(cfg.get("site_id", site_id))
	cage_id = str(cfg.get("cage_id", cage_id))
	base_title = str(cfg.get("title", "渔笼"))
	base_desc = str(cfg.get("desc", base_desc))
	name = "FishCage_%s_%s" % [site_id, cage_id]
	set_meta("fish_cage", true)
	_ensure_sprite()
	_refresh()


func _ready() -> void:
	super._ready()
	if not activated.is_connected(_on_activated):
		activated.connect(_on_activated)
	_refresh()


func _on_activated(_hs: InteractableHotspot) -> void:
	var st := FishingCatalog.cage_state(site_id, cage_id)
	var phase := str(st.get("phase", "empty"))
	match phase:
		"empty":
			FishingCatalog.cage_place(site_id, cage_id)
			_pulse()
		"soaking":
			if FishingCatalog.cage_try_ripen(site_id, cage_id, SOAK_MSEC):
				_pulse()
			# else still soaking — copy refresh only
		"ready":
			FishingCatalog.cage_collect(site_id, cage_id)
			_pulse()
		_:
			pass
	_refresh()


func _ensure_sprite() -> void:
	var visual := get_node_or_null("Visual") as Node2D
	if visual == null:
		return
	_spr = visual.get_node_or_null("CageSprite") as Sprite2D
	if _spr == null:
		_spr = Sprite2D.new()
		_spr.name = "CageSprite"
		_spr.centered = true
		_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_spr.position = Vector2(0, -8)
		_spr.scale = Vector2(0.95, 0.95)
		_spr.z_index = 2
		visual.add_child(_spr)
	_add_water_ring(visual)


func _add_water_ring(visual: Node2D) -> void:
	if visual.get_node_or_null("WaterRing") != null:
		return
	var ring_tex := WorldSpawnUtil.load_prop_texture("res://assets/sprites/fx/fish_ring_00.png")
	if ring_tex != null:
		var spr := Sprite2D.new()
		spr.name = "WaterRing"
		spr.texture = ring_tex
		spr.centered = true
		spr.position = Vector2(0, 10)
		spr.scale = Vector2(1.15, 1.0)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.z_index = 0
		visual.add_child(spr)
		return
	var ring := Polygon2D.new()
	ring.name = "WaterRing"
	ring.color = Color(0.4, 0.65, 0.8, 0.3)
	ring.position = Vector2(0, 10)
	var pts: PackedVector2Array = []
	for i in range(10):
		var a := TAU * float(i) / 10.0
		pts.append(Vector2(cos(a) * 16.0, sin(a) * 16.0 * 0.35))
	ring.polygon = pts
	ring.z_index = 0
	visual.add_child(ring)


func _refresh() -> void:
	var st := FishingCatalog.cage_state(site_id, cage_id)
	var phase := str(st.get("phase", "empty"))
	if phase == "soaking":
		FishingCatalog.cage_try_ripen(site_id, cage_id, SOAK_MSEC)
		st = FishingCatalog.cage_state(site_id, cage_id)
		phase = str(st.get("phase", "empty"))
	var path := SPRITE_EMPTY
	match phase:
		"empty":
			title = base_title
			description = "%s\n状态：空笼 — 点击下放。" % base_desc
			prompt_text = PROMPT_PLACE
		"soaking":
			var left_ms := maxi(0, int(st.get("ready_at", 0)) - Time.get_ticks_msec())
			var left_s := ceili(float(left_ms) / 1000.0)
			title = "%s · 浸泡中" % base_title
			description = "%s\n状态：浸泡中（约 %d 秒后可收；演示加速，正式版按昼夜）。" % [base_desc, left_s]
			prompt_text = PROMPT_WAIT
		"ready":
			path = SPRITE_FULL
			var fish_name := str(st.get("fish_name", "渔获"))
			title = "%s · 可收" % base_title
			description = "%s\n状态：笼内有【%s】— 点击收取。" % [base_desc, fish_name]
			prompt_text = PROMPT_COLLECT
		_:
			pass
	if _spr == null:
		_ensure_sprite()
	if _spr != null:
		var tex := WorldSpawnUtil.load_prop_texture(path)
		if tex != null:
			_spr.texture = tex


func _pulse() -> void:
	if _spr == null:
		return
	var tw := _spr.create_tween()
	tw.tween_property(_spr, "modulate", Color(1.25, 1.2, 0.9, 1.0), 0.12)
	tw.tween_property(_spr, "modulate", Color.WHITE, 0.2)
