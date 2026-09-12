#!/usr/bin/env python3
"""List interior profile actor ids vs existing npc packs."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
text = (ROOT / "scripts" / "interiors" / "interior_profiles.gd").read_text(encoding="utf-8")
packs = {
	p.name
	for p in (ROOT / "assets" / "sprites" / "npc").iterdir()
	if p.is_dir() and not p.name.startswith("_")
}
actors = re.findall(r'"id":\s*"([^"]+)"\s*,\s*\n\s*"title":\s*"([^"]+)"', text)
missing = []
print(f"actor pairs: {len(actors)}")
for aid, title in actors:
	ok = aid in packs
	print(("OK  " if ok else "MISS"), aid, title)
	if not ok:
		missing.append((aid, title))
print("MISSING", missing)
print("PACKS", sorted(packs))
