# Goal evidence — C59 clear FX + C61 chest MCP

**Date:** 2026-09-13  

## C59 Breakables clear FX

Clear no longer instant-despawn only: hide prop → play debris oneshot → free after ~0.55s.

| id | FX |
| --- | --- |
| rock / weed | `leaf_fall` |
| stake | `bench_dust` |
| crate | `crate_lid` |

MCP: `BreakablesKit.mcp_clear("rock"|"crate"|…)` → ok (reports `fx` / `fx_playing` after reload).

Shot: `docs/evidence/g8_c59_crate_clear_fx.png`

## C61 Hidden chest open

| Site | Probe | Result |
| --- | --- | --- |
| well (plaza) | `HiddenChests_well.mcp_open()` | ok, ChestLidFX frames=4 playing |

Shot: `docs/evidence/g8_c61_well_chest_open.png`

Lid oneshot now pauses on last frame (MCP parity with C58).

User §7 still required.
