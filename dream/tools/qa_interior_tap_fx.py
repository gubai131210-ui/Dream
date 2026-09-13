"""Static QA: interior tap FX inference must cover key semantic props.

Does not replace in-engine hand-feel (§7). Catches regressions where
non-open interior props lose multi-frame activate feedback wiring.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CRAFT = ROOT / "scripts" / "interiors" / "interior_craft.gd"


def function_body(source: str, name: str) -> str:
    # Support multi-line signatures: func name(\n ... ) -> void:
    match = re.search(
        rf"func {re.escape(name)}\s*\([\s\S]*?\)\s*(?:->\s*[^\n:]+)?\s*:[\s\S]*?(?=\nfunc |\Z)",
        source,
    )
    if not match:
        raise AssertionError(f"missing function: {name}")
    return match.group(0)


def main() -> int:
    source = CRAFT.read_text(encoding="utf-8")
    if "func mcp_play_tap_fx" not in source:
        raise AssertionError("mcp_play_tap_fx missing")
    if "TapFX_" not in source:
        raise AssertionError("TapFX_ node naming missing")
    spawn = function_body(source, "_spawn_prop")
    if "_infer_tap_fx" not in spawn:
        raise AssertionError("_spawn_prop must call _infer_tap_fx for non-open props")
    if "open_fx" not in spawn:
        raise AssertionError("_spawn_prop must keep open_fx path")
    infer = function_body(source, "_infer_tap_fx")
    # Crate must be classified before board keywords (avoid "rate" ⊆ "crate").
    crate_pos = infer.find('"crate"')
    rate_board_pos = infer.find("rate_board")
    board_contains = infer.find('key.contains("board")')
    if crate_pos < 0:
        raise AssertionError("crate keyword missing from _infer_tap_fx")
    if rate_board_pos >= 0 and crate_pos > rate_board_pos:
        raise AssertionError("crate keyword must appear before rate_board")
    if board_contains >= 0 and crate_pos > board_contains:
        raise AssertionError("crate keyword must appear before board contains check")
    # Required sheet prefixes for enriched interiors.
    for prefix in ("board_rustle", "lamp_spark", "crate_lid", "bench_dust", "leaf_fall"):
        if prefix not in infer:
            raise AssertionError(f"_infer_tap_fx missing prefix {prefix}")
    # open_fx exclusivity still present.
    open_infer = function_body(source, "_infer_open_fx")
    if "drawer_open" not in open_infer or "chest_lid" not in open_infer:
        raise AssertionError("open_fx inference lost dresser/chest")
    print("GREEN interior-tap-fx QA (inference order + TapFX wiring + open_fx exclusive)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as exc:
        print(f"RED interior-tap-fx QA: {exc}", file=sys.stderr)
        raise SystemExit(1)
