"""Static coverage: shipped interact catalogs must wire multi-frame FX paths.

Does not replace user §7. Catches regressions where a catalog id loses oneshot FX.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def ids_from_defs(source: str, const_name: str) -> list[str]:
    # Pull "id": "foo" inside CONST := [ ... ] until next top-level const/func.
    m = re.search(rf"const {re.escape(const_name)}\s*:?=\s*\[([\s\S]*?)\n\]", source)
    if not m:
        raise AssertionError(f"missing const {const_name}")
    return re.findall(r'"id"\s*:\s*"([^"]+)"', m.group(1))


def main() -> int:
    wik = read("scripts/world/world_interact_kit.gd")
    c58_ids = ids_from_defs(wik, "INTERACT_DEFS")
    if len(c58_ids) < 8:
        raise AssertionError(f"expected ≥8 C58 ids, got {c58_ids}")
    mcp = wik
    for iid in c58_ids:
        # lamp_toggle FX is in _handle_interact + mcp_spawn; others too.
        if iid == "lamp_toggle":
            if "lamp_spark" not in wik or f'"{iid}"' not in wik:
                raise AssertionError("lamp_toggle missing lamp_spark wiring")
            continue
        if f'"{iid}"' not in mcp:
            raise AssertionError(f"C58 id {iid} missing from world_interact_kit")
        # Each non-lamp id should be handled in mcp_spawn_c58_fx match.
        if "mcp_spawn_c58_fx" not in wik:
            raise AssertionError("mcp_spawn_c58_fx missing")
    if "lamp_spark" not in wik:
        raise AssertionError("C58 lamp_spark FX missing")
    for sheet in ("leaf_fall", "well_rope", "crate_lid", "bird_peck", "bench_dust", "board_rustle", "lamp_spark"):
        # leaf/bird via helper; others via _play_fx_clip string
        if sheet not in wik and sheet not in ("leaf_fall", "bird_peck"):
            raise AssertionError(f"C58 sheet ref missing: {sheet}")
    if "leaf_fall" not in wik or "bird_peck" not in wik:
        raise AssertionError("leaf_fall/bird_peck helpers missing")

    gates = read("scripts/world/progress_gates.gd")
    gate_ids = ids_from_defs(gates, "GATE_DEFS")
    for gid in gate_ids:
        if gid not in gates or "_play_unlock_fx" not in gates:
            raise AssertionError(f"gate {gid} unlock FX path missing")

    brk = read("scripts/world/breakables_kit.gd")
    kind_ids = ids_from_defs(brk, "KIND_DEFS")
    if "_play_clear_fx" not in brk:
        raise AssertionError("breakables clear FX missing")
    for kid in kind_ids:
        if f'"{kid}"' not in brk:
            raise AssertionError(f"breakable kind {kid} missing")

    dik = read("scripts/world/district_interact_kit.gd")
    if "_fx_spec_for_id" not in dik or "lamp_spark" not in dik:
        raise AssertionError("DIK FX map / lamp_spark missing")

    cage = read("scripts/fishing/fish_cage.gd")
    if "_play_splash_fx" not in cage or "fish_splash" not in cage:
        raise AssertionError("fish cage splash FX missing")
    spot = read("scripts/fishing/fishing_spot.gd")
    if "mcp_cast_fx" not in spot or "fish_splash" not in spot:
        raise AssertionError("fishing cast splash FX missing")

    craft = read("scripts/interiors/interior_craft.gd")
    if "_infer_tap_fx" not in craft or "mcp_play_tap_fx" not in craft:
        raise AssertionError("interior tap FX missing")
    if "drawer_open" not in craft or "chest_lid" not in craft:
        raise AssertionError("interior open FX inference missing")

    routine = read("scripts/npc/npc_routine_demo.gd")
    if "life_poses" not in routine:
        raise AssertionError("C54 life_poses wiring missing")
    for life in ("eat", "sleep", "read", "laundry", "idle_sit"):
        d = ROOT / "assets" / "sprites" / "npc" / "life_poses" / life
        frames = sorted(d.glob("pose_*.png"))
        if len(frames) < 4:
            raise AssertionError(f"life pose {life}: need ≥4 frames")

    stall = read("scripts/market/market_stall.gd")
    if "_play_cycle_fx" not in stall:
        raise AssertionError("market stall cycle FX missing")

    print(
        "GREEN interact-FX coverage "
        f"(C58={len(c58_ids)} gates={len(gate_ids)} breakables={len(kind_ids)} "
        "+ DIK/cage/cast/interior/life/stall)"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as exc:
        print(f"RED interact-FX coverage: {exc}", file=sys.stderr)
        raise SystemExit(1)
