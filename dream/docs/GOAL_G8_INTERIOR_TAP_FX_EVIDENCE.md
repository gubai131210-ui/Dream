# Goal G8 — Interior prop tap multi-frame FX

**Date:** 2026-09-13  
**Does not replace** user §7 hand-feel QA.

## Gap closed

Interior props without `open_fx` (dresser/chest only) previously had InfoPanel click with **no multi-frame activate feedback**. Objective asks for click/activate feedback and multi-frame where applicable across enriched interiors.

## Change

`interior_craft.gd` `_spawn_prop`:
- Keep `open_fx` path for dresser (`drawer_open`) / chest (`chest_lid`).
- Else `_infer_tap_fx(path, title)` → keyword map onto C58 sheets:
  - boards/ledgers/plaques/guides → `board_rustle`
  - lamps/forge/altar/stove → `lamp_spark`
  - desks/tables/crates/shelves → `crate_lid`
  - benches/beds/stools → `bench_dust`
  - plants/hay/reed/nest → `leaf_fall`
- `TapFX_*` oneshot with pause-on-end; `mcp_play_tap_fx(hotspot_name)`.

## MCP evidence (C07 school)

| Probe | Result |
| --- | --- |
| `Assembler.mcp_play_tap_fx("黑板")` | TapFX_board_rustle frames=4 |
| `mcp_play_tap_fx("前排课桌")` | TapFX_crate_lid frames=4 |
| `mcp_play_tap_fx("西壁灯")` | TapFX_lamp_spark frames=4 |
| Shot | `docs/evidence/g8_interior_tap_fx_blackboard.png` |

User §7 still required.
