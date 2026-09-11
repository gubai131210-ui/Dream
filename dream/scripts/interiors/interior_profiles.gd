class_name InteriorProfiles
extends RefCounted

## Room profile table for Phase 5 Wave A.
## Each profile: foundation size + return path + furniture zones + actor + light mood.
## Silhouettes must differ (home ≠ shop counter aisle ≠ barn stalls). See INTERIOR_FOUNDATION.md.

const PROP := 0.55
const TILE_DIR := "res://assets/sprites/interior/tiles"

## Shared prop paths (outdoor wood language).
const P_BENCH0 := "res://assets/sprites/props/bench_0.png"
const P_BENCH1 := "res://assets/sprites/props/bench_1.png"
const P_CRATE0 := "res://assets/sprites/props/crate_0.png"
const P_CRATE1 := "res://assets/sprites/props/crate_1.png"
const P_BARREL := "res://assets/sprites/props/barrel_1.png"
const P_BARREL_KEG := "res://assets/sprites/props/barrel_0.png"
const P_LAMP0 := "res://assets/sprites/props/lamp_0.png"
const P_LAMP1 := "res://assets/sprites/props/lamp_1.png"
const P_SACK0 := "res://assets/sprites/props/sack_0.png"
const P_SACK1 := "res://assets/sprites/props/sack_1.png"
const P_BED := "res://assets/sprites/interior/tiles/bed_00.png"


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
			"hint": "主角住宅 · 入口→起居→休息 — 点击家具查看",
			"return_path": "res://scenes/areas/village_residential/village_residential.tscn",
			"room_w": 32,
			"room_h": 20,
			"door_tx0": 14,
			"door_tx1": 17,
			"modulate": Color(0.82, 0.78, 0.72, 1.0),
			"rug": {"ox": 14, "oy": 12},
			"window": true,
			"props": [
				{"path": P_BENCH0, "tx": 10, "ty": 6, "title": "木桌", "desc": "北窗下用餐木桌。"},
				{"path": P_BENCH1, "tx": 10, "ty": 8, "title": "长椅", "desc": "桌旁歇脚长椅。"},
				{"path": P_CRATE0, "tx": 27, "ty": 7, "title": "储物箱", "desc": "东墙储物木箱。"},
				{"path": P_CRATE1, "tx": 27, "ty": 9, "title": "木箱", "desc": "叠放日用木箱。"},
				{"path": P_BARREL, "tx": 25, "ty": 11, "title": "木桶", "desc": "竖放储水木桶。"},
				{"path": P_LAMP0, "tx": 28, "ty": 6, "title": "壁灯", "desc": "东墙暖色壁灯。"},
				{"path": P_SACK0, "tx": 6, "ty": 15, "title": "粮袋", "desc": "门厅旁粮袋。"},
				{"path": P_BED, "tx": 25, "ty": 15, "scale": 1.0, "title": "床铺", "desc": "休息区床铺。"},
			],
			"lights": [
				{"tx": 28, "ty": 6, "oy": -20, "color": Color(1.0, 0.85, 0.55), "energy": 1.15, "scale": 2.2},
				{"tx": 15, "ty": 2, "oy": 24, "color": Color(1.0, 0.94, 0.75), "energy": 0.75, "scale": 2.8},
			],
			"actor": {
				"id": "farmer",
				"title": "屋主",
				"desc": "在室内整理桌面与储物箱。",
				"route": [[12, 10], [18, 10], [18, 14], [12, 14]],
			},
		},
		"c02_elder": {
			"title": "老人宅",
			"hint": "村民宅·老人 — 安静起居，少杂物",
			"return_path": "res://scenes/areas/village_residential/village_residential.tscn",
			"room_w": 28,
			"room_h": 18,
			"door_tx0": 12,
			"door_tx1": 15,
			"modulate": Color(0.80, 0.78, 0.74, 1.0),
			"rug": {"ox": 12, "oy": 11},
			"window": true,
			"props": [
				{"path": P_BENCH0, "tx": 8, "ty": 6, "title": "茶几", "desc": "窗边小茶几。"},
				{"path": P_BENCH1, "tx": 8, "ty": 8, "title": "靠椅", "desc": "老人常坐的靠椅。"},
				{"path": P_LAMP1, "tx": 22, "ty": 6, "title": "台灯", "desc": "柔和台灯。"},
				{"path": P_CRATE0, "tx": 23, "ty": 10, "title": "药箱", "desc": "常用草药箱。"},
				{"path": P_BED, "tx": 20, "ty": 13, "scale": 1.0, "title": "床铺", "desc": "靠墙单人床。"},
			],
			"lights": [
				{"tx": 22, "ty": 6, "oy": -16, "color": Color(1.0, 0.88, 0.6), "energy": 1.0, "scale": 2.0},
			],
			"actor": {
				"id": "elder_woman",
				"title": "老妇人",
				"desc": "在屋内缓步走动。",
				"route": [[10, 9], [16, 9], [16, 12], [10, 12]],
			},
		},
		"c02_farmer": {
			"title": "农家宅",
			"hint": "村民宅·农夫 — 粮袋与工具区",
			"return_path": "res://scenes/areas/village_residential/village_residential.tscn",
			"room_w": 30,
			"room_h": 18,
			"door_tx0": 13,
			"door_tx1": 16,
			"modulate": Color(0.84, 0.80, 0.70, 1.0),
			"rug": {"ox": 13, "oy": 11},
			"window": true,
			"props": [
				{"path": P_BENCH0, "tx": 9, "ty": 6, "title": "饭桌", "desc": "农家饭桌。"},
				{"path": P_SACK0, "tx": 24, "ty": 7, "title": "粮袋", "desc": "刚晒过的粮袋。"},
				{"path": P_SACK1, "tx": 26, "ty": 8, "title": "种子袋", "desc": "待播种子。"},
				{"path": P_CRATE1, "tx": 24, "ty": 10, "title": "工具箱", "desc": "锄镰收纳箱。"},
				{"path": P_BARREL, "tx": 6, "ty": 12, "title": "水桶", "desc": "门边取水桶。"},
				{"path": P_LAMP0, "tx": 26, "ty": 6, "title": "壁灯", "desc": "农家壁灯。"},
				{"path": P_BED, "tx": 22, "ty": 13, "scale": 1.0, "title": "床铺", "desc": "夫妻床铺。"},
			],
			"lights": [
				{"tx": 26, "ty": 6, "oy": -18, "color": Color(1.0, 0.82, 0.5), "energy": 1.1, "scale": 2.1},
			],
			"actor": {
				"id": "farmer",
				"title": "农夫",
				"desc": "进屋整理粮袋。",
				"route": [[11, 9], [18, 9], [18, 12], [11, 12]],
			},
		},
		"c02_merchant": {
			"title": "商贾宅",
			"hint": "村民宅·商贾 — 货箱与账桌",
			"return_path": "res://scenes/areas/village_residential/village_residential.tscn",
			"room_w": 30,
			"room_h": 18,
			"door_tx0": 13,
			"door_tx1": 16,
			"modulate": Color(0.78, 0.76, 0.80, 1.0),
			"rug": {"ox": 13, "oy": 11},
			"window": true,
			"props": [
				{"path": P_BENCH0, "tx": 9, "ty": 6, "title": "账桌", "desc": "算账用木桌。"},
				{"path": P_CRATE0, "tx": 24, "ty": 6, "title": "货箱", "desc": "待发货箱。"},
				{"path": P_CRATE1, "tx": 26, "ty": 8, "title": "货箱", "desc": "精品货箱。"},
				{"path": P_CRATE0, "tx": 24, "ty": 10, "title": "货箱", "desc": "堆叠货箱。"},
				{"path": P_LAMP0, "tx": 11, "ty": 5, "title": "壁灯", "desc": "账桌旁灯。"},
				{"path": P_BED, "tx": 22, "ty": 13, "scale": 1.0, "title": "床铺", "desc": "商贾卧榻。"},
			],
			"lights": [
				{"tx": 11, "ty": 5, "oy": -16, "color": Color(0.95, 0.9, 0.7), "energy": 1.05, "scale": 2.0},
			],
			"actor": {
				"id": "merchant",
				"title": "商人",
				"desc": "清点货箱。",
				"route": [[12, 9], [19, 9], [19, 12], [12, 12]],
			},
		},
		"c02_blacksmith_home": {
			"title": "铁匠宅",
			"hint": "村民宅·铁匠 — 工具与厚桌",
			"return_path": "res://scenes/areas/village_residential/village_residential.tscn",
			"room_w": 28,
			"room_h": 18,
			"door_tx0": 12,
			"door_tx1": 15,
			"modulate": Color(0.76, 0.74, 0.72, 1.0),
			"rug": {"ox": 12, "oy": 11},
			"window": true,
			"props": [
				{"path": P_BENCH0, "tx": 8, "ty": 7, "title": "厚桌", "desc": "耐用工作桌。"},
				{"path": P_CRATE1, "tx": 22, "ty": 7, "title": "工具箱", "desc": "锤钳箱。"},
				{"path": P_BARREL, "tx": 22, "ty": 10, "title": "淬火桶", "desc": "家用淬火水桶。"},
				{"path": P_LAMP0, "tx": 23, "ty": 6, "title": "壁灯", "desc": "暖黄壁灯。"},
				{"path": P_BED, "tx": 19, "ty": 13, "scale": 1.0, "title": "床铺", "desc": "铁匠床铺。"},
			],
			"lights": [
				{"tx": 23, "ty": 6, "oy": -16, "color": Color(1.0, 0.75, 0.45), "energy": 1.2, "scale": 2.0},
			],
			"actor": {
				"id": "blacksmith",
				"title": "铁匠",
				"desc": "回家收拾工具。",
				"route": [[10, 9], [16, 9], [16, 12], [10, 12]],
			},
		},
		"c03_barn": {
			"title": "谷仓内部",
			"hint": "谷仓 — 干草与饲料通道",
			"return_path": "res://scenes/areas/farm_residential/farm_residential.tscn",
			"room_w": 34,
			"room_h": 22,
			"door_tx0": 15,
			"door_tx1": 18,
			"modulate": Color(0.78, 0.72, 0.62, 1.0),
			"rug": {"ox": 15, "oy": 14},
			"window": false,
			"props": [
				{"path": P_SACK0, "tx": 6, "ty": 8, "title": "饲料袋", "desc": "西侧饲料堆。"},
				{"path": P_SACK1, "tx": 8, "ty": 10, "title": "饲料袋", "desc": "叠放饲料。"},
				{"path": P_SACK0, "tx": 6, "ty": 12, "title": "干草捆", "desc": "干草捆。"},
				{"path": P_CRATE0, "tx": 28, "ty": 8, "title": "农具箱", "desc": "东侧农具。"},
				{"path": P_CRATE1, "tx": 28, "ty": 11, "title": "农具箱", "desc": "备用农具。"},
				{"path": P_BARREL, "tx": 26, "ty": 14, "title": "水桶", "desc": "牲口饮水桶。"},
				{"path": P_LAMP0, "tx": 17, "ty": 5, "title": "吊灯", "desc": "谷仓暖灯。"},
			],
			"lights": [
				{"tx": 17, "ty": 5, "oy": -10, "color": Color(1.0, 0.8, 0.5), "energy": 1.0, "scale": 3.0},
			],
			"actor": {
				"id": "farmer",
				"title": "仓管",
				"desc": "巡视饲料通道。",
				"route": [[12, 12], [22, 12], [22, 16], [12, 16]],
			},
		},
		"c03_coop": {
			"title": "鸡舍内部",
			"hint": "鸡舍 — 窄室与食槽",
			"return_path": "res://scenes/areas/farm_residential/farm_residential.tscn",
			"room_w": 22,
			"room_h": 16,
			"door_tx0": 9,
			"door_tx1": 12,
			"modulate": Color(0.80, 0.76, 0.68, 1.0),
			"rug": {"ox": 9, "oy": 10},
			"window": true,
			"props": [
				{"path": P_CRATE0, "tx": 5, "ty": 6, "title": "巢箱", "desc": "西墙巢箱。"},
				{"path": P_CRATE1, "tx": 5, "ty": 8, "title": "巢箱", "desc": "产蛋巢箱。"},
				{"path": P_SACK0, "tx": 16, "ty": 7, "title": "鸡食", "desc": "鸡食袋。"},
				{"path": P_BARREL, "tx": 16, "ty": 10, "title": "水槽", "desc": "饮水桶。"},
				{"path": P_LAMP1, "tx": 11, "ty": 5, "title": "小灯", "desc": "鸡舍小灯。"},
			],
			"lights": [
				{"tx": 11, "ty": 5, "oy": -12, "color": Color(1.0, 0.9, 0.65), "energy": 0.9, "scale": 1.8},
			],
			"actor": {
				"id": "farmer",
				"title": "饲鸡人",
				"desc": "检查巢箱。",
				"route": [[8, 8], [14, 8], [14, 11], [8, 11]],
			},
		},
		"c04_grocery": {
			"title": "杂货店",
			"hint": "杂货店 — 柜台与货架通道",
			"return_path": "res://scenes/areas/market_street/market_street.tscn",
			"room_w": 30,
			"room_h": 18,
			"door_tx0": 13,
			"door_tx1": 16,
			"modulate": Color(0.84, 0.82, 0.78, 1.0),
			"rug": {"ox": 13, "oy": 12},
			"window": true,
			"props": [
				{"path": P_BENCH0, "tx": 14, "ty": 7, "title": "柜台", "desc": "南向柜台（顾客侧在南）。"},
				{"path": P_CRATE0, "tx": 6, "ty": 6, "title": "货架箱", "desc": "西墙货架。"},
				{"path": P_CRATE1, "tx": 6, "ty": 9, "title": "货架箱", "desc": "日杂货箱。"},
				{"path": P_SACK0, "tx": 24, "ty": 6, "title": "米袋", "desc": "东墙米袋。"},
				{"path": P_SACK1, "tx": 26, "ty": 8, "title": "糖袋", "desc": "糖盐袋。"},
				{"path": P_BARREL, "tx": 24, "ty": 11, "title": "油桶", "desc": "食用油桶。"},
				{"path": P_LAMP0, "tx": 16, "ty": 5, "title": "店灯", "desc": "柜台顶灯。"},
			],
			"lights": [
				{"tx": 16, "ty": 5, "oy": -14, "color": Color(1.0, 0.92, 0.7), "energy": 1.1, "scale": 2.4},
			],
			"actor": {
				"id": "merchant",
				"title": "店主",
				"desc": "在柜台后招呼。",
				"route": [[12, 6], [18, 6], [18, 8], [12, 8]],
			},
		},
		"c04_smith": {
			"title": "铁匠铺",
			"hint": "铁匠铺 — 炉火侧与顾客通道",
			"return_path": "res://scenes/areas/market_street/market_street.tscn",
			"room_w": 28,
			"room_h": 18,
			"door_tx0": 12,
			"door_tx1": 15,
			"modulate": Color(0.72, 0.68, 0.66, 1.0),
			"rug": {"ox": 12, "oy": 12},
			"window": false,
			"props": [
				{"path": P_BENCH0, "tx": 8, "ty": 8, "title": "砧桌", "desc": "西侧锻打桌。"},
				{"path": P_BARREL, "tx": 8, "ty": 11, "title": "淬火桶", "desc": "淬火水桶。"},
				{"path": P_CRATE1, "tx": 22, "ty": 7, "title": "成品箱", "desc": "待售铁器。"},
				{"path": P_CRATE0, "tx": 22, "ty": 10, "title": "废料箱", "desc": "铁屑箱。"},
				{"path": P_LAMP0, "tx": 10, "ty": 5, "title": "炉灯", "desc": "炉火旁暖灯。"},
				{"path": P_BENCH1, "tx": 16, "ty": 12, "title": "候坐", "desc": "顾客等候长椅。"},
			],
			"lights": [
				{"tx": 10, "ty": 5, "oy": -12, "color": Color(1.0, 0.55, 0.28), "energy": 1.35, "scale": 2.2},
			],
			"actor": {
				"id": "blacksmith",
				"title": "铁匠",
				"desc": "在砧桌与淬火桶间走动。",
				"route": [[9, 9], [14, 9], [14, 12], [9, 12]],
			},
		},
		"c04_tavern": {
			"title": "酒馆",
			"hint": "酒馆 — 吧台与座席",
			"return_path": "res://scenes/areas/market_street/market_street.tscn",
			"room_w": 32,
			"room_h": 20,
			"door_tx0": 14,
			"door_tx1": 17,
			"modulate": Color(0.74, 0.68, 0.60, 1.0),
			"rug": {"ox": 14, "oy": 13},
			"window": true,
			"props": [
				{"path": P_BENCH0, "tx": 8, "ty": 7, "title": "吧台", "desc": "西侧吧台。"},
				{"path": P_BARREL_KEG, "tx": 6, "ty": 9, "title": "酒桶", "desc": "横放取酒桶（特例）。"},
				{"path": P_BARREL, "tx": 6, "ty": 12, "title": "酒桶", "desc": "竖放存酒。"},
				{"path": P_BENCH1, "tx": 18, "ty": 8, "title": "雅座", "desc": "中央座席。"},
				{"path": P_BENCH1, "tx": 22, "ty": 8, "title": "雅座", "desc": "邻桌座席。"},
				{"path": P_BENCH0, "tx": 20, "ty": 11, "title": "大桌", "desc": "拼桌聚餐。"},
				{"path": P_LAMP0, "tx": 10, "ty": 5, "title": "酒馆灯", "desc": "暖黄吊灯感壁灯。"},
				{"path": P_CRATE0, "tx": 26, "ty": 14, "title": "酒窖箱", "desc": "东角存货。"},
			],
			"lights": [
				{"tx": 10, "ty": 5, "oy": -14, "color": Color(1.0, 0.7, 0.4), "energy": 1.2, "scale": 2.6},
				{"tx": 20, "ty": 8, "oy": -8, "color": Color(1.0, 0.8, 0.55), "energy": 0.7, "scale": 2.0},
			],
			"actor": {
				"id": "merchant",
				"title": "酒保",
				"desc": "在吧台与座席间穿梭。",
				"route": [[10, 8], [16, 8], [16, 12], [10, 12]],
			},
		},
	}
