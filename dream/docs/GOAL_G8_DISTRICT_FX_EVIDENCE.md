# Goal evidence — DistrictInteract multi-frame FX

**Date:** 2026-09-13  
**Change:** `DistrictInteractKit` no longer pulse-only — maps interact ids onto shipped C58 FX sheets.

## Mapping (keyword → FX)

| Keyword | FX |
| --- | --- |
| bench | `bench_dust` |
| sign / lamp | `board_rustle` |
| crate / handcart / barrel | `crate_lid` |
| trough | `well_rope` |
| hay / wood / sack / rock | `leaf_fall` |

## MCP probes

| Host | id | Result |
| --- | --- | --- |
| market | `mkt_crate_stack` | ok, FX_crate_lid frames=4 playing |
| market | `mkt_handcart` | ok, FX_crate_lid frames=4 |
| forest_entrance | `fent_sign` | ok, FX_board_rustle frames=4 |

Shot: `docs/evidence/g8_district_market_crate_fx.png`

Probe API: `DistrictInteractKit.mcp_spawn_fx(interact_id)`.

User §7 hand-feel still required.
