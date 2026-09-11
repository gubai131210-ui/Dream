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
	}
