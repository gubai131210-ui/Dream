#!/usr/bin/env python3
"""Static scan: make_hotspot call sites should shortly attach/reparent a Visual prop.

Looks at assembler .gd files. A hotspot is OK if within the next ~12 non-empty lines
we see attach_hotspot_prop / attach_prop_sprite / reparent(...Visual).
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
AREAS = ROOT / "scripts" / "areas"
HOTSPOT_RE = re.compile(r"(?:craft\.)?make_hotspot\(|(?<!func )_make_hotspot\(")
OK_RE = re.compile(
	r"attach_hotspot_prop|attach_prop_sprite|reparent\(|\.reparent\("
)


def scan_file(path: Path) -> list[str]:
	lines = path.read_text(encoding="utf-8").splitlines()
	bad: list[str] = []
	i = 0
	while i < len(lines):
		stripped = lines[i].lstrip()
		if stripped.startswith("func "):
			i += 1
			continue
		if HOTSPOT_RE.search(lines[i]):
			# Find end of statement (closing paren balance) then look ahead.
			depth = 0
			j = i
			started = False
			while j < len(lines):
				for ch in lines[j]:
					if ch == "(":
						depth += 1
						started = True
					elif ch == ")":
						depth -= 1
				if started and depth <= 0:
					break
				j += 1
			window = "\n".join(lines[i : min(len(lines), j + 14)])
			# Multi-hotspot loops that reparent in the same for-body are OK if OK_RE in window.
			if not OK_RE.search(window):
				# Allow fence posts / tiny segments that intentionally use only CollisionShape
				# when title suggests fence — still flag for review as soft.
				title_m = re.search(r'make_hotspot\(\s*\n?\s*[^,]*,\s*"([^"]+)"', window)
				title = title_m.group(1) if title_m else "?"
				bad.append(f"{path.relative_to(ROOT)}:{i+1} hotspot≈{title}")
			i = j + 1
			continue
		i += 1
	return bad


def main() -> int:
	bad: list[str] = []
	for path in sorted(AREAS.glob("*assembler*.gd")):
		bad.extend(scan_file(path))
	dress = AREAS / "market_street_dressing.gd"
	if dress.exists():
		bad.extend(scan_file(dress))
	# Fence posts are tiny collision segments — exclude known fence titles.
	filtered = [
		b
		for b in bad
		if "围栏" not in b and "Fence" not in b and "fence" not in b.lower()
	]
	if filtered:
		print("FAIL orphan hotspot Visual scan")
		for b in filtered:
			print(" ", b)
		return 1
	print(f"GREEN orphan-hotspot scan ({len(bad) - len(filtered)} fence-exempt, 0 orphan)")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
