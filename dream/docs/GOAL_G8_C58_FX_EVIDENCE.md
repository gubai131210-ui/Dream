# Goal evidence — G8_C58_FX

**Runner:** `res://tools/g8_c58_fx_smoke.gd`  
**Result:** PASS expected — play + **held last frame** for well / crate / tree / feed

## Log excerpt (expected)

```
G8_C58_FX: start
G8_C58_FX: ok well_water frames=4
G8_C58_FX: ok crate_search frames=4
G8_C58_FX: ok shake_tree frames=4
G8_C58_FX: ok feed_critter frames=4
G8_C58_FX: held well_water playing=false frame=3 last=3 held_ok=true
G8_C58_FX: held crate_search ...
G8_C58_FX: held shake_tree ...
G8_C58_FX: held feed_critter ...
G8_C58_FX: PASS
```

## MCP live (editor)

- `WorldInteractKit.mcp_spawn_c58_fx(id)` → `ok` + `frames=4` + `playing=true`
- After oneshot: FX pauses on last frame (re-trigger frees prior `FX_*`)
- Shots:
  - `docs/evidence/g8_c58_well_rope_live.png`
  - `docs/evidence/g8_c58_crate_lid_live.png`
  - `docs/evidence/g8_c58_leaf_fall_live.png`
  - `docs/evidence/g8_c58_bird_peck_live.png` (held frame=3 · scale=1.75)

User Godot QA still required for visual fidelity.
