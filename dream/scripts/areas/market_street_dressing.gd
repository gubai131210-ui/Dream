class_name MarketStreetDressing
extends RefCounted

## Stalls, zone benches, lamps, and NPCs for A10 commercial street.
## Goods stay small and beside/behind awnings — never blocking stall fronts.

var craft: AreaCraft


func spawn_all(ysort: Node2D) -> void:
	_spawn_market_stalls(ysort)
	_spawn_zone_benches_and_props(ysort)
	_spawn_actors(ysort)


func _spawn_market_stalls(ysort: Node2D) -> void:
	# Alcove-aligned stalls; initial states spread so ≥3 C05 states visible at once.
	var stalls := [
		{
			"id": "n_w",
			"pos": Vector2(496, 416),
			"title": "蔬果摊",
			"desc": "北街西凹口蔬果摊：小货箱靠棚侧，不挡门脸。",
			"crate": "res://assets/sprites/props/B11-02_crates_boxes_06.png",
			"barrel": "res://assets/sprites/props/B11-01_barrels_03.png",
			"body": "res://assets/sprites/market/stall_open_redstripe_00.png",
			"stripe_a": Color(0.85, 0.2, 0.2, 0.92),
			"stripe_b": Color(0.95, 0.95, 0.92, 0.92),
			"state": "open",
		},
		{
			"id": "n_m",
			"pos": Vector2(752, 416),
			"title": "双联摊",
			"desc": "北街中凹口双联摊：蓝白棚。",
			"crate": "res://assets/sprites/props/B11-02_crates_boxes_00.png",
			"barrel": "res://assets/sprites/props/B11-01_barrels_00.png",
			"body": "res://assets/sprites/market/stall_open_bluestripe_00.png",
			"stripe_a": Color(0.2, 0.45, 0.85, 0.92),
			"stripe_b": Color(0.95, 0.95, 0.92, 0.92),
			"state": "locked",
		},
		{
			"id": "n_e",
			"pos": Vector2(976, 416),
			"title": "百货摊",
			"desc": "北街东凹口百货摊（售罄态只留空箱、无桶）。",
			"crate": "res://assets/sprites/props/B11-02_crates_boxes_00.png",
			"barrel": "res://assets/sprites/props/B11-01_barrels_03.png",
			"body": "res://assets/sprites/market/stall_open_cream_00.png",
			"stripe_a": Color(0.85, 0.2, 0.2, 0.92),
			"stripe_b": Color(0.95, 0.95, 0.92, 0.92),
			"state": "sold_out",
		},
		{
			"id": "s_w",
			"pos": Vector2(576, 608),
			"title": "南口蔬摊",
			"desc": "南凹口蔬摊，面向主街。",
			"crate": "res://assets/sprites/props/B11-02_crates_boxes_06.png",
			"barrel": "res://assets/sprites/props/barrel_1.png",
			"body": "res://assets/sprites/market/stall_open_green_00.png",
			"stripe_a": Color(0.2, 0.55, 0.35, 0.92),
			"stripe_b": Color(0.95, 0.95, 0.9, 0.92),
			"state": "setup",
		},
		{
			"id": "s_m",
			"pos": Vector2(832, 608),
			"title": "南口杂货",
			"desc": "南中凹口杂货摊。",
			"crate": "res://assets/sprites/props/B11-02_crates_boxes_01.png",
			"barrel": "res://assets/sprites/props/B11-01_barrels_00.png",
			"body": "res://assets/sprites/market/stall_open_patched_00.png",
			"stripe_a": Color(0.75, 0.45, 0.15, 0.92),
			"stripe_b": Color(0.95, 0.92, 0.85, 0.92),
			"state": "closed",
		},
		{
			"id": "s_e",
			"pos": Vector2(944, 608),
			"title": "灯下小摊",
			"desc": "东南凹口小摊（横酒桶 specialty）。",
			"crate": "res://assets/sprites/props/crate_1.png",
			"barrel": "res://assets/sprites/props/barrel_0.png",
			"body": "res://assets/sprites/market/stall_open_wood_00.png",
			"stripe_a": Color(0.55, 0.25, 0.65, 0.92),
			"stripe_b": Color(0.95, 0.95, 0.92, 0.92),
			"state": "empty",
		},
	]
	for s in stalls:
		var pos: Vector2 = s["pos"]
		var t := craft.world_to_tile(pos)
		if craft.is_water(t.x, t.y):
			continue
		var stall := MarketStall.spawn(ysort, pos, Vector2(96, 72), s)
		var visual: Node2D = stall.get_node("Visual")
		craft.add_contact_shadow(visual, Vector2(0, 8), Vector2(30, 10))


func _add_awning(_parent: Node2D, _color_a: Color, _color_b: Color) -> void:
	# Legacy helper removed — awnings live inside MarketStall state layers.
	pass


func _spawn_zone_benches_and_props(ysort: Node2D) -> void:
	# One bench style per zone — never mix on the same street segment.
	var samples := [
		# Stone street seats → bench_1 only (south of north stalls / street edge).
		{"path": "res://assets/sprites/props/bench_1.png", "pos": Vector2(560, 500), "title": "街市长椅", "desc": "主街长椅（街市款），面向北摊。", "on_path": true},
		{"path": "res://assets/sprites/props/bench_1.png", "pos": Vector2(720, 500), "title": "街市长椅", "desc": "主街中段长椅（街市款）。", "on_path": true},
		{"path": "res://assets/sprites/props/bench_1.png", "pos": Vector2(880, 500), "title": "街市长椅", "desc": "主街东段长椅（街市款）。", "on_path": true},
		# West river / bridge → bench_2 only.
		{"path": "res://assets/sprites/props/bench_2.png", "pos": Vector2(280, 480), "title": "河畔木凳", "desc": "桥头河畔木凳（河岸款）。", "on_path": true},
		{"path": "res://assets/sprites/props/bench_2.png", "pos": Vector2(200, 420), "title": "河畔木凳", "desc": "西岸歇脚木凳（河岸款）。", "on_path": false},
		# North shop door dirt → bench_0 only.
		{"path": "res://assets/sprites/props/bench_0.png", "pos": Vector2(448, 360), "title": "铺前条凳", "desc": "货栈门前条凳（铺前款）。", "on_path": false},
		{"path": "res://assets/sprites/props/bench_0.png", "pos": Vector2(672, 360), "title": "铺前条凳", "desc": "主铺门前条凳（铺前款）。", "on_path": false},
		# Real lamp posts only — lamp_1/lamp_2 are flower pot / planter (see MARKET_STALL_ASSET_AUDIT.md).
		{"path": "res://assets/sprites/props/lamp_0.png", "pos": Vector2(400, 464), "title": "西街灯", "desc": "商业街西段路灯。", "on_path": true},
		{"path": "res://assets/sprites/props/B11-08_pots_lamps_03.png", "pos": Vector2(1040, 464), "title": "东街灯", "desc": "商业街东段弯臂路灯。", "on_path": true},
		{"path": "res://assets/sprites/props/B11-08_pots_lamps_06.png", "pos": Vector2(640, 608), "title": "南口灯", "desc": "南土路入口铁杆路灯。", "on_path": true},
		# Decorative planter (was mislabeled as lamp_2) — not a light.
		{"path": "res://assets/sprites/props/lamp_2.png", "pos": Vector2(1080, 520), "title": "街角花箱", "desc": "东街花箱装饰（非路灯）。", "on_path": true, "scale": 0.5},
		# Loose sack off stall sightline (shop side only), scaled down.
		{"path": "res://assets/sprites/props/sack_1.png", "pos": Vector2(400, 340), "title": "货栈麻袋", "desc": "西货栈旁麻袋，不挡摊面。", "on_path": false, "scale": 0.55},
	]
	for s in samples:
		if not ResourceLoader.exists(s["path"]):
			continue
		var pos: Vector2 = s["pos"]
		if s["on_path"]:
			var t := craft.world_to_tile(pos)
			if craft.is_water(t.x, t.y):
				continue
		else:
			var cleared := craft.find_clear_near(pos, 1, 1, 6, false)
			if cleared == Vector2.ZERO:
				# Soft fallback: keep ideal if not water.
				var t2 := craft.world_to_tile(pos)
				if craft.is_water(t2.x, t2.y):
					continue
			else:
				pos = cleared
		craft.add_contact_shadow(ysort, pos, Vector2(14, 6))
		var spr := craft.spawn_sprite(ysort, s["path"], pos)
		var sc := float(s.get("scale", 0.55))
		if sc > 0.55:
			sc = 0.55
		spr.scale = Vector2(sc, sc)
		var hs := craft.make_hotspot(ysort, s["title"], s["desc"], pos, Vector2(48, 48))
		spr.reparent(hs.get_node("Visual"))
		spr.position = Vector2.ZERO

	# Bridge hotspot + plank sprite (same treatment as plaza wood bridge).
	var br_lo := 2
	var br_hi := 5
	for ty in [14, 15]:
		for tx in range(9):
			if craft.is_water(tx, ty):
				br_lo = mini(br_lo, tx)
				br_hi = maxi(br_hi, tx)
	var mid_x := int((br_lo + br_hi) * 0.5)
	var bpos := craft.tile_center(mid_x, 14)
	var hs_bridge := craft.make_hotspot(
		ysort,
		"市集桥",
		"西河短跨：石板桥面连向广场方向。",
		bpos,
		Vector2(96, 48)
	)
	craft.attach_hotspot_prop(hs_bridge, "res://assets/sprites/props/bridge_plank_00.png", 0.85)


func _spawn_actors(ysort: Node2D) -> void:
	var actors := [
		{
			"id": "merchant",
			"title": "摊主甲",
			"desc": "看守北街中凹口双联摊。",
			"waypoints": [
				Vector2(752, 430),
				Vector2(720, 448),
				Vector2(780, 448),
				Vector2(752, 430),
			],
		},
		{
			"id": "elder_woman",
			"title": "摊主乙",
			"desc": "在南凹口蔬摊与杂货之间忙碌。",
			"waypoints": [
				Vector2(576, 620),
				Vector2(700, 620),
				Vector2(832, 620),
				Vector2(700, 600),
				Vector2(576, 620),
			],
		},
		{
			"id": "farmer",
			"title": "买菜客",
			"desc": "沿石板主街逛北排摊位。",
			"waypoints": [
				Vector2(496, 480),
				Vector2(640, 500),
				Vector2(800, 480),
				Vector2(960, 500),
				Vector2(640, 480),
				Vector2(496, 480),
			],
		},
		{
			"id": "station_master",
			"title": "脚夫",
			"desc": "在货栈与东街角店之间搬货。",
			"waypoints": [
				Vector2(448, 380),
				Vector2(640, 480),
				Vector2(1080, 480),
				Vector2(640, 480),
				Vector2(448, 380),
			],
		},
		{
			"id": "blacksmith",
			"title": "闲逛村民",
			"desc": "在街市长椅与南口之间闲逛。",
			"waypoints": [
				Vector2(560, 520),
				Vector2(720, 520),
				Vector2(720, 640),
				Vector2(560, 520),
			],
		},
		{
			"id": "merchant",
			"title": "访客商贩",
			"desc": "从南土路走进商业街。",
			"waypoints": [
				Vector2(640, 820),
				Vector2(640, 700),
				Vector2(640, 560),
				Vector2(720, 500),
				Vector2(640, 700),
			],
		},
		{
			"id": "farmer",
			"title": "桥头看客",
			"desc": "在西桥与河畔木凳一带停留。",
			"waypoints": [
				Vector2(280, 480),
				Vector2(200, 450),
				Vector2(360, 480),
				Vector2(280, 480),
			],
		},
	]
	# Prefer unique looks on screen: rotate ids if duplicate titles share one.
	var used: Dictionary = {}
	for a in actors:
		var cid: String = str(a["id"])
		if used.has(cid):
			# second merchant/farmer instances OK for density; keep id
			pass
		used[cid] = true
		craft.spawn_patrol_actor(ysort, cid, a["title"], a["desc"], a["waypoints"])
