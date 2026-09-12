class_name DreamUI
extends RefCounted

## Shared presentation layer for Dream's outdoor scenes.
## Keeps the world art readable while giving the prototype a consistent game HUD.

const INK := Color("#243229")
const INK_MUTED := Color("#6f7568")
const PAPER := Color("#fbf4df")
const PAPER_DARK := Color("#e6d4ad")
const GREEN := Color("#4f7455")
const GREEN_DARK := Color("#35513d")
const GOLD := Color("#d89a3c")
const GOLD_BRIGHT := Color("#f2c86e")

static func polish_area(root: Node, scene_title: String) -> void:
	var ui := root.get_node_or_null("UI") as CanvasLayer
	if ui == null:
		return
	var topbar := ui.get_node_or_null("TopBar") as Control
	if topbar == null:
		return
	_apply_topbar(topbar, scene_title, false)
	_add_help_card(ui, "左键调查物件  ·  中键拖拽镜头  ·  滚轮缩放  ·  G 网格  ·  K 工作环  ·  L 生活态")
	_add_ambient_fx(root)
	var info := root.get_node_or_null("InfoPanel")
	if info != null:
		polish_info_panel(info)


static func polish_hub(root: Node, connections: bool = false) -> void:
	var ui := root.get_node_or_null("UI") as CanvasLayer
	if ui == null:
		return
	var topbar := ui.get_node_or_null("TopBar") as Control
	if topbar != null:
		_apply_topbar(topbar, "场景连接总览" if connections else "世界总览", true)
	var nature_row := ui.get_node_or_null("NatureRow") as Control
	if nature_row != null:
		_apply_row_controls(nature_row)
		var nature_hint := nature_row.get_node_or_null("NatureHint") as Label
		if nature_hint:
			nature_hint.add_theme_color_override("font_color", PAPER_DARK)
			nature_hint.add_theme_font_size_override("font_size", 15)
	_add_help_card(ui, "选择一个地点开始探索  ·  点击地图标记或上方入口")
	_add_hub_pins(root)


static func polish_info_panel(panel_layer: Node) -> void:
	var panel := panel_layer.get_node_or_null("Root/Panel") as PanelContainer
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", _panel_style(Color("#243229e8"), PAPER_DARK, 2, 14, 10))
	var title := panel_layer.get_node_or_null("Root/Panel/Margin/VBox/Title") as Label
	if title:
		title.add_theme_color_override("font_color", GOLD_BRIGHT)
		title.add_theme_font_size_override("font_size", 20)
	var body := panel_layer.get_node_or_null("Root/Panel/Margin/VBox/Body") as Label
	if body:
		body.add_theme_color_override("font_color", PAPER)
		body.add_theme_font_size_override("font_size", 15)
	var close := panel_layer.get_node_or_null("Root/Panel/Margin/VBox/Close") as Button
	if close:
		_style_button(close, true)


static func _apply_topbar(topbar: Control, title: String, hub: bool) -> void:
	if topbar.has_meta("dream_ui_polished"):
		return
	topbar.set_meta("dream_ui_polished", true)
	topbar.anchor_left = 0.0
	topbar.anchor_right = 1.0
	topbar.offset_left = 22.0
	topbar.offset_right = -22.0
	topbar.offset_top = 18.0
	topbar.offset_bottom = 60.0
	topbar.add_theme_constant_override("separation", 10)
	var backdrop := PanelContainer.new()
	backdrop.name = "DreamTopBarBackdrop"
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.anchor_left = 0.0
	backdrop.anchor_right = 1.0
	backdrop.offset_left = 12.0
	backdrop.offset_right = -12.0
	backdrop.offset_top = 10.0
	backdrop.offset_bottom = 70.0 if not hub else 112.0
	backdrop.add_theme_stylebox_override("panel", _panel_style(Color("#243229d9"), Color("#d8b96e99"), 1, 14, 8))
	var parent := topbar.get_parent()
	parent.add_child(backdrop)
	parent.move_child(backdrop, 0)
	var hint := topbar.get_node_or_null("Hint") as Label
	if hint:
		hint.text = title + "  ·  点击物件查看详情"
		hint.add_theme_color_override("font_color", PAPER)
		hint.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.45))
		hint.add_theme_constant_override("shadow_offset_x", 1)
		hint.add_theme_constant_override("shadow_offset_y", 1)
		hint.add_theme_font_size_override("font_size", 16)
	for child in topbar.get_children():
		if child is Button:
			_style_button(child as Button, false)
		if child is Label and child != hint:
			(child as Label).add_theme_color_override("font_color", PAPER_DARK)


static func _apply_row_controls(row: Control) -> void:
	row.anchor_left = 0.0
	row.anchor_right = 1.0
	row.offset_left = 22.0
	row.offset_right = -22.0
	row.offset_top = 72.0
	row.offset_bottom = 108.0
	row.add_theme_constant_override("separation", 8)
	for child in row.get_children():
		if child is Button:
			_style_button(child as Button, false)


static func _add_help_card(ui: CanvasLayer, text: String) -> void:
	if ui.has_node("DreamHelpCard"):
		var existing := ui.get_node("DreamHelpCard/Label") as Label
		if existing:
			existing.text = text
		return
	var card := PanelContainer.new()
	card.name = "DreamHelpCard"
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.anchor_top = 1.0
	card.anchor_bottom = 1.0
	card.offset_left = 18.0
	card.offset_top = -52.0
	card.offset_right = 560.0
	card.offset_bottom = -16.0
	card.add_theme_stylebox_override("panel", _panel_style(Color("#243229c9"), Color("#d8b96e66"), 1, 10, 6))
	var label := Label.new()
	label.name = "Label"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", PAPER_DARK)
	label.add_theme_font_size_override("font_size", 13)
	card.add_child(label)
	ui.add_child(card)


static func _add_hub_pins(root: Node) -> void:
	var hotspots := root.get_node_or_null("Hotspots") as Node2D
	if hotspots == null:
		return
	var palette := {
		"VillageSquare": Color("#eab65b"),
		"VillageResidential": Color("#8fd69a"),
		"FarmResidential": Color("#e8a55c"),
		"Farmland": Color("#a9d76c"),
		"MarketStreet": Color("#e19bca"),
		"ForestEntrance": Color("#79b487"),
		"Station": Color("#9ab8e2"),
	}
	var labels := {
		"VillageSquare": "广场",
		"VillageResidential": "住宅",
		"FarmResidential": "农场",
		"Farmland": "农田",
		"MarketStreet": "市集",
		"ForestEntrance": "森林",
		"Station": "车站",
	}
	for child in hotspots.get_children():
		if not (child is Area2D):
			continue
		var area := child as Area2D
		var hint := area.get_node_or_null("Hint") as Polygon2D
		if hint:
			hint.visible = false
		if area.has_node("DreamHubPin"):
			continue
		var pin := HubPin.new()
		pin.name = "DreamHubPin"
		pin.pin_color = palette.get(area.name, GOLD)
		pin.caption = labels.get(area.name, area.name)
		area.add_child(pin)


static func _add_ambient_fx(root: Node) -> void:
	if root.has_node("DreamAmbientFX"):
		return
	var fx := AmbientFX.new()
	fx.name = "DreamAmbientFX"
	fx.setup(root.name)
	fx.z_index = 4
	# Area assemblers call polish_area from _ready while the scene is still
	# attaching children; defer this cosmetic node to avoid a blocked add_child.
	root.call_deferred("add_child", fx)


static func _style_button(button: Button, compact: bool) -> void:
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(92.0 if compact else 104.0, 32.0)
	button.add_theme_font_size_override("font_size", 14 if compact else 13)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_color_override("font_focus_color", INK)
	button.add_theme_stylebox_override("normal", _panel_style(PAPER, PAPER_DARK, 1, 8, 3))
	button.add_theme_stylebox_override("hover", _panel_style(GOLD_BRIGHT, GOLD, 2, 8, 4))
	button.add_theme_stylebox_override("pressed", _panel_style(Color("#dca85b"), GREEN_DARK, 2, 8, 2))
	button.add_theme_stylebox_override("focus", _panel_style(Color("#fff2c7"), GOLD, 2, 8, 4))


static func _panel_style(bg: Color, border: Color, border_width: int, radius: int, shadow: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = shadow
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 5.0
	style.content_margin_bottom = 5.0
	return style
