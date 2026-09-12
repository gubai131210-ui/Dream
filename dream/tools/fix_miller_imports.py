#!/usr/bin/env python3
from __future__ import annotations

import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
src = (ROOT / "assets/sprites/npc/farmer/walk_down_0.png.import").read_text(encoding="utf-8")
dst_dir = ROOT / "assets/sprites/npc/miller"
n = 0
for png in sorted(dst_dir.glob("walk_*.png")):
	text = src.replace("npc/farmer/walk_down_0.png", f"npc/miller/{png.name}")
	text = text.replace("walk_down_0.png-", f"{png.name}-")
	uid = "uid://m" + uuid.uuid4().hex[:12]
	lines = []
	for line in text.splitlines(True):
		if line.startswith("uid="):
			lines.append(f'uid="{uid}"\n')
		else:
			lines.append(line)
	(dst_dir / f"{png.name}.import").write_text("".join(lines), encoding="utf-8")
	n += 1
print(f"rewrote {n} imports")
print("\n".join((dst_dir / "walk_down_0.png.import").read_text(encoding="utf-8").splitlines()[:6]))
