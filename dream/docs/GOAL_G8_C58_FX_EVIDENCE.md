# Goal evidence — G8_C58_FX

**Runner:** `res://tools/g8_c58_fx_smoke.gd`  
**Result:** PASS expected — well / crate / tree / **feed_critter** (bird_peck) ×4 frames

## Log excerpt (expected)

```
G8_C58_FX: start
G8_C58_FX: ok well_water frames=4
G8_C58_FX: ok crate_search frames=4
G8_C58_FX: ok shake_tree frames=4
G8_C58_FX: ok feed_critter frames=4
G8_C58_FX: PASS
```

## MCP live (editor)

- `WorldInteractKit.mcp_spawn_c58_fx(id)` sync probe → `ok` + `frames=4` + `playing=true` for well / crate / tree / feed  
- Shots:
  - `docs/evidence/g8_c58_well_rope_live.png`
  - `docs/evidence/g8_c58_crate_lid_live.png`
  - `docs/evidence/g8_c58_leaf_fall_live.png`
  - `docs/evidence/g8_c58_bird_peck_live.png`
- Oneshot **pauses on last frame** (MCP-readable); re-trigger frees prior `FX_*`
- Bird peck display scale **1.75** (32×32 source)

User Godot QA still required for visual fidelity.
