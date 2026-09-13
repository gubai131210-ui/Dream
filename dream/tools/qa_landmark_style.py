#!/usr/bin/env python3
"""StyleQA: landmark props must reach painted-grade unique-color density."""
from __future__ import annotations

from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
PROPS = ROOT / "assets" / "sprites" / "props"
MARKET = ROOT / "assets" / "sprites" / "market"

# Lo-fi hatch was ~4–10 unique; painted props are hundreds+.
MIN_UNIQ = {
	"reed_clump_00.png": 80,
	"ruin_arch_00.png": 200,
	"grave_marker_00.png": 120,
	"boat_skiff_00.png": 100,
	"door_facade_00.png": 200,
	"facade_bath_00.png": 200,
	"facade_museum_00.png": 200,
	"breakable_stake_00.png": 40,
	"breakable_weed_00.png": 60,
	"gate_log_00.png": 60,
	"gate_locked_door_00.png": 40,
	"fence_post_00.png": 40,
	"bridge_plank_00.png": 60,
	"furrow_line_00.png": 20,
	"stall_awning_00.png": 120,
}


def uniq(path: Path) -> int:
	im = Image.open(path).convert("RGBA")
	data = getattr(im, "get_flattened_data", im.getdata)()
	return len({c[:3] for c in data if c[3] > 200})


def main() -> int:
	fails: list[str] = []
	for name, need in MIN_UNIQ.items():
		folder = MARKET if name.startswith("stall_") else PROPS
		path = folder / name
		if not path.exists():
			fails.append(f"missing {path}")
			continue
		n = uniq(path)
		if n < need:
			fails.append(f"{name}: uniq={n} < {need}")
	if fails:
		print("FAIL landmark StyleQA")
		for f in fails:
			print(" ", f)
		return 1
	print(f"GREEN landmark StyleQA ({len(MIN_UNIQ)} props, uniq≥painted floor)")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
