class_name InteriorProfiles
extends RefCounted

## Room profiles — functional clusters per INTERIOR_COMPOSITION.md.
## Specialty props under assets/sprites/interior/props/; floors via floor= plank|straw|stone|dark.

const PROP := 0.9
const DIR_INTERIOR_PROP := "res://assets/sprites/interior/props"
const DIR_OUTDOOR_PROP := "res://assets/sprites/props"

const P_FIREPLACE := DIR_INTERIOR_PROP + "/fireplace_00.png"
const P_FORGE := DIR_INTERIOR_PROP + "/forge_00.png"
const P_ANVIL := DIR_INTERIOR_PROP + "/anvil_00.png"
const P_STOVE := DIR_INTERIOR_PROP + "/stove_00.png"
const P_SHELF := DIR_INTERIOR_PROP + "/shelf_00.png"
const P_SHELF_GROCERY := DIR_INTERIOR_PROP + "/shelf_grocery_00.png"
const P_COUNTER := DIR_INTERIOR_PROP + "/counter_00.png"
const P_BAR := DIR_INTERIOR_PROP + "/bar_00.png"
const P_TABLE_R := DIR_INTERIOR_PROP + "/table_round_00.png"
const P_TABLE_DINING := DIR_INTERIOR_PROP + "/table_dining_00.png"
const P_MEETING_TABLE := DIR_INTERIOR_PROP + "/meeting_table_00.png"
const P_STOOL := DIR_INTERIOR_PROP + "/stool_00.png"
const P_STOOL_TEA := DIR_INTERIOR_PROP + "/stool_tea_00.png"
const P_STOOL_BAR := DIR_INTERIOR_PROP + "/stool_bar_00.png"
const P_HAY := DIR_INTERIOR_PROP + "/hay_00.png"
const P_HAY_STACK := DIR_INTERIOR_PROP + "/hay_stack_00.png"
const P_TROUGH := DIR_INTERIOR_PROP + "/trough_00.png"
const P_NEST := DIR_INTERIOR_PROP + "/nest_00.png"
const P_TOOL_RACK := DIR_INTERIOR_PROP + "/tool_rack_00.png"
const P_DRESSER := DIR_INTERIOR_PROP + "/dresser_00.png"
const P_MEDICINE := DIR_INTERIOR_PROP + "/medicine_00.png"
const P_LEDGER := DIR_INTERIOR_PROP + "/ledger_00.png"
const P_BASKET := DIR_INTERIOR_PROP + "/basket_00.png"
const P_NOTICE := DIR_INTERIOR_PROP + "/notice_00.png"
const P_CIVIC_BOARD := DIR_INTERIOR_PROP + "/civic_board_00.png"
const P_TIMETABLE := DIR_INTERIOR_PROP + "/timetable_00.png"
const P_FARE_BOARD := DIR_INTERIOR_PROP + "/fare_board_00.png"
const P_CLINIC_FEE_BOARD := DIR_INTERIOR_PROP + "/clinic_fee_board_00.png"
const P_EXHIBIT_GUIDE := DIR_INTERIOR_PROP + "/exhibit_guide_00.png"
const P_BATH_RULES := DIR_INTERIOR_PROP + "/bath_rules_00.png"
const P_INN_RATE_BOARD := DIR_INTERIOR_PROP + "/inn_rate_board_00.png"
const P_CARGO_MANIFEST := DIR_INTERIOR_PROP + "/cargo_manifest_00.png"
const P_SHOP_PRICE_BOARD := DIR_INTERIOR_PROP + "/shop_price_board_00.png"
const P_HOUSE_RULES := DIR_INTERIOR_PROP + "/house_rules_00.png"
const P_MINE_SAFETY := DIR_INTERIOR_PROP + "/mine_safety_00.png"
const P_CATALOG_CARD := DIR_INTERIOR_PROP + "/catalog_card_00.png"
const P_TRAIL_MARKER := DIR_INTERIOR_PROP + "/trail_marker_00.png"
const P_PIPE_SCHEMATIC := DIR_INTERIOR_PROP + "/pipe_schematic_00.png"
const P_CIPHER_PLAQUE := DIR_INTERIOR_PROP + "/cipher_plaque_00.png"
const P_SHIFT_BOARD := DIR_INTERIOR_PROP + "/shift_board_00.png"
const P_NIGHT_MARKET_BOARD := DIR_INTERIOR_PROP + "/night_market_board_00.png"
const P_CHARM_LIST := DIR_INTERIOR_PROP + "/charm_list_00.png"
const P_DONATION_BOARD := DIR_INTERIOR_PROP + "/donation_board_00.png"
const P_FERRY_SCHEDULE := DIR_INTERIOR_PROP + "/ferry_schedule_00.png"
const P_RUIN_STELE := DIR_INTERIOR_PROP + "/ruin_stele_00.png"
const P_BARK_GLYPH := DIR_INTERIOR_PROP + "/bark_glyph_00.png"
const P_MUG_SHELF := DIR_INTERIOR_PROP + "/mug_shelf_00.png"
const P_ROOST := DIR_INTERIOR_PROP + "/roost_00.png"
const P_COIN := DIR_INTERIOR_PROP + "/coin_chest_00.png"
const P_HERBS := DIR_INTERIOR_PROP + "/herbs_00.png"
const P_BED_S := DIR_INTERIOR_PROP + "/bed_single_00.png"
const P_BED_D := DIR_INTERIOR_PROP + "/bed_double_00.png"
const P_ROCKING := DIR_INTERIOR_PROP + "/rocking_00.png"
const P_STALL_RAIL := DIR_INTERIOR_PROP + "/stall_rail_00.png"
const P_STALL_RAIL_V := DIR_INTERIOR_PROP + "/stall_rail_v_00.png"
const P_PEN_FENCE := DIR_INTERIOR_PROP + "/pen_fence_00.png"
const P_PEN_FENCE_V := DIR_INTERIOR_PROP + "/pen_fence_v_00.png"
const P_PEN_CORNER_NW := DIR_INTERIOR_PROP + "/pen_corner_nw_00.png"
const P_PEN_CORNER_NE := DIR_INTERIOR_PROP + "/pen_corner_ne_00.png"
const P_PEN_CORNER_SW := DIR_INTERIOR_PROP + "/pen_corner_sw_00.png"
const P_PEN_CORNER_SE := DIR_INTERIOR_PROP + "/pen_corner_se_00.png"
const P_GRAIN_STACK := DIR_INTERIOR_PROP + "/grain_stack_00.png"
const P_PEW := DIR_INTERIOR_PROP + "/pew_00.png"
const P_MILLSTONE := DIR_INTERIOR_PROP + "/millstone_00.png"
const P_MILL_GEAR := DIR_INTERIOR_PROP + "/mill_gear_00.png"
const P_CHEESE_PRESS := DIR_INTERIOR_PROP + "/cheese_press_00.png"
const P_CHEESE_AGING := DIR_INTERIOR_PROP + "/cheese_aging_00.png"
const P_PICKLE_CROCK := DIR_INTERIOR_PROP + "/pickle_crock_00.png"
const P_WINE_RACK := DIR_INTERIOR_PROP + "/wine_rack_00.png"
const P_BREW_VAT := DIR_INTERIOR_PROP + "/brew_vat_00.png"
const P_BEEHIVE := DIR_INTERIOR_PROP + "/beehive_00.png"
const P_FLOWER_BED := DIR_INTERIOR_PROP + "/flower_bed_00.png"
const P_DOGHOUSE := DIR_INTERIOR_PROP + "/doghouse_00.png"
const P_CLOTHESLINE := DIR_INTERIOR_PROP + "/clothesline_00.png"
const P_CHIMNEY := DIR_INTERIOR_PROP + "/chimney_00.png"
const P_TELESCOPE := DIR_INTERIOR_PROP + "/telescope_00.png"
const P_WOOD_PILE := DIR_INTERIOR_PROP + "/wood_pile_00.png"
const P_FRUIT_PRESS := DIR_INTERIOR_PROP + "/fruit_press_00.png"
const P_FRUIT_CRATE_STACK := DIR_INTERIOR_PROP + "/fruit_crate_stack_00.png"
const P_HANDCART := DIR_INTERIOR_PROP + "/handcart_00.png"
const P_BALCONY_RAIL := DIR_INTERIOR_PROP + "/balcony_rail_00.png"
const P_TRUNK_OLD := DIR_INTERIOR_PROP + "/trunk_old_00.png"
const P_COBWEB := DIR_INTERIOR_PROP + "/cobweb_00.png"
const P_CRAFT_BENCH := DIR_INTERIOR_PROP + "/craft_bench_00.png"
const P_LANTERN_STRING := DIR_INTERIOR_PROP + "/lantern_string_00.png"
const P_RARE_CRATE := DIR_INTERIOR_PROP + "/rare_crate_00.png"
const P_HEADSTONE_0 := DIR_INTERIOR_PROP + "/headstone_00.png"
const P_HEADSTONE_1 := DIR_INTERIOR_PROP + "/headstone_01.png"
const P_CRYPT_DOOR := DIR_INTERIOR_PROP + "/crypt_door_00.png"
# Wave F CivicTour signature props (C40–C45)
const P_EXHIBIT_CASE := DIR_INTERIOR_PROP + "/exhibit_case_00.png"
const P_FISH_TANK := DIR_INTERIOR_PROP + "/fish_tank_00.png"
const P_SOAK_POOL := DIR_INTERIOR_PROP + "/soak_pool_00.png"
const P_BATH_POOL := DIR_INTERIOR_PROP + "/bath_pool_00.png"
const P_INN_DESK := DIR_INTERIOR_PROP + "/inn_desk_00.png"
const P_SECRET_CURTAIN := DIR_INTERIOR_PROP + "/secret_curtain_00.png"
# Wave F TransitDive signature props (C34–C36, C23)
const P_DOCK_PILE_FISH := DIR_INTERIOR_PROP + "/dock_pile_fish_00.png"
const P_DOCK_PILE_TRADE := DIR_INTERIOR_PROP + "/dock_pile_trade_00.png"
const P_WRECK_HULL := DIR_INTERIOR_PROP + "/wreck_hull_00.png"
const P_SEAWEED := DIR_INTERIOR_PROP + "/seaweed_00.png"
const P_SUNKEN_WOOD := DIR_INTERIOR_PROP + "/sunken_wood_00.png"
const P_TRAIN_SEAT_ROW := DIR_INTERIOR_PROP + "/train_seat_row_00.png"
const P_ROCK0 := DIR_OUTDOOR_PROP + "/rock_00.png"
const P_ROCK1 := DIR_OUTDOOR_PROP + "/rock_01.png"
const P_ROCK2 := DIR_OUTDOOR_PROP + "/rock_02.png"
const P_ROCK3 := DIR_OUTDOOR_PROP + "/rock_03.png"
const P_ROD_BAMBOO := "res://assets/sprites/fishing/rod_bamboo_00.png"
const P_BARREL := DIR_OUTDOOR_PROP + "/barrel_1.png"
const P_BARREL_KEG := DIR_OUTDOOR_PROP + "/barrel_0.png"
const P_CRATE0 := DIR_OUTDOOR_PROP + "/crate_0.png"
const P_CRATE1 := DIR_OUTDOOR_PROP + "/crate_1.png"
const P_SACK0 := DIR_OUTDOOR_PROP + "/sack_0.png"
const P_SACK1 := DIR_OUTDOOR_PROP + "/sack_1.png"
const P_LAMP_INDOOR := DIR_INTERIOR_PROP + "/lamp_indoor_00.png"
const P_LAMP_FARM := DIR_INTERIOR_PROP + "/lamp_farm_00.png"
const P_LAMP_SHOP := DIR_INTERIOR_PROP + "/lamp_shop_00.png"
const P_LAMP_SMITH := DIR_INTERIOR_PROP + "/lamp_smith_00.png"
const P_LAMP_TAVERN := DIR_INTERIOR_PROP + "/lamp_tavern_00.png"
const P_STALL_CORNER_NW := DIR_INTERIOR_PROP + "/stall_corner_nw_00.png"
const P_STALL_CORNER_NE := DIR_INTERIOR_PROP + "/stall_corner_ne_00.png"
const P_STALL_CORNER_SW := DIR_INTERIOR_PROP + "/stall_corner_sw_00.png"
const P_STALL_CORNER_SE := DIR_INTERIOR_PROP + "/stall_corner_se_00.png"
# Semantic signature props (replace dining/counter/hay/barrel proxies)
const P_ALTAR := DIR_INTERIOR_PROP + "/altar_00.png"
const P_SCRIPTURE_PLAQUE := DIR_INTERIOR_PROP + "/scripture_plaque_00.png"
const P_WAITING_BENCH := DIR_INTERIOR_PROP + "/waiting_bench_00.png"
const P_BLACKBOARD := DIR_INTERIOR_PROP + "/blackboard_00.png"
const P_SCHOOL_DESK := DIR_INTERIOR_PROP + "/school_desk_00.png"
const P_LECTERN := DIR_INTERIOR_PROP + "/lectern_00.png"
const P_SEWER_PIPE := DIR_INTERIOR_PROP + "/sewer_pipe_00.png"
const P_REED_CLUMP := DIR_INTERIOR_PROP + "/reed_clump_00.png"
const P_ROOT_TABLE := DIR_INTERIOR_PROP + "/root_table_00.png"
const P_PEG_LADDER := DIR_INTERIOR_PROP + "/peg_ladder_00.png"
const P_ROOT_MASS := DIR_INTERIOR_PROP + "/root_mass_00.png"

const RES := "res://scenes/areas/village_residential/village_residential.tscn"
const FARM := "res://scenes/areas/farm_residential/farm_residential.tscn"
const MKT := "res://scenes/areas/market_street/market_street.tscn"
const SQ := "res://scenes/areas/village_square/village_square.tscn"
const STN := "res://scenes/areas/station/station.tscn"
const FLD := "res://scenes/areas/farmland/farmland.tscn"
const LAKE := "res://scenes/areas/lake/lake.tscn"
const RIV := "res://scenes/areas/river/river.tscn"
const FDEEP := "res://scenes/areas/forest_deep/forest_deep.tscn"
const HILL := "res://scenes/areas/hill_farm/hill_farm.tscn"


static func get_profile(profile_id: String) -> Dictionary:
	var all := _all()
	if all.has(profile_id):
		return all[profile_id]
	push_warning("InteriorProfiles: unknown '%s', fallback c01_home" % profile_id)
	return all["c01_home"]


static func _m(
	path: String,
	dx: int,
	dy: int,
	title: String,
	desc: String,
	scale: float = PROP,
	open_fx: String = "",
) -> Dictionary:
	var d := {"path": path, "dx": dx, "dy": dy, "scale": scale, "title": title, "desc": desc}
	if not open_fx.is_empty():
		d["open_fx"] = open_fx
	return d


static func _cluster(id: String, ax: int, ay: int, members: Array) -> Dictionary:
	return {"id": id, "anchor": [ax, ay], "members": members}


static func _all() -> Dictionary:
	return {
		# ── C01 主角宅：西厨工作三角 · 北壁炉起居 · 东睡区 · 中轴通廊 ──
		"c01_home": {
			"title": "主角住宅",
			"hint": "主角宅 · 壁炉起居 / 厨房 / 床区",
			"return_path": RES,
			"room_w": 34,
			"room_h": 22,
			"door_tx0": 15,
			"door_tx1": 18,
			"floor": "plank",
			"modulate": Color(0.86, 0.80, 0.72, 1.0),
			# Rug under hearth_talk (west of door corridor 15–18).
			"rug": {"ox": 10, "oy": 8},
			"window": true,
			"clusters": [
				_cluster("kitchen", 5, 7, [
					_m(P_STOVE, 0, 0, "灶台", "西厨灶台（工作三角锚）。", 0.95),
					_m(P_SHELF, -2, 0, "厨架", "调料碗碟贴灶。", 0.9),
					_m(P_SHELF, -2, 2, "储物架", "灶下储物（体量）。", 0.85),
					_m(P_HERBS, 2, -1, "干草药", "灶旁北墙晾挂。", 0.8),
					_m(P_BARREL, 1, 2, "水桶", "灶前取水（三角第三点）。", PROP),
					_m(P_SACK0, 2, 2, "米袋", "厨角存粮小袋。", 0.75),
				]),
				# West of door axis so south→north 2-tile corridor stays clear.
				_cluster("hearth_talk", 11, 6, [
					_m(P_FIREPLACE, 0, -1, "壁炉", "北墙起居壁炉（偏西，让出中轴通廊）。", 1.0),
					_m(P_TABLE_DINING, 0, 2, "饭桌", "炉前用餐/闲谈桌（cozy_dining 成套）。", 0.95),
					_m(P_STOOL, -2, 2, "凳", "桌西矮凳（同 sheet）。", 0.85),
					_m(P_STOOL, 2, 2, "凳", "桌东矮凳（同 sheet；东侧留站位）。", 0.85),
					_m(P_STOOL, 0, 3, "凳", "桌南矮凳（同 sheet；南站位可交互）。", 0.85),
				]),
				_cluster("sleep", 28, 13, [
					_m(P_BED_D, 0, 1, "双人床", "东南私密睡区。", 1.05),
					_m(P_DRESSER, 0, -2, "衣柜", "床头北墙衣柜。", 0.95),
					_m(P_LAMP_INDOOR, 1, -3, "壁灯", "床区壁灯。", PROP),
				]),
			],
			"fx": [{"kind": "fire", "tx": 11, "ty": 5, "oy": -18}],
			"ambient": [{"species": "cat", "cluster": "hearth_talk", "dx": 3, "dy": 1}],
			"lights": [
				{"tx": 5, "ty": 7, "oy": -12, "color": Color(1.0, 0.75, 0.45), "energy": 0.7, "scale": 1.6},
				{"tx": 29, "ty": 10, "oy": -16, "color": Color(1.0, 0.88, 0.6), "energy": 0.9, "scale": 2.0},
			],
			"actor": {
				"id": "farmer",
				"title": "屋主",
				"desc": "在厨房与壁炉间忙碌。",
				"via_clusters": ["kitchen", "hearth_talk", "sleep"],
				"via_stands": {
					"kitchen": [2, 1],
					"hearth_talk": [0, 4],
					"sleep": [0, 3],
				},
			},
			# Wave A2 Well + Wave E SecondFloor: thin stair portals (no layout polish).
			"extra_portals": [
				{
					"tx": 3,
					"ty": 16,
					"label": "↓地下室",
					"path": SceneRouter.C15_BASEMENT_PATH,
				},
				{
					"tx": 30,
					"ty": 16,
					"label": "↑二楼",
					"path": SceneRouter.C46_SECOND_FLOOR_PATH,
				},
			],
		},
		# ── C02 老人宅：极简茶区 + 床区（药箱贴床） ──
		"c02_elder": {
			"title": "老人宅",
			"hint": "老人宅 · 安静茶区，少杂物",
			"return_path": RES,
			"room_w": 26,
			"room_h": 16,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "plank",
			"modulate": Color(0.78, 0.78, 0.76, 1.0),
			"rug": {"ox": 7, "oy": 7},
			"window": true,
			"clusters": [
				_cluster("tea", 8, 6, [
					_m(P_ROCKING, -1, 0, "摇椅", "窗边摇椅（交谈锚）。", 0.65),
					_m(P_TABLE_R, 1, 1, "茶几", "膝前小圆茶几（cozy_tea 成套）。", 0.55),
					_m(P_STOOL_TEA, 2, 2, "矮凳", "茶几配套矮凳（同 sheet）。", 0.7),
					_m(P_HERBS, -3, -2, "干花", "茶区旁干花。", 0.45),
				]),
				_cluster("sleep", 20, 10, [
					_m(P_BED_S, 0, 1, "单人床", "东墙私密床。", 0.65),
					_m(P_MEDICINE, 0, -2, "药箱", "床头药箱。", 0.6),
					_m(P_LAMP_INDOOR, -1, -1, "台灯", "床头柔和灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 19, "ty": 7, "oy": -14, "color": Color(1.0, 0.9, 0.7), "energy": 0.85, "scale": 1.8},
			],
			"actor": {
				"id": "elder_woman",
				"title": "老妇人",
				# C54 life: tea=read/idle_sit, sleep=sleep (NpcRing additive stands).
				"desc": "在摇椅阅读闲坐，再到床区歇息。",
				"via_clusters": ["tea", "sleep"],
				"via_stands": {
					"tea": [0, 2],  # read / idle_sit stand south of rocking
					"sleep": [2, 1],
				},
			},
		},
		# ── C02 农家宅：门厅工具粮袋 · 中餐 · 东睡 ──
		"c02_farmer": {
			"title": "农家宅",
			"hint": "农家宅 · 门厅粮袋与工具墙",
			"return_path": RES,
			"room_w": 31,
			"room_h": 19,
			"door_tx0": 13,
			"door_tx1": 16,
			"floor": "plank",
			"modulate": Color(0.88, 0.82, 0.68, 1.0),
			# Rug under dining (west of door corridor 13–16).
			"rug": {"ox": 9, "oy": 8},
			"window": true,
			"clusters": [
				_cluster("mudroom", 5, 13, [
					_m(P_TOOL_RACK, 0, -2, "工具架", "门厅西墙锄镰架。", 0.95),
					_m(P_GRAIN_STACK, 2, 0, "粮垛", "门厅存粮垛（体量锚）。", 0.75),
					_m(P_SACK0, 3, 1, "粮袋", "贴垛粮袋。", PROP),
					_m(P_SACK1, 2, 2, "种子袋", "贴粮袋种子。", 0.85),
					_m(P_BARREL, 1, 2, "水桶", "门厅取水。", PROP),
				]),
				# Off door axis — stools keep 1-tile approach; mid corridor clear.
				_cluster("dining", 10, 7, [
					_m(P_TABLE_DINING, 0, 0, "饭桌", "农家大饭桌（cozy_dining）。", 0.95),
					_m(P_STOOL, -2, 1, "凳", "饭桌西凳（同 sheet）。", 0.85),
					_m(P_STOOL, 2, 1, "凳", "饭桌东凳（同 sheet；东站位可坐）。", 0.85),
					_m(P_STOOL, 0, 2, "凳", "饭桌南凳（同 sheet）。", 0.85),
				]),
				_cluster("sleep", 24, 12, [
					_m(P_BED_D, 0, 1, "床铺", "夫妻床。", 1.0),
					_m(P_CRATE1, 0, -2, "工具箱", "床头备用农具箱。", PROP),
					_m(P_LAMP_INDOOR, 1, -3, "壁灯", "暖黄壁灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [{"species": "dog", "cluster": "mudroom", "dx": 2, "dy": -2}],
			"lights": [
				{"tx": 25, "ty": 7, "oy": -16, "color": Color(1.0, 0.82, 0.48), "energy": 1.05, "scale": 2.0},
			],
			"actor": {
				"id": "farmer",
				"title": "农夫",
				# C54 life: dining=eat, sleep=sleep; mudroom=入户整理 (NpcRing additive).
				"desc": "整理门厅粮袋后坐饭桌用餐，再到东房歇息。",
				"via_clusters": ["mudroom", "dining", "sleep"],
				"via_stands": {
					"mudroom": [0, -1],
					"dining": [0, 3],  # eat stand south of dining table
					"sleep": [0, 3],
				},
			},
		},
		# ── C02 商贾宅：账桌工作角 · 货箱仓 · 后室床 ──
		"c02_merchant": {
			"title": "商贾宅",
			"hint": "商贾宅 · 账桌与货箱半仓",
			"return_path": RES,
			"room_w": 32,
			"room_h": 17,
			"door_tx0": 13,
			"door_tx1": 16,
			"floor": "plank",
			"modulate": Color(0.80, 0.78, 0.84, 1.0),
			"rug": {"ox": 9, "oy": 7},
			"window": true,
			"clusters": [
				_cluster("ledger", 10, 6, [
					_m(P_LEDGER, 0, 0, "账桌", "北侧账簿桌。", 0.65),
					_m(P_LAMP_INDOOR, 2, -1, "台灯", "账桌灯。", PROP),
					_m(P_COIN, -2, 1, "钱箱", "账桌旁钱箱。", 0.55),
					_m(P_CARGO_MANIFEST, -3, -1, "货单", "壁挂货单（非 notice 代理）。", 0.5),
				]),
				_cluster("cargo", 25, 7, [
					_m(P_CRATE0, 0, -2, "货箱", "东墙货箱底垛。", PROP),
					_m(P_CRATE1, 1, -3, "货箱", "叠高精品箱。", 0.85),
					_m(P_CRATE0, 2, -1, "货箱", "侧垛货箱。", PROP),
					_m(P_CRATE1, 0, 0, "货箱", "中层待发。", 0.9),
					_m(P_CRATE0, 2, 1, "货箱", "前脚货箱。", 0.85),
					_m(P_CRATE1, 0, 2, "货箱", "底层待发。", PROP),
					_m(P_SHELF, 3, -2, "货架", "样品货架。", 0.5),
				]),
				_cluster("sleep", 22, 13, [
					_m(P_BED_S, 0, 0, "卧榻", "后室单人床（远离营业账桌）。", 0.65),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 12, "ty": 5, "oy": -14, "color": Color(0.95, 0.92, 0.75), "energy": 1.0, "scale": 1.9},
			],
			"actor": {
				"id": "merchant",
				"title": "商人",
				"desc": "清点账本与货箱。",
				"via_clusters": ["ledger", "cargo"],
				"via_stands": {"ledger": [0, 2], "cargo": [-2, 1]},
			},
		},
		# ── C02 铁匠宅：家用工具角 · 厚桌起居 · 床（非工坊） ──
		"c02_blacksmith_home": {
			"title": "铁匠宅",
			"hint": "铁匠宅 · 家用工具与淬火桶（非工坊）",
			"return_path": RES,
			"room_w": 28,
			"room_h": 17,
			"door_tx0": 12,
			"door_tx1": 15,
			"floor": "plank",
			"modulate": Color(0.74, 0.72, 0.70, 1.0),
			# Rug under living (west of door corridor 12–15).
			"rug": {"ox": 7, "oy": 8},
			"window": true,
			"clusters": [
				_cluster("home_tools", 5, 7, [
					_m(P_TOOL_RACK, -1, -2, "家用工具架", "下班带回的锤钳。", 0.9),
					_m(P_ANVIL, 0, 1, "小砧", "家用小砧（非铺内锻炉）。", 0.75),
					_m(P_BARREL, 2, 2, "淬火桶", "贴砧淬火水桶。", PROP),
				]),
				# Shift west so table/stools leave door axis open.
				_cluster("living", 9, 8, [
					_m(P_TABLE_DINING, 0, 0, "厚桌", "耐用木桌（cozy_dining）。", 0.95),
					_m(P_STOOL, -2, 1, "凳", "桌旁凳（同 sheet）。", 0.85),
					_m(P_STOOL, 2, 1, "凳", "桌旁凳（同 sheet；东站位）。", 0.85),
				]),
				_cluster("sleep", 21, 11, [
					_m(P_BED_S, 0, 1, "床铺", "铁匠床铺。", 1.0),
					_m(P_CRATE1, 1, -2, "零件箱", "床头铁钉零件。", PROP),
					_m(P_LAMP_INDOOR, 0, -3, "壁灯", "偏橙暖灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 21, "ty": 6, "oy": -14, "color": Color(1.0, 0.7, 0.42), "energy": 1.1, "scale": 1.9},
			],
			"actor": {
				"id": "blacksmith",
				"title": "铁匠",
				"desc": "回家收拾工具再坐桌边。",
				"via_clusters": ["home_tools", "living", "sleep"],
				"via_stands": {
					"home_tools": [0, 3],
					"living": [0, 2],
					"sleep": [0, 3],
				},
			},
		},
		# ── C03 谷仓：西栏 · 东栏 · 中央饲料过道 ──
		"c03_barn": {
			"title": "谷仓内部",
			"hint": "谷仓 · 中央通道 + 两侧畜栏隔栏 + 北粮垛",
			"return_path": FARM,
			"room_w": 36,
			"room_h": 22,
			"door_tx0": 16,
			"door_tx1": 19,
			"floor": "straw",
			"modulate": Color(0.82, 0.76, 0.62, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("stall_w", 6, 8, [
					_m(P_HAY_STACK, -1, -2, "干草垛", "西栏后墙高草垛。", 0.75),
					_m(P_HAY, 0, 1, "干草捆", "西栏脚边草捆。", 0.65),
					_m(P_TROUGH, 2, 0, "食槽", "朝过道的西食槽。", 0.65),
				]),
				_cluster("stall_e", 29, 8, [
					_m(P_HAY_STACK, 1, -2, "干草垛", "东栏后墙高草垛。", 0.75),
					_m(P_TROUGH, -2, 1, "水槽", "朝过道的东饮水槽。", 0.65),
					_m(P_CRATE0, 1, 2, "农具箱", "东角农具。", PROP),
					_m(P_TOOL_RACK, 2, -2, "耙叉架", "墙上农具。", 0.55),
				]),
				# Feed mass at aisle north; sacks beside aisle (dx±3) so mid band 16–19 stays walkable.
				_cluster("aisle_feed", 18, 4, [
					_m(P_GRAIN_STACK, 0, 0, "粮垛", "北端存粮高垛（体量锚）。", 0.85),
					_m(P_SACK0, -3, 1, "饲料袋", "过道西侧饲料（不占中轴）。", PROP),
					_m(P_SACK1, 3, 1, "饲料袋", "过道东侧饲料（不占中轴）。", PROP),
					_m(P_BARREL, 3, 2, "水桶", "北端备用饮水。", PROP),
					_m(P_LAMP_FARM, 1, 0, "仓灯", "过道铁壳油灯（农场灯，非家用台灯）。", PROP),
				]),
			],
			# Stall pens as enclosures (corners + rails); aisle-facing gaps for trough access.
			"enclosures": [
				{
					"rect": [4, 5, 11, 16],
					"prop_h": P_STALL_RAIL,
					"prop_v": P_STALL_RAIL_V,
					"corners": {
						"nw": P_STALL_CORNER_NW,
						"ne": P_STALL_CORNER_NE,
						"sw": P_STALL_CORNER_SW,
						"se": P_STALL_CORNER_SE,
					},
					"scale": 1.0,
					"title": "西畜栏",
					"desc": "西 stall 密板条围合（同套正/侧/角）。",
					"gaps": [[11, 7], [11, 8], [11, 9], [11, 10]],
				},
				{
					"rect": [24, 5, 31, 16],
					"prop_h": P_STALL_RAIL,
					"prop_v": P_STALL_RAIL_V,
					"corners": {
						"nw": P_STALL_CORNER_NW,
						"ne": P_STALL_CORNER_NE,
						"sw": P_STALL_CORNER_SW,
						"se": P_STALL_CORNER_SE,
					},
					"scale": 1.0,
					"title": "东畜栏",
					"desc": "东 stall 密板条围合（同套正/侧/角）。",
					"gaps": [[24, 7], [24, 8], [24, 9], [24, 10]],
				},
			],
			"rails": [],
			"fx": [],
			"ambient": [
				{"species": "sheep", "cluster": "stall_w", "dx": 1, "dy": 1},
				{"species": "cow", "cluster": "stall_e", "dx": -1, "dy": 1},
			],
			"lights": [
				{"tx": 18, "ty": 3, "oy": -8, "color": Color(1.0, 0.82, 0.5), "energy": 1.05, "scale": 3.2},
			],
			"actor": {
				"id": "farmer",
				"title": "仓管",
				"desc": "沿畜栏与饲料过道巡视。",
				"via_clusters": ["stall_w", "aisle_feed", "stall_e"],
				"via_stands": {"stall_w": [3, 0], "aisle_feed": [0, 3], "stall_e": [-3, 0]},
			},
		},
		# ── C03 鸡舍：整间几乎都是笔区，南门开缺口 ──
		"c03_coop": {
			"title": "鸡舍内部",
			"hint": "鸡舍 · 满间鸡栏：巢箱 / 食槽 / 栖木",
			"return_path": FARM,
			"room_w": 24,
			"room_h": 16,
			"door_tx0": 10,
			"door_tx1": 13,
			"floor": "straw",
			"modulate": Color(0.84, 0.80, 0.70, 1.0),
			"rug": null,
			"window": true,
			"clusters": [
				# Nest stack |d|≤2; leave x+1 clear for egg-collect approach.
				_cluster("nests", 4, 6, [
					_m(P_NEST, 0, -2, "巢箱", "西墙产蛋巢。", 0.7),
					_m(P_NEST, 0, -1, "巢箱", "上层巢箱。", 0.7),
					_m(P_NEST, 0, 1, "巢箱", "中层巢箱。", 0.65),
					_m(P_NEST, 0, 2, "巢箱", "下层巢箱。", 0.65),
				]),
				_cluster("feed", 7, 6, [
					_m(P_TROUGH, 0, 0, "食槽", "笔内西侧食槽（让出中轴通廊）。", 0.6),
					_m(P_SACK0, 2, 1, "鸡食", "贴槽鸡食袋。", PROP),
					_m(P_SACK1, -1, 1, "鸡食", "西侧鸡食袋。", 0.85),
					_m(P_BARREL, 2, 2, "水桶", "贴食饮水桶。", PROP),
					_m(P_LAMP_FARM, 0, -2, "栏灯", "鸡舍铁壳油灯（农场灯，非家用台灯）。", PROP),
				]),
				_cluster("roost", 19, 5, [
					_m(P_ROOST, 0, 0, "栖木", "东侧栖木。", 0.75),
					_m(P_HAY, -1, 1, "垫草", "栖木旁垫草。", 0.55),
					_m(P_ROOST, 1, 2, "栖木", "东南栖木。", 0.65),
				]),
			],
			# Pen fills almost the whole room; only 1-tile wall margin + south gate.
			"enclosures": [
				{
					"rect": [1, 2, 22, 13],
					"prop_h": P_PEN_FENCE,
					"prop_v": P_PEN_FENCE_V,
					"corners": {
						"nw": P_PEN_CORNER_NW,
						"ne": P_PEN_CORNER_NE,
						"sw": P_PEN_CORNER_SW,
						"se": P_PEN_CORNER_SE,
					},
					"scale": 1.0,
					"title": "鸡栏",
					"desc": "密板条鸡栏：正视/侧视同套，四角专用转角。",
					"gaps": [[10, 13], [11, 13], [12, 13], [13, 13]],
				},
			],
			"fx": [],
			"ambient": [
				{"species": "chicken", "cluster": "feed", "dx": -1, "dy": 1},
				{"species": "chicken", "cluster": "nests", "dx": 1, "dy": 0},
				{"species": "chicken", "cluster": "roost", "dx": -1, "dy": 1},
				{"species": "chicken", "cluster": "feed", "dx": 1, "dy": 2},
			],
			"lights": [
				{"tx": 7, "ty": 4, "oy": -10, "color": Color(1.0, 0.92, 0.7), "energy": 0.85, "scale": 1.8},
			],
			"actor": {
				"id": "farmer",
				"title": "饲鸡人",
				"desc": "检查巢箱与食槽。",
				"via_clusters": ["nests", "feed", "roost"],
				"via_stands": {"nests": [2, 0], "feed": [0, 2], "roost": [-2, 1]},
			},
		},
		# ── C04 杂货：西架 · 东架 · 南柜（筐贴柜，店主北） ──
		"c04_grocery": {
			"title": "杂货店",
			"hint": "杂货店 · 两侧货架 + 南向柜台",
			"return_path": MKT,
			"room_w": 29,
			"room_h": 19,
			"door_tx0": 13,
			"door_tx1": 16,
			"floor": "plank",
			"modulate": Color(0.90, 0.88, 0.82, 1.0),
			# Rug under customer stop south of counter.
			"rug": {"ox": 13, "oy": 10},
			"window": true,
			"clusters": [
				# Aisle anchors so patrol stands are off shelf sprites.
				_cluster("shelf_w", 6, 6, [
					_m(P_SHELF_GROCERY, -2, -1, "西货架", "日杂货架。", 1.0),
					_m(P_SHELF, -2, 1, "西货架", "罐装货架。", 0.95),
					_m(P_SHELF, -2, 3, "西货架", "下层货架（体量）。", 0.9),
					_m(P_BARREL, 0, 1, "油桶", "西架脚油桶。", PROP),
					_m(P_CRATE0, 0, 3, "货箱", "架脚存货箱。", 0.8),
				]),
				_cluster("shelf_e", 23, 6, [
					_m(P_SHELF_GROCERY, 2, -1, "东货架", "干货架。", 1.0),
					_m(P_SHELF, 2, 1, "东货架", "盐糖架。", 0.95),
					_m(P_GRAIN_STACK, 0, 1, "米垛", "东架脚米粮垛（体量）。", 0.7),
					_m(P_SACK0, -1, 2, "米袋", "贴垛米袋。", PROP),
					_m(P_SACK1, 1, 2, "糖袋", "贴垛糖袋。", 0.85),
				]),
				# Staff at anchor; counter face south; baskets staff/sides only (no dy≥2 south).
				_cluster("counter", 14, 7, [
					_m(P_COUNTER, 0, 1, "柜台", "南向收银台（顾客在南、店主在北）。", 1.05),
					_m(P_BASKET, -3, 0, "菜筐", "柜西侧蔬果筐（不挡顾客中轴）。", 0.85),
					_m(P_BASKET, 3, 0, "菜筐", "柜东侧根茎筐。", 0.85),
					_m(P_BASKET, -2, -1, "果筐", "柜后店主侧果筐。", 0.8),
					_m(P_SHOP_PRICE_BOARD, 2, -1, "告示板", "柜上价目（非 notice 代理）。", 0.85),
					_m(P_LAMP_SHOP, 1, -2, "店灯", "柜台吊罩店灯（非家用台灯）。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 15, "ty": 5, "oy": -12, "color": Color(1.0, 0.94, 0.75), "energy": 1.15, "scale": 2.5},
			],
			"actor": {
				"id": "merchant",
				"title": "店主",
				"desc": "在柜台后招呼，偶尔巡架。",
				"via_clusters": ["counter", "shelf_w", "shelf_e"],
				"via_stands": {"counter": [0, 0], "shelf_w": [0, 2], "shelf_e": [0, 2]},
			},
		},
		# ── C04 铁匠铺：北炉 · 砧+淬火 · 南候坐 ──
		"c04_smith": {
			"title": "铁匠铺",
			"hint": "铁匠铺 · 北炉 / 西砧 / 南候坐",
			"return_path": MKT,
			"room_w": 28,
			"room_h": 18,
			"door_tx0": 12,
			"door_tx1": 15,
			"floor": "stone",
			"modulate": Color(0.68, 0.64, 0.62, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("forge", 7, 4, [
					_m(P_FORGE, 0, 0, "锻炉", "北侧锻炉。", 1.05),
					_m(P_TOOL_RACK, -2, 1, "工具墙", "炉旁锤钳挂架。", 0.95),
				]),
				# Keep quench mass west of door band 12–15; satellites |d|≤3.
				_cluster("anvil_quench", 8, 9, [
					_m(P_ANVIL, 0, 0, "铁砧", "炉下锻打砧。", 0.95),
					_m(P_BARREL, 2, 1, "淬火桶", "贴砧淬火。", PROP),
					_m(P_CRATE1, 2, -1, "成品箱", "砧旁待售铁器。", PROP),
					_m(P_CRATE0, 3, 1, "废料箱", "贴成品废料。", PROP),
					_m(P_CRATE0, 3, 2, "废料箱", "叠放废铁（体量）。", 0.8),
					_m(P_LAMP_SMITH, 1, -2, "工坊壁灯", "锻工铁壁灯（非家用台灯）。", PROP),
				]),
				# East of corridor — stools approach from west aisle without blocking door.
				_cluster("wait", 20, 12, [
					_m(P_WAITING_BENCH, 0, 0, "候坐", "顾客等候长椅（非饭桌代理）。", 0.9),
					_m(P_STOOL, -2, 1, "凳", "候坐西凳（同 sheet；西站位）。", 0.85),
					_m(P_STOOL, 2, 1, "凳", "候坐东凳（同 sheet）。", 0.85),
				]),
			],
			"fx": [{"kind": "forge", "tx": 7, "ty": 5, "oy": -10}],
			"ambient": [],
			"lights": [
				{"tx": 9, "ty": 7, "oy": -12, "color": Color(1.0, 0.7, 0.4), "energy": 0.7, "scale": 1.8},
			],
			"actor": {
				"id": "blacksmith",
				"title": "铁匠",
				"desc": "在炉、砧与淬火桶间走动。",
				"via_clusters": ["forge", "anvil_quench", "wait"],
				"via_stands": {"forge": [2, 1], "anvil_quench": [0, 2], "wait": [0, 2]},
			},
		},
		# ── C04 酒馆：西吧 · 双雅座 · 东壁炉 ──
		"c04_tavern": {
			"title": "酒馆",
			"hint": "酒馆 · 西吧台酒桶 + 座席 + 壁炉",
			"return_path": MKT,
			"room_w": 34,
			"room_h": 20,
			"door_tx0": 15,
			"door_tx1": 18,
			"floor": "dark",
			"modulate": Color(0.70, 0.62, 0.54, 1.0),
			# Rug under party_a talk zone (west of door corridor 15–18).
			"rug": {"ox": 11, "oy": 9},
			"window": true,
			"clusters": [
				_cluster("bar", 5, 8, [
					_m(P_BAR, 1, 0, "吧台", "西侧长吧台。", 0.75),
					_m(P_BARREL_KEG, -1, 1, "酒桶", "吧后横放取酒桶。", 0.6),
					_m(P_BARREL, -1, 3, "存酒", "吧后竖放存酒。", PROP),
					_m(P_BARREL, -2, 2, "存酒", "吧后叠放酒桶（体量）。", 0.85),
					_m(P_MUG_SHELF, 0, -3, "杯架", "吧上墙杯架。", 0.6),
					_m(P_LAMP_TAVERN, 2, -3, "酒馆烛灯", "吧台烛灯（非家用台灯）。", PROP),
					_m(P_STOOL_BAR, 3, 1, "吧凳", "吧前高凳（同家族木色；东站位）。", 0.8),
					_m(P_STOOL_BAR, 3, 2, "吧凳", "吧前高凳（同家族木色）。", 0.8),
				]),
				# Between bar and corridor — not on door axis.
				_cluster("party_a", 12, 7, [
					_m(P_TABLE_R, 0, 0, "圆桌", "西侧雅座（cozy_tea）。", 0.7),
					_m(P_STOOL_TEA, -2, 1, "矮凳", "围桌配套凳。", 0.75),
					_m(P_STOOL_TEA, 2, 1, "矮凳", "围桌配套凳（东站位，不堵通廊）。", 0.75),
					_m(P_STOOL_TEA, 0, 2, "矮凳", "南侧围桌凳。", 0.75),
					_m(P_LAMP_TAVERN, -2, -2, "座席烛灯", "雅座烛灯。", 0.75),
					_m(P_HOUSE_RULES, -3, -2, "告示", "座席旁规矩牌（非 notice 代理）。", 0.5),
				]),
				# East of corridor; satellites pulled tight (|d|≤2).
				_cluster("party_b", 22, 7, [
					_m(P_TABLE_R, 0, 0, "圆桌", "东侧雅座（cozy_tea）。", 0.7),
					_m(P_STOOL_TEA, -1, 1, "矮凳", "邻桌配套凳。", 0.75),
					_m(P_STOOL_TEA, 2, 1, "矮凳", "邻桌配套凳。", 0.75),
					_m(P_CRATE0, 2, 0, "酒箱", "邻桌旁酒箱。", 0.7),
				]),
				_cluster("hearth", 28, 6, [
					_m(P_FIREPLACE, 0, 0, "壁炉", "东墙壁炉。", 0.7),
					_m(P_STOOL, -2, 2, "凳", "炉前烤火矮凳（同家族；西站位）。", 0.8),
					_m(P_CRATE0, 2, 1, "酒窖箱", "炉旁存货。", PROP),
					_m(P_CRATE1, 2, 2, "酒窖箱", "叠放酒窖箱（体量）。", 0.8),
				]),
			],
			"fx": [{"kind": "fire", "tx": 28, "ty": 6, "oy": -16}],
			"ambient": [],
			"lights": [
				{"tx": 7, "ty": 5, "oy": -12, "color": Color(1.0, 0.7, 0.4), "energy": 1.0, "scale": 2.2},
				{"tx": 12, "ty": 7, "oy": -6, "color": Color(1.0, 0.78, 0.5), "energy": 0.55, "scale": 1.8},
			],
			"actor": {
				"id": "merchant",
				"title": "酒保",
				"desc": "在吧台与座席间穿梭。",
				"via_clusters": ["bar", "party_a", "party_b", "hearth"],
				"via_stands": {"bar": [0, 0], "party_a": [0, 3], "party_b": [0, 2], "hearth": [-2, 1]},
			},
			# Wave F: thin upstairs portal (no tavern layout polish).
			"extra_portals": [
				{
					"tx": 30,
					"ty": 16,
					"label": "↑二楼",
					"path": SceneRouter.C45_TAVERN_UP_PATH,
				},
			],
		},
		# ── Wave A2 stubs (teams enrich; do not polish C01–C04) ──
		"c12_lighthouse": {
			"title": "灯塔内部",
			"hint": "灯塔 · 底层储物 / 中层楼梯 / 顶层灯室",
			"return_path": "res://scenes/areas/lighthouse/lighthouse.tscn",
			"room_w": 18,
			"room_h": 22,
			"door_tx0": 7,
			"door_tx1": 10,
			"floor": "stone",
			"modulate": Color(0.72, 0.74, 0.78, 1.0),
			"rug": null,
			"window": true,
			"clusters": [
				_cluster("gear", 5, 8, [
					_m(P_CRATE0, 0, 0, "补给箱", "灯塔底层补给。", PROP),
					_m(P_BARREL, 2, 1, "油桶", "灯油桶。", PROP),
					_m(P_TOOL_RACK, 0, -2, "工具架", "检修工具。", 0.7),
				]),
				_cluster("lamp_room", 12, 6, [
					_m(P_LAMP_FARM, 0, 0, "航标灯", "顶层航标灯具。", PROP),
					_m(P_CRATE1, 2, 2, "零件箱", "灯室零件。", 0.75),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 12, "ty": 5, "oy": -10, "color": Color(1.0, 0.95, 0.7), "energy": 1.2, "scale": 2.4},
			],
			"actor": {},
		},
		# ── C14 井底：积水池 · 井壁龛 · 隐藏缝 ──
		"c14_well": {
			"title": "井底",
			"hint": "井底 · 潮湿石室 · 返回住宅区",
			"return_path": RES,
			"room_w": 16,
			"room_h": 14,
			"door_tx0": 6,
			"door_tx1": 9,
			"floor": "stone",
			"modulate": Color(0.55, 0.62, 0.68, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("pool", 8, 7, [
					_m(P_BARREL, 0, 0, "水桶", "井底积水旁水桶。", PROP),
					_m(P_CRATE0, 2, 1, "沉箱", "半湿木箱。", 0.7),
					_m(P_SACK0, -2, 1, "湿袋", "潮湿麻袋。", 0.6),
				]),
				_cluster("ledge", 4, 4, [
					_m(P_CRATE1, 0, 0, "石龛箱", "嵌在井壁龛里的干箱。", 0.65),
					_m(P_LAMP_FARM, 1, -1, "井灯", "井壁提灯，幽蓝反光。", PROP),
					_m(P_BASKET, 2, 1, "吊篮", "上下井用的绳篮。", 0.7),
				]),
				_cluster("secret_mark", 12, 5, [
					_m(P_COIN, 0, 0, "湿石缝", "石缝里隐约有物，似可探入。", 0.55),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 8, "ty": 4, "oy": -8, "color": Color(0.7, 0.85, 1.0), "energy": 0.75, "scale": 2.1},
				{"tx": 4, "ty": 3, "oy": -10, "color": Color(0.65, 0.8, 1.0), "energy": 0.55, "scale": 1.5},
			],
			"actor": {},
		},
		# ── C15 地下室：储物 · 酒窖 · 梯脚（返回 C01）──
		"c15_basement": {
			"title": "地下室",
			"hint": "地下室 · 储藏 / 返回楼梯",
			"return_path": SceneRouter.C01_HOME_PATH,
			"room_w": 20,
			"room_h": 14,
			"door_tx0": 8,
			"door_tx1": 11,
			"floor": "stone",
			"modulate": Color(0.62, 0.58, 0.52, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("stores", 6, 6, [
					_m(P_SHELF, 0, 0, "储物架", "地下室货架。", 0.85),
					_m(P_CRATE0, 2, 2, "木箱", "存货箱。", PROP),
					_m(P_CRATE1, 3, 1, "木箱", "叠放木箱。", 0.8),
					_m(P_SACK0, -2, 2, "粮袋", "地窖粮袋。", PROP),
					_m(P_LAMP_INDOOR, 1, -2, "壁灯", "地窖灯。", PROP),
				]),
				_cluster("cellar", 15, 6, [
					_m(P_BARREL_KEG, 0, 0, "酒桶", "地窖横置酒桶。", PROP),
					_m(P_BARREL, 2, 1, "腌桶", "咸菜/腌货桶。", PROP),
					_m(P_MUG_SHELF, -1, -1, "瓶架", "贴墙瓶罐架。", 0.8),
					_m(P_SACK1, 1, 2, "干货袋", "地窖干货。", 0.7),
				]),
				_cluster("stair", 10, 11, [
					_m(P_CRATE0, 0, 0, "梯脚箱", "楼梯脚杂箱（返回南门）。", 0.7),
					_m(P_LAMP_INDOOR, -2, -1, "梯灯", "照亮返回楼梯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 7, "ty": 4, "oy": -10, "color": Color(1.0, 0.85, 0.55), "energy": 0.8, "scale": 1.8},
				{"tx": 15, "ty": 5, "oy": -8, "color": Color(1.0, 0.78, 0.45), "energy": 0.65, "scale": 1.6},
			],
			"actor": {},
		},
		# ── C17 矿洞入口层：西凿岩面 · 中轴通廊 · 东矿石堆 · 北支架箱 ──
		# Corridor: door tiles 12–15 stay clear south→north (≥2 tile aisle).
		"c17_mine": {
			"title": "矿洞入口",
			"hint": "矿洞 · 入口层可挖",
			"return_path": "res://scenes/areas/hill_farm/hill_farm.tscn",
			"room_w": 28,
			"room_h": 18,
			"door_tx0": 12,
			"door_tx1": 15,
			"floor": "stone",
			"modulate": Color(0.50, 0.48, 0.46, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				# West dig face (rocks as dig hotspots; tools/lamp satellites).
				_cluster("dig", 5, 7, [
					_m(DIR_OUTDOOR_PROP + "/rock_02.png", 0, 0, "可挖岩面", "入口西壁凿痕岩面，可交互试挖。", 0.75),
					_m(DIR_OUTDOOR_PROP + "/rock_00.png", -1, 1, "矿脉凿口", "浅层矿脉露出点。", 0.65),
					_m(DIR_OUTDOOR_PROP + "/rock_03.png", 1, 2, "碎石堆", "刚凿下的碎石。", 0.55),
					_m(P_TOOL_RACK, 2, 0, "镐架", "入口采矿工具架。", 0.7),
					_m(P_LAMP_SMITH, 1, -2, "矿灯", "钉在支架旁的矿用油灯。", PROP),
					_m(P_BARREL, 2, 2, "爆破桶", "慎放的爆破药桶。", PROP),
					_m(P_CRATE0, 3, 1, "矿车箱", "贴镐架的入料木箱。", 0.8),
				]),
				# East ore staging — approach from corridor west of crates.
				_cluster("ore", 21, 8, [
					_m(P_CRATE0, 0, 0, "矿石箱", "待运粗矿石箱。", PROP),
					_m(P_CRATE1, 2, 1, "矿石堆箱", "叠放矿石箱。", 0.85),
					_m(P_SACK1, -1, 2, "矿粉袋", "碎矿粉袋。", 0.7),
					_m(P_SACK0, 1, 2, "矿砂袋", "筛后矿砂。", 0.65),
					_m(P_BASKET, -2, 1, "拾矿筐", "手拣矿样筐。", 0.75),
					_m(P_LAMP_FARM, 0, -2, "货区灯", "矿石堆区矿灯。", PROP),
				]),
				# North timber / support staging (west of door axis).
				_cluster("timber", 8, 4, [
					_m(P_CRATE1, 0, 0, "支架木箱", "洞木与支柱备用箱。", 0.8),
					_m(P_BARREL, 2, 0, "水桶", "入口冲洗泥尘用。", PROP),
					_m(DIR_OUTDOOR_PROP + "/rock_01.png", -2, 1, "可挖岩壁", "北壁浅层可挖点。", 0.6),
					_m(P_MINE_SAFETY, 1, -1, "矿洞告示", "入口层安全告示（非 notice 代理）。", 0.7),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 6, "ty": 5, "oy": -10, "color": Color(1.0, 0.72, 0.35), "energy": 1.0, "scale": 2.2},
				{"tx": 21, "ty": 6, "oy": -8, "color": Color(1.0, 0.8, 0.45), "energy": 0.85, "scale": 1.8},
			],
			"actor": {
				"id": "farmer",
				"title": "矿工",
				"desc": "在凿岩面与矿石堆之间来回。",
				"via_clusters": ["dig", "timber", "ore"],
				"via_stands": {"dig": [3, 1], "timber": [0, 2], "ore": [-2, 1]},
			},
		},
		# ── C26 瀑后洞窟：水幕入口 · 遗迹宝箱 · 湿储（门轴 10–13 让出中廊）──
		"c26_waterfall_cave": {
			"title": "瀑后洞窟",
			"hint": "瀑布后 · 水幕石洞 / 遗迹宝箱",
			"return_path": "res://scenes/areas/waterfall/waterfall.tscn",
			"room_w": 24,
			"room_h": 16,
			"door_tx0": 10,
			"door_tx1": 13,
			"floor": "stone",
			"modulate": Color(0.48, 0.56, 0.62, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("drip_ledge", 5, 7, [
					_m(DIR_OUTDOOR_PROP + "/rock_00.png", 0, 0, "渗水岩", "洞口渗水岩壁脚。", 0.55),
					_m(DIR_OUTDOOR_PROP + "/rock_02.png", -2, 1, "碎岩", "水雾打湿的碎石。", 0.45),
					_m(P_BARREL, 2, 1, "积水桶", "接洞顶滴水。", 0.7),
					_m(P_SACK0, 1, 2, "湿麻袋", "潮气浸透的旧袋。", 0.55),
					_m(P_LAMP_TAVERN, 2, -1, "洞烛", "防潮烛火。", PROP),
				]),
				_cluster("relic", 17, 5, [
					_m(P_COIN, 0, 0, "遗迹宝箱", "瀑后石台上的旧宝箱。", 0.85),
					_m(DIR_OUTDOOR_PROP + "/rock_01.png", -2, 1, "祭台石", "箱侧承台碎岩。", 0.5),
					_m(DIR_OUTDOOR_PROP + "/rock_03.png", 2, 1, "承台石", "箱东承台。", 0.48),
					_m(P_CRATE0, 0, 2, "贡品箱", "箱前旧贡木箱（南站位可交互）。", 0.65),
					_m(P_LAMP_INDOOR, 1, -2, "壁灯", "遗迹壁龛冷光。", PROP),
				]),
				_cluster("wet_cache", 20, 10, [
					_m(P_CRATE1, 0, 0, "潮湿木箱", "靠东壁的存货箱。", 0.75),
					_m(P_SACK1, 2, 1, "苔藓袋", "长苔的储备袋。", 0.6),
					_m(P_TOOL_RACK, -1, -1, "探洞架", "绳钩与短镐。", 0.65),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 7, "ty": 6, "oy": -10, "color": Color(0.75, 0.88, 1.0), "energy": 0.65, "scale": 1.8},
				{"tx": 17, "ty": 4, "oy": -12, "color": Color(0.9, 0.95, 1.0), "energy": 0.9, "scale": 2.2},
			],
			"actor": {},
		},
		# ── C27A 猎人隐所：西卧铺 · 东猎获架（门轴 8–11 中廊清空）──
		"c27_forest_hide_a": {
			"title": "猎人隐所",
			"hint": "深林 · 猎人藏身处 / 干草铺与猎获",
			"return_path": "res://scenes/areas/forest_deep/forest_deep.tscn",
			"room_w": 20,
			"room_h": 14,
			"door_tx0": 8,
			"door_tx1": 11,
			"floor": "straw",
			"modulate": Color(0.52, 0.60, 0.46, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("camp", 4, 6, [
					_m(P_HAY, 0, 0, "干草铺", "西墙临时卧铺。", 0.75),
					_m(P_BED_S, 0, -2, "窄床架", "草铺北的简易床架。", 0.55),
					_m(P_LAMP_FARM, 2, -1, "营灯", "卧铺侧营灯。", PROP),
					_m(P_SACK0, 2, 1, "行囊", "猎人行囊（南可站）。", 0.55),
				]),
				_cluster("hunt_gear", 15, 6, [
					_m(P_TOOL_RACK, 0, -1, "猎具架", "东墙弓刀架。", 0.8),
					_m(P_CRATE0, 0, 1, "猎获箱", "猎物暂存箱。", PROP),
					_m(P_CRATE1, 2, 1, "皮货箱", "皮张木箱。", 0.75),
					_m(P_LEDGER, -2, 0, "猎簿", "兽迹笔记。", 0.55),
					_m(P_LAMP_FARM, 1, -2, "壁灯", "猎具区灯。", PROP),
				]),
				_cluster("dry", 15, 11, [
					_m(P_HERBS, 0, 0, "晾挂兽草", "东南角晾干药草。", 0.55),
					_m(P_BASKET, 2, 0, "皮条篮", "晾晒皮条。", 0.65),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 6, "ty": 5, "oy": -8, "color": Color(1.0, 0.78, 0.45), "energy": 0.7, "scale": 1.6},
				{"tx": 15, "ty": 5, "oy": -10, "color": Color(1.0, 0.82, 0.5), "energy": 0.75, "scale": 1.7},
			],
			"actor": {
				"id": "farmer",
				"title": "隐林猎人",
				"desc": "在卧铺与猎具架之间整理行装。",
				"via_clusters": ["camp", "hunt_gear"],
				"via_stands": {"camp": [0, 2], "hunt_gear": [0, 2]},
			},
		},
		# ── C27B 蘑菇窝棚：西采集台 · 东药草晾挂（门轴 7–10 中廊清空）──
		"c27_forest_hide_b": {
			"title": "蘑菇窝棚",
			"hint": "深林 · 蘑菇采集窝棚",
			"return_path": "res://scenes/areas/forest_deep/forest_deep.tscn",
			"room_w": 18,
			"room_h": 12,
			"door_tx0": 7,
			"door_tx1": 10,
			"floor": "straw",
			"modulate": Color(0.48, 0.56, 0.42, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("forage", 4, 5, [
					_m(P_BASKET, 0, 0, "蘑菇篮", "鲜菇采集篮（南站位）。", 0.8),
					_m(P_BASKET, 2, 0, "菌伞篮", "二号菌篮。", 0.7),
					_m(P_SACK0, 1, 2, "菌粉袋", "晒干菌粉。", 0.6),
					_m(P_STOOL, -1, 1, "矮凳", "分拣蘑菇用凳。", 0.55),
					_m(P_LAMP_FARM, 0, -2, "窝棚灯", "采集台灯。", PROP),
				]),
				_cluster("apothecary", 13, 5, [
					_m(P_HERBS, 0, -1, "挂草", "东壁晾挂药草。", 0.6),
					_m(P_MEDICINE, 0, 1, "药箱", "菌药小箱。", 0.65),
					_m(P_SHELF, 2, 0, "药架", "干菇与瓶罐。", 0.7),
					_m(P_SACK1, -2, 1, "药草袋", "待捣药草。", 0.55),
					_m(P_LAMP_INDOOR, 1, -2, "药架灯", "药区柔光。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 4, "ty": 3, "oy": -8, "color": Color(0.85, 1.0, 0.65), "energy": 0.6, "scale": 1.5},
				{"tx": 13, "ty": 3, "oy": -8, "color": Color(0.9, 1.0, 0.7), "energy": 0.65, "scale": 1.6},
			],
			"actor": {},
		},
		# ── Wave B stubs (teams enrich ONLY their key; do not polish C01–C04) ──
		# ── C06 村公所：西大厅（公告+议事）· 东办公室（案牍+档案体量）· 中轴南门通廊 ──
		"c06_town_hall": {
			"title": "村公所",
			"hint": "村公所 · 大厅议事 / 镇长办公室",
			"return_path": SQ,
			"room_w": 26,
			"room_h": 19,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "plank",
			"modulate": Color(0.86, 0.85, 0.81, 1.0),
			# Rug under hall visitor stop south of meeting table (not empty floor).
			"rug": {"ox": 7, "oy": 12},
			"window": true,
			"clusters": [
				# Public hall — notice + meeting seating; east stools stop before door aisle (tx11–14).
				_cluster("hall", 7, 9, [
					_m(P_CIVIC_BOARD, -1, -4, "公告板", "村务与告示栏（非 notice 代理；南侧留读位）。", 0.9),
					_m(P_MEETING_TABLE, 0, 0, "会议桌", "议事长桌（非饭桌代理）。", 0.95),
					_m(P_STOOL, -2, 0, "议事凳", "西席（对桌）。", 0.55),
					_m(P_STOOL, 2, 0, "议事凳", "东席（对桌，不侵中轴通廊）。", 0.55),
					_m(P_STOOL, 0, 2, "旁听凳", "南向旁听席。", 0.55),
					_m(P_STOOL_TEA, 0, -2, "主位凳", "北向主议席。", 0.55),
					_m(P_LAMP_INDOOR, -3, -3, "大厅灯", "公告侧台灯。", PROP),
				]),
				# Mayor office — staff north of counter, visitors south; shelf/crate archive mass east.
				_cluster("office", 19, 7, [
					_m(P_COUNTER, 0, 1, "办证柜", "访客侧办证柜台（职员在北、访客在南）。", 1.0),
					_m(P_LEDGER, 0, -1, "镇长案", "柜台后文书案。", 0.7),
					_m(P_STOOL, 0, 0, "职员凳", "柜台后职员位。", 0.5),
					_m(P_DRESSER, -1, -2, "档案柜", "镇务抽屉柜（职员侧）。", 0.8),
					_m(P_SHELF, 2, -2, "卷宗架", "归档书架。", 0.9),
					_m(P_SHELF, 2, 0, "卷宗架", "旧档架（体量）。", 0.85),
					_m(P_CRATE0, 3, -1, "档箱", "待整档箱。", 0.75),
					_m(P_CRATE1, 3, 1, "档箱", "密封档箱。", 0.7),
					_m(P_LAMP_INDOOR, 1, -1, "办公灯", "案侧台灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 6, "ty": 6, "oy": -12, "color": Color(1.0, 0.96, 0.86), "energy": 0.95, "scale": 1.8},
				{"tx": 19, "ty": 5, "oy": -10, "color": Color(1.0, 0.94, 0.8), "energy": 1.0, "scale": 1.7},
				{"tx": 13, "ty": 3, "oy": -8, "color": Color(0.92, 0.95, 1.0), "energy": 0.5, "scale": 1.4},
			],
			"actor": {
				"id": "mayor",
				"title": "镇长",
				"desc": "在办公室批文，偶尔到大厅看公告议事。",
				"via_clusters": ["office", "hall"],
				"via_stands": {"office": [0, 0], "hall": [0, 3]},
			},
		},
		# ── C07 学校：北黑板 + 中轴通廊两侧课桌阵列 + 东教材角（≠村公所议事/医馆诊床）──
		"c07_school": {
			"title": "学校",
			"hint": "学校 · 北黑板教室 / 课桌阵列 / 教材角",
			"return_path": SQ,
			"room_w": 28,
			"room_h": 18,
			"door_tx0": 12,
			"door_tx1": 15,
			"floor": "plank",
			"modulate": Color(0.91, 0.90, 0.86, 1.0),
			# Rug under front aisle (between desk columns) — gather / lesson stop.
			"rug": {"ox": 12, "oy": 9},
			"window": true,
			"clusters": [
				# North wall: board + flanking lamps + west-offset lectern (aisle 12–15 clear).
				_cluster("blackboard", 14, 3, [
					_m(P_BLACKBOARD, 0, 0, "黑板", "北壁黑板（授课锚）。", 1.05),
					_m(P_LAMP_INDOOR, -4, 0, "西壁灯", "黑板西侧教室灯。", PROP),
					_m(P_LAMP_INDOOR, 4, 0, "东壁灯", "黑板东侧教室灯。", PROP),
					_m(P_LECTERN, -4, 2, "讲台", "偏西讲台（非课桌代理；让出中轴通廊）。", 0.85),
					_m(P_STOOL, -4, 3, "教凳", "讲台南教凳（面向课桌）。", 0.5),
					_m(P_LEDGER, -3, 1, "教案", "讲台旁教案册。", 0.65),
				]),
				# Two columns × three rows facing north; stools south of desks; aisle 12–15 open.
				_cluster("desks", 6, 7, [
					_m(P_SCHOOL_DESK, 0, 0, "前排课桌", "西列前排（面北黑板）。", 0.72),
					_m(P_STOOL, 0, 2, "课凳", "西列前排课凳（南向站位可交互）。", 0.48),
					_m(P_SCHOOL_DESK, 14, 0, "前排课桌", "东列前排（面北黑板）。", 0.72),
					_m(P_STOOL, 14, 2, "课凳", "东列前排课凳（南向站位可交互）。", 0.48),
					_m(P_SCHOOL_DESK, 0, 3, "中排课桌", "西列中排。", 0.72),
					_m(P_STOOL, 0, 5, "课凳", "西列中排课凳。", 0.48),
					_m(P_SCHOOL_DESK, 14, 3, "中排课桌", "东列中排。", 0.72),
					_m(P_STOOL, 14, 5, "课凳", "东列中排课凳。", 0.48),
					_m(P_SCHOOL_DESK, 0, 6, "后排课桌", "西列后排（南门带空出）。", 0.72),
					_m(P_STOOL, 0, 8, "课凳", "西列后排课凳。", 0.48),
					_m(P_SCHOOL_DESK, 14, 6, "后排课桌", "东列后排（南门带空出）。", 0.72),
					_m(P_STOOL, 14, 8, "课凳", "东列后排课凳。", 0.48),
				]),
				# East book corner — secondary zone, not a second classroom.
				_cluster("books", 23, 5, [
					_m(P_SHELF, 0, 0, "教材架", "东墙教材/读物架。", 0.9),
					_m(P_LEDGER, 1, 1, "课本", "架旁课本册。", 0.65),
					_m(P_BASKET, 0, 2, "练习筐", "练习册筐贴架。", 0.55),
					_m(P_STOOL_TEA, 2, 2, "阅览凳", "教材角矮凳（西侧留站位）。", 0.5),
					_m(P_LAMP_INDOOR, 1, -1, "角灯", "教材角壁灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 14, "ty": 4, "oy": -10, "color": Color(1.0, 0.98, 0.92), "energy": 1.05, "scale": 2.2},
				{"tx": 14, "ty": 10, "oy": -6, "color": Color(1.0, 0.96, 0.88), "energy": 0.75, "scale": 1.8},
				{"tx": 23, "ty": 5, "oy": -8, "color": Color(1.0, 0.94, 0.85), "energy": 0.7, "scale": 1.5},
			],
			"actor": {
				"id": "elder_woman",
				"title": "老师",
				"desc": "在黑板前授课，偶尔巡视课桌与教材角。",
				"via_clusters": ["blackboard", "desks", "books"],
				"via_stands": {
					"blackboard": [0, 2],
					"desks": [6, 2],
					"books": [-2, 1],
				},
			},
		},
		# ── C08 医馆：西前台候诊 · 东诊床+药柜体量（≠杂货双架菜筐）──
		"c08_clinic": {
			"title": "医馆",
			"hint": "医馆 · 西前台候诊 / 东诊室药柜",
			"return_path": SQ,
			"room_w": 26,
			"room_h": 17,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "plank",
			# Soft cool clinical wash (not grocery warm cream / smith orange).
			"modulate": Color(0.82, 0.90, 0.92, 1.0),
			# Rug under waiting stop south of counter (west of door band 11–14).
			"rug": {"ox": 6, "oy": 11},
			"window": true,
			"clusters": [
				# Staff north of counter; patients approach dy=2; stools further south.
				_cluster("front", 7, 7, [
					_m(P_COUNTER, 0, 1, "前台", "挂号柜台（患者在南、医师在北）。", 1.0),
					_m(P_LEDGER, -1, 0, "挂号簿", "柜北侧挂号名册。", 0.7),
					_m(P_CLINIC_FEE_BOARD, -2, -1, "诊费告示", "西壁挂号须知（非 notice 代理）。", 0.75),
					_m(P_LAMP_SHOP, 1, -2, "医馆店灯", "前台吊罩店灯（非锻工/酒馆灯）。", PROP),
					_m(P_STOOL, -2, 3, "候诊凳", "西候诊矮凳（同 sheet）。", 0.55),
					_m(P_STOOL, 1, 3, "候诊凳", "东候诊矮凳（同 sheet；中轴留站位）。", 0.55),
				]),
				# Exam bed west approach free; jar shelves + medicine chests + herbs = pharmacy mass.
				_cluster("exam", 19, 6, [
					_m(P_BED_S, 0, 1, "诊床", "检查/卧诊单人床。", 0.9),
					_m(P_SHELF, 2, -1, "药罐架", "诊室东壁药罐柜（体量上层）。", 0.95),
					_m(P_SHELF, 2, 1, "药罐架", "诊室东壁药罐柜（体量下层）。", 0.9),
					_m(P_MEDICINE, 3, 0, "药箱", "架脚急救药箱。", 0.75),
					_m(P_MEDICINE, 3, 2, "药箱", "叠放草药箱（体量）。", 0.7),
					_m(P_HERBS, 0, -2, "晾挂药草", "诊床北壁干药草。", 0.65),
					_m(P_HERBS, 2, -2, "晾挂药草", "药架上晾挂药草。", 0.6),
					_m(P_LAMP_INDOOR, -1, -1, "诊室灯", "诊床侧柔和壁灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 8, "ty": 5, "oy": -10, "color": Color(0.92, 1.0, 0.98), "energy": 0.95, "scale": 2.0},
				{"tx": 19, "ty": 5, "oy": -12, "color": Color(0.95, 1.0, 0.96), "energy": 0.9, "scale": 1.9},
			],
			"actor": {
				"id": "merchant",
				"title": "医师",
				"desc": "在前台挂号与诊床间往来。",
				"via_clusters": ["front", "exam"],
				"via_stands": {"front": [0, 0], "exam": [-2, 1]},
			},
		},
		# ── C09 图书馆：西/东平行书脊体量 · 中廊借阅台 · 南门通廊 ──
		"c09_library": {
			"title": "图书馆",
			"hint": "图书馆 · 平行书架 / 中岛借阅",
			"return_path": SQ,
			# Long hall + wing stacks ≠ school desk grid ≠ church nave.
			"room_w": 30,
			"room_h": 18,
			"door_tx0": 13,
			"door_tx1": 16,
			"floor": "plank",
			"modulate": Color(0.84, 0.82, 0.78, 1.0),
			# Rug = customer approach south of borrow desk (not under stacks).
			"rug": {"ox": 13, "oy": 10},
			"window": true,
			"clusters": [
				# West stack wing — repeated shelves = readable book mass; keep east of wing clear for aisle.
				_cluster("stacks_w", 5, 6, [
					_m(P_SHELF, 0, -2, "西书架", "文学架（可检索分类）。", 0.95),
					_m(P_SHELF, 0, 0, "西书架", "史地架（可检索分类）。", 0.95),
					_m(P_SHELF, 0, 2, "西书架", "童书架（可检索分类）。", 0.9),
					_m(P_SHELF, -2, -1, "西内架", "诗集叠架（书脊体量）。", 0.9),
					_m(P_SHELF, -2, 1, "西内架", "期刊叠架（书脊体量）。", 0.85),
					_m(P_SACK0, 2, 2, "书捆", "待上架书捆（贴架脚，不挡中廊）。", 0.5),
					_m(P_CRATE0, 2, 3, "还书箱", "西翼还书暂存。", 0.75),
				]),
				# East stack wing — mirror mass; aisle face west toward center corridor.
				_cluster("stacks_e", 24, 6, [
					_m(P_SHELF, 0, -2, "东书架", "自然架（可检索分类）。", 0.95),
					_m(P_SHELF, 0, 0, "东书架", "农艺架（可检索分类）。", 0.95),
					_m(P_SHELF, 0, 2, "东书架", "档案架（可检索分类）。", 0.9),
					_m(P_SHELF, 2, -1, "东内架", "参考叠架（书脊体量）。", 0.9),
					_m(P_SHELF, 2, 1, "东内架", "地方志叠架（书脊体量）。", 0.85),
					_m(P_LEDGER, -2, 1, "索引册", "东翼馆藏索引（可搜条目）。", 0.7),
					_m(P_BASKET, -2, 3, "书篮", "阅览还书篮。", 0.7),
				]),
				# Center borrow island — staff north of counter; free approach tile south (dy≥2 empty).
				_cluster("desk", 14, 7, [
					_m(P_COUNTER, 0, 0, "借阅台", "中岛借阅台（顾客南站、馆员北侧）。", 1.05),
					_m(P_LEDGER, -1, -1, "借阅簿", "流通登记簿。", 0.7),
					_m(P_CATALOG_CARD, 2, -1, "分类卡", "架位索引卡（大厅检索提示；非 notice 代理）。", 0.8),
					_m(P_LAMP_INDOOR, 1, -2, "阅览灯", "借阅台灯。", PROP),
					_m(P_STOOL_TEA, 3, 0, "旁凳", "柜东短坐（不占南向站位）。", 0.55),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 5, "oy": -10, "color": Color(1.0, 0.93, 0.78), "energy": 0.85, "scale": 1.8},
				{"tx": 14, "ty": 5, "oy": -12, "color": Color(1.0, 0.94, 0.82), "energy": 1.1, "scale": 2.4},
				{"tx": 24, "ty": 5, "oy": -10, "color": Color(1.0, 0.93, 0.78), "energy": 0.85, "scale": 1.8},
			],
			"actor": {
				"id": "elder_woman",
				"title": "图书管理员",
				"desc": "在借阅台与东西书架间巡架整理。",
				"via_clusters": ["desk", "stacks_w", "stacks_e"],
				"via_stands": {
					"desk": [0, -1],
					"stacks_w": [2, 1],
					"stacks_e": [-2, 1],
				},
			},
		},
		# ── C10 教堂主礼堂：北祭坛 · 中轴通廊 · 东西座席（轴向 nave ≠ 教室/议事桌）──
		# Door aisle 12–15 (≥2) clear south→altar; pews stay west (tx≤10) / east (tx≥17).
		"c10_church": {
			"title": "教堂",
			"hint": "教堂 · 主礼堂（祭坛 + 座席）",
			"return_path": SQ,
			"room_w": 26,
			"room_h": 22,
			"door_tx0": 12,
			"door_tx1": 15,
			"floor": "stone",
			# Cool stone wash (not tavern warm orange).
			"modulate": Color(0.78, 0.81, 0.88, 1.0),
			# Rug under altar approach (north of mid-nave, on axis).
			"rug": {"ox": 12, "oy": 7},
			"window": true,
			"clusters": [
				# Verb: 祭礼 — north sanctuary; clergy south of altar facing nave.
				_cluster("altar", 13, 4, [
					_m(P_ALTAR, 0, 0, "祭坛", "北向长祭坛（礼堂主锚）。", 1.0),
					_m(P_SCRIPTURE_PLAQUE, 0, -2, "经文牌", "北壁经文牌（非 notice 代理）。", 0.85),
					_m(P_LEDGER, -2, 0, "经书", "祭坛西侧经书。", 0.65),
					_m(P_LAMP_INDOOR, 2, -1, "圣灯", "祭坛东侧圣灯。", PROP),
					_m(P_LAMP_INDOOR, -2, -1, "圣灯", "祭坛西侧圣灯。", 0.85),
					_m(P_STOOL, 0, 2, "跪凳", "祭坛前跪凳（南站位可交互）。", 0.5),
				]),
				# Verb: 西座席 — three rows facing north; aisle-side stands free.
				_cluster("pews_w", 7, 10, [
					_m(P_PEW, 0, 0, "长椅", "西排前座席。", 0.75),
					_m(P_PEW, 0, 3, "长椅", "西排中座席。", 0.75),
					_m(P_PEW, 0, 6, "长椅", "西排后座席。", 0.75),
					_m(P_STOOL, 2, 1, "边凳", "西排靠廊短坐（不堵中轴）。", 0.5),
				]),
				# Verb: 东座席 — mirror bank; keep dx clear of door band 12–15.
				_cluster("pews_e", 19, 10, [
					_m(P_PEW, 0, 0, "长椅", "东排前座席。", 0.75),
					_m(P_PEW, 0, 3, "长椅", "东排中座席。", 0.75),
					_m(P_PEW, 0, 6, "长椅", "东排后座席。", 0.75),
					_m(P_STOOL, -2, 1, "边凳", "东排靠廊短坐（不堵中轴）。", 0.5),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 13, "ty": 4, "oy": -14, "color": Color(0.86, 0.90, 1.0), "energy": 1.15, "scale": 2.6},
				{"tx": 7, "ty": 11, "oy": -8, "color": Color(0.80, 0.86, 0.98), "energy": 0.5, "scale": 1.7},
				{"tx": 19, "ty": 11, "oy": -8, "color": Color(0.80, 0.86, 0.98), "energy": 0.5, "scale": 1.7},
			],
			"actor": {
				"id": "elder_woman",
				"title": "司礼",
				"desc": "在祭坛与东西座席间巡视。",
				"via_clusters": ["altar", "pews_w", "pews_e"],
				"via_stands": {
					"altar": [0, 3],
					"pews_w": [2, 2],
					"pews_e": [-2, 2],
				},
			},
		},
		# ── C11 车站内部：西宽候车厅 · 中轴南门通廊 · 东售票/站长 + 货运体量 ──
		# Silhouette: long horizontal (30×16) ≠ C10 church tall nave (24×20).
		# Door aisle 13–16 clear south→north; benches stay west (tx≤12), ticket/freight east (tx≥20).
		"c11_station": {
			"title": "车站内部",
			"hint": "车站 · 候车厅 / 售票站长室",
			"return_path": STN,
			"room_w": 30,
			"room_h": 16,
			"door_tx0": 13,
			"door_tx1": 16,
			"floor": "plank",
			"modulate": Color(0.85, 0.83, 0.79, 1.0),
			# Rug under waiting seats (west of door corridor 13–16).
			"rug": {"ox": 7, "oy": 9},
			"window": true,
			"clusters": [
				# Verb: 候车 — dedicated waiting benches + timetable.
				_cluster("waiting", 6, 7, [
					_m(P_WAITING_BENCH, 0, 0, "候车长椅", "北排西座（候车）。", 0.85),
					_m(P_WAITING_BENCH, 3, 0, "候车长椅", "北排中座（候车）。", 0.85),
					_m(P_WAITING_BENCH, 6, 0, "候车长椅", "北排东座（贴通廊西缘）。", 0.85),
					_m(P_WAITING_BENCH, 0, 3, "候车长椅", "南排西座（候车）。", 0.85),
					_m(P_WAITING_BENCH, 3, 3, "候车长椅", "南排中座（候车）。", 0.85),
					_m(P_TIMETABLE, 3, -3, "时刻表", "班次与站台告示（非 notice 代理）。", 0.9),
					_m(P_LAMP_SHOP, 5, -2, "站厅灯", "候车厅壁灯。", PROP),
					_m(P_STOOL, -2, 1, "边座", "长椅端头短坐。", 0.55),
				]),
				# Verb: 售票 — counter faces south (passenger); staff/ledger north.
				_cluster("ticket", 22, 6, [
					_m(P_COUNTER, 0, 1, "售票窗", "站长/售票柜台（客南主北）。", 1.0),
					_m(P_LEDGER, -1, -1, "行车簿", "站长日志与班次簿。", 0.7),
					_m(P_LAMP_SHOP, 2, -1, "票窗灯", "售票台灯。", PROP),
					_m(P_COIN, 2, 1, "票箱", "零钱与票根匣。", 0.55),
					_m(P_FARE_BOARD, 1, -3, "票价牌", "票价与托运须知（非 notice 代理）。", 0.75),
				]),
				# Verb: 货运体量 — crate mass east of ticket (not in door aisle).
				_cluster("freight", 25, 9, [
					_m(P_CRATE0, 0, -2, "货运箱", "到站货箱底垛。", PROP),
					_m(P_CRATE1, 2, -2, "货运箱", "叠高托运箱。", 0.85),
					_m(P_CRATE0, 1, 0, "货运箱", "中层待发件。", 0.9),
					_m(P_CRATE1, 0, 1, "货运箱", "前脚小件货。", 0.8),
					_m(P_SACK0, 2, 1, "邮包", "袋装托运。", 0.65),
					_m(P_BARREL, 3, 0, "油桶", "站务补给桶。", 0.75),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 9, "ty": 4, "oy": -10, "color": Color(1.0, 0.96, 0.86), "energy": 1.0, "scale": 2.2},
				{"tx": 22, "ty": 4, "oy": -8, "color": Color(1.0, 0.94, 0.82), "energy": 0.95, "scale": 1.9},
			],
			"actor": {
				"id": "station_master",
				"title": "站长",
				"desc": "在候车厅与售票窗之间巡视，偶尔清点货箱。",
				"via_clusters": ["waiting", "ticket", "freight"],
				"via_stands": {
					"waiting": [2, 2],
					"ticket": [0, 0],
					"freight": [-2, 1],
				},
			},
		},
		# ── Wave C stubs (teams enrich ONLY their keys) ──
		"c13_mill": {
			"title": "磨坊",
			"hint": "磨坊 · 石磨盘 / 传动齿轮 / 面粉垛",
			"return_path": FLD,
			"room_w": 20,
			"room_h": 14,
			"door_tx0": 8,
			"door_tx1": 11,
			"floor": "plank",
			"modulate": Color(0.88, 0.84, 0.76, 1.0),
			"rug": null,
			"window": true,
			# West work: millstone+gears; east flour mass; door aisle 8–11 clear.
			"clusters": [
				_cluster("millstone", 5, 5, [
					_m(P_MILLSTONE, 0, 0, "石磨盘", "西侧石磨盘与木斗（工作锚）。", 1.0),
					_m(P_MILL_GEAR, -2, -1, "传动齿轮", "木架铁齿轮传动（贴磨盘）。", 0.85),
					_m(P_LAMP_FARM, 2, -2, "磨坊灯", "农场铁壳工作灯（非家用台灯）。", PROP),
					_m(P_BARREL, 2, 1, "麦桶", "待磨麦粒桶（站位东侧）。", 0.7),
					_m(P_TOOL_RACK, 1, -3, "检修架", "磨盘检修锤钳。", 0.55),
				]),
				_cluster("flour", 15, 6, [
					_m(P_GRAIN_STACK, 0, 0, "面粉垛", "袋装面粉高垛（体量锚）。", 0.85),
					_m(P_GRAIN_STACK, 2, -1, "面粉垛", "东墙第二面粉垛。", 0.75),
					_m(P_SACK0, -1, 2, "面袋", "待运面粉袋。", 0.65),
					_m(P_SACK1, 2, 2, "麸皮袋", "麸皮与筛余。", 0.6),
					_m(P_SACK0, 1, 1, "面袋", "垛前小袋。", 0.55),
					_m(P_BASKET, -2, 1, "筛筐", "面粉筛筐。", 0.55),
					_m(P_CRATE0, 3, 1, "运箱", "出货木箱。", 0.7),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -10, "color": Color(1.0, 0.95, 0.82), "energy": 1.0, "scale": 2.1},
				{"tx": 15, "ty": 5, "oy": -8, "color": Color(1.0, 0.94, 0.8), "energy": 0.9, "scale": 1.8},
			],
			"actor": {
				"id": "miller",
				"title": "磨坊主",
				"desc": "在石磨与面粉垛之间巡视，偶尔检修齿轮。",
				"via_clusters": ["millstone", "flour"],
				"via_stands": {
					"millstone": [2, 2],
					"flour": [-2, 2],
				},
			},
		},
		# ── C16 洞穴入口层：西洞口乱石营 · 东下探井口（门轴 11–14 中廊；≠矿洞）──
		"c16_cave_entry": {
			"title": "洞穴入口层",
			"hint": "洞穴 · 石质入口 / 下探井口",
			"return_path": HILL,
			"room_w": 26,
			"room_h": 17,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "stone",
			"modulate": Color(0.58, 0.54, 0.50, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				# West vestibule rubble — approach from corridor east of rocks.
				_cluster("mouth", 5, 9, [
					_m(P_ROCK0, 0, 0, "洞口乱石", "入口西壁塌落乱石。", 0.7),
					_m(P_ROCK2, -2, 1, "苔石", "带苔的洞口石。", 0.55),
					_m(P_ROCK3, 1, 2, "碎石堆", "刚滚落的碎石（南可站）。", 0.5),
					_m(P_CRATE0, 2, 0, "探险箱", "入口补给木箱。", 0.8),
					_m(P_SACK0, 3, 1, "行囊", "探洞人行囊。", 0.65),
					_m(P_LAMP_FARM, 2, -2, "洞口灯", "钉在乱石旁的入口油灯。", PROP),
				]),
				# NW camp — secondary rest / gear (west of door axis).
				_cluster("camp", 6, 5, [
					_m(P_HAY, 0, 0, "干草铺", "入口临时卧铺。", 0.7),
					_m(P_TOOL_RACK, -1, -1, "探洞架", "绳钩与短镐架。", 0.65),
					_m(P_CRATE1, 2, 1, "补给箱", "干粮与火绒箱。", 0.75),
					_m(P_BARREL, 2, -1, "饮水桶", "营边饮水。", PROP),
					_m(P_LAMP_FARM, 1, -2, "营灯", "卧铺侧营灯。", PROP),
				]),
				# East descent shaft — extra_portal south of notice for clear approach.
				_cluster("descent", 18, 7, [
					_m(P_TRAIL_MARKER, 0, 0, "下探标记", "通向水晶中层的井口标记（非 notice 代理）。", 0.7),
					_m(P_ROCK1, -2, 1, "井口岩", "下探口西缘承台石。", 0.55),
					_m(P_ROCK0, 1, 2, "阶缘石", "井口南缘碎岩。", 0.5),
					_m(P_CRATE1, 2, 1, "绳索箱", "下探绳索与铁钉。", 0.75),
					_m(P_BARREL, -1, 2, "压绳桶", "固定主绳的重桶（南站位）。", PROP),
					_m(P_BASKET, 2, -1, "绳钩筐", "备用钩环筐。", 0.7),
				]),
			],
			"extra_portals": [
				{"tx": 18, "ty": 10, "label": "↓中层", "path": "res://scenes/interiors/c16_cave_mid/c16_cave_mid.tscn"},
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 6, "ty": 7, "oy": -10, "color": Color(1.0, 0.88, 0.62), "energy": 0.85, "scale": 2.0},
				{"tx": 18, "ty": 6, "oy": -8, "color": Color(0.95, 0.82, 0.55), "energy": 0.75, "scale": 1.8},
			],
			"actor": {
				"id": "farmer",
				"title": "探洞人",
				"desc": "在洞口乱石与下探井口之间来回。",
				"via_clusters": ["mouth", "camp", "descent"],
				"via_stands": {"mouth": [3, 0], "camp": [0, 2], "descent": [0, 3]},
			},
		},
		# ── C16 洞穴中层：西晶簇台 · 东渗水池（门轴 9–12；冷光；回入口层）──
		"c16_cave_mid": {
			"title": "洞穴中层",
			"hint": "洞穴 · 水晶厅 / 渗水池",
			"return_path": "res://scenes/interiors/c16_cave_entry/c16_cave_entry.tscn",
			"room_w": 22,
			"room_h": 15,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.42, 0.50, 0.62, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				# West crystal plinth — primary silhouette (≠ entry rubble camp).
				_cluster("crystal", 6, 6, [
					_m(P_COIN, 0, 0, "晶簇箱", "嵌在晶台上的晶簇收藏箱。", 0.85),
					_m(P_ROCK3, -2, 1, "晶簇岩", "西侧粗晶簇岩。", 0.65),
					_m(P_ROCK1, 2, 1, "晶脉石", "东侧露出晶脉。", 0.55),
					_m(P_ROCK2, 0, 2, "碎晶堆", "台前碎晶（南可交互）。", 0.5),
					_m(P_CRATE0, 2, -1, "晶样箱", "已采晶样木箱。", 0.7),
					_m(P_LAMP_INDOOR, 1, -2, "晶龛灯", "壁龛冷白光。", PROP),
				]),
				# East seep pool — cool wet mass.
				_cluster("glow_pool", 16, 8, [
					_m(P_BARREL, 0, 0, "渗水桶", "接洞顶渗水。", 0.75),
					_m(P_BARREL_KEG, 2, 0, "积水桶", "池缘积水桶。", 0.7),
					_m(P_ROCK2, -1, 2, "湿岩", "池缘湿苔岩。", 0.5),
					_m(P_ROCK0, 1, 2, "池缘石", "东池缘承台。", 0.48),
					_m(P_SACK1, 2, 1, "湿麻袋", "潮气浸透的旧袋。", 0.55),
					_m(P_LAMP_INDOOR, -1, -1, "池边冷灯", "渗水池冷光。", PROP),
				]),
				# North sample bench — secondary, compact.
				_cluster("sample", 15, 4, [
					_m(P_CRATE1, 0, 0, "样本箱", "待鉴定晶矿样本。", 0.75),
					_m(P_BASKET, 2, 1, "拣晶筐", "手拣碎晶筐。", 0.7),
					_m(P_TOOL_RACK, 1, -2, "取样架", "凿刀与布袋架。", 0.65),
					_m(P_MINE_SAFETY, -1, -1, "晶脉告示", "中层晶脉安全告示（非 notice 代理）。", 0.65),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 6, "ty": 4, "oy": -12, "color": Color(0.65, 0.88, 1.0), "energy": 1.05, "scale": 2.3},
				{"tx": 16, "ty": 6, "oy": -10, "color": Color(0.55, 0.82, 1.0), "energy": 0.95, "scale": 2.0},
				{"tx": 11, "ty": 3, "oy": -6, "color": Color(0.7, 0.9, 1.0), "energy": 0.55, "scale": 1.5},
			],
			"actor": {
				"id": "farmer",
				"title": "晶脉探工",
				"desc": "在晶簇台与渗水池之间取样。",
				"via_clusters": ["crystal", "sample", "glow_pool"],
				"via_stands": {"crystal": [0, 3], "sample": [0, 2], "glow_pool": [-2, 1]},
			},
		},
		"c24_lake_island": {
			"title": "湖心岛",
			"hint": "湖心岛 · 野餐 / 废墟角",
			"return_path": LAKE,
			"room_w": 24,
			"room_h": 18,
			"door_tx0": 10,
			"door_tx1": 13,
			"floor": "straw",
			"modulate": Color(0.72, 0.82, 0.68, 1.0),
			"rug": {"ox": 6, "oy": 10},
			"window": false,
			"clusters": [
				_cluster("picnic", 6, 8, [
					_m(P_TABLE_R, 0, 0, "野餐圆桌", "西侧野餐圆桌（社交锚）。", 0.9),
					_m(P_STOOL, -2, 1, "矮凳", "桌西坐凳。", 0.55),
					_m(P_STOOL, 2, 1, "矮凳", "桌东坐凳。", 0.55),
					_m(P_STOOL, 0, 3, "矮凳", "桌南坐凳（南可站）。", 0.55),
					_m(P_BASKET, -2, -1, "食篮", "野餐食篮。", 0.7),
					_m(P_BASKET, 2, -1, "果篮", "野果篮。", 0.65),
					_m(P_LAMP_FARM, 1, -2, "岛灯", "野餐区日光感灯。", PROP),
				]),
				_cluster("ruin_corner", 18, 5, [
					_m(P_COIN, 0, 0, "宝箱", "废墟角神秘小箱。", 0.75),
					_m(P_ROCK2, -2, 1, "残垣石", "岛角残垣。", 0.6),
					_m(P_ROCK0, 2, 1, "残垣石", "箱东残石。", 0.55),
					_m(P_CRATE1, 0, 2, "旧箱", "废墟旧木箱。", 0.7),
					_m(P_LAMP_FARM, 2, -1, "废墟灯", "废墟角微光。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 6, "ty": 5, "oy": -8, "color": Color(1.0, 0.98, 0.88), "energy": 0.9, "scale": 2.0},
				{"tx": 18, "ty": 3, "oy": -6, "color": Color(0.95, 0.96, 0.9), "energy": 0.7, "scale": 1.6},
			],
			"actor": {
				"id": "elder_woman",
				"title": "岛上访客",
				"desc": "在野餐圆桌与废墟宝箱之间踱步。",
				"via_clusters": ["picnic", "ruin_corner"],
				"via_stands": {"picnic": [0, 2], "ruin_corner": [-2, 2]},
			},
		},
		# ── C25 河流隐藏：西芦苇口 · 北跳石隐径 · 东小船窖（门轴 9–12 南门通廊清空）──
		"c25_river_hide": {
			"title": "芦苇岔路",
			"hint": "河流隐藏 · 芦苇口 / 跳石隐径 / 小船窖",
			"return_path": RIV,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "straw",
			"modulate": Color(0.58, 0.70, 0.54, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				# West reed mouth — dense damp bank; leave south approach at (0,2).
				_cluster("reed", 4, 7, [
					_m(P_REED_CLUMP, 0, 0, "芦苇丛", "西岸芦苇丛掩口（主锚）。", 0.9),
					_m(P_HERBS, -2, -1, "湿苇梢", "潮气打湿的苇梢。", 0.55),
					_m(P_REED_CLUMP, 2, -1, "侧苇丛", "口缘侧苇。", 0.75),
					_m(P_BASKET, 2, 1, "采苇篮", "割苇篮（南站位可交互）。", 0.75),
					_m(P_SACK0, 0, 2, "湿袋", "岸边湿麻袋。", 0.55),
					_m(P_LAMP_FARM, -1, -2, "苇口灯", "隐径入口微光。", PROP),
				]),
				# North stepping / fallen-log path — secret fork in ≤3s.
				_cluster("stepping", 11, 4, [
					_m(P_ROCK0, 0, 0, "跳石", "岔路中段跳石。", 0.5),
					_m(P_ROCK2, -2, 1, "倒木脚石", "半没水的倒木脚石。", 0.45),
					_m(P_ROCK1, 2, 1, "踏脚石", "东向踏脚。", 0.48),
					_m(P_ROCK3, 0, -2, "北岸石", "隐径继续向北。", 0.42),
					_m(P_TRAIL_MARKER, -1, -1, "隐径记号", "芦苇后的岔路记号（非 notice 代理）。", 0.5),
				]),
				# East skiff cache — boat supply mass + hidden coin + bamboo rod.
				_cluster("skiff", 17, 8, [
					_m(P_CRATE0, 0, 0, "小船箱", "藏船补给主箱（南站位）。", 0.85),
					_m(P_CRATE1, 2, 0, "船舱箱", "船舷侧箱。", 0.75),
					_m(P_BARREL, -2, 1, "压舱桶", "系岸压舱桶。", 0.7),
					_m(P_COIN, 0, -2, "船底窖", "船底藏匿小箱。", 0.7),
					_m(P_ROD_BAMBOO, 2, -2, "竹钓竿", "靠船的竹钓竿。", 0.65),
					_m(P_SACK1, 1, 2, "网袋", "湿渔网袋。", 0.55),
					_m(P_BASKET, -2, -1, "饵料篮", "船边饵料篮。", 0.6),
					_m(P_LAMP_FARM, -1, -2, "船窖灯", "小船窖微光。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 6, "oy": -8, "color": Color(0.8, 1.0, 0.7), "energy": 0.6, "scale": 1.6},
				{"tx": 11, "ty": 4, "oy": -6, "color": Color(0.85, 1.0, 0.78), "energy": 0.55, "scale": 1.4},
				{"tx": 17, "ty": 7, "oy": -10, "color": Color(0.9, 0.95, 0.7), "energy": 0.75, "scale": 1.8},
			],
			"actor": {
				"id": "farmer",
				"title": "苇岸渔人",
				"desc": "在芦苇口与小船窖之间整理网具。",
				"via_clusters": ["reed", "skiff"],
				"via_stands": {"reed": [0, 2], "skiff": [0, 2]},
			},
		},
		# ── C28 巨树洞：北树洞厅（根桌聚会）· 西攀梯 · 东南根系窖 · 中轴南门通廊 ──
		# ≠ C27 猎人隐所：无卧铺/猎具；暖木调 + 挑高厅，读作树心空洞而非营地。
		"c28_giant_tree": {
			"title": "巨树洞",
			"hint": "巨树内部 · 树洞厅 / 攀梯 / 根系",
			"return_path": FDEEP,
			"room_w": 22,
			"room_h": 22,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "straw",
			"modulate": Color(0.72, 0.58, 0.42, 1.0),
			# Rug under hall talk/sit south of root table (not empty floor).
			"rug": {"ox": 10, "oy": 10},
			"window": false,
			"clusters": [
				# Verb: 树洞厅聚会 — stump table + log bench; south approach clear.
				_cluster("hall", 10, 8, [
					_m(P_ROOT_TABLE, 0, 0, "根桌", "树心刨平的粗根桌（非饭桌代理）。", 0.95),
					_m(P_STOOL, -2, 1, "木墩", "桌西坐墩（同 sheet）。", 0.7),
					_m(P_STOOL, 2, 1, "木墩", "桌东坐墩（东留站位）。", 0.7),
					_m(P_PEW, 0, 3, "原木长凳", "桌南原木长凳（南站位可坐）。", 0.75),
					_m(P_BARK_GLYPH, 0, -2, "树皮符", "北壁刻纹符板（非 notice 代理）。", 0.7),
					_m(P_LAMP_INDOOR, 2, -2, "洞厅灯", "暖黄树心灯（非农场仓灯）。", PROP),
					_m(P_BASKET, -2, -1, "果篮", "厅角野果篮。", 0.55),
				]),
				# Verb: 攀梯 — west trunk pegs + stump steps (≠ hunt gear rack).
				_cluster("climb", 4, 7, [
					_m(P_PEG_LADDER, 0, -2, "木钉梯", "西干壁攀钉/梯档（非工具架代理）。", 0.9),
					_m(P_CRATE0, 0, 1, "树墩踏", "攀梯脚底树墩踏级。", 0.75),
					_m(P_CRATE1, 0, 2, "树墩踏", "下层踏级（南可站）。", 0.7),
					_m(P_SHELF, 2, -1, "攀具搁板", "绳索与钉楔搁板。", 0.65),
					_m(P_LAMP_FARM, 2, 1, "梯侧灯", "攀梯侧微光。", PROP),
				]),
				# Verb: 根系窖 — SE mass; stays east of door aisle 9–12.
				_cluster("roots", 17, 13, [
					_m(P_ROOT_MASS, 0, -1, "根须垛", "缠结根须高垛（非干草代理）。", 0.9),
					_m(P_CRATE0, 0, 1, "根窖箱", "根系储物底箱。", PROP),
					_m(P_CRATE1, 2, 1, "根窖箱", "叠高根窖箱。", 0.75),
					_m(P_HERBS, 2, -2, "洞苔", "根壁苔藓挂簇。", 0.55),
					_m(P_SACK0, -2, 1, "树脂袋", "采下的树脂袋。", 0.6),
					_m(P_BARREL, 2, 2, "树液桶", "树液/积水桶。", 0.7),
					_m(P_COIN, -1, 2, "根宝匣", "根隙小匣（南可开）。", 0.55),
					_m(P_LAMP_FARM, 1, -2, "根窖灯", "东南根区油灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 10, "ty": 5, "oy": -12, "color": Color(1.0, 0.82, 0.48), "energy": 0.95, "scale": 2.4},
				{"tx": 4, "ty": 5, "oy": -8, "color": Color(1.0, 0.78, 0.45), "energy": 0.7, "scale": 1.6},
				{"tx": 17, "ty": 11, "oy": -6, "color": Color(0.95, 0.75, 0.4), "energy": 0.7, "scale": 1.7},
			],
			"actor": {
				"id": "elder_woman",
				"title": "守树人",
				"desc": "在树洞厅与根系窖之间踱步，偶停攀梯侧察看木钉。",
				"via_clusters": ["hall", "climb", "roots"],
				"via_stands": {"hall": [0, 2], "climb": [2, 2], "roots": [-2, 2]},
			},
		},
		# ── C29 遗迹主殿：北残祭石堆 · 东侧廊藏宝 · 中轴南门通廊 11–14 ──
		# ≠ C10 礼堂：无 pew 排座；祭台 = 碎石坍塌体量，非饭桌。
		"c29_ruins": {
			"title": "遗迹主殿",
			"hint": "遗迹 · 残祭主殿 / 侧廊藏宝",
			"return_path": FDEEP,
			"room_w": 26,
			"room_h": 20,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "stone",
			"modulate": Color(0.62, 0.66, 0.72, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				# Verb: 残祭 — north rubble altar; flanks west of tx11 / east of tx14.
				_cluster("nave", 13, 5, [
					_m(P_ROCK0, 0, 0, "残祭台", "坍塌主殿祭台碎石堆（体量锚）。", 0.95),
					_m(P_ROCK2, -1, 0, "砌石残块", "祭台西侧塌落砌石。", 0.72),
					_m(P_ROCK3, 1, 0, "砌石残块", "祭台东侧塌落砌石。", 0.7),
					_m(P_ROCK1, 0, -1, "塌顶石", "祭台北塌落顶石。", 0.65),
					_m(P_ROCK2, -3, 1, "侧廊残垣", "西廊坍塌残垣（西于门轴）。", 0.55),
					_m(P_ROCK3, 3, 1, "侧廊残垣", "东廊坍塌残垣（东于门轴）。", 0.55),
					_m(P_RUIN_STELE, 0, -2, "碑刻", "祭台北壁残碑刻文（非 notice 代理）。", 0.85),
					_m(P_LAMP_INDOOR, 2, -1, "残灯", "壁龛冷白灯。", PROP),
					_m(P_CRATE0, 0, 2, "清理箱", "祭台南清理碎石箱（南可站）。", 0.65),
				]),
				# Verb: 侧藏 — east alcove; approach from west (aisle side).
				_cluster("cache", 20, 10, [
					_m(P_COIN, 0, 0, "遗物箱", "侧廊掩埋的旧宝箱。", 0.8),
					_m(P_CRATE1, 2, 1, "碎石箱", "清理碎石的木箱。", 0.7),
					_m(P_CRATE0, 1, -1, "残件箱", "捡出的石雕残件箱。", 0.65),
					_m(P_SACK0, 2, -1, "麻袋", "装碎石的旧麻袋。", 0.55),
					_m(P_ROCK1, 0, 1, "掩箱石", "箱南遮掩碎岩（留西站位）。", 0.5),
					_m(P_ROCK3, 2, 2, "廊角岩", "东廊角塌岩。", 0.48),
					_m(P_LAMP_INDOOR, 0, -2, "廊灯", "侧廊冷光。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 13, "ty": 4, "oy": -12, "color": Color(0.72, 0.82, 1.0), "energy": 0.95, "scale": 2.3},
				{"tx": 20, "ty": 9, "oy": -8, "color": Color(0.7, 0.8, 1.0), "energy": 0.75, "scale": 1.7},
				{"tx": 12, "ty": 12, "oy": -6, "color": Color(0.68, 0.78, 0.98), "energy": 0.55, "scale": 1.5},
			],
			"actor": {
				"id": "elder_woman",
				"title": "遗迹学者",
				"desc": "在残祭台与侧廊遗物箱之间抄录碑文。",
				"via_clusters": ["nave", "cache"],
				"via_stands": {"nave": [0, 3], "cache": [-2, 0]},
			},
		},
		# ── C30 墓园：西墓区碑列 · 中轴南门通廊 · 东穴门体量（≠ C10 礼堂中轴座席）──
		"c30_cemetery": {
			"title": "墓园",
			"hint": "墓园 · 墓区 / 墓穴",
			"return_path": SQ,
			"room_w": 26,
			"room_h": 18,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "stone",
			# Cool blue-grey dusk (not tavern warm orange).
			"modulate": Color(0.56, 0.58, 0.66, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				# Verb: 祭扫 — west headstone rows; offerings south for approach stands.
				_cluster("graves", 6, 8, [
					_m(P_HEADSTONE_0, 0, -1, "墓碑", "西排北侧平顶碑。", 0.85),
					_m(P_HEADSTONE_1, 2, -1, "墓碑", "西排北侧圆顶碑。", 0.85),
					_m(P_HEADSTONE_0, 0, 1, "墓碑", "西排南侧平顶碑。", 0.8),
					_m(P_HEADSTONE_1, 2, 1, "墓碑", "西排南侧圆顶碑。", 0.8),
					_m(P_BASKET, 1, 3, "祭品篮", "碑前祭扫花果篮（南站位可交互）。", 0.6),
					_m(P_CRATE0, -1, 3, "供品箱", "祭扫供品木箱。", 0.55),
					_m(P_CRATE1, 3, 2, "纸钱箱", "纸钱与香烛箱。", 0.55),
					_m(P_LAMP_INDOOR, 3, -2, "墓灯", "西墓区冷蓝墓灯。", PROP),
				]),
				# Verb: 入穴 — east crypt door mass + rock perimeter + coin south.
				_cluster("crypt", 19, 7, [
					_m(P_CRYPT_DOOR, 0, 0, "穴门", "石砌拱门铁栅穴口（东侧主锚）。", 1.05),
					_m(P_ROCK2, -2, -1, "围石", "穴门西北围石体量。", 0.75),
					_m(P_ROCK1, 2, -1, "围石", "穴门东北围石体量。", 0.75),
					_m(P_ROCK0, -2, 1, "围石", "穴门西南围石。", 0.7),
					_m(P_ROCK3, 2, 1, "围石", "穴门东南围石。", 0.7),
					_m(P_COIN, 0, 2, "随葬箱", "穴门南随葬小箱（南站位可开）。", 0.65),
					_m(P_LAMP_INDOOR, 1, -2, "穴灯", "穴门顶冷灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 6, "ty": 6, "oy": -10, "color": Color(0.72, 0.76, 1.0), "energy": 0.75, "scale": 1.9},
				{"tx": 12, "ty": 5, "oy": -8, "color": Color(0.70, 0.74, 1.0), "energy": 0.55, "scale": 1.6},
				{"tx": 19, "ty": 5, "oy": -12, "color": Color(0.68, 0.72, 1.0), "energy": 0.9, "scale": 2.2},
			],
			"actor": {
				"id": "elder_woman",
				"title": "守墓人",
				"desc": "在西墓区碑列与东穴门之间踱步巡视。",
				"via_clusters": ["graves", "crypt"],
				"via_stands": {"graves": [1, 4], "crypt": [0, 3]},
			},
		},
		# ── C31 下水道：西长管段 · 中闸阀 · 东黑市摊（门轴 14–17 南廊清空；≠矿洞 C17）──
		"c31_sewer": {
			"title": "下水道",
			"hint": "下水道 · 管道段 / 黑市摊",
			"return_path": RES,
			"room_w": 32,
			"room_h": 11,
			"door_tx0": 14,
			"door_tx1": 17,
			"floor": "stone",
			"modulate": Color(0.40, 0.48, 0.46, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				# West horizontal pipe run — dedicated pipe segments along corridor.
				_cluster("pipe_run", 6, 4, [
					_m(P_SEWER_PIPE, 0, 0, "主管段", "西廊排污主管段。", 0.75),
					_m(P_SEWER_PIPE, 2, 0, "接管段", "水平接管。", 0.72),
					_m(P_SEWER_PIPE, 4, 0, "支管段", "横置支管。", 0.7),
					_m(P_CRATE0, 1, 1, "闸门箱", "管旁闸阀检修箱。", 0.7),
					_m(P_CRATE1, 3, 1, "法兰箱", "管件法兰箱。", 0.65),
					_m(P_TOOL_RACK, -1, 0, "管钳架", "管钳与扳手架。", 0.65),
					_m(P_SACK0, 0, 2, "堵漏沙袋", "管脚堵漏沙袋（不占门轴）。", 0.55),
					_m(P_LAMP_FARM, 2, -1, "隧灯", "管道检修灯。", PROP),
				]),
				# Mid junction north of door aisle — keeps south 14–17 clear.
				_cluster("junction", 15, 3, [
					_m(P_CRATE0, 0, 0, "总阀箱", "中段总阀检修箱。", 0.7),
					_m(P_BARREL, -2, 0, "溢流桶", "闸阀旁溢流桶。", 0.65),
					_m(P_PIPE_SCHEMATIC, 2, 0, "管网图", "下水支管走向图（非 notice 代理）。", 0.7),
					_m(P_LAMP_FARM, 1, -1, "阀灯", "闸阀区检修灯。", PROP),
				]),
				# East black-market booth — customer approach from west aisle.
				_cluster("black_market", 25, 5, [
					_m(P_COUNTER, 0, 0, "黑市摊", "管道东端黑市柜台（客西主东）。", 1.0),
					_m(P_STOOL_BAR, 1, 0, "摊主凳", "柜台东侧摊主位。", 0.75),
					_m(P_SHELF_GROCERY, 2, -1, "暗货架", "违禁货架体量。", 0.9),
					_m(P_SHELF, 2, 1, "暗货架", "下层暗货。", 0.85),
					_m(P_COIN, 0, -2, "赃箱", "柜台后赃物箱。", 0.7),
					_m(P_CRATE1, 1, 2, "走私箱", "摊脚走私木箱。", 0.75),
					_m(P_BASKET, -1, 1, "黑货筐", "柜西客侧旁筐（不挡站位）。", 0.7),
					_m(P_CIPHER_PLAQUE, -2, -1, "暗语牌", "接头暗号牌（非 notice 代理）。", 0.7),
					_m(P_LAMP_TAVERN, 0, -1, "摊烛", "黑市烛灯（非家用台灯）。", PROP),
				]),
			],
			# Stall booth boundary; west gaps open to pipe corridor.
			"enclosures": [
				{
					"rect": [22, 2, 30, 8],
					"prop_h": P_STALL_RAIL,
					"prop_v": P_STALL_RAIL_V,
					"corners": {
						"nw": P_STALL_CORNER_NW,
						"ne": P_STALL_CORNER_NE,
						"sw": P_STALL_CORNER_SW,
						"se": P_STALL_CORNER_SE,
					},
					"scale": 1.0,
					"title": "黑市摊位",
					"desc": "东端管道黑市围栏摊位（西向开口）。",
					"gaps": [[22, 4], [22, 5], [22, 6]],
				},
			],
			"rails": [],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 6, "ty": 3, "oy": -8, "color": Color(0.55, 0.85, 0.7), "energy": 0.65, "scale": 1.7},
				{"tx": 15, "ty": 2, "oy": -6, "color": Color(0.6, 0.88, 0.75), "energy": 0.55, "scale": 1.5},
				{"tx": 25, "ty": 4, "oy": -8, "color": Color(1.0, 0.78, 0.45), "energy": 0.85, "scale": 1.8},
			],
			"actor": {
				"id": "merchant",
				"title": "黑市摊主",
				"desc": "在管段检修点与东端黑市摊之间游走接头。",
				"via_clusters": ["pipe_run", "junction", "black_market"],
				"via_stands": {"pipe_run": [1, 2], "junction": [0, 2], "black_market": [-2, 1]},
			},
		},
		# ── Wave D stubs (enrich per-key only; remove 「占位」) ──
		# ── C32 市场后台：西卸货推车垛 · 东货架体量 · 东南休息（门轴 9–12 通廊）──
		"c32_market_back": {
			"title": "市场后台",
			"hint": "市场后台 · 卸货推车 / 货垛 / 休息角",
			"return_path": MKT,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "plank",
			"modulate": Color(0.86, 0.82, 0.74, 1.0),
			# Rug under rest nook (east of door corridor 9–12).
			"rug": {"ox": 15, "oy": 7},
			"window": true,
			"clusters": [
				# West dock unload — cart anchor + stacked crate/sack mass; leave tx 9–12 clear.
				_cluster("unload", 5, 5, [
					_m(P_HANDCART, 0, 0, "卸货推车", "西侧手推车（卸货锚；车斗载箱袋）。", 1.0),
					_m(P_CRATE0, -2, -1, "货箱垛", "推车西底垛货箱。", 0.9),
					_m(P_CRATE1, -1, -2, "叠箱", "西墙叠高待分拣箱。", 0.85),
					_m(P_CRATE0, 2, -1, "货箱", "推车东侧卸下箱。", 0.9),
					_m(P_CRATE1, 2, -2, "叠箱", "东侧第二层叠箱（体量）。", 0.8),
					_m(P_SACK0, -2, 1, "货袋", "贴垛待运麻袋。", 0.7),
					_m(P_SACK1, 1, 2, "货袋", "车前落地袋。", 0.65),
					_m(P_SACK0, 2, 1, "货袋", "东垛脚袋。", 0.6),
					_m(P_BARREL, -1, 2, "水桶", "卸货区冲洗桶（南站位西侧）。", 0.7),
					_m(P_LAMP_SHOP, 1, -3, "货栈灯", "卸货区吊罩店灯（非家用台灯）。", PROP),
				]),
				# East wall stock shelf mass — market return samples (≠ farm warehouse alone).
				_cluster("shelf", 17, 4, [
					_m(P_SHELF_GROCERY, 0, 0, "回货架", "东墙回货/样品架（竖向体量）。", 0.95),
					_m(P_CRATE1, -2, 1, "待上架箱", "架脚待拆箱。", 0.75),
					_m(P_BASKET, 1, 1, "分拣筐", "架前分拣筐。", 0.7),
					_m(P_SACK0, -1, 2, "零袋", "架脚零散袋。", 0.55),
				]),
				# Southeast rest nook — stool + notice; approach from west aisle.
				_cluster("rest", 16, 8, [
					_m(P_STOOL_BAR, 0, 0, "休息凳", "搬运工休息凳（交谈锚）。", 0.85),
					_m(P_SHIFT_BOARD, 1, -2, "排班牌", "壁挂排班与到货告示（非 notice 代理）。", 0.7),
					_m(P_BARREL, 2, 0, "饮水桶", "休息角饮水桶。", 0.65),
					_m(P_BASKET, -1, 1, "饭盒筐", "休息角饭盒筐。", 0.55),
					_m(P_LEDGER, -2, -1, "到货簿", "管事到货登记簿。", 0.55),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -10, "color": Color(1.0, 0.92, 0.75), "energy": 1.0, "scale": 2.0},
				{"tx": 17, "ty": 4, "oy": -8, "color": Color(1.0, 0.94, 0.8), "energy": 0.85, "scale": 1.7},
			],
			"actor": {
				"id": "merchant",
				"title": "货栈管事",
				"desc": "在卸货推车、回货架与休息凳之间巡视登记。",
				"via_clusters": ["unload", "shelf", "rest"],
				"via_stands": {
					"unload": [1, 2],
					"shelf": [-2, 2],
					"rest": [-2, 1],
				},
			},
		},
		# ── C33 夜市巷：西灯笼摊 · 北符签小摊 · 东稀有货（门轴 10–13 南廊清空；≠后台货栈/日间杂货）──
		"c33_night_market": {
			"title": "夜市巷",
			"hint": "夜市巷 · 灯笼摊 / 稀有货",
			"return_path": MKT,
			"room_w": 24,
			"room_h": 14,
			"door_tx0": 10,
			"door_tx1": 13,
			"floor": "dark",
			"modulate": Color(0.58, 0.56, 0.68, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				# West lantern bazaar — warm stall; customer approach from east aisle.
				_cluster("lantern_stall", 5, 5, [
					_m(P_COUNTER, 0, 0, "灯笼摊", "西廊灯笼摊柜台（客东主西）。", 1.0),
					_m(P_LANTERN_STRING, 0, -2, "灯笼串", "摊顶彩灯笼串（夜市剪影锚）。", 0.95),
					_m(P_STOOL_BAR, -1, 0, "摊主凳", "柜台西侧摊主位。", 0.75),
					_m(P_BASKET, 1, 1, "灯笼筐", "柜东客侧旁筐（不挡站位）。", 0.7),
					_m(P_BASKET, -2, 1, "纸灯筐", "摊脚备用纸灯筐。", 0.65),
					_m(P_NIGHT_MARKET_BOARD, 2, -1, "夜市牌", "灯笼价目与开摊暗号（非 notice 代理）。", 0.7),
					_m(P_LAMP_TAVERN, 1, -1, "摊烛", "暖烛灯（非家用台灯）。", PROP),
					_m(P_LAMP_TAVERN, -2, -1, "串烛", "灯笼串旁烛灯。", PROP),
				]),
				# North-east of door aisle — keeps tx 10–13 clear to north wall.
				_cluster("charm_booth", 15, 2, [
					_m(P_LEDGER, 0, 0, "符签摊", "北壁符签小摊台（偏东，让出中轴通廊）。", 0.85),
					_m(P_CHARM_LIST, 1, -1, "符单", "护身符价目单（非 notice 代理）。", 0.7),
					_m(P_BASKET, 2, 0, "符筐", "叠好的符纸筐。", 0.65),
					_m(P_STOOL_BAR, 0, 1, "守摊凳", "符签摊守摊凳（廊东站位）。", 0.7),
					_m(P_LAMP_SHOP, 0, -1, "巷灯", "北廊冷罩店灯。", PROP),
				]),
				# East rare-goods booth — cool glow + stock mass; customer from west aisle.
				_cluster("rare_goods", 19, 6, [
					_m(P_SHELF_GROCERY, 1, -1, "稀货架", "夜间稀有货架体量。", 0.95),
					_m(P_SHELF, 1, 1, "暗货架", "下层暗货。", 0.85),
					_m(P_RARE_CRATE, 0, 0, "稀货箱", "开盖稀有货箱（宝石/异物）。", 0.95),
					_m(P_COIN, 2, 1, "钱箱", "摊主钱箱。", 0.7),
					_m(P_CRATE1, -1, 2, "暗箱", "摊脚封条木箱。", 0.75),
					_m(P_BASKET, -2, 1, "客筐", "柜西客侧旁筐（不挡站位）。", 0.7),
					_m(P_LAMP_SHOP, -1, -2, "稀货灯", "稀货区罩灯（冷光感）。", PROP),
					_m(P_LAMP_TAVERN, 2, -1, "柜烛", "货架旁暖烛对比。", PROP),
				]),
			],
			# Stall booth boundaries; gaps open to mid door aisle (10–13).
			"enclosures": [
				{
					"rect": [1, 2, 8, 8],
					"prop_h": P_STALL_RAIL,
					"prop_v": P_STALL_RAIL_V,
					"corners": {
						"nw": P_STALL_CORNER_NW,
						"ne": P_STALL_CORNER_NE,
						"sw": P_STALL_CORNER_SW,
						"se": P_STALL_CORNER_SE,
					},
					"scale": 1.0,
					"title": "灯笼摊位",
					"desc": "西廊灯笼围栏摊位（东向开口）。",
					"gaps": [[8, 4], [8, 5], [8, 6]],
				},
				{
					"rect": [16, 3, 23, 9],
					"prop_h": P_STALL_RAIL,
					"prop_v": P_STALL_RAIL_V,
					"corners": {
						"nw": P_STALL_CORNER_NW,
						"ne": P_STALL_CORNER_NE,
						"sw": P_STALL_CORNER_SW,
						"se": P_STALL_CORNER_SE,
					},
					"scale": 1.0,
					"title": "稀货摊位",
					"desc": "东廊稀有货围栏摊位（西向开口）。",
					"gaps": [[16, 5], [16, 6], [16, 7]],
				},
			],
			"rails": [],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -12, "color": Color(1.0, 0.68, 0.38), "energy": 1.15, "scale": 2.2},
				{"tx": 15, "ty": 1, "oy": -8, "color": Color(0.75, 0.82, 1.0), "energy": 0.7, "scale": 1.5},
				{"tx": 19, "ty": 5, "oy": -10, "color": Color(0.78, 0.62, 1.0), "energy": 0.95, "scale": 1.9},
			],
			"actor": {
				"id": "merchant",
				"title": "夜市摊主",
				"desc": "在灯笼摊、符签小摊与稀货箱之间招呼夜客。",
				"via_clusters": ["lantern_stall", "charm_booth", "rare_goods"],
				"via_stands": {
					"lantern_stall": [2, 1],
					"charm_booth": [-1, 2],
					"rare_goods": [-2, 1],
				},
			},
		},
		# ── C37 农仓：西箱袋体量 · 东仓架拣货 · 南装车推车（门轴 9–12 通廊；≠ C03 畜栏 / ≠ C32 货栈休息）──
		"c37_warehouse": {
			"title": "农仓",
			"hint": "农仓 · 箱垛 / 袋垛 / 仓架 / 手推车",
			"return_path": FARM,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "plank",
			"modulate": Color(0.84, 0.80, 0.72, 1.0),
			"rug": null,
			"window": true,
			# West mass: tall crates+sacks; east shelves; cart bay west of door; aisle 9–12 clear.
			"clusters": [
				_cluster("crate_mass", 5, 5, [
					_m(P_GRAIN_STACK, 0, 0, "袋垛", "西墙麻袋高垛（体量锚）。", 0.9),
					_m(P_GRAIN_STACK, 2, -1, "袋垛", "第二袋垛叠高。", 0.8),
					_m(P_CRATE0, -1, -2, "木箱", "袋垛旁叠箱底。", 0.85),
					_m(P_CRATE1, 0, -3, "木箱", "叠高木箱。", 0.8),
					_m(P_CRATE0, 1, -2, "木箱", "侧垛木箱。", 0.75),
					_m(P_SACK0, -2, 1, "麻袋", "垛脚待运袋。", 0.65),
					_m(P_SACK1, 2, 2, "麻袋", "前脚麻袋（南可站）。", 0.6),
					_m(P_LAMP_FARM, 1, -2, "仓灯", "农场铁壳仓灯（非家用台灯）。", PROP),
				]),
				_cluster("shelf_aisle", 17, 5, [
					_m(P_SHELF, 0, 0, "仓架", "种子/农具仓架。", 0.95),
					_m(P_SHELF, 0, 2, "仓架", "下层仓架。", 0.9),
					_m(P_BARREL, 2, 1, "油桶", "备用油/种肥桶。", 0.75),
					_m(P_BASKET, -2, 1, "拣货筐", "拣货筐（南可站）。", 0.65),
					_m(P_CRATE1, 2, -1, "备货箱", "架旁备货箱。", 0.7),
					_m(P_LEDGER, -1, -1, "存货簿", "农仓库存登记。", 0.55),
					_m(P_LAMP_FARM, 2, -2, "架灯", "货架侧农场灯。", PROP),
				]),
				# Loading cart west of door axis — farm outbound, not market rest stool.
				_cluster("cart_bay", 6, 10, [
					_m(P_HANDCART, 0, 0, "手推车", "农仓装车用手推车。", 1.0),
					_m(P_CRATE0, 2, 0, "待装箱", "推车旁待装木箱（不占门轴）。", 0.7),
					_m(P_SACK0, 2, 1, "待装袋", "推车旁待装麻袋。", 0.6),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -8, "color": Color(1.0, 0.94, 0.8), "energy": 0.95, "scale": 2.0},
				{"tx": 17, "ty": 4, "oy": -8, "color": Color(1.0, 0.93, 0.78), "energy": 0.85, "scale": 1.8},
				{"tx": 6, "ty": 9, "oy": -6, "color": Color(1.0, 0.92, 0.76), "energy": 0.65, "scale": 1.5},
			],
			"actor": {
				"id": "farmer",
				"title": "仓管",
				"desc": "在箱袋垛、仓架与手推车之间清点装车。",
				"via_clusters": ["crate_mass", "shelf_aisle", "cart_bay"],
				"via_stands": {
					"crate_mass": [1, 2],
					"shelf_aisle": [-2, 2],
					"cart_bay": [1, -1],
				},
			},
		},
		"c38_workshop": {
			"title": "工坊",
			"hint": "工坊 · 西木工台钳 / 东酿料桶垛",
			"return_path": MKT,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "plank",
			"modulate": Color(0.85, 0.81, 0.74, 1.0),
			"rug": null,
			"window": true,
			# West craft bench (vise) ≠ C04 forge/anvil; east keg/crate mass; door 9–12 clear.
			"clusters": [
				_cluster("bench", 5, 5, [
					_m(P_CRAFT_BENCH, 0, 0, "木工台", "带台钳的木作台（非铁砧/锻炉）。", 1.0),
					_m(P_TOOL_RACK, -2, -1, "工具架", "刨凿锯钳挂架。", 0.85),
					_m(P_STOOL, 2, 1, "操作凳", "台前南站位操作凳。", 0.7),
					_m(P_CRATE0, 2, -1, "半成品箱", "台侧半成品木箱。", 0.65),
					_m(P_BASKET, -1, 2, "刨花筐", "刨花与边角料筐。", 0.55),
					_m(P_LAMP_SMITH, 1, -2, "工坊灯", "工坊铁壁灯（非家用台灯）。", PROP),
				]),
				_cluster("materials", 16, 6, [
					_m(P_BARREL_KEG, 0, 0, "酿料桶", "横置酿料/熟成桶（体量锚）。", 0.9),
					_m(P_BARREL, 2, 0, "原料桶", "竖放原料桶。", 0.85),
					_m(P_BARREL_KEG, 1, -1, "酿桶", "第二酿桶叠体量。", 0.75),
					_m(P_CRATE0, 3, 1, "木料箱", "板条与木料箱。", 0.75),
					_m(P_CRATE1, 2, 2, "瓶箱", "待装瓶成品箱。", 0.7),
					_m(P_SACK0, -1, 2, "木屑袋", "刨花袋。", 0.65),
					_m(P_SACK1, -2, 1, "辅料袋", "酿用辅料袋。", 0.6),
					_m(P_SHELF, 0, -2, "夹具搁板", "量尺与夹具搁板。", 0.7),
					_m(P_LAMP_SHOP, 2, -2, "料区灯", "料区吊罩店灯（非家用台灯）。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -10, "color": Color(1.0, 0.88, 0.65), "energy": 0.95, "scale": 1.9},
				{"tx": 16, "ty": 5, "oy": -8, "color": Color(1.0, 0.9, 0.72), "energy": 0.85, "scale": 1.7},
			],
			"actor": {
				"id": "merchant",
				"title": "工匠",
				"desc": "在木工台与酿料桶垛之间来回作业。",
				"via_clusters": ["bench", "materials"],
				"via_stands": {"bench": [1, 2], "materials": [-2, 1]},
			},
		},
		"c39_processing": {
			"title": "加工棚",
			"hint": "加工棚 · 奶酪压机 / 铜酿釜",
			"return_path": FLD,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "plank",
			"modulate": Color(0.86, 0.82, 0.74, 1.0),
			"rug": null,
			"window": true,
			# West cheese press machine; east brew kettle; door aisle 9–12 clear. ≠ C13 mill / C52 press.
			"clusters": [
				_cluster("cheese_press", 5, 5, [
					_m(P_CHEESE_PRESS, 0, 0, "奶酪压机", "西侧螺杆奶酪压机（工作锚）。", 1.0),
					_m(P_STOOL, 2, 1, "操作凳", "压机南侧操作位。", 0.7),
					_m(P_LAMP_FARM, 1, -2, "加工灯", "农场铁壳工作灯（非家用台灯）。", PROP),
					_m(P_BARREL, -2, 1, "奶桶", "待压凝乳奶桶。", 0.7),
					_m(P_BASKET, 2, -1, "凝乳筐", "滤布凝乳筐。", 0.55),
				]),
				_cluster("brew_vat", 16, 6, [
					_m(P_BREW_VAT, 0, 0, "铜酿釜", "东侧开口铜酿釜与放酒嘴（第二机具）。", 1.0),
					_m(P_BASKET, 2, 1, "果筐", "待酿果筐。", 0.7),
					_m(P_CRATE1, -2, 1, "瓶箱", "成品瓶箱（站位西侧）。", 0.75),
					_m(P_SACK0, 2, -1, "麦芽袋", "酿釜旁麦芽袋。", 0.6),
					_m(P_CRATE0, 3, 2, "空瓶箱", "待灌空瓶。", 0.55),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -10, "color": Color(1.0, 0.95, 0.82), "energy": 1.0, "scale": 2.0},
				{"tx": 16, "ty": 5, "oy": -8, "color": Color(1.0, 0.92, 0.78), "energy": 0.9, "scale": 1.8},
			],
			"actor": {
				"id": "farmer",
				"title": "加工工",
				"desc": "在奶酪压机与铜酿釜之间操作。",
				"via_clusters": ["cheese_press", "brew_vat"],
				"via_stands": {
					"cheese_press": [2, 2],
					"brew_vat": [-2, 2],
				},
			},
		},
		# ── C51 蜂场：西蜂箱列 · 东蜜源花田体量 · 南门 9–12 通廊（≠仓房木箱垛）──
		"c51_apiary": {
			"title": "蜂场",
			"hint": "蜂场 · 蜂箱列 / 蜜源花田",
			"return_path": FLD,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "straw",
			# Soft meadow green wash (not warehouse orange).
			"modulate": Color(0.86, 0.90, 0.78, 1.0),
			"rug": null,
			"window": true,
			# West hives (≥2 Langstroth silhouettes); east flower mass; door aisle 9–12 clear.
			"clusters": [
				_cluster("hives", 5, 5, [
					_m(P_BEEHIVE, 0, 0, "蜂箱", "西列 Langstroth 三层蜂箱（工作锚）。", 0.95),
					_m(P_BEEHIVE, 2, 0, "蜂箱", "西列第二蜂箱。", 0.9),
					_m(P_BEEHIVE, 1, -2, "蜂箱", "北侧第三蜂箱（簇可读）。", 0.85),
					_m(P_LAMP_FARM, 3, -2, "场灯", "农场铁壳场灯（非家用台灯）。", PROP),
					_m(P_TOOL_RACK, -2, 0, "养蜂架", "烟熏器与刮刀架。", 0.55),
					_m(P_BASKET, 0, 2, "蜜筐", "取蜜筐（南站位可交互）。", 0.65),
				]),
				_cluster("flowers", 16, 6, [
					_m(P_FLOWER_BED, 0, 0, "蜜源花田", "东侧蜜源花床体量（花田锚）。", 0.95),
					_m(P_FLOWER_BED, 2, 1, "蜜源花田", "东南第二花床。", 0.85),
					_m(P_FLOWER_BED, -1, -1, "蜜源花田", "花田西北补块。", 0.75),
					_m(P_HAY, 2, -2, "干草垫", "花田北缘干草垫。", 0.5),
					_m(P_BASKET, -2, 2, "花筐", "采花粉筐。", 0.6),
					_m(P_SACK0, 3, 2, "蜂粮袋", "越冬糖浆/蜂粮袋。", 0.55),
				]),
			],
			"fx": [],
			# No bee ambient species in AmbientCritter catalog — leave empty (do not invent).
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -10, "color": Color(1.0, 0.98, 0.86), "energy": 0.95, "scale": 2.0},
				{"tx": 16, "ty": 5, "oy": -8, "color": Color(0.98, 1.0, 0.88), "energy": 0.85, "scale": 1.8},
			],
			"actor": {
				"id": "farmer",
				"title": "养蜂人",
				"desc": "在蜂箱列与蜜源花田之间巡视取蜜。",
				"via_clusters": ["hives", "flowers"],
				"via_stands": {
					"hives": [1, 2],
					"flowers": [-2, 2],
				},
			},
		},
		# ── C52 果园附属：西果垛体量 · 东单机榨汁房（≠ C39 双机奶酪/酿桶）──
		"c52_orchard_store": {
			"title": "果仓",
			"hint": "果仓 · 果垛 / 榨汁压机",
			"return_path": FARM,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "plank",
			"modulate": Color(0.90, 0.86, 0.76, 1.0),
			"rug": null,
			"window": true,
			# West mass: crate stack + baskets; east work: single screw press; door 9–12 clear.
			"clusters": [
				_cluster("fruit_mass", 5, 5, [
					_m(P_FRUIT_CRATE_STACK, 0, 0, "果箱垛", "苹果梨箱高垛（体量锚）。", 0.95),
					_m(P_BASKET, 2, 1, "拣果筐", "鲜果拣选筐。", 0.75),
					_m(P_CRATE1, -2, 1, "果箱", "待入垛木箱。", 0.7),
					_m(P_BASKET, 1, 2, "果筐", "次拣果筐。", 0.65),
					_m(P_SACK0, 3, 0, "衬垫袋", "箱底稻草垫袋。", 0.55),
					_m(P_LAMP_FARM, 0, -2, "果仓灯", "农场铁壳工作灯（非家用台灯）。", PROP),
				]),
				_cluster("press", 16, 6, [
					_m(P_FRUIT_PRESS, 0, 0, "榨汁压机", "木架螺杆果压机（单机工作锚）。", 1.0),
					_m(P_BARREL, 2, 1, "果汁桶", "压出果汁承接桶。", 0.75),
					_m(P_SACK0, -2, 1, "果渣袋", "压渣出料袋。", 0.65),
					_m(P_CRATE0, 2, -1, "瓶箱", "果汁瓶装箱。", 0.7),
					_m(P_TOOL_RACK, 1, -3, "压机架", "压机检修扳手。", 0.55),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -8, "color": Color(1.0, 0.95, 0.82), "energy": 0.95, "scale": 1.9},
				{"tx": 16, "ty": 5, "oy": -10, "color": Color(1.0, 0.93, 0.78), "energy": 0.9, "scale": 1.85},
			],
			"actor": {
				"id": "farmer",
				"title": "果仓工",
				"desc": "在果垛与榨汁压机之间忙碌，偶尔倒渣装瓶。",
				"via_clusters": ["fruit_mass", "press"],
				"via_stands": {
					"fruit_mass": [2, 2],
					"press": [-2, 2],
				},
			},
		},
		# ── Wave E enriched (C46–C50; desk QA PASS) ──
		# ── C46 二楼：西卧室睡区 · 东阳台眺望（门轴 9–12；楼梯回 C01）──
		"c46_second_floor": {
			"title": "建筑二楼",
			"hint": "二楼 · 卧室睡区 / 阳台眺望",
			"return_path": SceneRouter.C01_HOME_PATH,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "plank",
			"modulate": Color(0.88, 0.84, 0.78, 1.0),
			# Rug under bedroom (west of mid door aisle 9–12).
			"rug": {"ox": 5, "oy": 6},
			"window": true,
			"clusters": [
				# West sleep — peer C01/C02 bed+dresser+lamp; south approach free.
				_cluster("bedroom", 5, 5, [
					_m(P_BED_S, 0, 1, "单人床", "西卧私密睡区（南侧站位可交互）。", 1.0),
					_m(P_DRESSER, 0, -2, "衣柜", "床头北墙衣柜。", 0.9),
					_m(P_LAMP_INDOOR, 2, -2, "壁灯", "卧室暖黄壁灯。", PROP),
					_m(P_BASKET, 2, 1, "衣篮", "床脚脏衣/换洗衣篮（不堵南站位）。", 0.55),
					_m(P_STOOL_TEA, -2, 1, "床边凳", "西侧轻起居矮凳（同家族；西站位）。", 0.7),
				]),
				# East balcony — railing silhouette ≠ attic crates / open roof deck.
				_cluster("balcony", 16, 5, [
					_m(P_BALCONY_RAIL, 1, -1, "阳台栏杆", "东缘木栏眺望（签名 prop；≠篱笆/畜栏）。", 1.05),
					_m(P_STOOL, 0, 1, "眺望凳", "栏前眺望矮凳（南站位可交互）。", 0.75),
					_m(P_FLOWER_BED, -1, -2, "花箱", "阳台花箱（靠栏内侧）。", 0.7),
					_m(P_HERBS, 2, -2, "盆栽", "栏角草本小盆。", 0.55),
				]),
			],
			"fx": [],
			"ambient": [{"species": "cat", "cluster": "balcony", "dx": -2, "dy": 0}],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -10, "color": Color(1.0, 0.9, 0.7), "energy": 0.9, "scale": 1.8},
				{"tx": 16, "ty": 4, "oy": -8, "color": Color(1.0, 0.95, 0.82), "energy": 0.75, "scale": 1.6},
			],
			"actor": {
				"id": "farmer",
				"title": "住户",
				"desc": "在卧室与阳台之间走动，偶尔凭栏眺望。",
				"via_clusters": ["bedroom", "balcony"],
				"via_stands": {
					"bedroom": [0, 3],
					"balcony": [0, 2],
				},
			},
			# Lead-seeded stairs to attic / roof (keep; clear of door aisle 9–12).
			"extra_portals": [
				{
					"tx": 3,
					"ty": 11,
					"label": "↑阁楼",
					"path": SceneRouter.C47_ATTIC_PATH,
				},
				{
					"tx": 18,
					"ty": 11,
					"label": "↑屋顶",
					"path": SceneRouter.C48_ROOF_PATH,
				},
			],
		},
		# ── C47 阁楼：西旧箱垛 · 东蛛网秘密角（门轴 8–11；≠ C15 石窖酒桶）──
		"c47_attic": {
			"title": "阁楼",
			"hint": "阁楼 · 旧箱垛 / 蛛网 / 秘密",
			"return_path": SceneRouter.C46_SECOND_FLOOR_PATH,
			"room_w": 20,
			"room_h": 12,
			"door_tx0": 8,
			"door_tx1": 11,
			"floor": "plank",
			"modulate": Color(0.64, 0.60, 0.52, 1.0),
			"rug": null,
			"window": false,
			# West storage mass (height via stacked crates); east secret behind cobweb; aisle 8–11 clear.
			"clusters": [
				_cluster("trunks", 5, 4, [
					_m(P_TRUNK_OLD, 0, 0, "旧皮箱", "积灰老式旅行皮箱（体量锚）。", 1.0),
					_m(P_CRATE0, -1, -2, "旧木箱", "西墙底垛木箱。", 0.85),
					_m(P_CRATE1, 0, -3, "叠箱", "叠高积灰木箱。", 0.8),
					_m(P_CRATE0, 1, -2, "侧箱", "侧垛木箱。", 0.75),
					_m(P_CRATE1, 2, -1, "前叠箱", "前脚叠箱（南可站）。", 0.7),
					_m(P_SACK0, -2, 1, "尘袋", "蒙尘麻袋。", 0.65),
					_m(P_SACK1, 2, 1, "旧袋", "垛脚旧袋。", 0.6),
					_m(P_COBWEB, 2, -3, "垛角蛛网", "箱垛顶角蛛网。", 0.55),
					_m(P_LAMP_INDOOR, 1, -1, "阁楼灯", "昏黄油灯。", PROP),
				]),
				_cluster("secret", 15, 5, [
					_m(P_COIN, 0, 0, "秘密箱", "蛛网后的小宝箱。", 0.75),
					_m(P_COBWEB, -1, -1, "遮箱蛛网", "挡在宝箱前的蛛网。", 0.7),
					_m(P_ROCKING, -2, 1, "旧摇椅", "蒙尘老家具。", 0.7),
					_m(P_DRESSER, 2, -1, "旧柜", "阁楼东角旧衣柜。", 0.75),
					_m(P_BASKET, 1, 2, "旧筐", "忘在角落的空筐（南可站）。", 0.55),
					_m(P_COBWEB, 2, 1, "角蛛网", "东墙角蛛网。", 0.5),
					_m(P_LAMP_INDOOR, -1, -2, "角灯", "秘密角昏灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [{"species": "cat", "cluster": "trunks", "dx": 2, "dy": 2}],
			"lights": [
				{"tx": 5, "ty": 3, "oy": -8, "color": Color(1.0, 0.78, 0.42), "energy": 0.65, "scale": 1.5},
				{"tx": 15, "ty": 4, "oy": -6, "color": Color(1.0, 0.72, 0.38), "energy": 0.55, "scale": 1.4},
			],
			"actor": {},
		},
		# ── C48 屋顶：西烟囱 · 东晾衣 · 东南观星（门轴 9–12；露天石面夜调）──
		"c48_roof": {
			"title": "屋顶",
			"hint": "屋顶 · 烟囱 / 晾衣 / 观星",
			"return_path": SceneRouter.C46_SECOND_FLOOR_PATH,
			"room_w": 22,
			"room_h": 12,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			# Cool night wash (blue-grey) — not orange; open sky-deck vs meadow apiary.
			"modulate": Color(0.60, 0.66, 0.84, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				# West primary: tall outdoor chimney (≠ indoor fireplace).
				_cluster("chimney", 5, 4, [
					_m(P_CHIMNEY, 0, 0, "烟囱", "西侧砖砌屋顶烟囱（剪影锚）。", 1.0),
					_m(P_BARREL, 2, 1, "雨水桶", "烟囱脚雨水桶。", 0.65),
					_m(P_STOOL, 1, 2, "暖脚凳", "烟囱南脚矮凳（猫旁站位可交互）。", 0.7),
					_m(P_CRATE0, -2, 1, "瓦箱", "修瓦小木箱。", 0.55),
				]),
				# East laundry — real clothesline (≠ herbs rename).
				_cluster("clothesline", 15, 4, [
					_m(P_CLOTHESLINE, 0, 0, "晾衣绳", "东侧两柱晾衣绳（衣物可读）。", 0.9),
					_m(P_BASKET, 2, 2, "衣筐", "晾衣南侧衣筐（站位可交互）。", 0.6),
					_m(P_BASKET, -2, 1, "衣筐", "未晒衣筐。", 0.55),
				]),
				# SE star deck — telescope + stool + tavern candle.
				_cluster("star_deck", 17, 7, [
					_m(P_TELESCOPE, 0, 0, "望远镜", "东南观星望远镜（工作锚）。", 0.9),
					_m(P_STOOL, -2, 1, "观星凳", "镜西矮凳（并排站位）。", 0.7),
					_m(P_LAMP_TAVERN, 2, 0, "屋顶烛", "夜观星小烛（非农场工业灯）。", PROP),
					_m(P_CRATE1, 1, 2, "星图箱", "星图/镜头小箱。", 0.5),
				]),
			],
			"fx": [],
			"ambient": [{"species": "cat", "cluster": "chimney", "dx": 2, "dy": 2}],
			"lights": [
				{"tx": 5, "ty": 3, "oy": -16, "color": Color(1.0, 0.86, 0.68), "energy": 0.65, "scale": 1.45},
				{"tx": 17, "ty": 6, "oy": -8, "color": Color(0.72, 0.84, 1.0), "energy": 0.85, "scale": 1.85},
			],
			"actor": {},
		},
		# ── C49 后院：西菜园体量 · 东柴垛/狗屋 · 西南晾衣（门轴 9–12 通廊；≠ C03 鸡舍 / ≠ C51 蜂场）──
		"c49_backyard": {
			"title": "后院",
			"hint": "后院 · 菜园 / 晾衣 / 柴垛 / 狗屋",
			"return_path": RES,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "straw",
			# Soft yard green wash (apiary-like; not warehouse orange / home lamp).
			"modulate": Color(0.86, 0.90, 0.78, 1.0),
			"rug": null,
			"window": true,
			# West garden mass; east wood+doghouse; SW clothesline clear of mid door aisle.
			"clusters": [
				_cluster("garden", 5, 5, [
					_m(P_FLOWER_BED, 0, 0, "菜畦", "西侧菜园畦（主锚）。", 0.95),
					_m(P_FLOWER_BED, 2, 1, "菜畦", "东南第二畦（体量）。", 0.85),
					_m(P_FLOWER_BED, -1, -1, "菜畦", "西北补畦。", 0.75),
					_m(P_BASKET, 2, -1, "菜筐", "采菜筐（北可站）。", 0.65),
					_m(P_BARREL, -2, 1, "浇水桶", "菜园浇水桶。", 0.65),
					_m(P_SACK0, 1, 2, "肥土袋", "畦脚堆肥袋（南站位可交互）。", 0.55),
					_m(P_LAMP_FARM, 0, -2, "院灯", "后院农场铁壳灯（非家用台灯）。", PROP),
				]),
				_cluster("wood_dog", 16, 5, [
					_m(P_WOOD_PILE, 0, 0, "柴垛", "东侧劈柴高垛（体量锚）。", 0.95),
					_m(P_DOGHOUSE, 2, 1, "狗屋", "柴旁尖顶狗屋（签名 prop）。", 0.85),
					_m(P_CRATE0, -2, 1, "柴箱", "待劈短柴箱。", 0.65),
					_m(P_HAY, 2, -1, "垫草", "狗屋旁垫草。", 0.5),
					_m(P_LAMP_FARM, 1, -2, "柴区灯", "柴垛侧农场灯。", PROP),
				]),
				# Clothesline SW of door axis — laundry readable, mid 9–12 free.
				_cluster("line", 5, 10, [
					_m(P_CLOTHESLINE, 0, 0, "晾衣绳", "西南两柱晾衣（签名 prop）。", 1.0),
					_m(P_BASKET, 2, 1, "衣筐", "收衣筐（不占门轴）。", 0.55),
				]),
			],
			"fx": [],
			"ambient": [{"species": "dog", "cluster": "wood_dog", "dx": 1, "dy": 2}],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -8, "color": Color(1.0, 0.98, 0.88), "energy": 0.9, "scale": 1.9},
				{"tx": 16, "ty": 4, "oy": -8, "color": Color(1.0, 0.96, 0.86), "energy": 0.8, "scale": 1.7},
			],
			"actor": {
				"id": "farmer",
				"title": "宅院住户",
				"desc": "在菜园、柴垛与晾衣绳之间打理后院。",
				"via_clusters": ["garden", "wood_dog", "line"],
				"via_stands": {
					"garden": [1, 2],
					"wood_dog": [-2, 2],
					"line": [2, 1],
				},
			},
		},
		# ── C50 农场地窖：西酒窖体量 · 东腌菜/奶酪陈化生产（≠ C15 家用储藏）──
		# Door aisle tx 9–12 clear; lamp_farm only; signature aging/crock/wine props.
		"c50_farm_cellar": {
			"title": "农场地窖",
			"hint": "农场地窖 · 酒窖 / 腌菜 / 奶酪陈化",
			"return_path": FARM,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.52, 0.54, 0.50, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				# West wine — keg mass + bottle rack volume (production cellar ≠ C15 mug shelf).
				_cluster("wine", 5, 5, [
					_m(P_WINE_RACK, 0, 0, "酒架", "菱格瓶架（陈酿成品体量锚）。", 1.0),
					_m(P_BARREL_KEG, -2, 1, "陈酿桶", "西墙横置陈酿大桶。", 0.95),
					_m(P_BARREL_KEG, 2, 1, "陈酿桶", "架东第二横桶（体量）。", 0.9),
					_m(P_BARREL, -1, 2, "立桶", "竖放待装瓶桶。", 0.85),
					_m(P_BARREL, 2, 2, "立桶", "架脚叠放立桶。", 0.8),
					_m(P_BARREL_KEG, 1, -2, "上层桶", "北壁第三陈酿桶（竖向体量）。", 0.75),
					_m(P_CRATE0, 3, 0, "瓶箱", "待上架空瓶箱。", 0.7),
					_m(P_LAMP_FARM, -2, -2, "酒窖灯", "农场铁壳灯（非家用台灯）。", PROP),
				]),
				# East cure — pickle crocks + cheese aging rack (≠ C39 screw press).
				_cluster("cure", 16, 5, [
					_m(P_CHEESE_AGING, 0, 0, "陈化架", "多层奶酪轮陈化架（非压机）。", 1.0),
					_m(P_PICKLE_CROCK, -2, 1, "腌菜缸", "釉陶腌菜缸簇（生产锚）。", 0.95),
					_m(P_SHELF, 2, -1, "罐架", "酱菜罐与标签搁板（竖向体量）。", 0.85),
					_m(P_SACK1, -2, 2, "盐袋", "腌渍粗盐袋。", 0.7),
					_m(P_SACK0, 1, 2, "麸袋", "奶酪包浆麸皮袋。", 0.65),
					_m(P_CRATE1, 2, 1, "罐箱", "待封酱菜罐箱。", 0.75),
					_m(P_BASKET, 3, 2, "检视筐", "抽检奶酪轮筐（南站位东）。", 0.6),
					_m(P_LAMP_FARM, 1, -2, "腌房灯", "农场铁壳灯（非家用台灯）。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -10, "color": Color(0.95, 0.82, 0.55), "energy": 0.75, "scale": 1.8},
				{"tx": 16, "ty": 4, "oy": -8, "color": Color(0.92, 0.78, 0.5), "energy": 0.7, "scale": 1.6},
			],
			"actor": {
				"id": "farmer",
				"title": "地窖农丁",
				"desc": "在酒窖桶垛与腌菜/奶酪陈化架之间巡视翻缸检轮。",
				"via_clusters": ["wine", "cure"],
				"via_stands": {
					"wine": [1, 2],
					"cure": [-2, 2],
				},
			},
		},

		# ── Wave F stubs (region teams enrich per-key; remove 「占位」) ──
		"c40_museum": {
			"title": "博物馆",
			"hint": "博物馆 · 西展厅展柜 / 东捐赠台",
			"return_path": SQ,
			"room_w": 24,
			"room_h": 14,
			"door_tx0": 10,
			"door_tx1": 13,
			"floor": "stone",
			"modulate": Color(0.86, 0.84, 0.80, 1.0),
			"rug": null,
			"window": true,
			# West exhibit hall (glass case mass); east donation desk; aisle 10–13 clear.
			"clusters": [
				_cluster("exhibit", 6, 5, [
					_m(P_EXHIBIT_CASE, 0, 0, "化石展柜", "玻璃化石展柜（展厅主锚；≠货架）。", 1.0),
					_m(P_EXHIBIT_CASE, 0, 2, "矿石展柜", "第二展柜叠体量。", 0.9),
					_m(P_CRATE0, 2, 1, "标本箱", "待编目标本箱。", 0.7),
					_m(P_CRATE1, 3, -1, "古物箱", "侧墙古物木箱。", 0.65),
					_m(P_EXHIBIT_GUIDE, -2, -2, "展厅导览", "展厅分区导览牌（非 notice 代理）。", 0.7),
					_m(P_STOOL, 2, 2, "观展凳", "展柜南观展凳（可站）。", 0.7),
					_m(P_LAMP_SHOP, 1, -2, "展厅灯", "展厅吊罩灯（非家用台灯）。", PROP),
				]),
				_cluster("donate", 17, 6, [
					_m(P_COUNTER, 0, 0, "捐赠台", "前台捐赠登记台。", 0.95),
					_m(P_LEDGER, 1, -1, "捐赠簿", "捐赠登记簿（钩子可读）。", 0.65),
					_m(P_COIN, 2, 0, "捐款匣", "台侧捐款木匣。", 0.7),
					_m(P_DONATION_BOARD, -1, -2, "捐赠告示", "欢迎捐赠化石/矿石告示（非 notice 代理）。", 0.7),
					_m(P_STOOL, -1, 1, "访客凳", "台前南站位访客凳。", 0.7),
					_m(P_BASKET, 2, 1, "捐赠筐", "小件捐赠筐。", 0.55),
					_m(P_LAMP_SHOP, 2, -2, "前台灯", "捐赠台侧店灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 6, "ty": 4, "oy": -8, "color": Color(1.0, 0.95, 0.85), "energy": 0.95, "scale": 1.9},
				{"tx": 17, "ty": 5, "oy": -8, "color": Color(1.0, 0.94, 0.82), "energy": 0.85, "scale": 1.7},
			],
			"actor": {
				"id": "merchant",
				"title": "馆员",
				"desc": "在展厅与捐赠台之间巡视登记。",
				"via_clusters": ["exhibit", "donate"],
				"via_stands": {"exhibit": [2, 2], "donate": [-2, 2]},
			},
		},
		"c41_aquarium": {
			"title": "水族馆",
			"hint": "水族馆 · 西水缸墙 / 东钓鱼捐赠台",
			"return_path": LAKE,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.70, 0.78, 0.86, 1.0),
			"rug": null,
			"window": false,
			# West tank wall mass; east fish-donate counter; aisle 9–12 clear.
			"clusters": [
				_cluster("tanks", 6, 5, [
					_m(P_FISH_TANK, 0, 0, "展示水缸", "玻璃展示水缸（水缸区主锚；≠货架）。", 1.05),
					_m(P_FISH_TANK, 0, 2, "侧缸", "第二水缸叠体量。", 0.95),
					_m(P_BARREL, 2, 1, "滤桶", "过滤循环水桶。", 0.7),
					_m(P_BASKET, -1, 2, "鱼食筐", "喂食筐（南可站）。", 0.55),
					_m(P_CRATE0, -2, -1, "设备箱", "气泵/滤材箱（西侧，不占门轴）。", 0.65),
					_m(P_LAMP_SHOP, 1, -2, "缸顶灯", "水缸顶吊罩灯（非家用台灯）。", PROP),
				]),
				_cluster("donate_fish", 16, 6, [
					_m(P_COUNTER, 0, 0, "捐赠台", "钓鱼捐赠登记台。", 0.9),
					_m(P_ROD_BAMBOO, -2, 0, "展示竿", "捐赠挂钩展示竿。", 0.7),
					_m(P_LEDGER, 1, -1, "鱼谱", "捐赠鱼种登记谱（钩子可读）。", 0.65),
					_m(P_DONATION_BOARD, 2, -2, "捐赠告示", "欢迎捐赠活鱼告示（非 notice 代理）。", 0.65),
					_m(P_BARREL, 2, 1, "暂养桶", "捐赠暂养水桶。", 0.7),
					_m(P_STOOL, -1, 1, "登记凳", "台前南站位凳。", 0.7),
					_m(P_LAMP_SHOP, 1, -2, "台灯", "捐赠台侧店灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 6, "ty": 4, "oy": -8, "color": Color(0.75, 0.9, 1.0), "energy": 1.0, "scale": 2.0},
				{"tx": 16, "ty": 5, "oy": -8, "color": Color(0.8, 0.92, 1.0), "energy": 0.85, "scale": 1.7},
			],
			"actor": {
				"id": "merchant",
				"title": "饲养员",
				"desc": "在水缸墙与钓鱼捐赠台之间照料登记。",
				"via_clusters": ["tanks", "donate_fish"],
				"via_stands": {"tanks": [2, 2], "donate_fish": [-2, 2]},
			},
		},
		"c42_hotspring": {
			"title": "温泉",
			"hint": "温泉 · 东泡池蒸汽 / 西更衣",
			"return_path": HILL,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.88, 0.82, 0.78, 1.0),
			"rug": null,
			"window": true,
			# East irregular soak pool + steam; west change; aisle 9–12 clear. ≠ civic bath rectangle.
			"clusters": [
				_cluster("pool", 16, 5, [
					_m(P_SOAK_POOL, 0, 0, "温泉泡池", "山石温泉泡池（蒸汽可读；≠矩形浴池）。", 1.05),
					_m(P_ROCK0, 2, 0, "池缘石", "东缘叠石。", 0.65),
					_m(P_ROCK1, 1, -2, "池缘石", "北缘叠石（不占门轴）。", 0.6),
					_m(P_STOOL, 1, 2, "池边凳", "入池前东南站位凳。", 0.7),
					_m(P_HERBS, 2, -2, "药草束", "池北药草晾挂。", 0.55),
					_m(P_BASKET, 2, 2, "毛巾筐", "池边毛巾筐。", 0.55),
				]),
				_cluster("change", 5, 8, [
					_m(P_DRESSER, 0, 0, "更衣柜", "温泉更衣柜。", 0.85),
					_m(P_BASKET, 2, 1, "衣筐", "更衣衣筐。", 0.6),
					_m(P_STOOL, 1, 2, "换衣凳", "更衣南站位凳。", 0.7),
					_m(P_LAMP_INDOOR, 1, -2, "更衣灯", "暖黄更衣壁灯。", PROP),
					_m(P_BATH_RULES, -1, -2, "浴规牌", "更衣/入池须知（非 notice 代理）。", 0.6),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 16, "ty": 4, "oy": -6, "color": Color(1.0, 0.9, 0.8), "energy": 0.95, "scale": 2.1},
				{"tx": 5, "ty": 7, "oy": -8, "color": Color(1.0, 0.88, 0.7), "energy": 0.75, "scale": 1.5},
			],
			"actor": {
				"id": "elder_woman",
				"title": "泉守",
				"desc": "在泡池与更衣区之间照看客人。",
				"via_clusters": ["pool", "change"],
				"via_stands": {"pool": [1, 2], "change": [2, 2]},
			},
		},
		"c43_bathhouse": {
			"title": "公共浴场",
			"hint": "浴场 · 东矩形浴池 / 西更衣柜",
			"return_path": SQ,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.84, 0.86, 0.88, 1.0),
			"rug": null,
			"window": true,
			# East tiled civic bath; west locker; aisle 9–12 clear. ≠ mountain soak irregular rim.
			"clusters": [
				_cluster("bath", 16, 5, [
					_m(P_BATH_POOL, 0, 0, "公共浴池", "瓷砖矩形浴池（镇区浴场；≠山石温泉）。", 1.0),
					_m(P_STOOL, 1, 2, "池凳", "池东南站位凳（不占门轴）。", 0.7),
					_m(P_BARREL, 3, 1, "冲洗桶", "入池前冲洗桶。", 0.75),
					_m(P_BASKET, 2, 2, "毛巾筐", "池边毛巾筐。", 0.55),
					_m(P_BATH_RULES, 1, -2, "浴场须知", "公共浴场开放须知（非 notice 代理）。", 0.6),
				]),
				_cluster("locker", 5, 7, [
					_m(P_DRESSER, 0, 0, "更衣柜", "公共更衣柜。", 0.85),
					_m(P_DRESSER, 0, 2, "更衣柜", "第二更衣柜叠体量。", 0.8),
					_m(P_BASKET, 2, 0, "衣筐", "更衣衣筐。", 0.6),
					_m(P_STOOL, 2, 2, "换衣凳", "更衣南站位凳。", 0.7),
					_m(P_LAMP_INDOOR, 1, -2, "浴场灯", "更衣壁灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 16, "ty": 4, "oy": -8, "color": Color(0.95, 0.95, 1.0), "energy": 0.9, "scale": 1.9},
				{"tx": 5, "ty": 6, "oy": -8, "color": Color(0.95, 0.94, 0.98), "energy": 0.75, "scale": 1.5},
			],
			"actor": {
				"id": "merchant",
				"title": "浴场管事",
				"desc": "在浴池与更衣柜之间巡场。",
				"via_clusters": ["bath", "locker"],
				"via_stands": {"bath": [1, 2], "locker": [2, 2]},
			},
		},
		"c44_inn": {
			"title": "旅馆",
			"hint": "旅馆 · 西大厅前台铃 / 东客房睡区",
			"return_path": MKT,
			"room_w": 26,
			"room_h": 16,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "plank",
			"modulate": Color(0.88, 0.82, 0.74, 1.0),
			"rug": {"ox": 8, "oy": 7},
			"window": true,
			# West lobby desk+bell; east guest bed; aisle 11–14 clear.
			"clusters": [
				_cluster("lobby", 7, 6, [
					_m(P_INN_DESK, 0, 0, "旅馆前台", "带服务铃的旅馆前台（≠普通柜台）。", 1.0),
					_m(P_LEDGER, 1, -1, "住宿簿", "住宿登记簿。", 0.65),
					_m(P_STOOL_BAR, -1, 1, "店主凳", "前台后店主位。", 0.75),
					_m(P_STOOL, 2, 2, "访客凳", "台前南站位访客凳。", 0.7),
					_m(P_COIN, 2, 0, "账匣", "房费账匣。", 0.65),
					_m(P_INN_RATE_BOARD, -2, -2, "房价牌", "房价与空房告示（非 notice 代理）。", 0.65),
					_m(P_LAMP_INDOOR, 2, -2, "大厅灯", "大厅暖壁灯。", PROP),
				]),
				_cluster("guest", 19, 7, [
					_m(P_BED_S, 0, 0, "客房床", "东侧一间客房睡区。", 1.0),
					_m(P_DRESSER, 0, -2, "床头柜", "客房床头柜。", 0.8),
					_m(P_BASKET, 2, 1, "行囊筐", "旅客行囊筐。", 0.55),
					_m(P_STOOL, -2, 1, "床边凳", "床西站位凳。", 0.7),
					_m(P_LAMP_INDOOR, 2, -1, "床灯", "客房床头灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [{"species": "cat", "cluster": "lobby", "dx": 3, "dy": 2}],
			"lights": [
				{"tx": 7, "ty": 5, "oy": -8, "color": Color(1.0, 0.9, 0.7), "energy": 0.95, "scale": 1.9},
				{"tx": 19, "ty": 6, "oy": -8, "color": Color(1.0, 0.88, 0.65), "energy": 0.85, "scale": 1.6},
			],
			"actor": {
				"id": "merchant",
				"title": "店主",
				"desc": "在前台与客房之间招呼旅客。",
				"via_clusters": ["lobby", "guest"],
				"via_stands": {"lobby": [2, 2], "guest": [-2, 2]},
			},
		},
		"c45_tavern_up": {
			"title": "酒馆二楼",
			"hint": "酒馆二楼 · 西客房 / 东密会帷幕",
			"return_path": SceneRouter.C04_TAVERN_PATH,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "dark",
			"modulate": Color(0.68, 0.60, 0.54, 1.0),
			"rug": {"ox": 5, "oy": 6},
			"window": true,
			# West guest bed; east secret curtain + meeting table; aisle 9–12 clear; return C04.
			"clusters": [
				_cluster("guest", 5, 5, [
					_m(P_BED_S, 0, 0, "客房床", "酒馆二楼客房睡区。", 1.0),
					_m(P_DRESSER, 0, -2, "柜", "客房柜。", 0.8),
					_m(P_BASKET, 2, 1, "行囊筐", "旅客行囊。", 0.55),
					_m(P_STOOL, -2, 1, "床边凳", "床西站位凳。", 0.7),
					_m(P_LAMP_TAVERN, 2, -2, "烛灯", "二楼酒馆烛灯（非家用台灯）。", PROP),
				]),
				_cluster("secret", 16, 6, [
					_m(P_SECRET_CURTAIN, 0, -2, "密会帷幕", "厚帷幕密会隔间（签名 prop；≠告示牌）。", 1.0),
					_m(P_TABLE_R, 0, 1, "密会桌", "帷幕后秘密会议圆桌。", 0.85),
					_m(P_STOOL_TEA, -2, 2, "凳", "围桌西凳。", 0.7),
					_m(P_STOOL_TEA, 2, 2, "凳", "围桌东凳（东站位可坐）。", 0.7),
					_m(P_CIPHER_PLAQUE, 2, -1, "暗号牌", "密会暗号小牌（非 notice 代理）。", 0.55),
					_m(P_COIN, -1, 0, "贿匣", "桌侧暗匣。", 0.55),
					_m(P_LAMP_TAVERN, -2, -1, "密会烛", "帷幕侧烛灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 4, "oy": -8, "color": Color(1.0, 0.75, 0.45), "energy": 0.9, "scale": 1.7},
				{"tx": 16, "ty": 5, "oy": -10, "color": Color(1.0, 0.7, 0.4), "energy": 0.8, "scale": 1.6},
			],
			"actor": {
				"id": "merchant",
				"title": "老板",
				"desc": "在客房与密会帷幕之间走动照应。",
				"via_clusters": ["guest", "secret"],
				"via_stands": {"guest": [2, 2], "secret": [-2, 2]},
			},
		},
		"c34_dock_fish": {
			"title": "渔码头",
			"hint": "渔码头 · 网垛 / 卸鱼台",
			"return_path": LAKE,
			"room_w": 22,
			"room_h": 12,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "plank",
			"modulate": Color(0.78, 0.82, 0.84, 1.0),
			"rug": null,
			"window": true,
			# West net mass (fish silhouette) ≠ trade crate tower; SW 登船 portal; door 9–12 clear.
			"clusters": [
				_cluster("nets", 5, 4, [
					_m(P_DOCK_PILE_FISH, 0, 0, "网垛", "渔网覆盖的鱼箱垛（渔码头体量锚）。", 1.0),
					_m(P_BASKET, 2, 1, "渔篓", "网旁收鱼篓（南可站）。", 0.7),
					_m(P_ROD_BAMBOO, -2, -1, "渔竿架", "西壁竿架。", 0.7),
					_m(P_CRATE0, 2, -1, "鲜鱼箱", "网垛东侧鲜鱼箱。", 0.75),
					_m(P_BARREL, -1, 2, "洗鱼桶", "网脚洗鱼桶。", 0.65),
					_m(P_LAMP_FARM, 1, -2, "码头灯", "渔码头农场铁壳灯（非家用台灯）。", PROP),
				]),
				_cluster("unload", 16, 5, [
					_m(P_HANDCART, 0, 0, "卸鱼车", "东侧卸鱼手推车。", 0.95),
					_m(P_CRATE1, 2, -1, "待运箱", "车旁待运鱼箱。", 0.75),
					_m(P_SACK0, 2, 1, "冰袋", "保鲜冰袋。", 0.6),
					_m(P_SACK1, -2, 1, "盐袋", "腌盐袋。", 0.55),
					_m(P_BARREL, -2, -1, "水桶", "卸鱼区冲洗桶。", 0.7),
					_m(P_LAMP_FARM, 1, -2, "卸货灯", "卸鱼区农场灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 3, "oy": -8, "color": Color(0.95, 0.95, 1.0), "energy": 0.9, "scale": 1.8},
				{"tx": 16, "ty": 4, "oy": -8, "color": Color(0.95, 0.94, 0.9), "energy": 0.75, "scale": 1.6},
			],
			"actor": {
				"id": "farmer",
				"title": "渔工",
				"desc": "在网垛与卸鱼车之间整理渔获。",
				"via_clusters": ["nets", "unload"],
				"via_stands": {"nets": [1, 2], "unload": [-1, 2]},
			},
			"extra_portals": [
				{"tx": 3, "ty": 9, "label": "登船", "path": SceneRouter.C35_BOAT_DOCKED_PATH},
			],
		},
		"c34_dock_trade": {
			"title": "商码头",
			"hint": "商码头 · 货垛 / 验货台",
			"return_path": "res://scenes/areas/lighthouse/lighthouse.tscn",
			"room_w": 22,
			"room_h": 12,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "plank",
			"modulate": Color(0.82, 0.78, 0.72, 1.0),
			"rug": null,
			"window": true,
			# Tall rope-tied cargo tower ≠ fish net pile; east verify desk; door 9–12 clear.
			"clusters": [
				_cluster("cargo", 5, 4, [
					_m(P_DOCK_PILE_TRADE, 0, 0, "货垛", "绳捆叠高商货箱垛（商码头体量锚）。", 1.05),
					_m(P_CRATE0, 2, 1, "散箱", "垛脚待验散箱（南可站）。", 0.75),
					_m(P_SACK1, -2, 1, "货袋", "垛西麻袋脚。", 0.65),
					_m(P_SACK0, 2, -1, "货袋", "垛东第二袋。", 0.6),
					_m(P_BARREL, -1, 2, "油桶", "商货油/酒桶。", 0.7),
					_m(P_LAMP_SHOP, 1, -2, "栈灯", "商码头罩灯（非家用台灯）。", PROP),
				]),
				_cluster("office", 16, 5, [
					_m(P_COUNTER, 0, 0, "验货台", "东侧验货台（主锚）。", 0.95),
					_m(P_LEDGER, -1, -1, "到货簿", "商港到货登记。", 0.7),
					_m(P_STOOL, -2, 1, "管事凳", "台西管事位。", 0.7),
					_m(P_FERRY_SCHEDULE, 2, -1, "班次牌", "靠泊与班次告示（非 notice 代理）。", 0.65),
					_m(P_CRATE1, 2, 1, "样品箱", "台东样品箱。", 0.65),
					_m(P_LAMP_SHOP, 1, -2, "台灯", "验货台罩灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 3, "oy": -8, "color": Color(1.0, 0.92, 0.8), "energy": 0.9, "scale": 1.8},
				{"tx": 16, "ty": 4, "oy": -8, "color": Color(1.0, 0.94, 0.82), "energy": 0.8, "scale": 1.6},
			],
			"actor": {
				"id": "merchant",
				"title": "栈管",
				"desc": "在货垛与验货台之间清点到港货物。",
				"via_clusters": ["cargo", "office"],
				"via_stands": {"cargo": [1, 2], "office": [-2, 2]},
			},
		},
		"c35_boat_docked": {
			"title": "停靠船",
			"hint": "停靠船 · 甲板货 / 舵舱",
			"return_path": SceneRouter.C34_DOCK_FISH_PATH,
			"room_w": 18,
			"room_h": 10,
			"door_tx0": 7,
			"door_tx1": 10,
			"floor": "plank",
			"modulate": Color(0.80, 0.84, 0.86, 1.0),
			"rug": null,
			"window": false,
			# Intact deck + tidy cabin ≠ wreck hull/chest; door 7–10 clear; lamp_farm only.
			"clusters": [
				_cluster("deck", 5, 4, [
					_m(P_BARREL, 0, 0, "甲板桶", "停靠船甲板淡水桶。", 0.85),
					_m(P_CRATE0, 2, 0, "舱货", "舱口待卸货箱。", 0.8),
					_m(P_CRATE1, 2, -1, "叠箱", "第二层甲板箱。", 0.7),
					_m(P_ROD_BAMBOO, -2, -1, "船竿", "船舷渔竿。", 0.65),
					_m(P_BASKET, -1, 2, "网筐", "甲板收网筐（南可站）。", 0.6),
					_m(P_SACK0, 1, 2, "粮袋", "短航粮袋。", 0.55),
				]),
				_cluster("cabin", 13, 4, [
					_m(P_STOOL, 0, 0, "舵凳", "舵位操作凳。", 0.75),
					_m(P_LEDGER, 1, -1, "航簿", "靠泊与航次簿。", 0.55),
					_m(P_BASKET, -1, 1, "舱筐", "舱内杂物筐。", 0.55),
					_m(P_LAMP_FARM, 1, -2, "舱灯", "船舱农场铁壳灯（非家用台灯）。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 3, "oy": -6, "color": Color(0.95, 0.95, 1.0), "energy": 0.7, "scale": 1.5},
				{"tx": 13, "ty": 3, "oy": -6, "color": Color(1.0, 0.9, 0.7), "energy": 0.85, "scale": 1.5},
			],
			"actor": {
				"id": "farmer",
				"title": "船夫",
				"desc": "在甲板货与舵舱之间整理靠泊。",
				"via_clusters": ["deck", "cabin"],
				"via_stands": {"deck": [1, 2], "cabin": [-1, 2]},
			},
		},
		"c35_boat_wreck": {
			"title": "半沉船",
			"hint": "半沉船 · 破壳 / 沉箱",
			"return_path": LAKE,
			"room_w": 18,
			"room_h": 10,
			"door_tx0": 7,
			"door_tx1": 10,
			"floor": "dark",
			"modulate": Color(0.55, 0.60, 0.66, 1.0),
			"rug": null,
			"window": false,
			# Broken hull cue + reef ≠ tidy docked deck; door 7–10 clear.
			"clusters": [
				_cluster("hull", 5, 4, [
					_m(P_WRECK_HULL, 0, 0, "破壳", "半沉船破损船体（沉船剪影锚）。", 1.1),
					_m(P_CRATE1, 2, -1, "破箱", "倾覆破箱。", 0.75),
					_m(P_BARREL_KEG, 2, 1, "倾桶", "倾覆酒桶。", 0.7),
					_m(P_ROCK2, -2, 1, "礁石", "卡船礁石。", 0.65),
					_m(P_ROCK1, -1, 2, "碎礁", "壳脚碎礁（南可站）。", 0.55),
				]),
				_cluster("cache", 13, 4, [
					_m(P_COIN, 0, 0, "沉箱", "破舱沉没宝箱。", 0.8),
					_m(P_SACK0, 2, 1, "湿袋", "浸湿麻袋。", 0.55),
					_m(P_SACK1, -2, 1, "烂袋", "霉烂货袋。", 0.5),
					_m(P_ROCK3, 2, -1, "舱礁", "舱内卡礁。", 0.6),
					_m(P_LAMP_TAVERN, -1, -1, "残烛", "残烛微光。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 3, "oy": -6, "color": Color(0.65, 0.8, 1.0), "energy": 0.55, "scale": 1.4},
				{"tx": 13, "ty": 3, "oy": -6, "color": Color(0.7, 0.85, 1.0), "energy": 0.75, "scale": 1.5},
			],
			"actor": {},
		},
		"c36_train_car": {
			"title": "火车厢",
			"hint": "火车厢 · 西座 / 东座 / 中廊",
			"return_path": STN,
			"room_w": 26,
			"room_h": 10,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "plank",
			"modulate": Color(0.82, 0.78, 0.74, 1.0),
			"rug": null,
			"window": true,
			# Dual seat-row benches + mid aisle (door 11–14); luggage satellites.
			"clusters": [
				_cluster("seats_w", 5, 4, [
					_m(P_TRAIN_SEAT_ROW, 0, 0, "西排座", "西侧双人客座排（车厢剪影）。", 1.0),
					_m(P_BASKET, 1, 2, "行李筐", "座前行李筐（南可站）。", 0.6),
					_m(P_SACK0, -1, 1, "行囊", "座侧行囊。", 0.55),
					_m(P_LAMP_INDOOR, 1, -2, "车厢灯", "西窗旁车厢顶灯。", PROP),
				]),
				_cluster("seats_e", 19, 4, [
					_m(P_TRAIN_SEAT_ROW, 0, 0, "东排座", "东侧双人客座排。", 1.0),
					_m(P_CRATE0, 1, 2, "邮包箱", "座前邮包/货箱（南可站）。", 0.7),
					_m(P_BASKET, -1, 1, "帽筐", "座侧帽筐。", 0.55),
					_m(P_LAMP_INDOOR, 1, -2, "车厢灯", "东窗旁车厢顶灯。", PROP),
				]),
				_cluster("aisle_rack", 12, 2, [
					_m(P_FERRY_SCHEDULE, 0, 0, "班次牌", "中廊北壁班次告示（不挡门轴；非 notice 代理）。", 0.65),
					_m(P_CRATE1, 2, 0, "行包", "廊侧小行包。", 0.55),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 3, "oy": -6, "color": Color(1.0, 0.92, 0.8), "energy": 0.8, "scale": 1.6},
				{"tx": 12, "ty": 3, "oy": -6, "color": Color(1.0, 0.94, 0.82), "energy": 0.7, "scale": 1.5},
				{"tx": 19, "ty": 3, "oy": -6, "color": Color(1.0, 0.92, 0.8), "energy": 0.8, "scale": 1.6},
			],
			"actor": {
				"id": "merchant",
				"title": "乘务",
				"desc": "在西座、中廊与东座之间检票巡视。",
				"via_clusters": ["seats_w", "aisle_rack", "seats_e"],
				"via_stands": {"seats_w": [1, 2], "aisle_rack": [0, 2], "seats_e": [-1, 2]},
			},
		},
		"c23_underwater": {
			"title": "水下",
			"hint": "水下 · 水草 / 沉木 / 宝箱",
			"return_path": LAKE,
			"room_w": 22,
			"room_h": 12,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.45, 0.58, 0.70, 1.0),
			"rug": null,
			"window": false,
			# Dive site: seaweed mass + sunken timber + chest; door 9–12 clear.
			"clusters": [
				_cluster("weed", 5, 4, [
					_m(P_SEAWEED, 0, 0, "水草", "西侧水草簇（潜水点植被锚）。", 1.0),
					_m(P_SEAWEED, 2, 1, "水草", "第二簇水草。", 0.85),
					_m(P_ROCK1, -1, 1, "沉石", "草脚沉石。", 0.65),
					_m(P_ROCK0, 2, -1, "沉石", "草丛北沉石。", 0.55),
					_m(P_ROCK2, -2, 2, "碎石", "西廊碎石（南可站）。", 0.5),
				]),
				_cluster("wreckage", 16, 5, [
					_m(P_SUNKEN_WOOD, 0, 0, "沉木", "水底沉没木梁（体量）。", 1.0),
					_m(P_COIN, -1, 1, "宝箱", "沉木旁水下宝箱（南可开）。", 0.75),
					_m(P_CRATE0, 2, 1, "沉箱", "浸水木箱。", 0.7),
					_m(P_ROCK3, 2, -1, "礁石", "沉木东礁。", 0.65),
					_m(P_SEAWEED, -2, -1, "附生草", "梁上附生水草。", 0.7),
					_m(P_LAMP_FARM, 1, -2, "潜灯", "潜水探照灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 5, "ty": 3, "oy": -6, "color": Color(0.5, 0.8, 1.0), "energy": 0.7, "scale": 1.6},
				{"tx": 16, "ty": 4, "oy": -6, "color": Color(0.55, 0.85, 1.0), "energy": 0.95, "scale": 1.9},
			],
			"actor": {},
		},

	}
