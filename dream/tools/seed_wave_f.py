#!/usr/bin/env python3
"""Lead seed for Phase 5 Wave F — rooms + system stubs + shells."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def patch_file(path: Path, old: str, new: str) -> None:
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise SystemExit(f"patch miss in {path}: {old[:80]!r}")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")
    print("patched", path.relative_to(ROOT))


def append_once(path: Path, needle: str, addition: str) -> None:
    text = path.read_text(encoding="utf-8")
    if needle in text:
        print("skip already", path.relative_to(ROOT), needle[:40])
        return
    if addition.strip() in text:
        print("skip content", path.relative_to(ROOT))
        return
    # unused helper
    path.write_text(text + addition, encoding="utf-8")


ROUTER_ADD = """
## Phase 5 Wave F civic / transit / dive
const C40_MUSEUM_PATH := "res://scenes/interiors/c40_museum/c40_museum.tscn"
const C41_AQUARIUM_PATH := "res://scenes/interiors/c41_aquarium/c41_aquarium.tscn"
const C42_HOTSPRING_PATH := "res://scenes/interiors/c42_hotspring/c42_hotspring.tscn"
const C43_BATHHOUSE_PATH := "res://scenes/interiors/c43_bathhouse/c43_bathhouse.tscn"
const C44_INN_PATH := "res://scenes/interiors/c44_inn/c44_inn.tscn"
const C45_TAVERN_UP_PATH := "res://scenes/interiors/c45_tavern_up/c45_tavern_up.tscn"
const C34_DOCK_FISH_PATH := "res://scenes/interiors/c34_dock_fish/c34_dock_fish.tscn"
const C34_DOCK_TRADE_PATH := "res://scenes/interiors/c34_dock_trade/c34_dock_trade.tscn"
const C35_BOAT_DOCKED_PATH := "res://scenes/interiors/c35_boat_docked/c35_boat_docked.tscn"
const C35_BOAT_WRECK_PATH := "res://scenes/interiors/c35_boat_wreck/c35_boat_wreck.tscn"
const C36_TRAIN_CAR_PATH := "res://scenes/interiors/c36_train_car/c36_train_car.tscn"
const C23_UNDERWATER_PATH := "res://scenes/interiors/c23_underwater/c23_underwater.tscn"
"""

GEN_ADD = """    # Wave F civic / transit / dive
    ("c40_museum", "c40_museum", "C40MuseumInterior"),
    ("c41_aquarium", "c41_aquarium", "C41AquariumInterior"),
    ("c42_hotspring", "c42_hotspring", "C42HotspringInterior"),
    ("c43_bathhouse", "c43_bathhouse", "C43BathhouseInterior"),
    ("c44_inn", "c44_inn", "C44InnInterior"),
    ("c45_tavern_up", "c45_tavern_up", "C45TavernUpInterior"),
    ("c34_dock_fish", "c34_dock_fish", "C34DockFishInterior"),
    ("c34_dock_trade", "c34_dock_trade", "C34DockTradeInterior"),
    ("c35_boat_docked", "c35_boat_docked", "C35BoatDockedInterior"),
    ("c35_boat_wreck", "c35_boat_wreck", "C35BoatWreckInterior"),
    ("c36_train_car", "c36_train_car", "C36TrainCarInterior"),
    ("c23_underwater", "c23_underwater", "C23UnderwaterInterior"),
"""

STUBS = r'''
		# ── Wave F stubs (region teams enrich per-key; remove 「占位」) ──
		"c40_museum": {
			"title": "博物馆",
			"hint": "博物馆 · 展厅 / 捐赠（占位）",
			"return_path": SQ,
			"room_w": 24,
			"room_h": 14,
			"door_tx0": 10,
			"door_tx1": 13,
			"floor": "stone",
			"modulate": Color(0.86, 0.84, 0.80, 1.0),
			"rug": null,
			"window": true,
			"clusters": [
				_cluster("exhibit", 6, 5, [
					_m(P_SHELF, 0, 0, "展柜", "化石展柜（占位）。", 0.9),
					_m(P_CRATE0, 2, 1, "标本箱", "待编目标本。", 0.7),
					_m(P_NOTICE, -1, -2, "捐赠告示", "可捐赠钩子告示。", 0.7),
					_m(P_LAMP_SHOP, 1, -2, "展厅灯", "展厅吊灯。", PROP),
				]),
				_cluster("donate", 17, 6, [
					_m(P_COUNTER, 0, 0, "捐赠台", "前台捐赠登记台（占位）。", 0.95),
					_m(P_LEDGER, 1, -1, "捐赠簿", "捐赠登记簿。", 0.65),
					_m(P_STOOL, -1, 1, "访客凳", "台前凳。", 0.7),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 6, "ty": 4, "oy": -8, "color": Color(1.0, 0.95, 0.85), "energy": 0.9, "scale": 1.8}],
			"actor": {},
		},
		"c41_aquarium": {
			"title": "水族馆",
			"hint": "水族馆 · 水缸区（占位）",
			"return_path": LAKE,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.70, 0.78, 0.86, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("tanks", 6, 5, [
					_m(P_SHELF_GROCERY, 0, 0, "水缸墙", "展示水缸墙（占位）。", 0.95),
					_m(P_BARREL, 2, 1, "滤桶", "过滤水桶。", 0.7),
					_m(P_BASKET, -1, 2, "鱼食筐", "喂食筐。", 0.55),
					_m(P_LAMP_SHOP, 1, -2, "缸灯", "水缸顶灯。", PROP),
				]),
				_cluster("donate_fish", 16, 6, [
					_m(P_COUNTER, 0, 0, "捐赠台", "钓鱼捐赠台（占位）。", 0.9),
					_m(P_ROD_BAMBOO, -2, 0, "展示竿", "捐赠挂钩竿。", 0.7),
					_m(P_LEDGER, 1, -1, "鱼谱", "捐赠鱼谱。", 0.65),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 6, "ty": 4, "oy": -8, "color": Color(0.75, 0.9, 1.0), "energy": 0.95, "scale": 1.9}],
			"actor": {},
		},
		"c42_hotspring": {
			"title": "温泉",
			"hint": "温泉 · 泡池 / 更衣（占位）",
			"return_path": HILL,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.88, 0.82, 0.78, 1.0),
			"rug": null,
			"window": true,
			"clusters": [
				_cluster("pool", 11, 5, [
					_m(P_BARREL, 0, 0, "泡池", "温泉泡池锚（占位）。", 1.0),
					_m(P_BARREL, 2, 0, "池缘", "池缘石/桶。", 0.85),
					_m(P_STOOL, -2, 1, "池边凳", "更衣后入池凳。", 0.7),
				]),
				_cluster("change", 5, 8, [
					_m(P_DRESSER, 0, 0, "更衣柜", "更衣区（占位）。", 0.85),
					_m(P_BASKET, 2, 1, "衣筐", "更衣筐。", 0.6),
					_m(P_LAMP_INDOOR, 1, -2, "更衣灯", "暖灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 11, "ty": 4, "oy": -6, "color": Color(1.0, 0.9, 0.8), "energy": 0.85, "scale": 2.0}],
			"actor": {},
		},
		"c43_bathhouse": {
			"title": "公共浴场",
			"hint": "浴场 · 浴池 / 更衣（占位）",
			"return_path": SQ,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.84, 0.86, 0.88, 1.0),
			"rug": null,
			"window": true,
			"clusters": [
				_cluster("bath", 12, 5, [
					_m(P_BARREL, 0, 0, "浴池", "公共浴池（占位）。", 1.0),
					_m(P_STOOL, -2, 1, "池凳", "池边凳。", 0.7),
					_m(P_BARREL, 2, 1, "水桶", "冲洗桶。", 0.75),
				]),
				_cluster("locker", 5, 7, [
					_m(P_DRESSER, 0, 0, "更衣柜", "更衣柜（占位）。", 0.85),
					_m(P_BASKET, 2, 0, "衣筐", "衣筐。", 0.6),
					_m(P_LAMP_INDOOR, 1, -2, "浴场灯", "壁灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 12, "ty": 4, "oy": -8, "color": Color(0.95, 0.95, 1.0), "energy": 0.85, "scale": 1.8}],
			"actor": {},
		},
		"c44_inn": {
			"title": "旅馆",
			"hint": "旅馆 · 大厅 / 客房（占位）",
			"return_path": MKT,
			"room_w": 26,
			"room_h": 16,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "plank",
			"modulate": Color(0.88, 0.82, 0.74, 1.0),
			"rug": {"ox": 8, "oy": 7},
			"window": true,
			"clusters": [
				_cluster("lobby", 7, 6, [
					_m(P_COUNTER, 0, 0, "前台", "旅馆前台（占位）。", 0.95),
					_m(P_LEDGER, 1, -1, "住宿簿", "登记簿。", 0.65),
					_m(P_STOOL_BAR, -1, 1, "前台凳", "店主位。", 0.75),
					_m(P_LAMP_INDOOR, 2, -2, "大厅灯", "暖灯。", PROP),
				]),
				_cluster("guest", 19, 7, [
					_m(P_BED_S, 0, 0, "客房床", "一间客房（占位）。", 1.0),
					_m(P_DRESSER, 0, -2, "床头柜", "客房柜。", 0.8),
					_m(P_LAMP_INDOOR, 2, -1, "床灯", "客房灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [
				{"tx": 7, "ty": 5, "oy": -8, "color": Color(1.0, 0.9, 0.7), "energy": 0.9, "scale": 1.8},
				{"tx": 19, "ty": 6, "oy": -8, "color": Color(1.0, 0.88, 0.65), "energy": 0.8, "scale": 1.6},
			],
			"actor": {},
		},
		"c45_tavern_up": {
			"title": "酒馆二楼",
			"hint": "酒馆二楼 · 客房 / 密会（占位）",
			"return_path": SceneRouter.C04_TAVERN_PATH,
			"room_w": 22,
			"room_h": 14,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "dark",
			"modulate": Color(0.68, 0.60, 0.54, 1.0),
			"rug": {"ox": 5, "oy": 6},
			"window": true,
			"clusters": [
				_cluster("guest", 5, 5, [
					_m(P_BED_S, 0, 0, "客房床", "酒馆客房（占位）。", 1.0),
					_m(P_DRESSER, 0, -2, "柜", "客房柜。", 0.8),
					_m(P_LAMP_TAVERN, 2, -2, "烛灯", "二楼烛灯。", PROP),
				]),
				_cluster("secret", 16, 6, [
					_m(P_TABLE_R, 0, 0, "密会桌", "秘密会议桌（占位）。", 0.85),
					_m(P_STOOL_TEA, -2, 1, "凳", "围桌凳。", 0.7),
					_m(P_STOOL_TEA, 2, 1, "凳", "围桌凳。", 0.7),
					_m(P_NOTICE, 1, -2, "暗号牌", "密会暗号。", 0.6),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 5, "ty": 4, "oy": -8, "color": Color(1.0, 0.75, 0.45), "energy": 0.85, "scale": 1.7}],
			"actor": {},
		},
		"c34_dock_fish": {
			"title": "渔码头",
			"hint": "渔码头 · 网篓 / 卸鱼（占位）",
			"return_path": LAKE,
			"room_w": 22,
			"room_h": 12,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "plank",
			"modulate": Color(0.78, 0.82, 0.84, 1.0),
			"rug": null,
			"window": true,
			"clusters": [
				_cluster("nets", 5, 4, [
					_m(P_BASKET, 0, 0, "渔篓", "渔网篓（占位）。", 0.85),
					_m(P_ROD_BAMBOO, 2, -1, "渔竿架", "竿架。", 0.7),
					_m(P_CRATE0, -1, 1, "鱼箱", "鲜鱼箱。", 0.75),
					_m(P_LAMP_FARM, 1, -2, "码头灯", "渔码头灯。", PROP),
				]),
				_cluster("unload", 16, 5, [
					_m(P_HANDCART, 0, 0, "卸鱼车", "卸货手推车（占位）。", 0.9),
					_m(P_SACK0, 2, 1, "冰袋", "保鲜袋。", 0.6),
					_m(P_BARREL, -2, 1, "水桶", "洗鱼桶。", 0.7),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 5, "ty": 3, "oy": -8, "color": Color(0.95, 0.95, 1.0), "energy": 0.85, "scale": 1.7}],
			"actor": {},
			"extra_portals": [
				{"tx": 3, "ty": 9, "label": "登船", "path": SceneRouter.C35_BOAT_DOCKED_PATH},
			],
		},
		"c34_dock_trade": {
			"title": "商码头",
			"hint": "商码头 · 货垛 / 栈桥（占位）",
			"return_path": "res://scenes/areas/lighthouse/lighthouse.tscn",
			"room_w": 22,
			"room_h": 12,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "plank",
			"modulate": Color(0.82, 0.78, 0.72, 1.0),
			"rug": null,
			"window": true,
			"clusters": [
				_cluster("cargo", 5, 4, [
					_m(P_CRATE0, 0, 0, "货箱", "商货垛（占位）。", 0.9),
					_m(P_CRATE1, 2, -1, "叠箱", "叠高货箱。", 0.8),
					_m(P_SACK1, -1, 1, "货袋", "麻袋垛。", 0.7),
					_m(P_LAMP_SHOP, 1, -2, "栈灯", "商码头灯。", PROP),
				]),
				_cluster("office", 16, 5, [
					_m(P_LEDGER, 0, 0, "到货簿", "商港登记（占位）。", 0.75),
					_m(P_COUNTER, 1, 1, "验货台", "验货台。", 0.85),
					_m(P_STOOL, -1, 1, "管事凳", "管事位。", 0.7),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 5, "ty": 3, "oy": -8, "color": Color(1.0, 0.92, 0.8), "energy": 0.85, "scale": 1.7}],
			"actor": {},
		},
		"c35_boat_docked": {
			"title": "停靠船",
			"hint": "停靠船 · 甲板 / 舱（占位）",
			"return_path": SceneRouter.C34_DOCK_FISH_PATH,
			"room_w": 18,
			"room_h": 10,
			"door_tx0": 7,
			"door_tx1": 10,
			"floor": "plank",
			"modulate": Color(0.80, 0.84, 0.86, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("deck", 5, 4, [
					_m(P_BARREL, 0, 0, "甲板桶", "停靠船甲板桶（占位）。", 0.8),
					_m(P_CRATE0, 2, 0, "舱货", "舱口货箱。", 0.75),
					_m(P_ROD_BAMBOO, -1, -1, "船竿", "船舷渔竿。", 0.65),
				]),
				_cluster("cabin", 13, 4, [
					_m(P_STOOL, 0, 0, "舵凳", "舵位凳（占位）。", 0.7),
					_m(P_LAMP_FARM, 1, -2, "舱灯", "船舱灯。", PROP),
					_m(P_BASKET, -1, 1, "网筐", "收网筐。", 0.55),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 13, "ty": 3, "oy": -6, "color": Color(1.0, 0.9, 0.7), "energy": 0.8, "scale": 1.5}],
			"actor": {},
		},
		"c35_boat_wreck": {
			"title": "半沉船",
			"hint": "半沉船 · 破舱 / 箱（占位）",
			"return_path": LAKE,
			"room_w": 18,
			"room_h": 10,
			"door_tx0": 7,
			"door_tx1": 10,
			"floor": "dark",
			"modulate": Color(0.55, 0.60, 0.66, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("hull", 5, 4, [
					_m(P_CRATE1, 0, 0, "破箱", "半沉船破箱（占位）。", 0.85),
					_m(P_BARREL_KEG, 2, 1, "倾桶", "倾覆桶。", 0.75),
					_m(P_ROCK2, -1, 1, "礁石", "卡船礁石。", 0.6),
				]),
				_cluster("cache", 13, 4, [
					_m(P_COIN, 0, 0, "沉箱", "破舱宝箱（占位）。", 0.7),
					_m(P_SACK0, 2, 1, "湿袋", "浸湿麻袋。", 0.55),
					_m(P_LAMP_TAVERN, -1, -1, "残烛", "残烛。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 13, "ty": 3, "oy": -6, "color": Color(0.7, 0.85, 1.0), "energy": 0.7, "scale": 1.5}],
			"actor": {},
		},
		"c36_train_car": {
			"title": "火车厢",
			"hint": "火车厢 · 客座 / 过道（占位）",
			"return_path": STN,
			"room_w": 26,
			"room_h": 10,
			"door_tx0": 11,
			"door_tx1": 14,
			"floor": "plank",
			"modulate": Color(0.82, 0.78, 0.74, 1.0),
			"rug": null,
			"window": true,
			"clusters": [
				_cluster("seats_w", 5, 4, [
					_m(P_STOOL_BAR, 0, 0, "客座", "西排客座（占位）。", 0.8),
					_m(P_STOOL_BAR, 2, 0, "客座", "西排第二座。", 0.8),
					_m(P_BASKET, 1, 2, "行李筐", "座下行李。", 0.55),
					_m(P_LAMP_INDOOR, 1, -2, "车厢灯", "顶灯。", PROP),
				]),
				_cluster("seats_e", 19, 4, [
					_m(P_STOOL_BAR, 0, 0, "客座", "东排客座（占位）。", 0.8),
					_m(P_STOOL_BAR, 2, 0, "客座", "东排第二座。", 0.8),
					_m(P_CRATE0, 1, 2, "邮包箱", "邮包/货箱。", 0.7),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 12, "ty": 3, "oy": -6, "color": Color(1.0, 0.92, 0.8), "energy": 0.85, "scale": 1.8}],
			"actor": {},
		},
		"c23_underwater": {
			"title": "水下",
			"hint": "水下 · 水草 / 沉木 / 箱（占位）",
			"return_path": LAKE,
			"room_w": 22,
			"room_h": 12,
			"door_tx0": 9,
			"door_tx1": 12,
			"floor": "stone",
			"modulate": Color(0.45, 0.58, 0.70, 1.0),
			"rug": null,
			"window": false,
			"clusters": [
				_cluster("weed", 5, 4, [
					_m(P_HERBS, 0, 0, "水草", "水下水草簇（占位）。", 0.85),
					_m(P_HERBS, 2, 1, "水草", "第二簇水草。", 0.75),
					_m(P_ROCK1, -1, 1, "沉石", "水底石。", 0.6),
				]),
				_cluster("wreckage", 16, 5, [
					_m(P_CRATE0, 0, 0, "沉箱", "沉木旁箱（占位）。", 0.85),
					_m(P_ROCK3, 2, 1, "沉木礁", "沉木/礁。", 0.7),
					_m(P_COIN, -1, 1, "宝箱", "水下宝箱。", 0.65),
					_m(P_LAMP_FARM, 1, -2, "潜灯", "潜水灯。", PROP),
				]),
			],
			"fx": [],
			"ambient": [],
			"lights": [{"tx": 16, "ty": 4, "oy": -6, "color": Color(0.55, 0.85, 1.0), "energy": 0.9, "scale": 1.8}],
			"actor": {},
		},
'''


SYSTEM_SCRIPTS = {
    "scripts/npc/npc_routine_rings.gd": '''class_name NpcRoutineRings
extends RefCounted

## C53 work rings + C54 life rings — Wave F NpcRing team enriches.
## Mount via thin hooks on square/market/C02; do not rewrite assemblers wholesale.

const WORK_RING_IDS := ["sow", "smith", "stall", "fish", "cook"]
const LIFE_STATE_IDS := ["eat", "sleep", "read", "laundry", "idle_sit"]


static func work_demo_waypoints() -> Array:
	## ≥3 work rings (placeholder anchors — team replaces with real outdoor/indoor anchors).
	return [
		{"id": "sow", "title": "播种环", "scene": "farmland", "hint": "田垄工作环（占位）"},
		{"id": "smith", "title": "打铁环", "scene": "c04_smith", "hint": "铁匠工作环（占位）"},
		{"id": "stall", "title": "摆货环", "scene": "market", "hint": "摊位摆货环（占位）"},
	]


static func life_demo_states() -> Array:
	## ≥3 life states (placeholder — team wires to C02 actor stands).
	return [
		{"id": "eat", "title": "用餐", "hint": "餐桌生活态（占位）"},
		{"id": "sleep", "title": "睡眠", "hint": "床区生活态（占位）"},
		{"id": "read", "title": "阅读", "hint": "摇椅/灯下阅读（占位）"},
	]
''',
    "scripts/env/seasonal_decor.gd": '''class_name SeasonalDecor
extends Node

## C55 — plaza seasonal decoration layer (reuse A09 skeleton). Wave F WorldSys enriches.

enum Season { SPRING, SUMMER, AUTUMN, WINTER }

signal season_changed(season: int)

var _season: int = Season.SPRING
var _host: Node2D
var _layer: Node2D


static func attach_to(host: Node2D, top_bar: Control = null) -> SeasonalDecor:
	var node := SeasonalDecor.new()
	host.add_child(node)
	node.setup(host, top_bar)
	return node


func setup(host: Node2D, top_bar: Control = null) -> void:
	_host = host
	_layer = Node2D.new()
	_layer.name = "SeasonalDecorLayer"
	_layer.z_index = 3
	host.add_child(_layer)
	_rebuild()
	if top_bar:
		var btn := Button.new()
		btn.text = "季节"
		btn.pressed.connect(cycle_season)
		top_bar.add_child(btn)


func cycle_season() -> void:
	_season = (_season + 1) % 4
	_rebuild()
	season_changed.emit(_season)


func _rebuild() -> void:
	for c in _layer.get_children():
		c.queue_free()
	## Stub markers — WorldSys replaces with real props / modulate veils.
	var label := Label.new()
	label.text = ["春花", "夏海", "秋收", "冬雪"][_season] + "装饰（占位）"
	label.position = Vector2(40, 80)
	_layer.add_child(label)
''',
    "scripts/world/world_interact_kit.gd": '''class_name WorldInteractKit
extends RefCounted

## C58 — ≥8 world interact types. Wave F WorldSys wires hotspots on village_square.

const INTERACT_TYPES := [
	"sit_bench", "well_water", "shake_tree", "notice_board", "crate_search",
	"lamp_toggle", "feed_critter", "read_sign",
]


static func stub_catalog() -> Array:
	var out: Array = []
	for id in INTERACT_TYPES:
		out.append({"id": id, "title": id, "hint": "交互占位 — WorldSys 接线"})
	return out
''',
    "scripts/world/breakables_kit.gd": '''class_name BreakablesKit
extends RefCounted

## C59 — ≥4 clearable props. Wave F WorldSys places on square/farm edge.

const KINDS := ["rock", "stake", "weed", "crate"]


static func stub_catalog() -> Array:
	var out: Array = []
	for id in KINDS:
		out.append({"id": id, "title": "可清:" + id, "hint": "破坏占位"})
	return out
''',
    "scripts/world/progress_gates.gd": '''class_name ProgressGates
extends RefCounted

## C60 — ≥3 progress gates (log / boulder / locked door). Wave F WorldSys.

const GATES := ["fallen_log", "boulder", "locked_door"]


static func stub_catalog() -> Array:
	var out: Array = []
	for id in GATES:
		out.append({"id": id, "title": "障碍:" + id, "hint": "进度门占位"})
	return out
''',
    "scripts/world/hidden_chests.gd": '''class_name HiddenChests
extends RefCounted

## C61 — ≥5 hidden chest sites. Wave F WorldSys places across explore maps.

const SITES := ["tree_behind", "waterfall", "cave", "well", "island"]


static func stub_catalog() -> Array:
	var out: Array = []
	for id in SITES:
		out.append({"id": id, "title": "箱:" + id, "hint": "隐藏箱占位"})
	return out
''',
    "scripts/world/secret_passage_chain.gd": '''class_name SecretPassageChain
extends RefCounted

## C62 — ≥1 cross-map secret chain. Wave F WorldSys wires portals.

const CHAIN_A := [
	{"from": "forest_deep", "label": "树洞密道", "to": "c16_cave_entry"},
	{"from": "c16_cave_entry", "label": "暗河出口", "to": "waterfall"},
	{"from": "waterfall", "label": "瀑后回湖", "to": "lake"},
]


static func stub_chain() -> Array:
	return CHAIN_A
''',
}


def main() -> None:
    # Router
    router = ROOT / "scripts/core/scene_router.gd"
    text = router.read_text(encoding="utf-8")
    if "C40_MUSEUM_PATH" not in text:
        patch_file(
            router,
            'const C50_FARM_CELLAR_PATH := "res://scenes/interiors/c50_farm_cellar/c50_farm_cellar.tscn"\n',
            'const C50_FARM_CELLAR_PATH := "res://scenes/interiors/c50_farm_cellar/c50_farm_cellar.tscn"\n'
            + ROUTER_ADD,
        )

    # gen_interior_scenes
    gen = ROOT / "tools/gen_interior_scenes.py"
    gtext = gen.read_text(encoding="utf-8")
    if "c40_museum" not in gtext:
        patch_file(
            gen,
            '    ("c50_farm_cellar", "c50_farm_cellar", "C50FarmCellarInterior"),\n]',
            '    ("c50_farm_cellar", "c50_farm_cellar", "C50FarmCellarInterior"),\n'
            + GEN_ADD
            + "]",
        )

    # PHASE5.md row
    phase5 = ROOT / "docs/PHASE5.md"
    p5 = phase5.read_text(encoding="utf-8")
    if "Wave F" not in p5:
        patch_file(
            phase5,
            "| Vertical/Yard C46–C50 | **Wave E DONE (code)** | 二楼/阁楼/屋顶/后院/农场地窖；见 [`PHASE5_WAVE_E.md`](PHASE5_WAVE_E.md)。用户 Godot QA |\n",
            "| Vertical/Yard C46–C50 | **Wave E DONE (code)** | 二楼/阁楼/屋顶/后院/农场地窖；见 [`PHASE5_WAVE_E.md`](PHASE5_WAVE_E.md)。用户 Godot QA |\n"
            "| Civic/Transit/NPC/World | **Wave F IN PROGRESS** | C40–C45 · C34–C36+C23 · C53–C54 · C55+C58–C62；见 [`PHASE5_WAVE_F.md`](PHASE5_WAVE_F.md) |\n",
        )

    # Tavern upstairs portal
    profiles = ROOT / "scripts/interiors/interior_profiles.gd"
    pt = profiles.read_text(encoding="utf-8")
    if "C45_TAVERN_UP_PATH" not in pt.split('"c04_tavern"')[1].split('"c12_lighthouse"')[0]:
        patch_file(
            profiles,
            '''			"actor": {
				"id": "merchant",
				"title": "酒保",
				"desc": "在吧台与座席间穿梭。",
				"via_clusters": ["bar", "party_a", "party_b", "hearth"],
				"via_stands": {"bar": [0, 0], "party_a": [0, 3], "party_b": [0, 2], "hearth": [-2, 1]},
			},
		},
		# ── Wave A2 stubs (teams enrich; do not polish C01–C04) ──
''',
            '''			"actor": {
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
''',
        )

    # Append Wave F stubs before closing of _all
    pt = profiles.read_text(encoding="utf-8")
    if '"c40_museum"' not in pt:
        if not pt.rstrip().endswith("}"):
            raise SystemExit("unexpected profiles ending")
        # Replace final `\t}\n` of _all dict — last occurrence before class end
        idx = pt.rfind("\t\t},\n\t}")
        if idx < 0:
            idx = pt.rfind("\t\t}\n\t}")
            if idx < 0:
                raise SystemExit("cannot find _all close")
            insert_at = idx + len("\t\t}")
            pt = pt[:insert_at] + ",\n" + STUBS + pt[insert_at:]
        else:
            # ends with `},\n\t}` — insert before `\n\t}`
            insert_at = idx + len("\t\t},")
            pt = pt[:insert_at] + "\n" + STUBS + pt[insert_at:]
        profiles.write_text(pt, encoding="utf-8")
        print("appended Wave F stubs to interior_profiles.gd")

    # Outdoor portals
    patches = [
        (
            ROOT / "scripts/areas/village_square_assembler.gd",
            'craft.make_portal(\n\t\tysort, "进入墓园", SceneRouter.C30_CEMETERY_PATH, grave + Vector2(0, 14), Vector2(100, 52)\n\t)\n',
            'craft.make_portal(\n\t\tysort, "进入墓园", SceneRouter.C30_CEMETERY_PATH, grave + Vector2(0, 14), Vector2(100, 52)\n\t)\n'
            '\t# Wave F civic tour\n'
            '\tcraft.make_portal(ysort, "进入博物馆", SceneRouter.C40_MUSEUM_PATH, Vector2(220, 280), Vector2(100, 52))\n'
            '\tcraft.make_portal(ysort, "进入浴场", SceneRouter.C43_BATHHOUSE_PATH, Vector2(1080, 280), Vector2(100, 52))\n',
        ),
        (
            ROOT / "scripts/areas/lake_assembler.gd",
            'craft.make_portal(ysort, "登湖心岛", SceneRouter.C24_LAKE_ISLAND_PATH, isle + Vector2(0, 14), Vector2(100, 52))\n',
            'craft.make_portal(ysort, "登湖心岛", SceneRouter.C24_LAKE_ISLAND_PATH, isle + Vector2(0, 14), Vector2(100, 52))\n'
            '\t# Wave F transit / dive\n'
            '\tcraft.make_portal(ysort, "进入水族馆", SceneRouter.C41_AQUARIUM_PATH, Vector2(420, 480), Vector2(100, 52))\n'
            '\tcraft.make_portal(ysort, "进入渔码头", SceneRouter.C34_DOCK_FISH_PATH, Vector2(280, 620), Vector2(100, 52))\n'
            '\tcraft.make_portal(ysort, "半沉船", SceneRouter.C35_BOAT_WRECK_PATH, Vector2(900, 640), Vector2(100, 52))\n'
            '\tcraft.make_portal(ysort, "↓潜水", SceneRouter.C23_UNDERWATER_PATH, Vector2(640, 700), Vector2(100, 52))\n',
        ),
        (
            ROOT / "scripts/areas/hill_farm_assembler.gd",
            'craft.make_portal(\n\t\tysort, "进入洞穴", SceneRouter.C16_CAVE_ENTRY_PATH, cave_mouth + Vector2(0, 12), Vector2(96, 52)\n\t)\n',
            'craft.make_portal(\n\t\tysort, "进入洞穴", SceneRouter.C16_CAVE_ENTRY_PATH, cave_mouth + Vector2(0, 12), Vector2(96, 52)\n\t)\n'
            '\t# Wave F\n'
            '\tcraft.make_portal(ysort, "进入温泉", SceneRouter.C42_HOTSPRING_PATH, Vector2(640, 360), Vector2(100, 52))\n',
        ),
        (
            ROOT / "scripts/areas/market_street_assembler.gd",
            'craft.make_portal(\n\t\tysort, "进入工坊", SceneRouter.C38_WORKSHOP_PATH, Vector2(980, 320), Vector2(88, 48)\n\t)\n',
            'craft.make_portal(\n\t\tysort, "进入工坊", SceneRouter.C38_WORKSHOP_PATH, Vector2(980, 320), Vector2(88, 48)\n\t)\n'
            '\t# Wave F\n'
            '\tcraft.make_portal(ysort, "进入旅馆", SceneRouter.C44_INN_PATH, Vector2(200, 400), Vector2(100, 52))\n',
        ),
        (
            ROOT / "scripts/areas/station_assembler.gd",
            'craft.make_portal(\n\t\tysort,\n\t\t"进入车站",\n\t\tSceneRouter.C11_STATION_INT_PATH,\n\t\tVector2(640, 320),\n\t\tVector2(120, 56)\n\t)\n',
            'craft.make_portal(\n\t\tysort,\n\t\t"进入车站",\n\t\tSceneRouter.C11_STATION_INT_PATH,\n\t\tVector2(640, 320),\n\t\tVector2(120, 56)\n\t)\n'
            '\t# Wave F\n'
            '\tcraft.make_portal(ysort, "进入车厢", SceneRouter.C36_TRAIN_CAR_PATH, Vector2(900, 360), Vector2(110, 52))\n',
        ),
        (
            ROOT / "scripts/areas/lighthouse_assembler.gd",
            'craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(80, 520), Vector2(96, 56))\n'
            '\tcraft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))\n',
            'craft.make_portal(ysort, "→湖泊", SceneRouter.LAKE_PATH, Vector2(80, 520), Vector2(96, 56))\n'
            '\tcraft.make_portal(ysort, "→总览", SceneRouter.HUB_PATH, Vector2(640, 40), Vector2(96, 48))\n'
            '\t# Wave F trade dock\n'
            '\tcraft.make_portal(ysort, "进入商码头", SceneRouter.C34_DOCK_TRADE_PATH, Vector2(360, 700), Vector2(100, 52))\n',
        ),
    ]
    for path, old, new in patches:
        t = path.read_text(encoding="utf-8")
        if "Wave F" in t and path.name != "lighthouse_assembler.gd":
            # allow re-run partial
            if "C40_MUSEUM" in t or "C41_AQUARIUM" in t or "C42_HOTSPRING" in t or "C44_INN" in t or "C36_TRAIN" in t:
                print("skip portals", path.name)
                continue
        if "C34_DOCK_TRADE" in t and path.name == "lighthouse_assembler.gd":
            print("skip portals", path.name)
            continue
        patch_file(path, old, new)

    # Thin Env-H style hook note file for WorldSys / NpcRing
    for rel, body in SYSTEM_SCRIPTS.items():
        p = ROOT / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        if not p.exists():
            p.write_text(body, encoding="utf-8")
            print("wrote", rel)
        else:
            print("skip exists", rel)

    # Hook stubs into village_square_controller if present
    ctrl = ROOT / "scripts/areas/village_square_controller.gd"
    if ctrl.exists():
        ct = ctrl.read_text(encoding="utf-8")
        if "SeasonalDecor" not in ct and "DayNightWeather" in ct:
            # append soft comment-only marker for WorldSys — actual attach left to team
            if "Wave F WorldSys" not in ct:
                ct += "\n# Wave F WorldSys/NpcRing: attach SeasonalDecor + interact kits (team).\n"
                ctrl.write_text(ct, encoding="utf-8")
                print("noted controller for Wave F hooks")

    print("seed done — run gen_interior_scenes.py --only-new")


if __name__ == "__main__":
    main()
