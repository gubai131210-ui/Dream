class_name FishingSession
extends CanvasLayer

## Minimal cast → wait → bite → reel → catch loop (C20).
## Click during BITE to reel; miss if the window expires.

signal finished(result: Dictionary)

enum Phase { CAST, WAIT, BITE, REEL, RESULT, MISS }

var site_id: String = "river"
var rod_id: String = FishingCatalog.ROD_BAMBOO
var spot: FishingSpot = null

var _phase: Phase = Phase.CAST
var _busy := false
var _panel: PanelContainer
var _title: Label
var _body: Label
var _progress: ProgressBar
var _btn_rod: Button
var _btn_action: Button
var _btn_close: Button
var _tween: Tween
var _caught: Dictionary = {}
var _ripple: Node2D


func _ready() -> void:
	layer = 40
	_build_ui()
	visible = true


func begin(p_spot: FishingSpot, p_site_id: String, p_rod_id: String) -> void:
	spot = p_spot
	site_id = p_site_id
	rod_id = p_rod_id
	FishingCatalog.current_rod_id = rod_id
	_busy = true
	_caught = {}
	_set_phase(Phase.CAST)
	_run_cast()


func _build_ui() -> void:
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	var dim := ColorRect.new()
	dim.color = Color(0.05, 0.08, 0.12, 0.35)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(dim)

	_panel = PanelContainer.new()
	_panel.position = Vector2(400, 220)
	_panel.custom_minimum_size = Vector2(480, 260)
	root.add_child(_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	_title = Label.new()
	_title.text = "钓鱼"
	_title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(_title)

	_body = Label.new()
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.custom_minimum_size = Vector2(440, 72)
	vbox.add_child(_body)

	_progress = ProgressBar.new()
	_progress.min_value = 0.0
	_progress.max_value = 1.0
	_progress.value = 0.0
	_progress.show_percentage = false
	_progress.custom_minimum_size = Vector2(0, 18)
	vbox.add_child(_progress)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	vbox.add_child(row)

	_btn_rod = Button.new()
	_btn_rod.text = "换竿"
	_btn_rod.pressed.connect(_on_cycle_rod)
	row.add_child(_btn_rod)

	_btn_action = Button.new()
	_btn_action.text = "收杆"
	_btn_action.pressed.connect(_on_action)
	row.add_child(_btn_action)

	_btn_close = Button.new()
	_btn_close.text = "关闭"
	_btn_close.pressed.connect(_close)
	row.add_child(_btn_close)

	_refresh_rod_button()


func _refresh_rod_button() -> void:
	var rod := FishingCatalog.rod_by_id(rod_id)
	_btn_rod.text = "竿：%s（点换）" % str(rod.get("name", "?"))


func _on_cycle_rod() -> void:
	if _phase != Phase.CAST and _phase != Phase.RESULT and _phase != Phase.MISS:
		return
	var rod := FishingCatalog.cycle_rod()
	rod_id = str(rod["id"])
	_refresh_rod_button()
	if _phase == Phase.CAST:
		_body.text = "地点：%s\n装备：%s — %s\n准备抛竿…" % [
			FishingCatalog.site_label(site_id),
			str(rod.get("name", "?")),
			str(rod.get("desc", "")),
		]


func _set_phase(p: Phase) -> void:
	_phase = p
	match p:
		Phase.CAST:
			_title.text = "抛竿"
			_btn_action.disabled = true
			_btn_rod.disabled = false
			_btn_close.disabled = false
		Phase.WAIT:
			_title.text = "等待咬钩"
			_btn_action.disabled = true
			_btn_rod.disabled = true
			_btn_close.disabled = true
		Phase.BITE:
			_title.text = "咬钩！"
			_btn_action.disabled = false
			_btn_action.text = "收杆！"
			_btn_rod.disabled = true
			_btn_close.disabled = true
		Phase.REEL:
			_title.text = "拉扯中"
			_btn_action.disabled = true
			_btn_rod.disabled = true
			_btn_close.disabled = true
		Phase.RESULT:
			_title.text = "渔获"
			_btn_action.disabled = true
			_btn_rod.disabled = false
			_btn_close.disabled = false
			_btn_close.text = "收下"
		Phase.MISS:
			_title.text = "脱钩"
			_btn_action.disabled = true
			_btn_rod.disabled = false
			_btn_close.disabled = false
			_btn_close.text = "关闭"


func _run_cast() -> void:
	var rod := FishingCatalog.rod_by_id(rod_id)
	_body.text = "地点：%s\n装备：%s\n抛竿入水…" % [
		FishingCatalog.site_label(site_id),
		str(rod.get("name", "?")),
	]
	_animate_progress(0.55)
	if spot:
		spot.play_cast_fx()
	await get_tree().create_timer(0.55).timeout
	if not is_instance_valid(self):
		return
	_run_wait()


func _run_wait() -> void:
	_set_phase(Phase.WAIT)
	var rod := FishingCatalog.rod_by_id(rod_id)
	var wait := randf_range(1.1, 2.2) * float(rod.get("wait_mul", 1.0))
	_body.text = "浮漂轻轻晃动…\n（水面有涟漪 / 泡影提示）"
	if spot:
		spot.play_wait_fx()
	_animate_progress(wait)
	await get_tree().create_timer(wait).timeout
	if not is_instance_valid(self):
		return
	_run_bite()


func _run_bite() -> void:
	_set_phase(Phase.BITE)
	_body.text = "浮漂猛沉！快点收杆！"
	if spot:
		spot.play_bite_fx()
	var window := 1.35
	_animate_progress(window)
	await get_tree().create_timer(window).timeout
	if not is_instance_valid(self):
		return
	if _phase == Phase.BITE:
		_fail_miss()


func _on_action() -> void:
	if _phase != Phase.BITE:
		return
	_run_reel()


func _run_reel() -> void:
	_set_phase(Phase.REEL)
	_body.text = "线绷紧，正在拉扯…"
	_animate_progress(0.45)
	await get_tree().create_timer(0.45).timeout
	if not is_instance_valid(self):
		return
	_caught = FishingCatalog.roll_fish(site_id, rod_id)
	_show_result()


func _fail_miss() -> void:
	_set_phase(Phase.MISS)
	_progress.value = 0.0
	_body.text = "慢了一步，鱼跑了。\n可换竿后再试。"
	if spot:
		spot.play_miss_fx()
		spot.apply_last_result({
			"ok": false,
			"site_id": site_id,
			"rod_id": rod_id,
			"fish_name": "",
		})
	finished.emit({"ok": false, "site_id": site_id, "rod_id": rod_id})


func _show_result() -> void:
	_set_phase(Phase.RESULT)
	_progress.value = 1.0
	var fish_name := str(_caught.get("name", "？"))
	var rarity := str(_caught.get("rarity", "common"))
	var rod := FishingCatalog.rod_by_id(rod_id)
	_body.text = "钓到了【%s】（%s）\n使用：%s · 地点：%s" % [
		fish_name,
		_rarity_cn(rarity),
		str(rod.get("name", "?")),
		FishingCatalog.site_label(site_id),
	]
	if spot:
		spot.play_catch_fx(_caught)
		spot.apply_last_result({
			"ok": true,
			"site_id": site_id,
			"rod_id": rod_id,
			"fish_name": fish_name,
			"fish_id": str(_caught.get("id", "")),
			"rarity": rarity,
		})
	finished.emit({
		"ok": true,
		"site_id": site_id,
		"rod_id": rod_id,
		"fish": _caught,
	})


func _rarity_cn(rarity: String) -> String:
	match rarity:
		"uncommon":
			return "少见"
		"junk":
			return "杂物"
		_:
			return "常见"


func _animate_progress(duration: float) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_progress.value = 0.0
	_tween = create_tween()
	_tween.tween_property(_progress, "value", 1.0, duration)


func _close() -> void:
	# Abort allowed on CAST / RESULT / MISS only — not mid wait/bite/reel.
	if _phase == Phase.WAIT or _phase == Phase.BITE or _phase == Phase.REEL:
		return
	if spot:
		spot.clear_session()
	queue_free()
