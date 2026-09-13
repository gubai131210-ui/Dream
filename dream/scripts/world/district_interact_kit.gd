extends Node

## G4 district prop-backed interacts (expanding beyond market / farmland / forest_deep).

const NODE_NAME := "DistrictInteractKit"
const HOST_MARKET := "market"
const HOST_FARMLAND := "farmland"
const HOST_FOREST := "forest_deep"
const HOST_RIVER := "river"
const HOST_LAKE := "lake"
const HOST_STATION := "station"
const HOST_RESIDENTIAL := "residential"

const HOST_DEFS := {
	"market": [
		{
			"id": "mkt_handcart",
			"title": "货板车",
			"desc": "推一把市集货板车，轮子咯吱响。",
			"pos": Vector2(640, 520),
			"sprite": "res://assets/sprites/props/handcart_00.png",
			"scale": 0.5,
			"color": Color(0.72, 0.55, 0.32, 0.92),
		},
		{
			"id": "mkt_crate_stack",
			"title": "果箱堆",
			"desc": "翻看摊侧果箱，闻到熟透果香。",
			"pos": Vector2(1080, 480),
			"sprite": "res://assets/sprites/props/fruit_crate_stack_00.png",
			"scale": 0.5,
			"color": Color(0.85, 0.55, 0.3, 0.92),
		},
	],
	"farmland": [
		{
			"id": "fld_hay_stack",
			"title": "干草垛",
			"desc": "拍打草垛，扬起一缕尘草。",
			"pos": Vector2(880, 520),
			"sprite": "res://assets/sprites/props/hay_stack_00.png",
			"scale": 0.5,
			"color": Color(0.9, 0.78, 0.35, 0.92),
		},
		{
			"id": "fld_trough",
			"title": "饮水槽",
			"desc": "检查槽里清水，牲畜脚印还湿着。",
			"pos": Vector2(1000, 640),
			"sprite": "res://assets/sprites/props/trough_00.png",
			"scale": 0.5,
			"color": Color(0.45, 0.65, 0.85, 0.92),
		},
	],
	"forest_deep": [
		{
			"id": "fdeep_wood_pile",
			"title": "枯枝堆",
			"desc": "拨开枯枝，听林间鸟雀惊飞。",
			"pos": Vector2(480, 520),
			"sprite": "res://assets/sprites/props/wood_pile_00.png",
			"scale": 0.5,
			"color": Color(0.45, 0.35, 0.25, 0.92),
		},
		{
			"id": "fdeep_moss_rock",
			"title": "苔石",
			"desc": "抚摸苔石，凉意沁入指尖。",
			"pos": Vector2(360, 640),
			"sprite": "res://assets/sprites/props/rocks/river/rock_01.png",
			"scale": 0.32,
			"color": Color(0.4, 0.55, 0.4, 0.92),
		},
	],
	"river": [
		{
			"id": "riv_barrel",
			"title": "河岸木桶",
			"desc": "敲敲木桶，听回声测水位。",
			"pos": Vector2(420, 700),
			"sprite": "res://assets/sprites/props/barrel_1.png",
			"scale": 0.5,
			"color": Color(0.55, 0.45, 0.3, 0.92),
		},
		{
			"id": "riv_sack",
			"title": "晒网袋",
			"desc": "抖一抖岸边网袋，沙粒簌簌落下。",
			"pos": Vector2(900, 680),
			"sprite": "res://assets/sprites/props/sack_0.png",
			"scale": 0.5,
			"color": Color(0.7, 0.65, 0.4, 0.92),
		},
	],
	"lake": [
		{
			"id": "lake_dock_barrel",
			"title": "系缆桶",
			"desc": "检查系缆空桶，绳结还沾着水。",
			"pos": Vector2(960, 500),
			"sprite": "res://assets/sprites/props/barrel_1.png",
			"scale": 0.5,
			"color": Color(0.5, 0.55, 0.7, 0.92),
		},
		{
			"id": "lake_bench",
			"title": "湖畔长凳",
			"desc": "坐一会儿看湖面粼光。",
			"pos": Vector2(720, 700),
			"sprite": "res://assets/sprites/props/bench_0.png",
			"scale": 0.55,
			"color": Color(0.65, 0.55, 0.35, 0.92),
		},
	],
	"station": [
		{
			"id": "stn_crate",
			"title": "站台货箱",
			"desc": "掀开货箱盖，闻到机油味。",
			"pos": Vector2(720, 560),
			"sprite": "res://assets/sprites/props/crate_0.png",
			"scale": 0.5,
			"color": Color(0.6, 0.5, 0.35, 0.92),
		},
		{
			"id": "stn_lamp",
			"title": "月台灯",
			"desc": "拨一下灯罩，铜环叮一声。夜间会照亮站台。",
			"pos": Vector2(520, 480),
			"sprite": "res://assets/sprites/props/lamp_0.png",
			"scale": 1.15,
			"color": Color(0.9, 0.75, 0.35, 0.92),
		},
	],
	"residential": [
		{
			"id": "res_bench",
			"title": "巷口木凳",
			"desc": "在巷口木凳歇脚，听见邻里闲话。",
			"pos": Vector2(560, 560),
			"sprite": "res://assets/sprites/props/bench_0.png",
			"scale": 0.55,
			"color": Color(0.7, 0.6, 0.4, 0.92),
		},
		{
			"id": "res_sack",
			"title": "门廊粮袋",
			"desc": "拍拍门廊粮袋，谷壳飞起。",
			"pos": Vector2(880, 520),
			"sprite": "res://assets/sprites/props/sack_0.png",
			"scale": 0.5,
			"color": Color(0.75, 0.68, 0.4, 0.92),
		},
	],
	"waterfall": [
		{
			"id": "fall_rock",
			"title": "瀑缘苔石",
			"desc": "抚摸湿润苔石，水雾扑面。",
			"pos": Vector2(560, 640),
			"sprite": "res://assets/sprites/props/rocks/river/rock_00.png",
			"scale": 0.32,
			"color": Color(0.45, 0.6, 0.55, 0.92),
		},
		{
			"id": "fall_barrel",
			"title": "观瀑木桶",
			"desc": "桶沿还挂着水珠。",
			"pos": Vector2(780, 700),
			"sprite": "res://assets/sprites/props/barrel_1.png",
			"scale": 0.5,
			"color": Color(0.55, 0.5, 0.4, 0.92),
		},
	],
	"lighthouse": [
		{
			"id": "light_crate",
			"title": "灯塔货箱",
			"desc": "翻看补给箱，闻到煤油味。",
			"pos": Vector2(480, 620),
			"sprite": "res://assets/sprites/props/crate_0.png",
			"scale": 0.5,
			"color": Color(0.6, 0.5, 0.35, 0.92),
		},
		{
			"id": "light_lamp",
			"title": "岸边航标灯",
			"desc": "拨一下灯罩，铜环叮一声。夜间照亮岸边。",
			"pos": Vector2(640, 700),
			"sprite": "res://assets/sprites/props/lamp_0.png",
			"scale": 1.15,
			"color": Color(0.95, 0.8, 0.4, 0.92),
		},
	],
	"hill_farm": [
		{
			"id": "hill_hay",
			"title": "坡顶干草",
			"desc": "拍打草捆，扬起尘屑。",
			"pos": Vector2(720, 480),
			"sprite": "res://assets/sprites/props/hay_00.png",
			"scale": 0.5,
			"color": Color(0.9, 0.78, 0.35, 0.92),
		},
		{
			"id": "hill_rock",
			"title": "梯田沿石",
			"desc": "踩稳沿石，俯瞰农田。",
			"pos": Vector2(900, 560),
			"sprite": "res://assets/sprites/props/rock_02.png",
			"scale": 0.55,
			"color": Color(0.5, 0.55, 0.5, 0.92),
		},
	],
	"forest_entrance": [
		{
			"id": "fent_wood",
			"title": "林口柴堆",
			"desc": "拨开柴堆，惊起虫鸣。",
			"pos": Vector2(520, 560),
			"sprite": "res://assets/sprites/props/wood_pile_00.png",
			"scale": 0.5,
			"color": Color(0.45, 0.35, 0.25, 0.92),
		},
		{
			"id": "fent_sign",
			"title": "林径路牌",
			"desc": "路牌：前路深林，小心迷路。",
			"pos": Vector2(700, 480),
			"sprite": "res://assets/sprites/props/B11-06_mailbox_board_00.png",
			"scale": 0.5,
			"color": Color(0.65, 0.7, 0.55, 0.92),
		},
	],
	"farm_residential": [
		{
			"id": "farmres_trough",
			"title": "院内水槽",
			"desc": "检查水槽水位。",
			"pos": Vector2(640, 560),
			"sprite": "res://assets/sprites/props/trough_00.png",
			"scale": 0.5,
			"color": Color(0.45, 0.65, 0.85, 0.92),
		},
		{
			"id": "farmres_bench",
			"title": "院墙长凳",
			"desc": "在院墙边长凳歇脚。",
			"pos": Vector2(820, 500),
			"sprite": "res://assets/sprites/props/bench_0.png",
			"scale": 0.55,
			"color": Color(0.7, 0.6, 0.4, 0.92),
		},
	],
	"lake_house": [
		{
			"id": "lh_barrel",
			"title": "小屋系缆桶",
			"desc": "码头尽头的空桶。",
			"pos": Vector2(420, 580),
			"sprite": "res://assets/sprites/props/barrel_1.png",
			"scale": 0.5,
			"color": Color(0.5, 0.55, 0.7, 0.92),
		},
		{
			"id": "lh_sack",
			"title": "廊边渔网袋",
			"desc": "抖抖晒干的网袋。",
			"pos": Vector2(700, 540),
			"sprite": "res://assets/sprites/props/sack_0.png",
			"scale": 0.5,
			"color": Color(0.7, 0.65, 0.4, 0.92),
		},
	],
}

signal interacted(interact_id: String)

var _info: InfoPanel
var _root: Node2D


static func attach_to(host: Node2D, host_id: String, top_bar: Control = null) -> Node:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME)
	if existing:
		return existing
	var kit = load("res://scripts/world/district_interact_kit.gd").new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit.setup(host, host_id, top_bar)
	return kit


func setup(host: Node2D, host_id: String, _top_bar: Control = null) -> void:
	_info = WorldSpawnUtil.resolve_info(host)
	var ysort := WorldSpawnUtil.resolve_ysort(host)
	_root = Node2D.new()
	_root.name = "DistrictInteractRoot"
	_root.y_sort_enabled = true
	_root.z_index = 4
	ysort.add_child(_root)
	var defs: Array = HOST_DEFS.get(host_id, [])
	for d in defs:
		var interact_id := str(d["id"])
		var title := str(d["title"])
		var desc := str(d["desc"])
		var col: Color = d.get("color", Color(0.85, 0.75, 0.35, 0.9))
		var hs := WorldSpawnUtil.make_hotspot(
			_root,
			title,
			desc,
			d["pos"] as Vector2,
			Vector2(56, 48),
			col,
			str(d.get("sprite", "")),
			float(d.get("scale", 0.55)),
		)
		hs.set_meta("interact_id", interact_id)
		hs.set_meta("district_fx", _fx_spec_for_id(interact_id))
		if interact_id.contains("lamp"):
			_setup_lamp(hs)
		hs.activated.connect(func(_h: InteractableHotspot) -> void:
			_on_interact(interact_id, title, desc, _h)
		)


func live_count() -> int:
	if _root == null:
		return 0
	return _root.get_child_count()


func _fx_spec_for_id(interact_id: String) -> Dictionary:
	## Map district hotspots onto shipped C58 FX sheets (formal pixels, not pulse-only).
	var id := interact_id
	if id.contains("bench"):
		return {"dir": "res://assets/sprites/fx", "prefix": "bench_dust", "pos": Vector2(0, 6), "fps": 10.0}
	if id.contains("sign"):
		return {"dir": "res://assets/sprites/fx", "prefix": "board_rustle", "pos": Vector2(0, -18), "fps": 10.0}
	if id.contains("crate") or id.contains("handcart") or id.contains("barrel"):
		return {"dir": "res://assets/sprites/props", "prefix": "crate_lid", "pos": Vector2(0, -16), "fps": 8.0}
	if id.contains("trough"):
		return {"dir": "res://assets/sprites/props", "prefix": "well_rope", "pos": Vector2(0, -14), "fps": 8.0}
	if id.contains("hay") or id.contains("wood") or id.contains("sack") or id.contains("rock"):
		return {"dir": "res://assets/sprites/fx", "prefix": "leaf_fall", "pos": Vector2(0, -12), "fps": 12.0}
	if id.contains("lamp"):
		return {"dir": "res://assets/sprites/fx", "prefix": "lamp_spark", "pos": Vector2(0, -28), "fps": 10.0}
	return {"dir": "res://assets/sprites/fx", "prefix": "bench_dust", "pos": Vector2(0, 4), "fps": 10.0}


func _setup_lamp(hs: InteractableHotspot) -> void:
	## Result layer: PointLight2D + sprite modulate (plaza lamp_toggle parity).
	if hs == null:
		return
	var visual := hs.get_node_or_null("Visual") as Node2D
	if visual == null:
		return
	if visual.get_node_or_null("LampLight") != null:
		hs.set_meta("lamp_on", true)
		return
	var light := PointLight2D.new()
	light.name = "LampLight"
	WorldSpawnUtil.configure_lamp_light(light, Color(1.0, 0.82, 0.52, 1.0), WorldSpawnUtil.LAMP_ENERGY_NIGHT, WorldSpawnUtil.LAMP_TEX_SCALE, WorldSpawnUtil.LAMP_TEX_SIZE)
	light.position = WorldSpawnUtil.LAMP_LIGHT_OFFSET
	visual.add_child(light)
	hs.set_meta("lamp_on", true)
	var spr := visual.get_node_or_null("PropSprite") as Sprite2D
	if spr:
		spr.modulate = Color(1.2, 1.08, 0.82)
	var host := get_parent() as Node2D
	if host:
		var _olk := load("res://scripts/world/outdoor_lamp_kit.gd")
		if _olk:
			_olk.attach_to(host)


func _toggle_lamp(hs: InteractableHotspot) -> String:
	if hs == null:
		return ""
	var on := not bool(hs.get_meta("lamp_on", true))
	hs.set_meta("lamp_on", on)
	var visual := hs.get_node_or_null("Visual") as Node2D
	if visual:
		var light := visual.get_node_or_null("LampLight") as PointLight2D
		if light:
			light.enabled = on
			light.energy = WorldSpawnUtil.LAMP_ENERGY_NIGHT if on else 0.0
		var spr := visual.get_node_or_null("PropSprite") as Sprite2D
		if spr:
			spr.modulate = Color(1.2, 1.08, 0.82) if on else Color(0.55, 0.55, 0.65)
	var body := "路灯已%s。" % ("点亮" if on else "熄灭")
	if on:
		var env := DayNightWeather.find_on(get_parent())
		if env and not env.is_night():
			env.pulse_dusk_for_lamps()
			body += "（已切夜间观灯；关灯或按 N 回白天）"
	else:
		var env_off := DayNightWeather.find_on(get_parent())
		if env_off:
			var restored := env_off.restore_day_from_lamps()
			if bool(restored.get("restored", false)):
				body += "（已回白天）"
	return body


func _on_interact(interact_id: String, title: String, desc: String, hs: InteractableHotspot) -> void:
	var body := desc
	if hs:
		if interact_id.contains("lamp"):
			var blurb := _toggle_lamp(hs)
			if not blurb.is_empty():
				body = blurb
		var visual := hs.get_node_or_null("Visual") as CanvasItem
		if visual:
			var tw := visual.create_tween()
			tw.tween_property(visual, "modulate", Color(1.25, 1.2, 0.9), 0.08)
			tw.tween_property(visual, "modulate", Color.WHITE, 0.18)
		var spec: Dictionary = hs.get_meta("district_fx", {}) as Dictionary
		if spec.is_empty():
			spec = _fx_spec_for_id(interact_id)
		if not spec.is_empty():
			_play_fx_clip(
				hs,
				str(spec.get("dir", "")),
				str(spec.get("prefix", "")),
				4,
				spec.get("pos", Vector2.ZERO) as Vector2,
				float(spec.get("fps", 10.0)),
			)
	if _info:
		_info.show_info(title, body)
	interacted.emit(interact_id)


func mcp_spawn_fx(interact_id: String) -> Dictionary:
	## Sync MCP probe: find hotspot by interact_id and play its district FX.
	if _root == null:
		return {"ok": false, "reason": "no_root", "id": interact_id}
	for child in _root.get_children():
		if child is InteractableHotspot and str(child.get_meta("interact_id", "")) == interact_id:
			var hs := child as InteractableHotspot
			var lamp_blurb := ""
			if interact_id.contains("lamp"):
				lamp_blurb = _toggle_lamp(hs)
			var spec: Dictionary = hs.get_meta("district_fx", {}) as Dictionary
			if spec.is_empty():
				spec = _fx_spec_for_id(interact_id)
			_play_fx_clip(
				hs,
				str(spec.get("dir", "")),
				str(spec.get("prefix", "")),
				4,
				spec.get("pos", Vector2.ZERO) as Vector2,
				float(spec.get("fps", 10.0)),
			)
			var fx_name := "FX_%s" % str(spec.get("prefix", ""))
			var visual := hs.get_node_or_null("Visual") as Node
			var fx: AnimatedSprite2D = null
			if visual:
				fx = visual.get_node_or_null(fx_name) as AnimatedSprite2D
			if fx == null:
				return {"ok": false, "reason": "fx_not_spawned", "id": interact_id, "fx": fx_name}
			var sf := fx.sprite_frames
			var frames := 0
			if sf != null and sf.has_animation("oneshot"):
				frames = sf.get_frame_count("oneshot")
			var out := {
				"ok": true,
				"id": interact_id,
				"fx": fx_name,
				"frames": frames,
				"playing": fx.is_playing(),
				"path": str(fx.get_path()),
			}
			if interact_id.contains("lamp"):
				out["lamp_on"] = bool(hs.get_meta("lamp_on", false))
				out["lamp_blurb"] = lamp_blurb
				var light := visual.get_node_or_null("LampLight") as PointLight2D if visual else null
				out["has_light"] = light != null
				if light != null:
					out["light_enabled"] = light.enabled
					out["light_energy"] = light.energy
					out["has_light_texture"] = light.texture != null
			return out
	return {"ok": false, "reason": "missing_hotspot", "id": interact_id}


func _play_fx_clip(hs: Node, dir_path: String, prefix: String, frame_count: int, local_pos: Vector2, fps: float = 10.0) -> void:
	if hs == null or dir_path.is_empty() or prefix.is_empty():
		return
	var visual := hs.get_node_or_null("Visual") as Node2D
	if visual == null:
		return
	var prior := visual.get_node_or_null("FX_%s" % prefix)
	if prior != null:
		prior.free()
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")
	frames.add_animation("oneshot")
	frames.set_animation_loop("oneshot", false)
	frames.set_animation_speed("oneshot", fps)
	var n := 0
	for i in range(frame_count):
		var path := "%s/%s_%02d.png" % [dir_path, prefix, i]
		if not ResourceLoader.exists(path) and not FileAccess.file_exists(ProjectSettings.globalize_path(path)):
			continue
		var tex: Texture2D = null
		if ResourceLoader.exists(path):
			tex = load(path) as Texture2D
		if tex == null:
			var img := Image.load_from_file(ProjectSettings.globalize_path(path))
			if img != null:
				tex = ImageTexture.create_from_image(img)
		if tex == null:
			continue
		frames.add_frame("oneshot", tex)
		n += 1
	if n == 0:
		push_warning("DistrictInteractKit: no FX frames for %s in %s" % [prefix, dir_path])
		return
	var anim := AnimatedSprite2D.new()
	anim.name = "FX_%s" % prefix
	anim.sprite_frames = frames
	anim.position = local_pos
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anim.z_index = 8
	anim.centered = true
	visual.add_child(anim)
	anim.play("oneshot")
	anim.animation_finished.connect(func() -> void:
		if not is_instance_valid(anim):
			return
		anim.pause()
		var sf2 := anim.sprite_frames
		if sf2 != null and sf2.has_animation("oneshot"):
			var last := sf2.get_frame_count("oneshot") - 1
			if last >= 0:
				anim.frame = last
	)
