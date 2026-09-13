class_name OutdoorLampKit
extends Node

## Wires radial PointLight2D onto outdoor street lamps and syncs with night grade.
## CanvasModulate darkens PointLight too — night energy is boosted to compensate.

const NODE_NAME := "OutdoorLampKit"
const GROUP_LAMPS := "outdoor_street_lamps"

## Aliases kept for callers / QA (canonical values live on WorldSpawnUtil).
const LAMP0_SCALE := WorldSpawnUtil.LAMP_SPRITE_SCALE
const LIGHT_OFFSET := WorldSpawnUtil.LAMP_LIGHT_OFFSET
const ENERGY_NIGHT := WorldSpawnUtil.LAMP_ENERGY_NIGHT
const ENERGY_DAY := WorldSpawnUtil.LAMP_ENERGY_DAY
const TEX_SCALE := WorldSpawnUtil.LAMP_TEX_SCALE
const TEX_SIZE := WorldSpawnUtil.LAMP_TEX_SIZE


static func attach_to(host: Node2D) -> OutdoorLampKit:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME) as OutdoorLampKit
	if existing:
		existing.refresh()
		return existing
	var kit := OutdoorLampKit.new()
	kit.name = NODE_NAME
	host.add_child(kit)
	kit._boot()
	return kit


var _host: Node2D
var _lights: Array[PointLight2D] = []


func _boot() -> void:
	_host = get_parent() as Node2D
	call_deferred("refresh")
	# WorldInteractKit / DistrictInteractKit often mount after Env — rescan once.
	var t := get_tree().create_timer(0.15)
	t.timeout.connect(refresh)
	var env := DayNightWeather.find_on(_host)
	if env and env.has_signal("state_changed") and not env.state_changed.is_connected(_on_env):
		env.state_changed.connect(_on_env)


func refresh() -> void:
	_lights.clear()
	if _host == null:
		return
	var ysort := WorldSpawnUtil.resolve_ysort(_host)
	if ysort == null:
		ysort = _host
	_scan(ysort)
	_apply_grade(_is_night())


func _on_env(time_grade: int, _weather: int) -> void:
	_apply_grade(time_grade == int(DayNightWeather.TimeGrade.NIGHT))


func _is_night() -> bool:
	var env := DayNightWeather.find_on(_host)
	return env != null and env.is_night()


func _scan(node: Node) -> void:
	if node is Sprite2D:
		_maybe_wire_sprite(node as Sprite2D)
	if node is InteractableHotspot:
		_maybe_wire_hotspot(node as InteractableHotspot)
	for c in node.get_children():
		_scan(c)


func _is_street_lamp_path(path: String) -> bool:
	var p := path.replace("\\", "/").to_lower()
	# Real post only — lamp_1 = flower pot, lamp_2 = planter/花箱 (MARKET_STALL_ASSET_AUDIT).
	return p.ends_with("/lamp_0.png")


func _maybe_wire_sprite(spr: Sprite2D) -> void:
	if spr == null or spr.texture == null:
		return
	var path := str(spr.texture.resource_path)
	if not _is_street_lamp_path(path):
		return
	# Normalize post scale for readable street presence.
	var s := absf(spr.scale.x)
	if s > 0.01 and s < 0.85:
		var ratio := LAMP0_SCALE / s
		spr.scale = Vector2(LAMP0_SCALE, LAMP0_SCALE)
		# Keep feet-ish when sprite was centered tall.
		spr.position.y *= ratio
	_ensure_light_under(spr.get_parent() as Node2D, spr)


func _maybe_wire_hotspot(hs: InteractableHotspot) -> void:
	if hs == null:
		return
	var title := hs.title
	var path_hint := ""
	var spr := hs.get_node_or_null("Visual/PropSprite") as Sprite2D
	if spr and spr.texture:
		path_hint = str(spr.texture.resource_path)
	var pl := path_hint.to_lower()
	# Misnamed pots/planters titled as lamps — retitle, never light.
	if pl.ends_with("/lamp_1.png") and ("灯" in title):
		hs.title = "花盆"
		hs.description = "巷边花盆（不是灯柱）。"
		return
	if pl.ends_with("/lamp_2.png") and ("灯" in title):
		hs.title = "花箱"
		hs.description = "街角花箱装饰（不是灯柱）。"
		return
	if _is_street_lamp_path(path_hint) or (spr == null and ("路灯" in title or "站台灯" in title or title.ends_with("灯"))):
		if spr:
			_maybe_wire_sprite(spr)
		else:
			var vis := hs.get_node_or_null("Visual") as Node2D
			_ensure_light_under(vis, null)


func _ensure_light_under(visual: Node2D, spr: Sprite2D) -> void:
	if visual == null:
		return
	var light := visual.get_node_or_null("LampLight") as PointLight2D
	if light == null:
		light = PointLight2D.new()
		light.name = "LampLight"
		WorldSpawnUtil.configure_lamp_light(
			light,
			Color(1.0, 0.82, 0.52, 1.0),
			ENERGY_NIGHT,
			TEX_SCALE,
			TEX_SIZE,
		)
		var oy := LIGHT_OFFSET.y
		if spr != null:
			# Aim at lantern head (~top 30% of post).
			oy = spr.position.y - absf(spr.scale.y) * 14.0
		light.position = Vector2(LIGHT_OFFSET.x, oy)
		visual.add_child(light)
	else:
		WorldSpawnUtil.configure_lamp_light(
			light,
			Color(1.0, 0.82, 0.52, 1.0),
			ENERGY_NIGHT,
			TEX_SCALE,
			TEX_SIZE,
		)
	if not light.is_in_group(GROUP_LAMPS):
		light.add_to_group(GROUP_LAMPS)
	_lights.append(light)


func _apply_grade(night: bool) -> void:
	var e := ENERGY_NIGHT if night else ENERGY_DAY
	for light in _lights:
		if light == null or not is_instance_valid(light):
			continue
		var forced_off := false
		var vis := light.get_parent()
		if vis:
			var hs := vis.get_parent()
			if hs != null and hs.has_meta("lamp_on") and not bool(hs.get_meta("lamp_on")):
				forced_off = true
		if forced_off:
			light.enabled = false
			light.energy = 0.0
			continue
		light.enabled = true
		light.energy = e
		var spr := light.get_parent().get_node_or_null("PropSprite") as Sprite2D if light.get_parent() else null
		if spr:
			spr.modulate = Color(1.08, 1.0, 0.88) if night else Color(0.92, 0.92, 0.95)
