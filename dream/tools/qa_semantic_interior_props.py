#!/usr/bin/env python3
"""Fail if signature interior clusters still use known proxy sprites."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROFILES = ROOT / "scripts" / "interiors" / "interior_profiles.gd"

# cluster_name -> forbidden path substrings still used as primary marker in that cluster.
FORBIDDEN = {
	"blackboard": ["notice_00"],
	"desks": ["table_dining"],
	"altar": ["counter_00", "notice_00"],
	"waiting": ["table_dining", "notice_00"],
	"wait": ["table_dining"],
	"hall": ["table_dining"],
	"climb": ["tool_rack"],
	"roots": ["hay_"],
	"nave": ["notice_00"],
	"reed": ["hay_00"],
	"pipe_run": ["barrel_"],
	"front": ["notice_00"],
	"exhibit": ["notice_00"],
	"change": ["notice_00"],
	"bath": ["notice_00"],
	"lobby": ["notice_00"],
	"ledger": ["notice_00"],
	"counter": ["notice_00"],
	"rest": ["notice_00"],
	"donate": ["notice_00"],
	"donate_fish": ["notice_00"],
	"aisle_rack": ["notice_00"],
	"office": ["notice_00"],
}

REQUIRED_ASSETS = [
	"assets/sprites/interior/props/altar_00.png",
	"assets/sprites/interior/props/waiting_bench_00.png",
	"assets/sprites/interior/props/blackboard_00.png",
	"assets/sprites/interior/props/school_desk_00.png",
	"assets/sprites/interior/props/lectern_00.png",
	"assets/sprites/interior/props/meeting_table_00.png",
	"assets/sprites/interior/props/civic_board_00.png",
	"assets/sprites/interior/props/timetable_00.png",
	"assets/sprites/interior/props/root_table_00.png",
	"assets/sprites/interior/props/peg_ladder_00.png",
	"assets/sprites/interior/props/root_mass_00.png",
	"assets/sprites/interior/props/fare_board_00.png",
	"assets/sprites/interior/props/ruin_stele_00.png",
	"assets/sprites/interior/props/bark_glyph_00.png",
	"assets/sprites/interior/props/scripture_plaque_00.png",
	"assets/sprites/interior/props/clinic_fee_board_00.png",
	"assets/sprites/interior/props/exhibit_guide_00.png",
	"assets/sprites/interior/props/bath_rules_00.png",
	"assets/sprites/interior/props/inn_rate_board_00.png",
	"assets/sprites/interior/props/cargo_manifest_00.png",
	"assets/sprites/interior/props/shop_price_board_00.png",
	"assets/sprites/interior/props/house_rules_00.png",
	"assets/sprites/interior/props/mine_safety_00.png",
	"assets/sprites/interior/props/catalog_card_00.png",
	"assets/sprites/interior/props/trail_marker_00.png",
	"assets/sprites/interior/props/pipe_schematic_00.png",
	"assets/sprites/interior/props/cipher_plaque_00.png",
	"assets/sprites/interior/props/shift_board_00.png",
	"assets/sprites/interior/props/night_market_board_00.png",
	"assets/sprites/interior/props/charm_list_00.png",
	"assets/sprites/interior/props/donation_board_00.png",
	"assets/sprites/interior/props/ferry_schedule_00.png",
	"assets/sprites/interior/props/sewer_pipe_00.png",
	"assets/sprites/interior/props/reed_clump_00.png",
]

TITLE_CONST = {
	"讲台": "P_LECTERN",
	"会议桌": "P_MEETING_TABLE",
	"公告板": "P_CIVIC_BOARD",
	"时刻表": "P_TIMETABLE",
	"票价牌": "P_FARE_BOARD",
	"碑刻": "P_RUIN_STELE",
	"树皮符": "P_BARK_GLYPH",
	"经文牌": "P_SCRIPTURE_PLAQUE",
	"诊费告示": "P_CLINIC_FEE_BOARD",
	"展厅导览": "P_EXHIBIT_GUIDE",
	"浴规牌": "P_BATH_RULES",
	"浴场须知": "P_BATH_RULES",
	"房价牌": "P_INN_RATE_BOARD",
	"货单": "P_CARGO_MANIFEST",
	"告示板": "P_SHOP_PRICE_BOARD",
	"告示": "P_HOUSE_RULES",
	"矿洞告示": "P_MINE_SAFETY",
	"晶脉告示": "P_MINE_SAFETY",
	"分类卡": "P_CATALOG_CARD",
	"下探标记": "P_TRAIL_MARKER",
	"隐径记号": "P_TRAIL_MARKER",
	"管网图": "P_PIPE_SCHEMATIC",
	"暗语牌": "P_CIPHER_PLAQUE",
	"暗号牌": "P_CIPHER_PLAQUE",
	"排班牌": "P_SHIFT_BOARD",
	"夜市牌": "P_NIGHT_MARKET_BOARD",
	"符单": "P_CHARM_LIST",
	"捐赠告示": "P_DONATION_BOARD",
	"班次牌": "P_FERRY_SCHEDULE",
	"根桌": "P_ROOT_TABLE",
	"木钉梯": "P_PEG_LADDER",
	"根须垛": "P_ROOT_MASS",
}

REQUIRED_CONSTS = (
	"P_ALTAR",
	"P_WAITING_BENCH",
	"P_BLACKBOARD",
	"P_SCHOOL_DESK",
	"P_LECTERN",
	"P_MEETING_TABLE",
	"P_CIVIC_BOARD",
	"P_TIMETABLE",
	"P_FARE_BOARD",
	"P_RUIN_STELE",
	"P_BARK_GLYPH",
	"P_SCRIPTURE_PLAQUE",
	"P_CLINIC_FEE_BOARD",
	"P_EXHIBIT_GUIDE",
	"P_BATH_RULES",
	"P_INN_RATE_BOARD",
	"P_CARGO_MANIFEST",
	"P_SHOP_PRICE_BOARD",
	"P_HOUSE_RULES",
	"P_MINE_SAFETY",
	"P_CATALOG_CARD",
	"P_TRAIL_MARKER",
	"P_PIPE_SCHEMATIC",
	"P_CIPHER_PLAQUE",
	"P_SHIFT_BOARD",
	"P_NIGHT_MARKET_BOARD",
	"P_CHARM_LIST",
	"P_DONATION_BOARD",
	"P_FERRY_SCHEDULE",
	"P_ROOT_TABLE",
	"P_PEG_LADDER",
	"P_ROOT_MASS",
	"P_SEWER_PIPE",
	"P_REED_CLUMP",
)


def main() -> int:
	text = PROFILES.read_text(encoding="utf-8")
	fails: list[str] = []
	for rel in REQUIRED_ASSETS:
		if not (ROOT / rel).is_file():
			fails.append(f"missing asset {rel}")
	# Hard ban: no marker may still use the generic notice const.
	if re.search(r"_m\(\s*P_NOTICE\b", text):
		fails.append("profiles still place _m(P_NOTICE …) markers")
	for name, bad_subs in FORBIDDEN.items():
		for m in re.finditer(rf'_cluster\("{name}".*?(?=_cluster\(|^\t\t\t\],)', text, flags=re.S | re.M):
			block = m.group(0)
			for bad in bad_subs:
				if bad in block:
					fails.append(f"cluster {name} still references proxy '{bad}'")
		if f'_cluster("{name}"' not in text:
			fails.append(f"cluster {name} not found")
	for const in REQUIRED_CONSTS:
		if f"const {const}" not in text:
			fails.append(f"missing const {const}")
	# Longer titles first so 「告示板」wins over 「告示」.
	for title, const in sorted(TITLE_CONST.items(), key=lambda kv: -len(kv[0])):
		for m in re.finditer(rf'_m\(([^)]*"{re.escape(title)}"[^)]*)\)', text):
			if const not in m.group(1):
				fails.append(f"{title} not on {const}: {m.group(0)[:90]}")
	if fails:
		print("RED semantic-interior proxy QA")
		for f in fails:
			print(" -", f)
		return 1
	print("GREEN semantic-interior proxy QA (zero P_NOTICE markers + full notice taxonomy)")
	return 0


if __name__ == "__main__":
	sys.exit(main())
