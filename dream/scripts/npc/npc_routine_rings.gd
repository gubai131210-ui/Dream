class_name NpcRoutineRings
extends RefCounted

## C53 work rings + C54 life states — catalog + host-scoped waypoint resolution.
## Mount via NpcRoutineDemo thin hooks (square / market / farmland). Do not rewrite assemblers.

const WORK_RING_IDS := ["sow", "smith", "stall", "fish", "cook"]
const LIFE_STATE_IDS := ["eat", "sleep", "read", "laundry", "idle_sit"]

## Host keys used by NpcRoutineDemo.attach_to(..., host_key).
const HOST_SQUARE := "square"
const HOST_MARKET := "market"
const HOST_FARMLAND := "farmland"


static func work_demo_waypoints(host_key: String = HOST_SQUARE) -> Array:
	## ≥3 occupational work loops with real outdoor anchors (no placeholder labels).
	var all := _work_catalog()
	var out: Array = []
	for ring in all:
		var pts: Array = _waypoints_for_host(ring, host_key)
		if pts.size() < 2:
			continue
		out.append({
			"id": ring["id"],
			"title": ring["title"],
			"scene": ring.get("scene", host_key),
			"hint": ring["hint"],
			"character": ring.get("character", "farmer"),
			"actor_title": ring.get("actor_title", ring["title"]),
			"actor_desc": ring.get("actor_desc", ring["hint"]),
			"waypoints": pts,
			"indoor_ref": ring.get("indoor_ref", ""),
		})
	return out


static func life_demo_states(host_key: String = HOST_SQUARE) -> Array:
	## ≥3 life states with real plaza/market anchors; C02 via_clusters documented in indoor_ref.
	var all := _life_catalog()
	var out: Array = []
	for st in all:
		var pts: Array = _waypoints_for_host(st, host_key)
		if pts.size() < 2:
			continue
		out.append({
			"id": st["id"],
			"title": st["title"],
			"hint": st["hint"],
			"character": st.get("character", "elder_woman"),
			"actor_title": st.get("actor_title", st["title"]),
			"actor_desc": st.get("actor_desc", st["hint"]),
			"waypoints": pts,
			"indoor_ref": st.get("indoor_ref", ""),
		})
	return out


static func work_ring_ids_wired(host_key: String = HOST_SQUARE) -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for r in work_demo_waypoints(host_key):
		ids.append(str(r["id"]))
	return ids


static func life_state_ids_wired(host_key: String = HOST_SQUARE) -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for s in life_demo_states(host_key):
		ids.append(str(s["id"]))
	return ids


static func _waypoints_for_host(entry: Dictionary, host_key: String) -> Array:
	var by_host: Dictionary = entry.get("waypoints_by_host", {})
	if by_host.has(host_key):
		return by_host[host_key]
	# No silent cross-host fallback — only rings wired for this host are runnable.
	return []


static func _work_catalog() -> Array:
	return [
		{
			"id": "sow",
			"title": "播种环",
			"scene": "farmland",
			"hint": "田垄往返：取种 → 垄间点播 → 回田埂",
			"character": "farmer",
			"actor_title": "播种农",
			"actor_desc": "沿田垄播种，再回到田埂整理种子袋。",
			"indoor_ref": "",
			"waypoints_by_host": {
				# Plaza south edge toward farm portal — sow loop readable without leaving square.
				HOST_SQUARE: [
					Vector2(560, 700), Vector2(720, 700), Vector2(720, 760),
					Vector2(560, 760), Vector2(560, 700),
				],
				HOST_FARMLAND: [
					Vector2(640, 480), Vector2(800, 420), Vector2(640, 560),
					Vector2(480, 420), Vector2(640, 480),
				],
				# Market south alcove dirt pocket — “苗床/货前土袋”短环.
				HOST_MARKET: [
					Vector2(900, 620), Vector2(1000, 620), Vector2(1000, 700),
					Vector2(900, 700), Vector2(900, 620),
				],
			},
		},
		{
			"id": "smith",
			"title": "打铁环",
			"scene": "c04_smith",
			"hint": "炉前取料 → 砧上锻打 → 淬火桶 → 候坐交件",
			"character": "blacksmith",
			"actor_title": "铁匠",
			"actor_desc": "在铁匠铺门前取料、锻打示意点与交件位之间走动。",
			"indoor_ref": "c04_smith actor via forge / anvil_quench / wait",
			"waypoints_by_host": {
				# East plaza toward market / smith district approach.
				HOST_SQUARE: [
					Vector2(980, 460), Vector2(1100, 460), Vector2(1100, 540),
					Vector2(980, 540), Vector2(980, 460),
				],
				# Door-feet of market smith shop (~896, 296 + door offset).
				HOST_MARKET: [
					Vector2(860, 340), Vector2(920, 340), Vector2(920, 400),
					Vector2(860, 400), Vector2(860, 340),
				],
			},
		},
		{
			"id": "stall",
			"title": "摆货环",
			"scene": "market",
			"hint": "货箱 → 摊面摆货 → 回看价签",
			"character": "merchant",
			"actor_title": "摊主",
			"actor_desc": "在摊位货箱与摊面之间摆货、整理价签。",
			"indoor_ref": "",
			"waypoints_by_host": {
				# East plaza crate / stall props (~780,430).
				HOST_SQUARE: [
					Vector2(720, 430), Vector2(800, 430), Vector2(800, 500),
					Vector2(720, 500), Vector2(720, 430),
				],
				# North mid stall alcove (market_street_dressing merchant loop).
				HOST_MARKET: [
					Vector2(752, 430), Vector2(720, 448), Vector2(780, 448),
					Vector2(752, 430),
				],
			},
		},
		{
			"id": "cook",
			"title": "烹饪环",
			"scene": "c01_home",
			"hint": "灶台取水 → 炉前备餐 → 回灶",
			"character": "farmer",
			"actor_title": "厨务",
			"actor_desc": "在灶台示意点与备餐桌之间忙碌（对应室内厨房/饭桌生活锚）。",
			"indoor_ref": "c01_home via kitchen / hearth_talk",
			"waypoints_by_host": {
				# West plaza near residential approach — cook/home errand loop.
				HOST_SQUARE: [
					Vector2(420, 500), Vector2(500, 500), Vector2(500, 580),
					Vector2(420, 580), Vector2(420, 500),
				],
				# Near tavern east wing — street cook / tavern kitchen errand.
				HOST_MARKET: [
					Vector2(1040, 440), Vector2(1120, 440), Vector2(1120, 520),
					Vector2(1040, 520), Vector2(1040, 440),
				],
			},
		},
	]


static func _life_catalog() -> Array:
	return [
		{
			"id": "eat",
			"title": "用餐",
			"hint": "饭桌/餐点短环 — 对应 C02 农家宅 dining / 主角宅 hearth_talk",
			"character": "farmer",
			"actor_title": "用餐村民",
			"actor_desc": "在餐点示意位坐下用餐，再起身整理碗筷。",
			"indoor_ref": "c02_farmer via dining; c01_home via hearth_talk",
			"waypoints_by_host": {
				HOST_SQUARE: [
					Vector2(600, 500), Vector2(640, 520), Vector2(600, 540),
					Vector2(600, 500),
				],
				HOST_MARKET: [
					Vector2(640, 500), Vector2(700, 500), Vector2(700, 560),
					Vector2(640, 560), Vector2(640, 500),
				],
				HOST_FARMLAND: [
					Vector2(560, 460), Vector2(720, 460), Vector2(720, 540),
					Vector2(560, 540), Vector2(560, 460),
				],
			},
		},
		{
			"id": "sleep",
			"title": "睡眠",
			"hint": "宅前歇息短环 — 对应 C02 sleep 簇",
			"character": "elder_woman",
			"actor_title": "歇息村民",
			"actor_desc": "走向宅前歇息位，短暂驻足后再回廊檐。",
			"indoor_ref": "c02_elder / c02_farmer / c01_home via sleep",
			"waypoints_by_host": {
				HOST_SQUARE: [
					Vector2(1080, 520), Vector2(1140, 520), Vector2(1140, 580),
					Vector2(1080, 580), Vector2(1080, 520),
				],
				HOST_MARKET: [
					Vector2(280, 480), Vector2(200, 450), Vector2(360, 480),
					Vector2(280, 480),
				],
				HOST_FARMLAND: [
					Vector2(200, 280), Vector2(400, 280), Vector2(400, 360),
					Vector2(200, 360), Vector2(200, 280),
				],
			},
		},
		{
			"id": "read",
			"title": "阅读",
			"hint": "长椅/灯下阅读 — 对应 C02 老人宅 tea（摇椅）",
			"character": "elder_woman",
			"actor_title": "阅读村民",
			"actor_desc": "在长椅与井边之间缓步，坐下阅读片刻。",
			"indoor_ref": "c02_elder via tea (rocking)",
			"waypoints_by_host": {
				HOST_SQUARE: [
					Vector2(560, 540), Vector2(600, 520), Vector2(560, 560),
					Vector2(560, 540),
				],
				HOST_MARKET: [
					Vector2(576, 620), Vector2(700, 620), Vector2(700, 600),
					Vector2(576, 620),
				],
				HOST_FARMLAND: [
					Vector2(480, 600), Vector2(560, 600), Vector2(560, 680),
					Vector2(480, 680), Vector2(480, 600),
				],
			},
		},
		{
			"id": "laundry",
			"title": "洗衣",
			"hint": "井边取水 → 晾衣示意 — 对应宅院 line / clothesline",
			"character": "farmer",
			"actor_title": "洗衣村民",
			"actor_desc": "在井边取水与晾衣示意点之间往返。",
			"indoor_ref": "c49 yard via line (clothesline); C02 life demo outdoor stand-in",
			"waypoints_by_host": {
				HOST_SQUARE: [
					Vector2(640, 500), Vector2(500, 430), Vector2(560, 540),
					Vector2(640, 500),
				],
				HOST_MARKET: [
					Vector2(480, 500), Vector2(560, 520), Vector2(480, 560),
					Vector2(480, 500),
				],
				HOST_FARMLAND: [
					Vector2(640, 560), Vector2(720, 560), Vector2(720, 640),
					Vector2(640, 640), Vector2(640, 560),
				],
			},
		},
		{
			"id": "idle_sit",
			"title": "闲坐",
			"hint": "长椅闲坐 — 对应 C02 tea / 候坐凳位",
			"character": "elder_woman",
			"actor_title": "闲坐村民",
			"actor_desc": "在长椅两端来回，大部分时间驻足闲坐。",
			"indoor_ref": "c02_elder via tea; c04_smith wait stools",
			"waypoints_by_host": {
				HOST_SQUARE: [
					Vector2(540, 540), Vector2(580, 540), Vector2(540, 540),
				],
				HOST_MARKET: [
					Vector2(560, 520), Vector2(720, 520), Vector2(560, 520),
				],
				HOST_FARMLAND: [
					Vector2(600, 500), Vector2(680, 500), Vector2(600, 500),
				],
			},
		},
	]
