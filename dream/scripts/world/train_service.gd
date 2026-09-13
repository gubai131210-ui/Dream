extends Node

## Autoload: scarce train services, tickets, dwell/depart, destination hops.
## Research: docs/research/TRAIN_SERVICE_RESEARCH.md

signal state_changed(service_id: String, state: int)
signal ticket_changed(service_id: String, seats_left: int)
signal boarded(service_id: String)
signal arrived(service_id: String, dest_path: String)

enum State { ABSENT, APPROACHING, DOCKED, DEPARTING, EN_ROUTE }

const SAVE_META := "train_service_v1"

## Real-time cadence while station (or any host) is running.
const APPROACH_SEC := 4.0
const DEPART_ANIM_SEC := 5.0
const RIDE_SEC := 6.5

var _services: Dictionary = {}
var _state: int = State.ABSENT
var _active_id: String = ""
var _state_t := 0.0
var _cooldown_t := 5.0
var _held_ticket: String = ""
var _day_key: String = ""
var _seats_sold: Dictionary = {}
var _pending_dest: String = ""
var _ride_host: Node = null
## Sticky env snapshot from last outdoor DayNightWeather (C11/C36 have no env node).
var _cached_night := false
var _cached_bad_weather := false


func _ready() -> void:
	_services = {
		"local_hill": {
			"title": "村线慢车",
			"desc": "开往坡田的日常慢车。班次最多，但仍要趁停站买票。",
			"dest_path": SceneRouter.HILL_FARM_PATH,
			"dest_title": "坡田",
			"dwell": 42.0,
			"cooldown": 55.0,
			"seats": 3,
			"need_night": false,
			"need_clear": false,
			"weight": 3.0,
		},
		"lake_coast": {
			"title": "湖岸线",
			"desc": "开往湖区。雨雾停开——车票更难撞上。",
			"dest_path": SceneRouter.LAKE_PATH,
			"dest_title": "湖区",
			"dwell": 38.0,
			"cooldown": 90.0,
			"seats": 2,
			"need_night": false,
			"need_clear": true,
			"weight": 1.4,
		},
		"night_express": {
			"title": "夜行慢车",
			"desc": "仅夜间开往灯塔。站长每天只肯放一张票。",
			"dest_path": SceneRouter.LIGHTHOUSE_PATH,
			"dest_title": "灯塔",
			"dwell": 48.0,
			"cooldown": 120.0,
			"seats": 1,
			"need_night": true,
			"need_clear": false,
			"weight": 0.8,
		},
	}
	_roll_day_bucket()


func _process(delta: float) -> void:
	_refresh_env_cache()
	_state_t += delta
	match _state:
		State.ABSENT:
			_cooldown_t -= delta
			if _cooldown_t <= 0.0:
				_try_spawn_service()
		State.APPROACHING:
			if _state_t >= APPROACH_SEC:
				_set_state(State.DOCKED)
		State.DOCKED:
			var dwell := float(_services.get(_active_id, {}).get("dwell", 40.0))
			if _state_t >= dwell:
				_begin_depart()
		State.DEPARTING:
			if _state_t >= DEPART_ANIM_SEC:
				if _ride_host != null and is_instance_valid(_ride_host) and not _held_ticket.is_empty() and _held_ticket == _active_id:
					_set_state(State.EN_ROUTE)
				else:
					_finish_absent()
		State.EN_ROUTE:
			if _state_t >= RIDE_SEC:
				_finish_arrival()


func get_state() -> int:
	return _state


func get_active_id() -> String:
	return _active_id


func get_active_service() -> Dictionary:
	if _active_id.is_empty():
		return {}
	return _services.get(_active_id, {})


func get_held_ticket() -> String:
	return _held_ticket


func has_ticket_for_active() -> bool:
	return not _held_ticket.is_empty() and _held_ticket == _active_id


func seats_left(service_id: String = "") -> int:
	var sid := service_id if not service_id.is_empty() else _active_id
	if sid.is_empty() or not _services.has(sid):
		return 0
	var cap := int(_services[sid].get("seats", 0))
	var sold := int(_seats_sold.get(_day_seat_key(sid), 0))
	return maxi(0, cap - sold)


func timetable_text() -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("【本站行车牌】")
	match _state:
		State.ABSENT:
			lines.append("站台空 · 下一班约 %.0f 秒后接近" % maxf(0.0, _cooldown_t))
		State.APPROACHING:
			lines.append("进站中 · %s" % str(get_active_service().get("title", "")))
		State.DOCKED:
			lines.append("停靠中 · %s → %s" % [
				str(get_active_service().get("title", "")),
				str(get_active_service().get("dest_title", "")),
			])
			lines.append("余票 %d · 停站剩余 %.0f 秒" % [
				seats_left(),
				maxf(0.0, float(get_active_service().get("dwell", 40.0)) - _state_t),
			])
		State.DEPARTING:
			lines.append("发车中 · 门已关")
		State.EN_ROUTE:
			lines.append("车已开出 · 窗外景色掠过…")
	lines.append("")
	for sid in _services.keys():
		var s: Dictionary = _services[sid]
		var gate := _gate_label(s)
		lines.append("%s → %s | 今日余座 %d %s" % [
			str(s.get("title", sid)),
			str(s.get("dest_title", "?")),
			seats_left(sid),
			gate,
		])
	if not _held_ticket.is_empty() and _services.has(_held_ticket):
		lines.append("")
		lines.append("你持有：%s 车票" % str(_services[_held_ticket].get("title", _held_ticket)))
	else:
		lines.append("")
		lines.append("你未持票 · 售票窗只在停靠时开放")
	# Spine D soft sink — no hard lock on boarding.
	lines.append("")
	lines.append("闲话：深林遗迹的苔树脂可做灯饰/家具（soft gate，不挡上车）。")
	return "\n".join(lines)


func try_buy_ticket_from_booth() -> Dictionary:
	## Call when player interacts with ticket booth / station master during dwell.
	if _state != State.DOCKED:
		return {"ok": false, "msg": "火车未停靠。班次很少，得等汽笛再来。"}
	if _active_id.is_empty():
		return {"ok": false, "msg": "没有可售车次。"}
	if not _held_ticket.is_empty():
		return {"ok": false, "msg": "你已经有一张车票了（本站规矩：一次一程）。"}
	if seats_left() <= 0:
		return {"ok": false, "msg": "这班票售罄了。站长摇头：明日再碰运气。"}
	var s := get_active_service()
	if not _gates_ok(s):
		return {"ok": false, "msg": "本班因天气/时段停售。"}
	_held_ticket = _active_id
	var key := _day_seat_key(_active_id)
	_seats_sold[key] = int(_seats_sold.get(key, 0)) + 1
	ticket_changed.emit(_active_id, seats_left())
	return {
		"ok": true,
		"msg": "买到「%s」→ %s。余座 %d。快上车，停站不等人。" % [
			str(s.get("title", "")),
			str(s.get("dest_title", "")),
			seats_left(),
		],
	}


func try_favor_ticket() -> Dictionary:
	## Station master soft unlock: if no ticket and docked with seats, 40% night / 25% day.
	if _state != State.DOCKED or seats_left() <= 0:
		return {"ok": false, "msg": "站长忙着挥旗，没空递人情票。"}
	if not _held_ticket.is_empty():
		return {"ok": false, "msg": "你已经有票了。"}
	var night := _is_night_now()
	var chance := 0.4 if night else 0.22
	if randf() > chance:
		return {"ok": false, "msg": "站长只剩摇头：「今天人情票也紧。」"}
	return try_buy_ticket_from_booth()


func can_board_car() -> bool:
	return _state == State.DOCKED and has_ticket_for_active()


func board_hint() -> String:
	if _state == State.ABSENT:
		return "轨道空着。等汽笛吧——本站车次本来就少。"
	if _state == State.APPROACHING:
		return "火车正在进站。先去售票窗碰碰运气。"
	if _state == State.DOCKED:
		if has_ticket_for_active():
			return "车门开着。持票可进入车厢，停站结束会发车。"
		if seats_left() > 0:
			return "车门虚掩。没票只能看看——去售票窗或求站长。"
		return "车门边挤满人，这班票已罄。"
	if _state == State.DEPARTING:
		return "汽笛响了，门已关。错过就等下一班稀缺车次。"
	return "车在途中。"


func notify_player_entered_car(host: Node) -> void:
	_ride_host = host
	if _state == State.DOCKED and has_ticket_for_active():
		boarded.emit(_active_id)


func request_early_depart() -> void:
	if _state == State.DOCKED:
		_begin_depart()


func force_demo_service(service_id: String = "local_hill") -> void:
	## Debug / QA helper.
	if not _services.has(service_id):
		return
	_active_id = service_id
	_cooldown_t = 9999.0
	_set_state(State.APPROACHING)


func _try_spawn_service() -> void:
	_roll_day_bucket()
	var candidates: Array[String] = []
	var weights: Array[float] = []
	for sid in _services.keys():
		var s: Dictionary = _services[sid]
		if not _gates_ok(s):
			continue
		if seats_left(sid) <= 0:
			continue
		candidates.append(sid)
		weights.append(float(s.get("weight", 1.0)))
	if candidates.is_empty():
		_cooldown_t = 25.0
		return
	var pick := _weighted_pick(candidates, weights)
	_active_id = pick
	_set_state(State.APPROACHING)


func _begin_depart() -> void:
	_pending_dest = str(get_active_service().get("dest_path", ""))
	_set_state(State.DEPARTING)


func _finish_absent() -> void:
	var cd := float(get_active_service().get("cooldown", 60.0))
	# Missed boarding: void unused ticket so the player is not soft-locked.
	if not _held_ticket.is_empty() and _state != State.EN_ROUTE:
		_held_ticket = ""
	_active_id = ""
	_pending_dest = ""
	_ride_host = null
	_cooldown_t = cd
	_set_state(State.ABSENT)


func _finish_arrival() -> void:
	var dest := _pending_dest
	var sid := _active_id
	_held_ticket = ""
	arrived.emit(sid, dest)
	_finish_absent()
	if dest.is_empty():
		return
	var tree := get_tree()
	if tree:
		SceneRouter.change_to(tree, dest)


func _set_state(next: int) -> void:
	_state = next
	_state_t = 0.0
	state_changed.emit(_active_id, _state)


func _gates_ok(s: Dictionary) -> bool:
	var need_night := bool(s.get("need_night", false))
	var need_clear := bool(s.get("need_clear", false))
	var night := _is_night_now()
	if need_night and not night:
		return false
	if not need_night and night:
		# Day services never run at night (村线 + 湖岸线).
		return false
	if need_clear and _is_bad_weather_now():
		return false
	return true


func _gate_label(s: Dictionary) -> String:
	if bool(s.get("need_night", false)):
		return "[仅夜]"
	if bool(s.get("need_clear", false)):
		return "[晴开]"
	return "[日班]"


func _refresh_env_cache() -> void:
	var scene := get_tree().current_scene if get_tree() else null
	var env := DayNightWeather.find_on(scene) if scene else null
	if env == null:
		return
	_cached_night = env.is_night()
	_cached_bad_weather = env.weather != DayNightWeather.WeatherKind.CLEAR


func _is_night_now() -> bool:
	var scene := get_tree().current_scene if get_tree() else null
	var env := DayNightWeather.find_on(scene) if scene else null
	if env:
		_cached_night = env.is_night()
		return _cached_night
	# Prefer last outdoor snapshot over wall-clock (C11/C36 have no DayNightWeather).
	return _cached_night


func _is_bad_weather_now() -> bool:
	var scene := get_tree().current_scene if get_tree() else null
	var env := DayNightWeather.find_on(scene) if scene else null
	if env:
		_cached_bad_weather = env.weather != DayNightWeather.WeatherKind.CLEAR
		return _cached_bad_weather
	return _cached_bad_weather


func _roll_day_bucket() -> void:
	var d := Time.get_date_dict_from_system()
	_day_key = "%04d-%02d-%02d" % [int(d.get("year", 0)), int(d.get("month", 0)), int(d.get("day", 0))]


func _day_seat_key(sid: String) -> String:
	return "%s|%s" % [_day_key, sid]


func _weighted_pick(ids: Array[String], weights: Array[float]) -> String:
	var total := 0.0
	for w in weights:
		total += w
	var r := randf() * total
	var acc := 0.0
	for i in ids.size():
		acc += weights[i]
		if r <= acc:
			return ids[i]
	return ids[ids.size() - 1]
