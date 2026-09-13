extends Control

## Goal §7 user QA checklist — jump to scenes + persist checkmarks.
## Open from World Hub 「§7验收」or run scene directly.
## Saves to user://goal_user_qa.cfg — does NOT auto-complete the Goal.

const SAVE_PATH := "user://goal_user_qa.cfg"
const ITEMS := [
	{"id": "square", "title": "广场 C58–C60 / K姿态 / 门脸", "hint": "点井/树/箱/灯/喂鸟；桩草；锁门；K 工作环", "path": SceneRouter.SQUARE_PATH},
	{"id": "market", "title": "市集摊位木棚", "hint": "默认木棚可见；可进市场后台/夜市", "path": SceneRouter.MARKET_PATH},
	{"id": "farmland", "title": "农田垄线/栅栏/农夫", "hint": "无白底盘；DistrictInteract", "path": SceneRouter.FARMLAND_PATH},
	{"id": "residential", "title": "住宅区门阶", "hint": "门阶/拱门；可进后院", "path": SceneRouter.RESIDENTIAL_PATH},
	{"id": "farm_home", "title": "农场住宅/地窖", "hint": "栅栏；进入地窖", "path": SceneRouter.FARM_HOME_PATH},
	{"id": "forest", "title": "林口/深林/C62密道", "hint": "树洞密道可进", "path": SceneRouter.FOREST_DEEP_PATH},
	{"id": "river", "title": "河渔笼/浮漂", "hint": "下放→约6s→可收；浮漂+水环", "path": SceneRouter.RIVER_PATH},
	{"id": "lake", "title": "湖渔笼/渡口", "hint": "东码头笼；登岛渡口", "path": SceneRouter.LAKE_PATH},
	{"id": "waterfall", "title": "瀑布水体动画", "hint": "WaterfallAnim 循环可见", "path": SceneRouter.WATERFALL_PATH},
	{"id": "station", "title": "车站轨枕", "hint": "轨枕精灵非色块", "path": SceneRouter.STATION_PATH},
	{"id": "c01", "title": "C01 衣柜/钱箱开合", "hint": "开合短帧；可↑二楼", "path": SceneRouter.C01_HOME_PATH},
	{"id": "c02", "title": "C02 钱箱开盖", "hint": "chest_lid 开合", "path": SceneRouter.C02_MERCHANT_PATH},
	{"id": "c06", "title": "C06 议事厅进出", "hint": "进门出门外观正常", "path": SceneRouter.C06_TOWN_HALL_PATH},
	{"id": "c43", "title": "C43 浴场立面进门", "hint": "广场立面→室内→返回", "path": SceneRouter.C43_BATHHOUSE_PATH},
	{"id": "wave_d", "title": "Wave D 抽样（后台/夜市）", "hint": "市集进后台或夜市再返回", "path": SceneRouter.C32_MARKET_BACK_PATH},
	{"id": "wave_e", "title": "Wave E 抽样（二楼）", "hint": "C01↑二楼再返回", "path": SceneRouter.C46_SECOND_FLOOR_PATH},
]

var _checks: Dictionary = {}
var _status: Label
var _list: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_load()
	_build_ui()
	_refresh_status()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.14, 0.16, 1.0)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 12)
	margin.add_child(root)

	var title := Label.new()
	title.text = "Goal §7 用户验收清单"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(0.95, 0.92, 0.82))
	root.add_child(title)

	var sub := Label.new()
	sub.text = "每项：跳转场景手测 → 勾选「通过」。全部通过后请在聊天回复「§7 已勾」。\n勾选只保存在本机 user://，不会自动把 Goal 标 complete。"
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_color_override("font_color", Color(0.75, 0.78, 0.72))
	root.add_child(sub)

	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 16)
	_status.add_theme_color_override("font_color", Color(0.85, 0.9, 0.55))
	root.add_child(_status)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)

	for item in ITEMS:
		_list.add_child(_make_row(item))

	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 12)
	root.add_child(foot)

	var hub := Button.new()
	hub.text = "回世界总览"
	hub.pressed.connect(func() -> void:
		SceneRouter.change_to(get_tree(), SceneRouter.HUB_PATH)
	)
	foot.add_child(hub)

	var clear_btn := Button.new()
	clear_btn.text = "清空勾选"
	clear_btn.pressed.connect(_clear_all)
	foot.add_child(clear_btn)


func _make_row(item: Dictionary) -> Control:
	var id := str(item["id"])
	var panel := PanelContainer.new()
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	panel.add_child(h)

	var cb := CheckBox.new()
	cb.text = ""
	cb.button_pressed = bool(_checks.get(id, false))
	cb.toggled.connect(func(on: bool) -> void:
		_checks[id] = on
		_save()
		_refresh_status()
	)
	h.add_child(cb)

	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var t := Label.new()
	t.text = str(item["title"])
	t.add_theme_color_override("font_color", Color(0.95, 0.93, 0.88))
	texts.add_child(t)
	var hint := Label.new()
	hint.text = str(item["hint"])
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", Color(0.65, 0.7, 0.66))
	texts.add_child(hint)
	h.add_child(texts)

	var go := Button.new()
	go.text = "跳转"
	go.custom_minimum_size = Vector2(72, 0)
	var path := str(item["path"])
	go.pressed.connect(func() -> void:
		SceneRouter.change_to(get_tree(), path)
	)
	h.add_child(go)
	return panel


func _refresh_status() -> void:
	var done := 0
	for item in ITEMS:
		if bool(_checks.get(str(item["id"]), false)):
			done += 1
	var total := ITEMS.size()
	if done >= total:
		_status.text = "进度 %d/%d — 全部通过。请在 Cursor 聊天回复：§7 已勾" % [done, total]
	else:
		_status.text = "进度 %d/%d" % [done, total]


func _load() -> void:
	_checks.clear()
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	for item in ITEMS:
		var id := str(item["id"])
		_checks[id] = bool(cfg.get_value("checks", id, false))


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	for item in ITEMS:
		var id := str(item["id"])
		cfg.set_value("checks", id, bool(_checks.get(id, false)))
	cfg.save(SAVE_PATH)


func _clear_all() -> void:
	_checks.clear()
	_save()
	# Rebuild rows to reset checkboxes.
	for c in _list.get_children():
		c.queue_free()
	for item in ITEMS:
		_list.add_child(_make_row(item))
	_refresh_status()
