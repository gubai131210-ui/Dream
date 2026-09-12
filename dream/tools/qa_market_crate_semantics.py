#!/usr/bin/env python3
"""Fail if market dressing uses stall_face (_04) as produce goods or raw B11-02_04 path."""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DRESS = ROOT / "scripts" / "areas" / "market_street_dressing.gd"
STALL = ROOT / "scripts" / "market" / "market_stall.gd"

FORBIDDEN = (
	"B11-02_crates_boxes_04.png",
	"stall_face_00.png",  # must not be used as crate= produce goods
)


def main() -> int:
	fails: list[str] = []
	dress = DRESS.read_text(encoding="utf-8")
	stall = STALL.read_text(encoding="utf-8")
	if "B11-02_crates_boxes_04" in dress or "B11-02_crates_boxes_04" in stall:
		fails.append("raw B11-02_04 still referenced (use stall_face only as face, never crate goods)")
	# crate: lines must not point at stall_face
	for i, line in enumerate(dress.splitlines(), 1):
		if '"crate"' in line and "stall_face" in line:
			fails.append(f"dressing L{i}: crate uses stall_face")
		if '"crate"' in line and "B11-02_crates_boxes_04" in line:
			fails.append(f"dressing L{i}: crate uses _04 face board")
	# Produce stalls should use produce_crate
	if "produce_crate_00.png" not in dress:
		fails.append("dressing missing produce_crate_00 for fruit stalls")
	if "produce_crate_00.png" not in stall:
		fails.append("market_stall default crate should be produce_crate_00")
	for rel in (
		"assets/sprites/props/produce_crate_00.png",
		"assets/sprites/props/stall_face_00.png",
		"assets/sprites/props/lumber_stack_00.png",
		"assets/sprites/props/stall_bin_base_00.png",
	):
		if not (ROOT / rel).is_file():
			fails.append(f"missing {rel}")
	if fails:
		print("RED market crate semantics")
		for f in fails:
			print(" -", f)
		return 1
	print("GREEN market crate semantics (produce≠stall_face)")
	return 0


if __name__ == "__main__":
	sys.exit(main())
