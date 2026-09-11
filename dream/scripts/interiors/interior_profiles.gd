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


static func _m(path: String, dx: int, dy: int, title: String, desc: String, scale: float = PROP) -> Dictionary:
	return {"path": path, "dx": dx, "dy": dy, "scale": scale, "title": title, "desc": desc}


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
			# Wave A2 Well team: thin basement stair portal (no layout polish).
			"extra_portals": [
				{
					"tx": 3,
					"ty": 16,
					"label": "↓地下室",
					"path": SceneRouter.C15_BASEMENT_PATH,
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
				"desc": "在茶几与床铺间缓步。",
				"via_clusters": ["tea", "sleep"],
				"via_stands": {"tea": [0, 2], "sleep": [2, 1]},
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
				"desc": "进屋整理粮袋再坐饭桌。",
				"via_clusters": ["mudroom", "dining", "sleep"],
				"via_stands": {
					"mudroom": [0, -1],
					"dining": [0, 3],
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
					_m(P_NOTICE, -3, -1, "货单", "壁挂货单。", 0.5),
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
					_m(P_NOTICE, 2, -1, "告示板", "柜上价目。", 0.85),
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
					_m(P_TABLE_DINING, 0, 0, "候坐", "顾客等候桌（cozy_dining）。", 0.9),
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
					_m(P_NOTICE, -3, -2, "告示", "座席旁规矩牌。", 0.5),
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
		},
		# ── Wave A2 stubs (teams enrich; do not polish C01–C04) ──
		"c12_lighthouse": {
			"title": "灯塔内部",
			"hint": "灯塔 · 底层储物 / 中层楼梯 / 顶层灯室（占位）",
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
					_m(P_LAMP_FARM, 0, 0, "航标灯", "顶层灯具占位。", PROP),
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
		# ── C14 井底：积水池 · 井壁龛 · 隐藏缝占位 ──
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
					_m(P_COIN, 0, 0, "湿石缝", "石缝里隐约有物（隐藏入口占位）。", 0.55),
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
					_m(P_NOTICE, 1, -1, "矿洞告示", "入口层安全告示。", 0.7),
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
					_m(P_NOTICE, -1, -4, "公告板", "村务与告示栏（南侧留读位）。", 0.85),
					_m(P_TABLE_DINING, 0, 0, "会议桌", "议事长桌。", 0.9),
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
					_m(P_NOTICE, 0, 0, "黑板", "北壁黑板（授课锚）。", 1.05),
					_m(P_LAMP_INDOOR, -4, 0, "西壁灯", "黑板西侧教室灯。", PROP),
					_m(P_LAMP_INDOOR, 4, 0, "东壁灯", "黑板东侧教室灯。", PROP),
					_m(P_TABLE_DINING, -4, 2, "讲台", "偏西讲台（让出中轴通廊）。", 0.8),
					_m(P_STOOL, -4, 3, "教凳", "讲台南教凳（面向课桌）。", 0.5),
					_m(P_LEDGER, -3, 1, "教案", "讲台旁教案册。", 0.65),
				]),
				# Two columns × three rows facing north; stools south of desks; aisle 12–15 open.
				_cluster("desks", 6, 7, [
					_m(P_TABLE_DINING, 0, 0, "前排课桌", "西列前排（面北黑板）。", 0.72),
					_m(P_STOOL, 0, 2, "课凳", "西列前排课凳（南向站位可交互）。", 0.48),
					_m(P_TABLE_DINING, 14, 0, "前排课桌", "东列前排（面北黑板）。", 0.72),
					_m(P_STOOL, 14, 2, "课凳", "东列前排课凳（南向站位可交互）。", 0.48),
					_m(P_TABLE_DINING, 0, 3, "中排课桌", "西列中排。", 0.72),
					_m(P_STOOL, 0, 5, "课凳", "西列中排课凳。", 0.48),
					_m(P_TABLE_DINING, 14, 3, "中排课桌", "东列中排。", 0.72),
					_m(P_STOOL, 14, 5, "课凳", "东列中排课凳。", 0.48),
					_m(P_TABLE_DINING, 0, 6, "后排课桌", "西列后排（南门带空出）。", 0.72),
					_m(P_STOOL, 0, 8, "课凳", "西列后排课凳。", 0.48),
					_m(P_TABLE_DINING, 14, 6, "后排课桌", "东列后排（南门带空出）。", 0.72),
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
					_m(P_NOTICE, -2, -1, "诊费告示", "西壁挂号须知。", 0.75),
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
					_m(P_NOTICE, 2, -1, "分类卡", "架位索引卡（大厅检索提示）。", 0.8),
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
					_m(P_COUNTER, 0, 0, "祭坛", "北向长祭坛（礼堂主锚）。", 1.0),
					_m(P_NOTICE, 0, -2, "经文牌", "北壁经文/彩窗下告示。", 0.8),
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
				# Verb: 候车 — long bench rows + timetable (table_dining = bench proxy).
				_cluster("waiting", 6, 7, [
					_m(P_TABLE_DINING, 0, 0, "候车长椅", "北排西座（候车）。", 0.85),
					_m(P_TABLE_DINING, 3, 0, "候车长椅", "北排中座（候车）。", 0.85),
					_m(P_TABLE_DINING, 6, 0, "候车长椅", "北排东座（贴通廊西缘）。", 0.85),
					_m(P_TABLE_DINING, 0, 3, "候车长椅", "南排西座（候车）。", 0.85),
					_m(P_TABLE_DINING, 3, 3, "候车长椅", "南排中座（候车）。", 0.85),
					_m(P_NOTICE, 3, -3, "时刻表", "班次与站台告示。", 0.85),
					_m(P_LAMP_SHOP, 5, -2, "站厅灯", "候车厅壁灯。", PROP),
					_m(P_STOOL, -2, 1, "边座", "长椅端头短坐。", 0.55),
				]),
				# Verb: 售票 — counter faces south (passenger); staff/ledger north.
				_cluster("ticket", 22, 6, [
					_m(P_COUNTER, 0, 1, "售票窗", "站长/售票柜台（客南主北）。", 1.0),
					_m(P_LEDGER, -1, -1, "行车簿", "站长日志与班次簿。", 0.7),
					_m(P_LAMP_SHOP, 2, -1, "票窗灯", "售票台灯。", PROP),
					_m(P_COIN, 2, 1, "票箱", "零钱与票根匣。", 0.55),
					_m(P_NOTICE, 1, -3, "票价牌", "票价与托运须知。", 0.7),
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
			"hint": "磨坊 · 磨盘 / 面粉（占位）",
			"return_path": FLD,
			"room_w": 20,
			"room_h": 14,
			"door_tx0": 8,
			"door_tx1": 11,
			"floor": "plank",
			"modulate": Color(0.88, 0.84, 0.76, 1.0),
			"rug": null,
			"window": true,
			"clusters": [
				_cluster("millstone", 10, 6, [
					_m(P_TABLE_DINING, 0, 0, "磨盘", "中央磨盘占位。", 1.0),
					_m(P_TOOL_RACK, -3, 0, "齿轮架", "传动齿轮架占位。", 0.7),
					_m(P_LAMP_FARM, 2, -2, "磨坊灯", "工作灯。", PROP),
				]),
				_cluster("flour", 15, 8, [
					_m(P_GRAIN_STACK, 0, 0, "面粉垛", "袋装面粉体量。", 0.75),
					_m(P_SACK0, 2, 1, "面袋", "待运面袋。", 0.6),
					_m(P_SACK1, -1, 2, "麸皮袋", "麸皮袋。", 0.55),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 10, "ty": 4, "oy": -8, "color": Color(1.0, 0.95, 0.8), "energy": 0.95, "scale": 2.0},
			],
			"actor": {},
		},
		"c16_cave_entry": {
			"title": "洞穴入口层",
			"hint": "洞穴 · 入口层（占位）",
			"return_path": HILL,
			"room_w": 24,
			"room_h": 16,
			"door_tx0": 10,
			"door_tx1": 13,
			"floor": "stone",
			"modulate": Color(0.55, 0.52, 0.50, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("mouth", 8, 8, [
					_m(P_CRATE0, 0, 0, "探险箱", "入口补给。", 0.75),
					_m(P_LAMP_FARM, 2, -1, "洞口灯", "入口照明。", PROP),
				]),
				_cluster("descent", 16, 7, [
					_m(P_NOTICE, 0, 0, "下探标记", "通向中层。", 0.7),
					_m(P_CRATE1, 2, 2, "绳索箱", "下探绳索。", 0.7),
				]),
			],
			"extra_portals": [
				{"tx": 16, "ty": 9, "label": "↓中层", "path": "res://scenes/interiors/c16_cave_mid/c16_cave_mid.tscn"},
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 12, "ty": 5, "oy": -6, "color": Color(0.9, 0.85, 0.7), "energy": 0.7, "scale": 1.8},
			],
			"actor": {},
		},
		"c16_cave_mid": {
			"title": "洞穴中层",
			"hint": "洞穴 · 水晶中层（占位）",
			"return_path": "res://scenes/interiors/c16_cave_entry/c16_cave_entry.tscn",
			"room_w": 22,
			"room_h": 15,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.48, 0.52, 0.62, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("crystal", 8, 6, [
					_m(P_COIN, 0, 0, "晶簇箱", "水晶矿箱占位。", 0.7),
					_m(P_LAMP_INDOOR, 2, -1, "晶光灯", "冷光。", PROP),
				]),
				_cluster("pool", 15, 8, [
					_m(P_BARREL, 0, 0, "积水桶", "地下渗水。", 0.65),
					_m(P_CRATE0, 2, 1, "样本箱", "晶矿样本。", 0.7),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 8, "ty": 4, "oy": -8, "color": Color(0.7, 0.85, 1.0), "energy": 0.85, "scale": 1.9},
			],
			"actor": {},
		},
		"c24_lake_island": {
			"title": "湖心岛",
			"hint": "湖心岛 · 野餐 / 废墟角（占位）",
			"return_path": LAKE,
			"room_w": 22,
			"room_h": 16,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "straw",
			"modulate": Color(0.78, 0.86, 0.80, 1.0),
			"rug": {"ox": 9, "oy": 10},
			"window": false,
			"clusters": [
				_cluster("picnic", 8, 8, [
					_m(P_TABLE_DINING, 0, 0, "野餐毯桌", "岛上野餐。", 0.85),
					_m(P_BASKET, 2, 1, "食篮", "野餐篮。", 0.7),
					_m(P_STOOL, -2, 1, "矮凳", "坐席。", 0.5),
				]),
				_cluster("ruin_corner", 16, 6, [
					_m(P_CRATE1, 0, 0, "废墟箱", "岛角旧箱。", 0.7),
					_m(P_COIN, 2, 1, "小宝箱", "神秘小箱。", 0.65),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 11, "ty": 5, "oy": -6, "color": Color(1.0, 0.98, 0.9), "energy": 0.8, "scale": 1.8},
			],
			"actor": {},
		},
		"c25_river_hide": {
			"title": "芦苇岔路",
			"hint": "河流隐藏 · 芦苇口（占位）",
			"return_path": RIV,
			"room_w": 18,
			"room_h": 13,
			"door_tx0": 7,
			"door_tx1": 10,
			"floor": "straw",
			"modulate": Color(0.62, 0.72, 0.58, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("reed", 6, 6, [
					_m(P_BASKET, 0, 0, "苇篮", "采苇篮。", 0.7),
					_m(P_SACK0, 2, 1, "湿袋", "岸边湿袋。", 0.55),
				]),
				_cluster("skiff", 12, 7, [
					_m(P_CRATE0, 0, 0, "小船箱", "藏船补给。", 0.7),
					_m(P_LAMP_FARM, 1, -2, "岔路灯", "隐径微光。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 9, "ty": 4, "oy": -6, "color": Color(0.85, 1.0, 0.75), "energy": 0.65, "scale": 1.6},
			],
			"actor": {},
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
					_m(P_TABLE_DINING, 0, 0, "根桌", "树心刨平的粗根桌（厅锚）。", 0.9),
					_m(P_STOOL, -2, 1, "木墩", "桌西坐墩（同 sheet）。", 0.7),
					_m(P_STOOL, 2, 1, "木墩", "桌东坐墩（东留站位）。", 0.7),
					_m(P_PEW, 0, 3, "原木长凳", "桌南原木长凳（南站位可坐）。", 0.75),
					_m(P_NOTICE, 0, -2, "树皮符", "北壁刻纹符板。", 0.65),
					_m(P_LAMP_INDOOR, 2, -2, "洞厅灯", "暖黄树心灯（非农场仓灯）。", PROP),
					_m(P_BASKET, -2, -1, "果篮", "厅角野果篮。", 0.55),
				]),
				# Verb: 攀梯 — west trunk pegs + stump steps (≠ hunt gear rack).
				_cluster("climb", 4, 7, [
					_m(P_TOOL_RACK, 0, -2, "木钉梯", "西干壁攀钉/梯档。", 0.85),
					_m(P_CRATE0, 0, 1, "树墩踏", "攀梯脚底树墩踏级。", 0.75),
					_m(P_CRATE1, 0, 2, "树墩踏", "下层踏级（南可站）。", 0.7),
					_m(P_SHELF, 2, -1, "攀具搁板", "绳索与钉楔搁板。", 0.65),
					_m(P_LAMP_FARM, 2, 1, "梯侧灯", "攀梯侧微光。", PROP),
				]),
				# Verb: 根系窖 — SE mass; stays east of door aisle 9–12.
				_cluster("roots", 17, 13, [
					_m(P_HAY_STACK, 0, -1, "根须垛", "缠结根须/枯纤维高垛（体量锚）。", 0.8),
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
		"c29_ruins": {
			"title": "遗迹主殿",
			"hint": "遗迹 · 主殿（占位）",
			"return_path": FDEEP,
			"room_w": 26,
			"room_h": 18,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "stone",
			"modulate": Color(0.70, 0.68, 0.66, 1.0),
			"rug": {"ox": 11, "oy": 12},
			"window": false,
			"clusters": [
				_cluster("nave", 13, 7, [
					_m(P_TABLE_DINING, 0, 0, "祭台残座", "主殿残祭台。", 0.9),
					_m(P_NOTICE, 0, -2, "碑刻", "残碑。", 0.75),
					_m(P_LAMP_INDOOR, 2, 0, "残灯", "冷光。", PROP),
				]),
				_cluster("cache", 20, 10, [
					_m(P_COIN, 0, 0, "遗物箱", "殿侧宝箱。", 0.7),
					_m(P_CRATE1, 2, 1, "碎石箱", "清理碎石。", 0.65),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 13, "ty": 5, "oy": -10, "color": Color(0.9, 0.92, 1.0), "energy": 0.9, "scale": 2.1},
			],
			"actor": {},
		},
		"c30_cemetery": {
			"title": "墓园",
			"hint": "墓园 · 墓区 / 墓穴（占位）",
			"return_path": SQ,
			"room_w": 24,
			"room_h": 16,
			"door_tx0": 10,
			"door_tx1": 13,
			"floor": "stone",
			"modulate": Color(0.62, 0.64, 0.68, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("graves", 8, 8, [
					_m(P_NOTICE, 0, 0, "墓碑", "西排墓碑。", 0.8),
					_m(P_NOTICE, 3, 1, "墓碑", "中排墓碑。", 0.75),
					_m(P_CRATE0, 1, 3, "供品箱", "祭扫供品。", 0.6),
				]),
				_cluster("crypt", 17, 7, [
					_m(P_TABLE_DINING, 0, 0, "墓穴石台", "地下穴入口石台。", 0.85),
					_m(P_COIN, 2, 1, "随葬箱", "穴内小箱。", 0.65),
					_m(P_LAMP_INDOOR, 0, -2, "穴灯", "冷灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 12, "ty": 5, "oy": -8, "color": Color(0.75, 0.8, 0.95), "energy": 0.7, "scale": 1.8},
			],
			"actor": {},
		},
		"c31_sewer": {
			"title": "下水道",
			"hint": "下水道 · 管道段（占位）",
			"return_path": RES,
			"room_w": 28,
			"room_h": 12,
			"door_tx0": 12,
			"door_tx1": 15,
			"floor": "stone",
			"modulate": Color(0.45, 0.48, 0.46, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("pipe", 8, 6, [
					_m(P_BARREL, 0, 0, "排污桶", "管道旁桶。", 0.7),
					_m(P_CRATE0, 2, 1, "闸门箱", "检修箱。", 0.7),
					_m(P_LAMP_FARM, 1, -2, "隧灯", "管道灯。", PROP),
				]),
				_cluster("black_market", 20, 6, [
					_m(P_COUNTER, 0, 0, "黑市摊", "管道黑市占位。", 0.95),
					_m(P_COIN, 2, 1, "赃箱", "黑市小箱。", 0.65),
					_m(P_NOTICE, -2, -1, "暗语牌", "接头暗号。", 0.7),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 8, "ty": 4, "oy": -6, "color": Color(0.7, 0.9, 0.75), "energy": 0.6, "scale": 1.5},
				{"tx": 20, "ty": 4, "oy": -6, "color": Color(1.0, 0.85, 0.6), "energy": 0.7, "scale": 1.6},
			],
			"actor": {},
		},
	}
