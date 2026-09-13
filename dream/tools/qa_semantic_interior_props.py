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
	"根桌": "P_ROOT_TABLE",
	"木钉梯": "P_PEG_LADDER",
	"根须垛": "P_ROOT_MASS",
}


def main() -> int:
	text = PROFILES.read_text(encoding="utf-8")
	fails: list[str] = []
	for rel in REQUIRED_ASSETS:
		if not (ROOT / rel).is_file():
			fails.append(f"missing asset {rel}")
	for name, bad_subs in FORBIDDEN.items():
		# Prefer giant-tree climb/roots/hall by scanning all clusters with that name;
		# any remaining proxy in any matching cluster fails.
		for m in re.finditer(rf'_cluster\("{name}".*?(?=_cluster\(|^\t\t\t\],)', text, flags=re.S | re.M):
			block = m.group(0)
			for bad in bad_subs:
				if bad in block:
					fails.append(f"cluster {name} still references proxy '{bad}'")
		if f'_cluster("{name}"' not in text:
			fails.append(f"cluster {name} not found")
	for const in (
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
		"P_ROOT_TABLE",
		"P_PEG_LADDER",
		"P_ROOT_MASS",
		"P_SEWER_PIPE",
		"P_REED_CLUMP",
	):
		if f"const {const}" not in text:
			fails.append(f"missing const {const}")
	for title, const in TITLE_CONST.items():
		for m in re.finditer(rf'_m\(([^)]*"{title}"[^)]*)\)', text):
			if const not in m.group(1):
				fails.append(f"{title} not on {const}: {m.group(0)[:90]}")
	if fails:
		print("RED semantic-interior proxy QA")
		for f in fails:
			print(" -", f)
		return 1
	print("GREEN semantic-interior proxy QA (stele/fare/bark + civic+C28 + signature)")
	return 0


if __name__ == "__main__":
	sys.exit(main())
