class_name InteriorProfiles
extends RefCounted

## Room profiles — differentiated by INTERIOR_ROOM_BRIEFS.md.
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
const P_HAY := DIR_INTERIOR_PROP + "/hay_00.png"
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
const P_BARREL := DIR_OUTDOOR_PROP + "/barrel_1.png"
const P_BARREL_KEG := DIR_OUTDOOR_PROP + "/barrel_0.png"
const P_CRATE0 := DIR_OUTDOOR_PROP + "/crate_0.png"
const P_CRATE1 := DIR_OUTDOOR_PROP + "/crate_1.png"
const P_SACK0 := DIR_OUTDOOR_PROP + "/sack_0.png"
const P_SACK1 := DIR_OUTDOOR_PROP + "/sack_1.png"
const P_LAMP0 := DIR_OUTDOOR_PROP + "/lamp_0.png"
const P_LAMP1 := DIR_OUTDOOR_PROP + "/lamp_1.png"

const RES := "res://scenes/areas/village_residential/village_residential.tscn"
const FARM := "res://scenes/areas/farm_residential/farm_residential.tscn"
const MKT := "res://scenes/areas/market_street/market_street.tscn"


static func get_profile(profile_id: String) -> Dictionary:
	var all := _all()
	if all.has(profile_id):
		return all[profile_id]
	push_warning("InteriorProfiles: unknown '%s', fallback c01_home" % profile_id)
	return all["c01_home"]


static func _all() -> Dictionary:
	return {
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
			"rug": {"ox": 15, "oy": 14},
			"window": true,
			"props": [
				{"path": P_FIREPLACE, "tx": 16, "ty": 4, "scale": 1.0, "title": "壁炉", "desc": "起居区壁炉，暖光锚点。"},
				{"path": P_STOVE, "tx": 5, "ty": 6, "scale": 0.95, "title": "灶台", "desc": "西侧厨房灶台。"},
				{"path": P_SHELF, "tx": 3, "ty": 6, "scale": 0.9, "title": "厨架", "desc": "调料与碗碟架。"},
				{"path": P_TABLE_DINING, "tx": 12, "ty": 8, "scale": 0.95, "title": "饭桌", "desc": "中轴旁用餐桌。"},
				{"path": P_STOOL, "tx": 11, "ty": 9, "scale": 0.75, "title": "凳", "desc": "饭桌旁矮凳。"},
				{"path": P_STOOL, "tx": 14, "ty": 9, "scale": 0.75, "title": "凳", "desc": "饭桌旁矮凳。"},
				{"path": P_HERBS, "tx": 7, "ty": 4, "scale": 0.8, "title": "干草药", "desc": "北墙晾挂草药。"},
				{"path": P_DRESSER, "tx": 28, "ty": 6, "scale": 0.95, "title": "衣柜", "desc": "东墙衣柜。"},
				{"path": P_BED_D, "tx": 28, "ty": 14, "scale": 1.05, "title": "双人床", "desc": "东南休息区。"},
				{"path": P_LAMP0, "tx": 29, "ty": 5, "title": "壁灯", "desc": "床区壁灯。"},
				{"path": P_BARREL, "tx": 6, "ty": 16, "title": "水桶", "desc": "门厅储水桶。"},
			],
			"fx": [{"kind": "fire", "tx": 16, "ty": 5, "oy": -18}],
			"ambient": [{"species": "cat", "tx": 20, "ty": 12}],
			"lights": [
				{"tx": 5, "ty": 6, "oy": -12, "color": Color(1.0, 0.75, 0.45), "energy": 0.7, "scale": 1.6},
				{"tx": 29, "ty": 5, "oy": -16, "color": Color(1.0, 0.88, 0.6), "energy": 0.9, "scale": 2.0},
			],
			"actor": {
				"id": "farmer",
				"title": "屋主",
				"desc": "在厨房与起居间忙碌。",
				"route": [[10, 10], [18, 10], [18, 15], [10, 15]],
			},
		},
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
			"rug": {"ox": 11, "oy": 10},
			"window": true,
			"props": [
				{"path": P_ROCKING, "tx": 7, "ty": 6, "scale": 0.65, "title": "摇椅", "desc": "窗边摇椅。"},
				{"path": P_TABLE_R, "tx": 9, "ty": 7, "scale": 0.5, "title": "茶几", "desc": "小圆茶几。"},
				{"path": P_MEDICINE, "tx": 20, "ty": 5, "scale": 0.6, "title": "药箱", "desc": "草药箱。"},
				{"path": P_LAMP1, "tx": 19, "ty": 6, "title": "台灯", "desc": "柔和台灯。"},
				{"path": P_BED_S, "tx": 20, "ty": 11, "scale": 0.65, "title": "单人床", "desc": "靠墙单人床。"},
				{"path": P_HERBS, "tx": 4, "ty": 4, "scale": 0.45, "title": "干花", "desc": "一束干花。"},
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 19, "ty": 6, "oy": -14, "color": Color(1.0, 0.9, 0.7), "energy": 0.85, "scale": 1.8},
			],
			"actor": {
				"id": "elder_woman",
				"title": "老妇人",
				"desc": "缓步走到茶几旁。",
				"route": [[8, 8], [14, 8], [14, 11], [8, 11]],
			},
		},
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
			"rug": {"ox": 13, "oy": 12},
			"window": true,
			"props": [
				{"path": P_TOOL_RACK, "tx": 4, "ty": 6, "scale": 0.95, "title": "工具架", "desc": "西墙锄镰架。"},
				{"path": P_SACK0, "tx": 6, "ty": 14, "title": "粮袋", "desc": "门厅粮袋。"},
				{"path": P_SACK1, "tx": 8, "ty": 15, "title": "种子袋", "desc": "待播种子。"},
				{"path": P_TABLE_DINING, "tx": 14, "ty": 7, "scale": 0.95, "title": "饭桌", "desc": "农家大饭桌。"},
				{"path": P_STOOL, "tx": 12, "ty": 8, "scale": 0.75, "title": "凳", "desc": "饭桌凳。"},
				{"path": P_STOOL, "tx": 16, "ty": 8, "scale": 0.75, "title": "凳", "desc": "饭桌凳。"},
				{"path": P_CRATE1, "tx": 24, "ty": 7, "title": "工具箱", "desc": "备用农具箱。"},
				{"path": P_BED_D, "tx": 24, "ty": 13, "scale": 1.0, "title": "床铺", "desc": "夫妻床。"},
				{"path": P_LAMP0, "tx": 25, "ty": 5, "title": "壁灯", "desc": "暖黄壁灯。"},
				{"path": P_BARREL, "tx": 10, "ty": 14, "title": "水桶", "desc": "门边取水。"},
			],
			"fx": [],
			"ambient": [{"species": "dog", "tx": 18, "ty": 14}],
			"lights": [
				{"tx": 25, "ty": 5, "oy": -16, "color": Color(1.0, 0.82, 0.48), "energy": 1.05, "scale": 2.0},
			],
			"actor": {
				"id": "farmer",
				"title": "农夫",
				"desc": "进屋整理粮袋。",
				"route": [[10, 9], [18, 9], [18, 13], [10, 13]],
			},
		},
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
			"rug": {"ox": 13, "oy": 11},
			"window": true,
			"props": [
				{"path": P_LEDGER, "tx": 10, "ty": 6, "scale": 0.65, "title": "账桌", "desc": "北侧账簿桌。"},
				{"path": P_LAMP1, "tx": 12, "ty": 5, "title": "台灯", "desc": "账桌灯。"},
				{"path": P_COIN, "tx": 8, "ty": 7, "scale": 0.55, "title": "钱箱", "desc": "账桌旁钱箱。"},
				{"path": P_CRATE0, "tx": 24, "ty": 5, "title": "货箱", "desc": "东墙货箱堆。"},
				{"path": P_CRATE1, "tx": 26, "ty": 7, "title": "货箱", "desc": "精品货箱。"},
				{"path": P_CRATE0, "tx": 24, "ty": 9, "title": "货箱", "desc": "待发货。"},
				{"path": P_SHELF, "tx": 27, "ty": 5, "scale": 0.5, "title": "货架", "desc": "样品货架。"},
				{"path": P_BED_S, "tx": 22, "ty": 13, "scale": 0.65, "title": "卧榻", "desc": "后室单人床。"},
				{"path": P_NOTICE, "tx": 5, "ty": 5, "scale": 0.5, "title": "货单", "desc": "壁挂货单。"},
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 12, "ty": 5, "oy": -14, "color": Color(0.95, 0.92, 0.75), "energy": 1.0, "scale": 1.9},
			],
			"actor": {
				"id": "merchant",
				"title": "商人",
				"desc": "清点货箱与账本。",
				"route": [[12, 8], [20, 8], [20, 12], [12, 12]],
			},
		},
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
			"rug": {"ox": 12, "oy": 11},
			"window": true,
			"props": [
				{"path": P_TOOL_RACK, "tx": 5, "ty": 5, "scale": 0.9, "title": "家用工具架", "desc": "下班带回的锤钳。"},
				{"path": P_TABLE_DINING, "tx": 10, "ty": 7, "scale": 0.95, "title": "厚桌", "desc": "耐用木桌。"},
				{"path": P_ANVIL, "tx": 6, "ty": 8, "scale": 0.75, "title": "小砧", "desc": "家用小砧（非铺内锻炉）。"},
				{"path": P_BARREL, "tx": 8, "ty": 10, "title": "淬火桶", "desc": "家用淬火水桶。"},
				{"path": P_CRATE1, "tx": 22, "ty": 6, "title": "零件箱", "desc": "铁钉零件。"},
				{"path": P_BED_S, "tx": 20, "ty": 12, "scale": 1.0, "title": "床铺", "desc": "铁匠床铺。"},
				{"path": P_LAMP0, "tx": 21, "ty": 5, "title": "壁灯", "desc": "偏橙暖灯。"},
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 21, "ty": 5, "oy": -14, "color": Color(1.0, 0.7, 0.42), "energy": 1.1, "scale": 1.9},
			],
			"actor": {
				"id": "blacksmith",
				"title": "铁匠",
				"desc": "回家收拾工具。",
				"route": [[9, 8], [16, 8], [16, 12], [9, 12]],
			},
		},
		"c03_barn": {
			"title": "谷仓内部",
			"hint": "谷仓 · 中央通道 + 两侧畜栏",
			"return_path": FARM,
			"room_w": 36,
			"room_h": 22,
			"door_tx0": 16,
			"door_tx1": 19,
			"floor": "straw",
			"modulate": Color(0.82, 0.76, 0.62, 1.0),
			"rug": null,
			"window": false,
			"props": [
				{"path": P_HAY, "tx": 5, "ty": 6, "scale": 0.7, "title": "干草堆", "desc": "西栏干草。"},
				{"path": P_HAY, "tx": 5, "ty": 10, "scale": 0.65, "title": "干草捆", "desc": "西栏叠草。"},
				{"path": P_TROUGH, "tx": 8, "ty": 8, "scale": 0.65, "title": "食槽", "desc": "西侧食槽。"},
				{"path": P_HAY, "tx": 30, "ty": 6, "scale": 0.7, "title": "干草堆", "desc": "东栏干草。"},
				{"path": P_TROUGH, "tx": 27, "ty": 9, "scale": 0.65, "title": "水槽", "desc": "东侧饮水槽。"},
				{"path": P_CRATE0, "tx": 30, "ty": 12, "title": "农具箱", "desc": "东角农具。"},
				{"path": P_SACK0, "tx": 6, "ty": 14, "title": "饲料袋", "desc": "通道旁饲料。"},
				{"path": P_SACK1, "tx": 8, "ty": 15, "title": "饲料袋", "desc": "叠放饲料。"},
				{"path": P_BARREL, "tx": 28, "ty": 15, "title": "水桶", "desc": "备用饮水。"},
				{"path": P_LAMP0, "tx": 18, "ty": 4, "title": "吊灯", "desc": "通道暖灯。"},
				{"path": P_TOOL_RACK, "tx": 32, "ty": 5, "scale": 0.55, "title": "耙叉架", "desc": "墙上农具。"},
			],
			"fx": [],
			"ambient": [
				{"species": "sheep", "tx": 10, "ty": 10},
				{"species": "cow", "tx": 26, "ty": 11},
			],
			"lights": [
				{"tx": 18, "ty": 4, "oy": -8, "color": Color(1.0, 0.82, 0.5), "energy": 1.05, "scale": 3.2},
			],
			"actor": {
				"id": "farmer",
				"title": "仓管",
				"desc": "沿中央通道巡视畜栏。",
				"route": [[14, 12], [22, 12], [22, 16], [14, 16]],
			},
		},
		"c03_coop": {
			"title": "鸡舍内部",
			"hint": "鸡舍 · 巢箱与栖木，鸡只啄食",
			"return_path": FARM,
			"room_w": 20,
			"room_h": 14,
			"door_tx0": 8,
			"door_tx1": 11,
			"floor": "straw",
			"modulate": Color(0.84, 0.80, 0.70, 1.0),
			"rug": null,
			"window": true,
			"props": [
				{"path": P_NEST, "tx": 3, "ty": 4, "scale": 0.65, "title": "巢箱", "desc": "西墙产蛋巢。"},
				{"path": P_NEST, "tx": 3, "ty": 7, "scale": 0.65, "title": "巢箱", "desc": "下层巢箱。"},
				{"path": P_NEST, "tx": 3, "ty": 9, "scale": 0.6, "title": "巢箱", "desc": "底层巢箱。"},
				{"path": P_ROOST, "tx": 14, "ty": 4, "scale": 0.7, "title": "栖木", "desc": "东侧栖木。"},
				{"path": P_TROUGH, "tx": 10, "ty": 7, "scale": 0.55, "title": "食槽", "desc": "中央食槽。"},
				{"path": P_SACK0, "tx": 15, "ty": 8, "title": "鸡食", "desc": "鸡食袋。"},
				{"path": P_BARREL, "tx": 15, "ty": 10, "title": "水桶", "desc": "饮水桶。"},
				{"path": P_LAMP1, "tx": 10, "ty": 3, "title": "小灯", "desc": "鸡舍小灯。"},
			],
			"fx": [],
			"ambient": [
				{"species": "chicken", "tx": 8, "ty": 8},
				{"species": "chicken", "tx": 12, "ty": 9},
				{"species": "chicken", "tx": 9, "ty": 10},
			],
			"lights": [
				{"tx": 10, "ty": 3, "oy": -10, "color": Color(1.0, 0.92, 0.7), "energy": 0.8, "scale": 1.6},
			],
			"actor": {
				"id": "farmer",
				"title": "饲鸡人",
				"desc": "检查巢箱与食槽。",
				"route": [[7, 6], [13, 6], [13, 10], [7, 10]],
			},
		},
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
			"rug": {"ox": 13, "oy": 13},
			"window": true,
			"props": [
				{"path": P_SHELF_GROCERY, "tx": 4, "ty": 5, "scale": 1.0, "title": "西货架", "desc": "日杂货架。"},
				{"path": P_SHELF, "tx": 4, "ty": 9, "scale": 0.95, "title": "西货架", "desc": "罐装货架。"},
				{"path": P_SHELF_GROCERY, "tx": 25, "ty": 5, "scale": 1.0, "title": "东货架", "desc": "干货架。"},
				{"path": P_SHELF, "tx": 25, "ty": 9, "scale": 0.95, "title": "东货架", "desc": "盐糖架。"},
				{"path": P_COUNTER, "tx": 14, "ty": 8, "scale": 1.05, "title": "柜台", "desc": "南向收银台（顾客在南）。"},
				{"path": P_BASKET, "tx": 10, "ty": 10, "scale": 0.85, "title": "菜筐", "desc": "新鲜蔬果筐。"},
				{"path": P_BASKET, "tx": 18, "ty": 10, "scale": 0.85, "title": "菜筐", "desc": "根茎菜筐。"},
				{"path": P_SACK0, "tx": 22, "ty": 12, "title": "米袋", "desc": "米粮袋。"},
				{"path": P_BARREL, "tx": 7, "ty": 12, "title": "油桶", "desc": "食用油桶。"},
				{"path": P_NOTICE, "tx": 16, "ty": 5, "scale": 0.85, "title": "告示板", "desc": "今日价目。"},
				{"path": P_LAMP0, "tx": 15, "ty": 4, "title": "店灯", "desc": "柜台顶灯。"},
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 15, "ty": 4, "oy": -12, "color": Color(1.0, 0.94, 0.75), "energy": 1.15, "scale": 2.5},
			],
			"actor": {
				"id": "merchant",
				"title": "店主",
				"desc": "在柜台后招呼顾客。",
				"route": [[12, 6], [17, 6], [17, 7], [12, 7]],
			},
		},
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
			"props": [
				{"path": P_FORGE, "tx": 8, "ty": 4, "scale": 1.05, "title": "锻炉", "desc": "北侧锻炉。"},
				{"path": P_ANVIL, "tx": 7, "ty": 8, "scale": 0.95, "title": "铁砧", "desc": "西侧锻打砧。"},
				{"path": P_BARREL, "tx": 10, "ty": 9, "title": "淬火桶", "desc": "淬火水桶。"},
				{"path": P_TOOL_RACK, "tx": 4, "ty": 5, "scale": 0.95, "title": "工具墙", "desc": "锤钳挂架。"},
				{"path": P_CRATE1, "tx": 22, "ty": 6, "title": "成品箱", "desc": "待售铁器。"},
				{"path": P_CRATE0, "tx": 22, "ty": 9, "title": "废料箱", "desc": "铁屑箱。"},
				{"path": P_TABLE_DINING, "tx": 16, "ty": 13, "scale": 0.9, "title": "候坐", "desc": "顾客等候桌椅。"},
				{"path": P_LAMP0, "tx": 20, "ty": 5, "title": "壁灯", "desc": "铺内壁灯。"},
			],
			"fx": [{"kind": "forge", "tx": 8, "ty": 5, "oy": -10}],
			"ambient": [],
			"lights": [
				{"tx": 20, "ty": 5, "oy": -12, "color": Color(1.0, 0.7, 0.4), "energy": 0.7, "scale": 1.8},
			],
			"actor": {
				"id": "blacksmith",
				"title": "铁匠",
				"desc": "在砧与淬火桶间走动。",
				"route": [[8, 9], [14, 9], [14, 12], [8, 12]],
			},
		},
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
			"rug": {"ox": 15, "oy": 14},
			"window": true,
			"props": [
				{"path": P_BAR, "tx": 6, "ty": 7, "scale": 0.75, "title": "吧台", "desc": "西侧长吧台。"},
				{"path": P_BARREL_KEG, "tx": 4, "ty": 9, "scale": 0.6, "title": "酒桶", "desc": "横放取酒桶（特例）。"},
				{"path": P_BARREL, "tx": 4, "ty": 12, "title": "存酒", "desc": "竖放存酒。"},
				{"path": P_MUG_SHELF, "tx": 5, "ty": 4, "scale": 0.6, "title": "杯架", "desc": "墙上杯架。"},
				{"path": P_TABLE_R, "tx": 16, "ty": 8, "scale": 0.65, "title": "圆桌", "desc": "中央雅座。"},
				{"path": P_STOOL, "tx": 14, "ty": 9, "scale": 0.5, "title": "高凳", "desc": "圆桌凳。"},
				{"path": P_STOOL, "tx": 18, "ty": 9, "scale": 0.5, "title": "高凳", "desc": "圆桌凳。"},
				{"path": P_TABLE_R, "tx": 22, "ty": 8, "scale": 0.65, "title": "圆桌", "desc": "邻桌雅座。"},
				{"path": P_STOOL, "tx": 21, "ty": 9, "scale": 0.5, "title": "高凳", "desc": "邻桌凳。"},
				{"path": P_FIREPLACE, "tx": 28, "ty": 5, "scale": 0.7, "title": "壁炉", "desc": "东墙壁炉。"},
				{"path": P_NOTICE, "tx": 12, "ty": 4, "scale": 0.5, "title": "告示", "desc": "酒馆规矩牌。"},
				{"path": P_CRATE0, "tx": 30, "ty": 14, "title": "酒窖箱", "desc": "东角存货。"},
				{"path": P_LAMP0, "tx": 8, "ty": 4, "title": "酒馆灯", "desc": "吧台暖灯。"},
			],
			"fx": [{"kind": "fire", "tx": 28, "ty": 5, "oy": -16}],
			"ambient": [],
			"lights": [
				{"tx": 8, "ty": 4, "oy": -12, "color": Color(1.0, 0.7, 0.4), "energy": 1.0, "scale": 2.2},
				{"tx": 18, "ty": 8, "oy": -6, "color": Color(1.0, 0.78, 0.5), "energy": 0.55, "scale": 1.8},
			],
			"actor": {
				"id": "merchant",
				"title": "酒保",
				"desc": "在吧台与座席间穿梭。",
				"route": [[9, 8], [18, 8], [18, 12], [9, 12]],
			},
		},
	}
