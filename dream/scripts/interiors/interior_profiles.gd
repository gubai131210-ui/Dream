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
const P_GRAIN_STACK := DIR_INTERIOR_PROP + "/grain_stack_00.png"
const P_BARREL := DIR_OUTDOOR_PROP + "/barrel_1.png"
const P_BARREL_KEG := DIR_OUTDOOR_PROP + "/barrel_0.png"
const P_CRATE0 := DIR_OUTDOOR_PROP + "/crate_0.png"
const P_CRATE1 := DIR_OUTDOOR_PROP + "/crate_1.png"
const P_SACK0 := DIR_OUTDOOR_PROP + "/sack_0.png"
const P_SACK1 := DIR_OUTDOOR_PROP + "/sack_1.png"
const P_LAMP_INDOOR := DIR_INTERIOR_PROP + "/lamp_indoor_00.png"

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
			"rug": {"ox": 14, "oy": 8},
			"window": true,
			"clusters": [
				_cluster("kitchen", 5, 7, [
					_m(P_STOVE, 0, 0, "灶台", "西厨灶台（工作三角锚）。", 0.95),
					_m(P_SHELF, -2, 0, "厨架", "调料碗碟贴灶。", 0.9),
					_m(P_HERBS, 2, -2, "干草药", "灶旁北墙晾挂。", 0.8),
					_m(P_BARREL, 1, 2, "水桶", "灶前取水（三角第三点）。", PROP),
				]),
				_cluster("hearth_talk", 16, 6, [
					_m(P_FIREPLACE, 0, -1, "壁炉", "北墙起居壁炉。", 1.0),
					_m(P_TABLE_DINING, 0, 2, "饭桌", "炉前用餐/闲谈桌（cozy_dining 成套）。", 0.95),
					_m(P_STOOL, -2, 2, "凳", "桌西矮凳（同 sheet）。", 0.85),
					_m(P_STOOL, 2, 2, "凳", "桌东矮凳（同 sheet）。", 0.85),
					_m(P_STOOL, 0, 3, "凳", "桌南矮凳（同 sheet）。", 0.85),
				]),
				_cluster("sleep", 28, 13, [
					_m(P_BED_D, 0, 1, "双人床", "东南私密睡区。", 1.05),
					_m(P_DRESSER, 0, -2, "衣柜", "床头北墙衣柜。", 0.95),
					_m(P_LAMP_INDOOR, 1, -3, "壁灯", "床区壁灯。", PROP),
				]),
			],
			"fx": [{"kind": "fire", "tx": 16, "ty": 5, "oy": -18}],
			"ambient": [{"species": "cat", "cluster": "hearth_talk", "dx": 3, "dy": 1}],
			"lights": [
				{"tx": 5, "ty": 7, "oy": -12, "color": Color(1.0, 0.75, 0.45), "energy": 0.7, "scale": 1.6},
				{"tx": 29, "ty": 7, "oy": -16, "color": Color(1.0, 0.88, 0.6), "energy": 0.9, "scale": 2.0},
			],
			"actor": {
				"id": "farmer",
				"title": "屋主",
				"desc": "在厨房与壁炉间忙碌。",
				"via_clusters": ["kitchen", "hearth_talk", "sleep"],
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
			"rug": {"ox": 12, "oy": 8},
			"window": true,
			"clusters": [
				_cluster("mudroom", 5, 13, [
					_m(P_TOOL_RACK, 0, -2, "工具架", "门厅西墙锄镰架。", 0.95),
					_m(P_GRAIN_STACK, 2, 0, "粮垛", "门厅存粮垛（体量锚）。", 0.75),
					_m(P_SACK0, 4, 1, "粮袋", "贴垛粮袋。", PROP),
					_m(P_SACK1, 3, 2, "种子袋", "贴粮袋种子。", 0.85),
					_m(P_BARREL, 1, 2, "水桶", "门厅取水。", PROP),
				]),
				_cluster("dining", 14, 7, [
					_m(P_TABLE_DINING, 0, 0, "饭桌", "农家大饭桌（cozy_dining）。", 0.95),
					_m(P_STOOL, -2, 1, "凳", "饭桌西凳（同 sheet）。", 0.85),
					_m(P_STOOL, 2, 1, "凳", "饭桌东凳（同 sheet）。", 0.85),
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
			"rug": {"ox": 10, "oy": 8},
			"window": true,
			"clusters": [
				_cluster("home_tools", 6, 7, [
					_m(P_TOOL_RACK, -1, -2, "家用工具架", "下班带回的锤钳。", 0.9),
					_m(P_ANVIL, 0, 1, "小砧", "家用小砧（非铺内锻炉）。", 0.75),
					_m(P_BARREL, 2, 2, "淬火桶", "贴砧淬火水桶。", PROP),
				]),
				_cluster("living", 12, 8, [
					_m(P_TABLE_DINING, 0, 0, "厚桌", "耐用木桌（cozy_dining）。", 0.95),
					_m(P_STOOL, -2, 1, "凳", "桌旁凳（同 sheet）。", 0.85),
					_m(P_STOOL, 2, 1, "凳", "桌旁凳（同 sheet）。", 0.85),
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
					_m(P_CRATE0, 1, 3, "农具箱", "东角农具。", PROP),
					_m(P_TOOL_RACK, 3, -3, "耙叉架", "墙上农具。", 0.55),
				]),
				_cluster("aisle_feed", 18, 11, [
					_m(P_GRAIN_STACK, 0, -4, "粮垛", "北端存粮高垛（体量锚）。", 0.85),
					_m(P_SACK0, -2, 0, "饲料袋", "通道饲料。", PROP),
					_m(P_SACK1, 1, 1, "饲料袋", "贴垛饲料。", PROP),
					_m(P_BARREL, 3, 1, "水桶", "通道备用饮水。", PROP),
					_m(P_LAMP_INDOOR, 0, -1, "吊灯", "通道暖灯。", PROP),
				]),
			],
			# Seamless same-family fence: H = front, V = side; step 1 = no gaps.
			"rails": [
				{"axis": "v", "tx": 11, "a0": 5, "a1": 16, "step": 1, "prop": P_STALL_RAIL_V, "scale": 1.0, "title": "西畜栏隔栏", "desc": "西 stall 朝过道隔栏（侧视）。"},
				{"axis": "v", "tx": 24, "a0": 5, "a1": 16, "step": 1, "prop": P_STALL_RAIL_V, "scale": 1.0, "title": "东畜栏隔栏", "desc": "东 stall 朝过道隔栏（侧视）。"},
				{"axis": "h", "ty": 5, "a0": 4, "a1": 10, "step": 1, "prop": P_STALL_RAIL, "scale": 1.0, "title": "西栏北档", "desc": "西栏北端横档（正视）。"},
				{"axis": "h", "ty": 5, "a0": 25, "a1": 31, "step": 1, "prop": P_STALL_RAIL, "scale": 1.0, "title": "东栏北档", "desc": "东栏北端横档（正视）。"},
				{"axis": "h", "ty": 16, "a0": 4, "a1": 10, "step": 1, "prop": P_STALL_RAIL, "scale": 1.0, "title": "西栏南档", "desc": "西栏南端横档（正视）。"},
				{"axis": "h", "ty": 16, "a0": 25, "a1": 31, "step": 1, "prop": P_STALL_RAIL, "scale": 1.0, "title": "东栏南档", "desc": "东栏南端横档（正视）。"},
			],
			"fx": [],
			"ambient": [
				{"species": "sheep", "cluster": "stall_w", "dx": 1, "dy": 1},
				{"species": "cow", "cluster": "stall_e", "dx": -1, "dy": 1},
			],
			"lights": [
				{"tx": 18, "ty": 4, "oy": -8, "color": Color(1.0, 0.82, 0.5), "energy": 1.05, "scale": 3.2},
			],
			"actor": {
				"id": "farmer",
				"title": "仓管",
				"desc": "沿畜栏与饲料过道巡视。",
				"via_clusters": ["stall_w", "aisle_feed", "stall_e"],
			},
		},
		# ── C03 鸡舍：西巢 · 中饲 · 东栖 · 低围栏笔 ──
		"c03_coop": {
			"title": "鸡舍内部",
			"hint": "鸡舍 · 围栏笔内巢箱/食槽/栖木",
			"return_path": FARM,
			"room_w": 20,
			"room_h": 14,
			"door_tx0": 8,
			"door_tx1": 11,
			"floor": "straw",
			"modulate": Color(0.84, 0.80, 0.70, 1.0),
			"rug": null,
			"window": true,
			"clusters": [
				_cluster("nests", 4, 6, [
					_m(P_NEST, 0, -2, "巢箱", "西墙产蛋巢。", 0.65),
					_m(P_NEST, 0, 0, "巢箱", "中层巢箱。", 0.65),
					_m(P_NEST, 0, 2, "巢箱", "底层巢箱。", 0.6),
				]),
				_cluster("feed", 10, 6, [
					_m(P_TROUGH, 0, 0, "食槽", "笔内食槽。", 0.55),
					_m(P_SACK0, 2, 1, "鸡食", "贴槽鸡食袋。", PROP),
					_m(P_BARREL, 2, 2, "水桶", "贴食饮水桶。", PROP),
					_m(P_LAMP_INDOOR, 0, -2, "小灯", "鸡舍小灯。", PROP),
				]),
				_cluster("roost", 15, 5, [
					_m(P_ROOST, 0, 0, "栖木", "东侧栖木。", 0.7),
				]),
			],
			# Low pen around work clusters; south gate aligns with door aisle.
			"enclosures": [
				{
					"rect": [2, 3, 17, 10],
					"prop_h": P_PEN_FENCE,
					"prop_v": P_PEN_FENCE_V,
					"scale": 1.0,
					"title": "鸡栏",
					"desc": "同一低栏的正视/侧视无缝围合。",
					"gaps": [[8, 10], [9, 10], [10, 10], [11, 10]],
				},
			],
			"fx": [],
			"ambient": [
				{"species": "chicken", "cluster": "feed", "dx": -1, "dy": 1},
				{"species": "chicken", "cluster": "nests", "dx": 2, "dy": 0},
				{"species": "chicken", "cluster": "roost", "dx": -1, "dy": 2},
			],
			"lights": [
				{"tx": 10, "ty": 3, "oy": -10, "color": Color(1.0, 0.92, 0.7), "energy": 0.8, "scale": 1.6},
			],
			"actor": {
				"id": "farmer",
				"title": "饲鸡人",
				"desc": "检查巢箱与食槽。",
				"via_clusters": ["nests", "feed", "roost"],
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
			"rug": {"ox": 12, "oy": 11},
			"window": true,
			"clusters": [
				_cluster("shelf_w", 4, 7, [
					_m(P_SHELF_GROCERY, 0, -2, "西货架", "日杂货架。", 1.0),
					_m(P_SHELF, 0, 1, "西货架", "罐装货架。", 0.95),
					_m(P_BARREL, 2, 2, "油桶", "西架脚油桶。", PROP),
				]),
				_cluster("shelf_e", 25, 7, [
					_m(P_SHELF_GROCERY, 0, -2, "东货架", "干货架。", 1.0),
					_m(P_SHELF, 0, 1, "东货架", "盐糖架。", 0.95),
					_m(P_SACK0, -2, 2, "米袋", "东架脚米粮。", PROP),
				]),
				_cluster("counter", 14, 9, [
					_m(P_COUNTER, 0, 0, "柜台", "南向收银台（顾客在南、店主在北）。", 1.05),
					_m(P_BASKET, -2, 2, "菜筐", "柜前蔬果筐。", 0.85),
					_m(P_BASKET, 2, 2, "菜筐", "柜前根茎筐。", 0.85),
					_m(P_NOTICE, 2, -2, "告示板", "柜上价目。", 0.85),
					_m(P_LAMP_INDOOR, 1, -3, "店灯", "柜台顶灯。", PROP),
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
				_cluster("forge", 8, 4, [
					_m(P_FORGE, 0, 0, "锻炉", "北侧锻炉。", 1.05),
					_m(P_TOOL_RACK, -3, 1, "工具墙", "炉旁锤钳挂架。", 0.95),
				]),
				_cluster("anvil_quench", 9, 9, [
					_m(P_ANVIL, 0, 0, "铁砧", "炉下锻打砧。", 0.95),
					_m(P_BARREL, 2, 1, "淬火桶", "贴砧淬火。", PROP),
					_m(P_CRATE1, 3, -1, "成品箱", "砧旁待售铁器。", PROP),
					_m(P_CRATE0, 3, 1, "废料箱", "贴成品废料。", PROP),
					_m(P_LAMP_INDOOR, 2, -2, "壁灯", "工作区壁灯。", PROP),
				]),
				_cluster("wait", 16, 13, [
					_m(P_TABLE_DINING, 0, 0, "候坐", "顾客等候桌（cozy_dining）。", 0.9),
					_m(P_STOOL, -2, 1, "凳", "候坐凳（同 sheet）。", 0.85),
					_m(P_STOOL, 2, 1, "凳", "候坐凳（同 sheet）。", 0.85),
				]),
			],
			"fx": [{"kind": "forge", "tx": 8, "ty": 5, "oy": -10}],
			"ambient": [],
			"lights": [
				{"tx": 20, "ty": 5, "oy": -12, "color": Color(1.0, 0.7, 0.4), "energy": 0.7, "scale": 1.8},
			],
			"actor": {
				"id": "blacksmith",
				"title": "铁匠",
				"desc": "在炉、砧与淬火桶间走动。",
				"via_clusters": ["forge", "anvil_quench", "wait"],
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
			"rug": {"ox": 15, "oy": 10},
			"window": true,
			"clusters": [
				_cluster("bar", 5, 8, [
					_m(P_BAR, 1, 0, "吧台", "西侧长吧台。", 0.75),
					_m(P_BARREL_KEG, -1, 1, "酒桶", "吧后横放取酒桶。", 0.6),
					_m(P_BARREL, -1, 3, "存酒", "吧后竖放存酒。", PROP),
					_m(P_MUG_SHELF, 0, -3, "杯架", "吧上墙杯架。", 0.6),
					_m(P_LAMP_INDOOR, 2, -3, "酒馆灯", "吧台暖灯。", PROP),
					_m(P_STOOL_BAR, 3, 1, "吧凳", "吧前高凳（同家族木色）。", 0.8),
					_m(P_STOOL_BAR, 3, 3, "吧凳", "吧前高凳（同家族木色）。", 0.8),
				]),
				_cluster("party_a", 16, 8, [
					_m(P_TABLE_R, 0, 0, "圆桌", "中央雅座（cozy_tea）。", 0.7),
					_m(P_STOOL_TEA, -2, 1, "矮凳", "围桌配套凳。", 0.75),
					_m(P_STOOL_TEA, 2, 1, "矮凳", "围桌配套凳。", 0.75),
					_m(P_STOOL_TEA, 0, 2, "矮凳", "南侧围桌凳。", 0.75),
					_m(P_NOTICE, -3, -3, "告示", "座席旁规矩牌。", 0.5),
				]),
				_cluster("party_b", 22, 8, [
					_m(P_TABLE_R, 0, 0, "圆桌", "邻桌雅座（cozy_tea）。", 0.7),
					_m(P_STOOL_TEA, -1, 1, "矮凳", "邻桌配套凳。", 0.75),
					_m(P_STOOL_TEA, 2, 1, "矮凳", "邻桌配套凳。", 0.75),
				]),
				_cluster("hearth", 28, 6, [
					_m(P_FIREPLACE, 0, 0, "壁炉", "东墙壁炉。", 0.7),
					_m(P_STOOL, -2, 2, "凳", "炉前烤火矮凳（同家族）。", 0.8),
					_m(P_CRATE0, 2, 2, "酒窖箱", "炉旁存货。", PROP),
				]),
			],
			"fx": [{"kind": "fire", "tx": 28, "ty": 6, "oy": -16}],
			"ambient": [],
			"lights": [
				{"tx": 7, "ty": 5, "oy": -12, "color": Color(1.0, 0.7, 0.4), "energy": 1.0, "scale": 2.2},
				{"tx": 16, "ty": 8, "oy": -6, "color": Color(1.0, 0.78, 0.5), "energy": 0.55, "scale": 1.8},
			],
			"actor": {
				"id": "merchant",
				"title": "酒保",
				"desc": "在吧台与座席间穿梭。",
				"via_clusters": ["bar", "party_a", "party_b", "hearth"],
			},
		},
	}
