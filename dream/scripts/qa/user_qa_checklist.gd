extends Control

## Goal §7 user QA checklist — jump to scenes + persist checkmarks.
## Open from World Hub 「§7验收」or run scene directly.
## Saves to user://goal_user_qa.cfg — does NOT auto-complete the Goal.

const SAVE_PATH := "user://goal_user_qa.cfg"
## Mirrors GOAL_INTERACT_COMPLETE §7 outdoor rows + indoor sample rows (full user gate).
## expect = pass criteria shown under hint (hand-feel only; Agent MCP never auto-checks).
const ITEMS := [
	{"id": "square", "group": "户外", "title": "广场 C58–C60 / K·L姿态 / 门脸", "hint": "点井/树/箱/灯/喂鸟；白天点灯会切夜间观灯（N 回白天）；桩草；锁门；K工作；L睡眠看枕头；「互动」", "expect": "通过：多帧 FX；点灯夜间粘性；L 睡眠枕头可见；K/L 无卡死", "path": SceneRouter.SQUARE_PATH},
	{"id": "market", "group": "户外", "title": "市集摊位木棚", "hint": "默认木棚可见；点摊切换状态看 FX；可进市场后台/夜市", "expect": "通过：木棚非色块；摊位状态 FX；可进出后台", "path": SceneRouter.MARKET_PATH},
	{"id": "farmland", "group": "户外", "title": "农田垄线/栅栏/农夫", "hint": "无白底盘；DistrictInteract；N 可用", "expect": "通过：垄线/栅栏精灵；农夫无白边盘", "path": SceneRouter.FARMLAND_PATH},
	{"id": "residential", "group": "户外", "title": "住宅区门阶", "hint": "门阶/拱门；可进后院", "expect": "通过：门阶可辨；进出后院正常", "path": SceneRouter.RESIDENTIAL_PATH},
	{"id": "farm_home", "group": "户外", "title": "农场住宅/地窖", "hint": "栅栏；进入地窖", "expect": "通过：栅栏精灵；地窖可进可出", "path": SceneRouter.FARM_HOME_PATH},
	{"id": "forest_entrance", "group": "户外", "title": "林口 DistrictInteract", "hint": "门脸/交互点可点；可进深林", "expect": "通过：交互反馈；进深林", "path": SceneRouter.FOREST_ENTRANCE_PATH},
	{"id": "forest", "group": "户外", "title": "深林 C62 密道", "hint": "树洞密道可进洞窟链", "expect": "通过：密道可进；可回出", "path": SceneRouter.FOREST_DEEP_PATH},
	{"id": "river", "group": "户外", "title": "河渔笼/浮漂/施放", "hint": "下放→约6s→可收；施放水花多帧；浮漂+水环", "expect": "通过：笼循环完整；cast splash 多帧", "path": SceneRouter.RIVER_PATH},
	{"id": "lake", "group": "户外", "title": "湖渔笼/渡口/施放", "hint": "东码头笼；钓点施放 splash；登岛渡口", "expect": "通过：笼+渡口可玩；splash 可见", "path": SceneRouter.LAKE_PATH},
	{"id": "waterfall", "group": "户外", "title": "瀑布水体动画", "hint": "WaterfallAnim 循环可见", "expect": "通过：水体循环动画连续", "path": SceneRouter.WATERFALL_PATH},
	{"id": "lighthouse", "group": "户外", "title": "灯塔户外门脸", "hint": "DistrictInteract；N夜间+航标灯开关晕光；进室内可返回", "expect": "通过：夜间灯开关；室内可回", "path": SceneRouter.LIGHTHOUSE_PATH},
	{"id": "hill_farm", "group": "户外", "title": "坡田 DistrictInteract", "hint": "门脸/交互；无色块占位", "expect": "通过：交互精灵齐全；无色块墙", "path": SceneRouter.HILL_FARM_PATH},
	{"id": "station", "group": "户外", "title": "车站轨枕", "hint": "轨枕精灵；N夜间+月台灯开关；非色块", "expect": "通过：轨枕精灵；夜间灯开关", "path": SceneRouter.STATION_PATH},
	{"id": "lake_house", "group": "户外", "title": "湖畔小屋门脸", "hint": "门脸可进；返回湖区", "expect": "通过：门脸进出正常", "path": SceneRouter.LAKE_HOUSE_PATH},
	{"id": "c01", "group": "室内", "title": "C01 衣柜开合 / 二楼", "hint": "drawer_open 短帧；可↑二楼", "expect": "通过：开合多帧；二楼可回", "path": SceneRouter.C01_HOME_PATH},
	{"id": "c02", "group": "室内", "title": "C02 钱箱开盖", "hint": "chest_lid 开合", "expect": "通过：箱盖多帧", "path": SceneRouter.C02_MERCHANT_PATH},
	{"id": "c06", "group": "室内", "title": "C06 议事厅进出", "hint": "进门出门外观正常", "expect": "通过：进出与门脸正常", "path": SceneRouter.C06_TOWN_HALL_PATH},
	{"id": "c40", "group": "室内", "title": "C40 博物馆立面进门", "hint": "广场立面→室内→返回", "expect": "通过：立面可发现并进出", "path": SceneRouter.C40_MUSEUM_PATH},
	{"id": "c43", "group": "室内", "title": "C43 浴场立面进门", "hint": "广场立面→室内→返回", "expect": "通过：立面可发现并进出", "path": SceneRouter.C43_BATHHOUSE_PATH},
	{"id": "wave_d", "group": "室内", "title": "Wave D 抽样（后台）", "hint": "市集进后台再返回", "expect": "通过：C32 进出正常", "path": SceneRouter.C32_MARKET_BACK_PATH},
	{"id": "wave_e", "group": "室内", "title": "Wave E 抽样（二楼）", "hint": "C01↑二楼再返回", "expect": "通过：C46 进出正常", "path": SceneRouter.C46_SECOND_FLOOR_PATH},
]

var _checks: Dictionary = {}
var _status: Label
var _next_label: Label
var _list: VBoxContainer
var _reply_btn: Button
var _next_btn: Button


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
	sub.text = "每项：跳转场景按「通过标准」手测 → 勾选。场景内点「回§7清单」继续。\n勾选只保存在本机 user://，不会自动把 Goal 标 complete。全部通过后回复 Cursor：「§7 已勾」。"
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_color_override("font_color", Color(0.75, 0.78, 0.72))
	root.add_child(sub)

	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 16)
	_status.add_theme_color_override("font_color", Color(0.85, 0.9, 0.55))
	root.add_child(_status)

	_next_label = Label.new()
	_next_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_next_label.add_theme_color_override("font_color", Color(0.7, 0.85, 0.95))
	root.add_child(_next_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)

	_rebuild_rows()

	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 12)
	root.add_child(foot)

	var hub := Button.new()
	hub.text = "回世界总览"
	hub.pressed.connect(func() -> void:
		DreamUI.clear_user_qa_return()
		SceneRouter.change_to(get_tree(), SceneRouter.HUB_PATH)
	)
	foot.add_child(hub)

	_next_btn = Button.new()
	_next_btn.text = "跳转下一项未勾"
	_next_btn.pressed.connect(_jump_next_unchecked)
	foot.add_child(_next_btn)

	var clear_btn := Button.new()
	clear_btn.text = "清空勾选"
	clear_btn.pressed.connect(_clear_all)
	foot.add_child(clear_btn)

	_reply_btn = Button.new()
	_reply_btn.text = "复制「§7 已勾」"
	_reply_btn.disabled = true
	_reply_btn.pressed.connect(func() -> void:
		DisplayServer.clipboard_set("§7 已勾")
		_status.text = "已复制到剪贴板：§7 已勾 — 请粘贴到 Cursor 聊天"
	)
	foot.add_child(_reply_btn)


func _rebuild_rows() -> void:
	for c in _list.get_children():
		c.queue_free()
	var last_group := ""
	for item in ITEMS:
		var group := str(item.get("group", ""))
		if group != last_group:
			last_group = group
			var hdr := Label.new()
			hdr.text = "—— %s ——" % group
			hdr.add_theme_font_size_override("font_size", 15)
			hdr.add_theme_color_override("font_color", Color(0.55, 0.72, 0.62))
			_list.add_child(hdr)
		_list.add_child(_make_row(item))


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
	var expect := Label.new()
	expect.text = str(item.get("expect", ""))
	expect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	expect.add_theme_color_override("font_color", Color(0.78, 0.88, 0.7))
	texts.add_child(expect)
	h.add_child(texts)

	var go := Button.new()
	go.text = "跳转"
	go.custom_minimum_size = Vector2(72, 0)
	var path := str(item["path"])
	go.pressed.connect(func() -> void:
		DreamUI.arm_user_qa_return()
		SceneRouter.change_to(get_tree(), path)
	)
	h.add_child(go)
	return panel


func _first_unchecked() -> Dictionary:
	for item in ITEMS:
		if not bool(_checks.get(str(item["id"]), false)):
			return item
	return {}


func _jump_next_unchecked() -> void:
	var item := _first_unchecked()
	if item.is_empty():
		_status.text = "全部已勾 — 请复制「§7 已勾」"
		return
	DreamUI.arm_user_qa_return()
	SceneRouter.change_to(get_tree(), str(item["path"]))


func _refresh_status() -> void:
	var done := 0
	for item in ITEMS:
		if bool(_checks.get(str(item["id"]), false)):
			done += 1
	var total := ITEMS.size()
	var all_done := done >= total
	if _reply_btn:
		_reply_btn.disabled = not all_done
	if _next_btn:
		_next_btn.disabled = all_done
	if all_done:
		_status.text = "进度 %d/%d — 全部通过。点「复制「§7 已勾」」或手动回复 Cursor。" % [done, total]
		if _next_label:
			_next_label.text = "下一项：无（清单完成）"
	else:
		_status.text = "进度 %d/%d（对齐 GOAL §7 户外全表 + 室内抽样）" % [done, total]
		var nxt := _first_unchecked()
		if _next_label and not nxt.is_empty():
			_next_label.text = "下一项未勾：[%s] %s — %s" % [
				str(nxt.get("group", "")),
				str(nxt.get("title", "")),
				str(nxt.get("expect", "")),
			]


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
	_rebuild_rows()
	_refresh_status()


func mcp_jump_first() -> Dictionary:
	## MCP probe: arm return chip and enter square.
	if ITEMS.is_empty():
		return {"ok": false, "reason": "no_items"}
	DreamUI.arm_user_qa_return()
	var path := str(ITEMS[0]["path"])
	SceneRouter.change_to(get_tree(), path)
	return {"ok": true, "path": path, "armed": DreamUI.is_user_qa_return_armed()}


func mcp_next_unchecked() -> Dictionary:
	## MCP/UX probe: first unchecked item metadata (does not mark checks).
	var item := _first_unchecked()
	if item.is_empty():
		return {"ok": true, "done": true, "remaining": 0}
	var remaining := 0
	for it in ITEMS:
		if not bool(_checks.get(str(it["id"]), false)):
			remaining += 1
	return {
		"ok": true,
		"done": false,
		"remaining": remaining,
		"id": str(item.get("id", "")),
		"title": str(item.get("title", "")),
		"expect": str(item.get("expect", "")),
		"path": str(item.get("path", "")),
	}
