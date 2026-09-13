class_name EncounterPocketKit
extends Node

## C29 ruins Phase0 — moss blob pocket + dual-source cache urn → Inventory.
## Never attach on square / station / farmland.

const NODE_NAME := "EncounterPocketKit"
const CRITTER := "res://assets/sprites/props/moss_blob_00.png"
const CRITTER_HURT := "res://assets/sprites/props/moss_blob_hurt_00.png"
const CLEAR_FX := "res://assets/sprites/fx/moss_clear_fx_00.png"
const URN := "res://assets/sprites/props/ruin_cache_urn_00.png"
const LOOT_RESIN := "loot_moss_resin"
const LOOT_SHARD := "loot_ruin_shard"
const HITS_TO_CLEAR := 3

## Local positions in InteriorWorld (align east cache ~tx 16–20).
const POCKET_LOCAL := Vector2(560, 220)
const URN_LOCAL := Vector2(620, 250)


static func attach_to(host: Node, world: Node2D, info: Node = null) -> EncounterPocketKit:
	if host == null or world == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as EncounterPocketKit
	if existing:
		return existing
	var kit := EncounterPocketKit.new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit._boot(world, info)
	return kit


var _world: Node2D
var _info: Node
var _hs: InteractableHotspot
var _spr: Sprite2D
var _urn_hs: InteractableHotspot
var _hits: int = 0
var _cleared: bool = false
var _urn_broken: bool = false


func _boot(world: Node2D, info: Node) -> void:
	_world = world
	_info = info
	if not ResourceLoader.exists(CRITTER):
		push_warning("EncounterPocketKit: missing moss_blob art")
		return
	_spawn_moss()
	_spawn_urn()


func _spawn_moss() -> void:
	_hs = InteractableHotspot.new()
	_hs.name = "MossBlob"
	_hs.title = "苔团"
	_hs.description = "遗迹里聚成一团的苔藓。点几次可驱散，可能掉下苔树脂。"
	_hs.position = POCKET_LOCAL
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(48, 36)
	shape.shape = rect
	_hs.add_child(shape)
	var vis := Node2D.new()
	vis.name = "Visual"
	_hs.add_child(vis)
	_spr = Sprite2D.new()
	_spr.texture = load(CRITTER) as Texture2D
	_spr.centered = true
	_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_spr.position = Vector2(0, -10)
	vis.add_child(_spr)
	_hs.activated.connect(_on_hit)
	_world.add_child(_hs)


func _spawn_urn() -> void:
	if not ResourceLoader.exists(URN):
		return
	_urn_hs = InteractableHotspot.new()
	_urn_hs.name = "RuinCacheUrn"
	_urn_hs.title = "苔斑陶瓮"
	_urn_hs.description = "侧廊藏宝瓮。轻敲可能掉出与苔团同源的苔树脂（低概率）。"
	_urn_hs.position = URN_LOCAL
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40, 40)
	shape.shape = rect
	_urn_hs.add_child(shape)
	var vis := Node2D.new()
	vis.name = "Visual"
	_urn_hs.add_child(vis)
	var spr := Sprite2D.new()
	spr.texture = load(URN) as Texture2D
	spr.centered = true
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.position = Vector2(0, -12)
	vis.add_child(spr)
	_urn_hs.set_meta("urn_spr", spr)
	_urn_hs.activated.connect(_on_urn)
	_world.add_child(_urn_hs)


func _on_hit(_h: InteractableHotspot = null) -> void:
	if _cleared:
		return
	_hits += 1
	if ResourceLoader.exists(CRITTER_HURT) and _spr:
		_spr.texture = load(CRITTER_HURT) as Texture2D
		var tw := _spr.create_tween()
		tw.tween_property(_spr, "modulate", Color(1.2, 0.9, 0.9), 0.08)
		tw.tween_property(_spr, "modulate", Color.WHITE, 0.12)
	if _hits < HITS_TO_CLEAR:
		_toast("苔团", "苔团抖了抖（%d/%d）。再点。" % [_hits, HITS_TO_CLEAR])
		return
	_cleared = true
	_spawn_clear_fx(POCKET_LOCAL)
	var resin: Dictionary = InventoryService.try_add(LOOT_RESIN, 1)
	var extra := ""
	if randf() < 0.35:
		var sh: Dictionary = InventoryService.try_add(LOOT_SHARD, 1)
		extra = "\n" + str(sh.get("msg", ""))
	_toast(
		"苔团驱散",
		str(resin.get("msg", "")) + extra
		+ "\n（苔树脂：灯饰/家具 soft gate，非主线硬锁。车站售票处也会提及。）"
	)
	if _hs:
		_hs.queue_free()
		_hs = null


func _on_urn(_h: InteractableHotspot = null) -> void:
	if _urn_broken:
		return
	_urn_broken = true
	_spawn_clear_fx(URN_LOCAL)
	var msg := "陶瓮裂开了，里面只有干泥。"
	if randf() < 0.4:
		var resin: Dictionary = InventoryService.try_add(LOOT_RESIN, 1)
		msg = str(resin.get("msg", "")) + "\n（与苔团同源材料 · soft sink）"
	else:
		msg += "\n（下次可再找苔团；材料 sink 仍软提示。）"
	_toast("苔斑陶瓮", msg)
	if _urn_hs:
		var spr: Sprite2D = _urn_hs.get_meta("urn_spr", null) as Sprite2D
		if spr:
			spr.modulate = Color(0.55, 0.55, 0.55, 0.7)
		_urn_hs.title = "碎裂陶瓮"
		_urn_hs.description = "已经敲开了。"


func _spawn_clear_fx(at: Vector2) -> void:
	var path := CLEAR_FX if ResourceLoader.exists(CLEAR_FX) else ""
	if path.is_empty() or _world == null:
		return
	var fx := Sprite2D.new()
	fx.texture = load(path) as Texture2D
	fx.centered = true
	fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fx.position = at + Vector2(0, -16)
	fx.z_index = 12
	_world.add_child(fx)
	var tw := fx.create_tween()
	tw.tween_property(fx, "modulate:a", 0.0, 0.7)
	tw.tween_callback(fx.queue_free)


func _toast(title: String, body: String) -> void:
	if _info and _info.has_method("show_info"):
		_info.call("show_info", title, body)
