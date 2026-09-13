# Goal evidence — C05 MarketStall cycle FX

**Date:** 2026-09-13  

## Change

`MarketStall.cycle_next()` now plays a short multi-frame tap FX after state rebuild:

| Destination state | FX |
| --- | --- |
| OPEN / SETUP / SOLD_OUT | `crate_lid`×4 |
| CLOSED | `leaf_fall`×4 |
| EMPTY / LOCKED | `board_rustle`×4 |

## MCP

`MarketStall_n_m.mcp_cycle()` → `{ok, from, to, fx, fx_frames:4, fx_playing:true}`

Example: setup→open → `FX_crate_lid` frames=4.

Shot: `docs/evidence/g8_c05_stall_cycle_fx.png`

User §7 still required.
