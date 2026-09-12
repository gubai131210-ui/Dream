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
	"altar": ["counter_00"],
	"waiting": ["table_dining"],
	"wait": ["table_dining"],
	"reed": ["hay_00"],
	"pipe_run": ["barrel_"],
}

REQUIRED_ASSETS = [
	"assets/sprites/interior/props/altar_00.png",
	"assets/sprites/interior/props/waiting_bench_00.png",
	"assets/sprites/interior/props/blackboard_00.png",
	"assets/sprites/interior/props/school_desk_00.png",
	"assets/sprites/interior/props/lectern_00.png",
	"assets/sprites/interior/props/sewer_pipe_00.png",
	"assets/sprites/interior/props/reed_clump_00.png",
]


def main() -> int:
	text = PROFILES.read_text(encoding="utf-8")
	fails: list[str] = []
	for rel in REQUIRED_ASSETS:
		if not (ROOT / rel).is_file():
			fails.append(f"missing asset {rel}")
	for name, bad_subs in FORBIDDEN.items():
		pat = rf'_cluster\("{name}".*?(?=_cluster\(|^\t\t\t\],)'
		m = re.search(pat, text, flags=re.S | re.M)
		if not m:
			fails.append(f"cluster {name} not found")
			continue
		block = m.group(0)
		for bad in bad_subs:
			if bad in block:
				fails.append(f"cluster {name} still references proxy '{bad}'")
	for const in (
		"P_ALTAR",
		"P_WAITING_BENCH",
		"P_BLACKBOARD",
		"P_SCHOOL_DESK",
		"P_LECTERN",
		"P_SEWER_PIPE",
		"P_REED_CLUMP",
	):
		if f"const {const}" not in text:
			fails.append(f"missing const {const}")
	# Lectern must own the 讲台 marker (not school_desk).
	if 'P_LECTERN' not in text or '"讲台"' not in text:
		fails.append("lectern / 讲台 wiring missing")
	else:
		# Any _m(...讲台...) line must use P_LECTERN
		for m in re.finditer(r'_m\(([^)]*"讲台"[^)]*)\)', text):
			if "P_LECTERN" not in m.group(1):
				fails.append(f"讲台 still not on P_LECTERN: {m.group(0)[:80]}")
	if fails:
		print("RED semantic-interior proxy QA")
		for f in fails:
			print(" -", f)
		return 1
	print("GREEN semantic-interior proxy QA (wait+lectern + 6 signature clusters)")
	return 0


if __name__ == "__main__":
	sys.exit(main())
