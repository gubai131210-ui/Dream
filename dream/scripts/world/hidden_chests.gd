class_name HiddenChests
extends Node

## C61 — ≥5 hidden chest sites across explore maps (tree/waterfall/cave/well/island).

const NODE_NAME := "HiddenChests"
const CHEST_TEX := "res://assets/sprites/interior/props/coin_chest_00.png"

const SITE_DEFS := {
	"tree_behind": {
		"title": "树后宝箱",
		"desc": "巨树根后藏着一只落满苔藓的箱子。",
		"host": "forest_deep",
		"pos": Vector2(560, 520),
		"loot": "找到树后宝箱：一小袋铜币。",
	},
	"waterfall": {
		"title": "瀑后宝箱",
		"desc": "水帘后的石龛里有一只潮湿木箱。",
		"host": "waterfall",
		"pos": Vector2(700, 420),
		"loot": "找到瀑后宝箱：发光贝壳。",
	},
	"cave": {
		"title": "洞口宝箱",
		"desc": "山丘洞口乱石旁埋着探险箱。",
		"host": "hill_farm",
		"pos": Vector2(980, 320),
		"loot": "找到洞口宝箱：探洞绳钩。",
	},
	"well": {
		"title": "井边宝箱",
		"desc": "广场井栏阴影里藏着一只小箱。",
		"host": "village_square",
		"pos": Vector2(700, 500),
		"loot": "找到井边宝箱：许愿铜钱。",
	},
	"island": {
		"title": "岛岸宝箱",
		"desc": "湖心岛渡口旁半埋的宝箱。",
		"host": "lake",
		"pos": Vector2(900, 620),
		"loot": "找到岛岸宝箱：潮汐玻璃珠。",
	},
}

signal opened(site_id: String)

var _info: InfoPanel
var _root: Node2D
var _site_id: String = ""
var _opened: bool = false


static func attach_site(host: Node2D, site_id: String, top_bar: Control = null) -> HiddenChests:
	if host == null or site_id.is_empty():
		return null
	if not SITE_DEFS.has(site_id):
		push_warning("HiddenChests: unknown site %s" % site_id)
		return null
	var node_name := "%s_%s" % [NODE_NAME, site_id]
	var existing := host.get_node_or_null(node_name) as HiddenChests
	if existing:
		return existing
	var kit := HiddenChests.new()
	kit.name = node_name
	host.add_child(kit)
	kit.setup(host, site_id, top_bar)
	return kit


static func catalog() -> Array:
	var out: Array = []
	for id in SITE_DEFS.keys():
		var d: Dictionary = SITE_DEFS[id]
		out.append({"id": id, "title": d["title"], "hint": d["desc"], "host": d["host"]})
	return out


static func stub_catalog() -> Array:
	return catalog()


static func site_ids() -> Array:
	return SITE_DEFS.keys()


func setup(host: Node2D, site_id: String, _top_bar: Control = null) -> void:
	_site_id = site_id
	_info = WorldSpawnUtil.resolve_info(host)
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	_root = Node2D.new()
	_root.name = "HiddenChestRoot"
	_root.y_sort_enabled = true
	_root.z_index = 5
	ysort.add_child(_root)
	var d: Dictionary = SITE_DEFS[site_id]
	var hs := WorldSpawnUtil.make_hotspot(
		_root,
		str(d["title"]),
		str(d["desc"]),
		d["pos"] as Vector2,
		Vector2(60, 48),
		Color(0.95, 0.78, 0.28, 0.95),
		CHEST_TEX,
		0.55,
	)
	hs.activated.connect(func(h: InteractableHotspot) -> void:
		_open_chest(str(d["title"]), str(d["loot"]), h)
	)


func _open_chest(title: String, loot: String, hs: InteractableHotspot = null) -> void:
	if _opened:
		if _info:
			_info.show_info(title, "箱子已经空了。")
		return
	_opened = true
	_play_lid_open(hs)
	if _info:
		_info.show_info(title, loot)
	opened.emit(_site_id)


func _play_lid_open(hs: InteractableHotspot) -> void:
	if hs == null:
		return
	var visual := hs.get_node_or_null("Visual") as Node2D
	if visual == null:
		return
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("open")
	frames.set_animation_loop("open", false)
	frames.set_animation_speed("open", 8.0)
	var n := 0
	for i in range(4):
		var path := "res://assets/sprites/props/chest_lid_%02d.png" % i
		var tex: Texture2D = null
		if ResourceLoader.exists(path):
			tex = load(path) as Texture2D
		if tex == null:
			var abs_path := ProjectSettings.globalize_path(path)
			if FileAccess.file_exists(abs_path):
				var img := Image.load_from_file(abs_path)
				if img != null:
					tex = ImageTexture.create_from_image(img)
		if tex == null:
			continue
		frames.add_frame("open", tex)
		n += 1
	if n == 0:
		var spr := visual.get_node_or_null("PropSprite") as CanvasItem
		if spr:
			spr.modulate = Color(0.75, 0.75, 0.7, 0.85)
		return
	var anim := AnimatedSprite2D.new()
	anim.name = "ChestLidFX"
	anim.sprite_frames = frames
	anim.position = Vector2(0, -14)
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.z_index = 8
	anim.centered = true
	visual.add_child(anim)
	anim.play("open")
	var body := visual.get_node_or_null("PropSprite") as CanvasItem
	if body:
		body.modulate = Color(0.85, 0.85, 0.8, 0.95)
