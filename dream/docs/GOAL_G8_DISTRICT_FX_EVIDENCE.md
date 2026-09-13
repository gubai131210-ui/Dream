# Goal evidence — DistrictInteract multi-frame FX

**Date:** 2026-09-13  
**Change:** `DistrictInteractKit` no longer pulse-only — maps interact ids onto shipped C58 FX sheets.  
**Addendum:** District `*lamp*` now matches plaza `lamp_toggle` result layer — `PointLight2D` + sprite modulate + Info「路灯已点亮/熄灭」+ `lamp_spark` oneshot.

## Mapping (keyword → FX)

| Keyword | FX |
| --- | --- |
| bench | `bench_dust` |
| sign | `board_rustle` |
| lamp | `lamp_spark` (+ light toggle) |
| crate / handcart / barrel | `crate_lid` |
| trough | `well_rope` |
| hay / wood / sack / rock | `leaf_fall` |

## MCP probes

| Host | id | Result |
| --- | --- | --- |
| market | `mkt_crate_stack` | ok, FX_crate_lid frames=4 playing |
| market | `mkt_handcart` | ok, FX_crate_lid frames=4 |
| forest_entrance | `fent_sign` | ok, FX_board_rustle frames=4 |
| lighthouse | `light_lamp` | ok → 熄灭 (`lamp_on=false`, energy=0) → 点亮 (`lamp_on=true`, energy=0.85); FX_lamp_spark frames=4; `has_light=true` |
| station | `stn_lamp` | ok, 熄灭 + FX_lamp_spark frames=4; `has_light=true` |

Shots:

- `docs/evidence/g8_district_market_crate_fx.png`
- `docs/evidence/g8_district_lighthouse_lamp_on.png`
- `docs/evidence/g8_district_lighthouse_lamp_off.png`

Probe API: `DistrictInteractKit.mcp_spawn_fx(interact_id)` — for `*lamp*` ids also toggles light (returns `lamp_on` / `lamp_blurb` / `has_light`).

User §7 hand-feel still required.
