extends Node

## Keyboard map travel — no on-screen nav chrome required.
## [ ] cycle outdoor maps · M hub · Esc connections · F11 fullscreen

const NODE_NAME := "MapTravelKit"

## Ordered outdoor ring for [ ] cycling (hub excluded).
const OUTDOOR_RING := [
	SceneRouter.SQUARE_PATH,
	SceneRouter.RESIDENTIAL_PATH,
	SceneRouter.MARKET_PATH,
	SceneRouter.FARMLAND_PATH,
	SceneRouter.FARM_HOME_PATH,
	SceneRouter.STATION_PATH,
	SceneRouter.FOREST_ENTRANCE_PATH,
	SceneRouter.FOREST_DEEP_PATH,
	SceneRouter.RIVER_PATH,
	SceneRouter.WATERFALL_PATH,
	SceneRouter.HILL_FARM_PATH,
	SceneRouter.LAKE_PATH,
	SceneRouter.LAKE_HOUSE_PATH,
	SceneRouter.LIGHTHOUSE_PATH,
]

const TITLE_BY_PATH := {
	SceneRouter.SQUARE_PATH: "村广场",
	SceneRouter.RESIDENTIAL_PATH: "民居区",
	SceneRouter.MARKET_PATH: "市集街",
	SceneRouter.FARMLAND_PATH: "农田",
	SceneRouter.FARM_HOME_PATH: "农舍",
	SceneRouter.STATION_PATH: "车站",
	SceneRouter.FOREST_ENTRANCE_PATH: "林缘",
	SceneRouter.FOREST_DEEP_PATH: "深林",
	SceneRouter.RIVER_PATH: "河岸",
	SceneRouter.WATERFALL_PATH: "瀑布",
	SceneRouter.HILL_FARM_PATH: "山坡田",
	SceneRouter.LAKE_PATH: "湖畔",
	SceneRouter.LAKE_HOUSE_PATH: "湖屋",
	SceneRouter.LIGHTHOUSE_PATH: "灯塔",
	SceneRouter.HUB_PATH: "世界总览",
	SceneRouter.CONNECTION_PATH: "连接总览",
}


static func attach_to(host: Node) -> Node:
	if host == null:
		return null
	var existing := host.get_node_or_null(NODE_NAME)
	if existing:
		return existing
	var kit = load("res://scripts/world/map_travel_kit.gd").new()
	kit.name = NODE_NAME
	host.add_child(kit)
	return kit


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_BRACKETLEFT:
				_cycle(-1)
				get_viewport().set_input_as_handled()
			KEY_BRACKETRIGHT:
				_cycle(1)
				get_viewport().set_input_as_handled()
			KEY_M:
				SceneRouter.change_to(get_tree(), SceneRouter.HUB_PATH)
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				SceneRouter.change_to(get_tree(), SceneRouter.CONNECTION_PATH)
				get_viewport().set_input_as_handled()
			KEY_F11:
				_toggle_fullscreen()
				get_viewport().set_input_as_handled()


func _cycle(delta: int) -> void:
	var cur := get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	var idx := OUTDOOR_RING.find(cur)
	if idx < 0:
		idx = 0
	else:
		idx = (idx + delta) % OUTDOOR_RING.size()
		if idx < 0:
			idx += OUTDOOR_RING.size()
	var path: String = OUTDOOR_RING[idx]
	_toast(str(TITLE_BY_PATH.get(path, path.get_file())))
	SceneRouter.change_to(get_tree(), path, "default")


func _toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _toast(text: String) -> void:
	var host := get_parent()
	if host == null:
		return
	var layer := host.get_node_or_null("UI") as CanvasLayer
	if layer == null:
		return
	var old := layer.get_node_or_null("MapTravelToast")
	if old:
		old.queue_free()
	var lbl := Label.new()
	lbl.name = "MapTravelToast"
	lbl.text = text
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(0.98, 0.95, 0.88, 0.92))
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
	lbl.offset_top = 28
	lbl.offset_bottom = 52
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layer.add_child(lbl)
	var tw := lbl.create_tween()
	tw.tween_interval(0.85)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.45)
	tw.tween_callback(lbl.queue_free)
