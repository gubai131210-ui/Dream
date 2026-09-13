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
	_add_user_qa_return(ui)
	_add_user_qa_brief(ui)
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
	# Hub already has §7验收 entry — clear return arm so it does not stack.
	clear_user_qa_return()


static func arm_user_qa_return() -> void:
	Engine.set_meta("dream_user_qa_return", true)


static func arm_user_qa_brief(title: String, hint: String, expect: String) -> void:
	## Carry the current §7 item criteria into the jumped scene HUD.
	Engine.set_meta("dream_user_qa_brief", {
		"title": title,
		"hint": hint,
		"expect": expect,
	})


static func clear_user_qa_return() -> void:
	if Engine.has_meta("dream_user_qa_return"):
		Engine.remove_meta("dream_user_qa_return")
	if Engine.has_meta("dream_user_qa_brief"):
		Engine.remove_meta("dream_user_qa_brief")


static func is_user_qa_return_armed() -> bool:
	return bool(Engine.get_meta("dream_user_qa_return", false))


static func user_qa_brief() -> Dictionary:
	var v = Engine.get_meta("dream_user_qa_brief", {})
	return v if typeof(v) == TYPE_DICTIONARY else {}


static func go_user_qa(tree: SceneTree) -> void:
	clear_user_qa_return()
	SceneRouter.change_to(tree, SceneRouter.USER_QA_PATH)


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


static func _add_user_qa_return(ui: CanvasLayer) -> void:
	## After §7 checklist「跳转」, keep a single return chip so hand-feel QA can loop.
	if not is_user_qa_return_armed():
		return
	if ui.get_node_or_null("UserQaReturnBtn") != null:
		return
	var btn := Button.new()
	btn.name = "UserQaReturnBtn"
	btn.text = "回§7清单"
	btn.tooltip_text = "返回 Goal 用户验收清单继续勾选"
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.anchor_top = 0.0
	btn.anchor_bottom = 0.0
	btn.offset_left = -150.0
	btn.offset_right = -22.0
	btn.offset_top = 78.0
	btn.offset_bottom = 112.0
	_style_button(btn, true)
	btn.pressed.connect(func() -> void:
		var tree := ui.get_tree()
		if tree:
			go_user_qa(tree)
	)
	ui.add_child(btn)


static func _add_user_qa_brief(ui: CanvasLayer) -> void:
	## Show the armed checklist item's hand-feel criteria while testing in-scene.
	if not is_user_qa_return_armed():
		return
	var brief := user_qa_brief()
	if brief.is_empty():
		return
	if ui.get_node_or_null("UserQaBrief") != null:
		return
	var card := PanelContainer.new()
	card.name = "UserQaBrief"
	card.anchor_left = 1.0
	card.anchor_right = 1.0
	card.anchor_top = 0.0
	card.anchor_bottom = 0.0
	card.offset_left = -360.0
	card.offset_right = -22.0
	card.offset_top = 120.0
	card.offset_bottom = 120.0
	card.custom_minimum_size = Vector2(330, 0)
	card.add_theme_stylebox_override("panel", _panel_style(Color("#243229f0"), GOLD, 2, 10, 8))
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	margin.add_child(v)
	var head := Label.new()
	head.text = "§7 手测 · %s" % str(brief.get("title", ""))
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.add_theme_color_override("font_color", GOLD_BRIGHT)
	head.add_theme_font_size_override("font_size", 14)
	v.add_child(head)
	var hint := Label.new()
	hint.text = str(brief.get("hint", ""))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", PAPER)
	hint.add_theme_font_size_override("font_size", 12)
	v.add_child(hint)
	var expect := Label.new()
	expect.text = str(brief.get("expect", ""))
	expect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	expect.add_theme_color_override("font_color", Color(0.78, 0.9, 0.7))
	expect.add_theme_font_size_override("font_size", 12)
	v.add_child(expect)
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
