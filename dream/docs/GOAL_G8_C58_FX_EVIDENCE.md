# Goal evidence — G8_C58_FX

**Runner:** `res://tools/g8_c58_fx_smoke.gd`  
**Result:** PASS (exit=0) — matrix re-run 2026-09-13

## Log excerpt

```
G8_C58_FX: start
G8_C58_FX: ok well_water frames=4
G8_C58_FX: ok crate_search frames=4
G8_C58_FX: ok shake_tree frames=4
G8_C58_FX: PASS
```

## MCP live (editor)

- `WorldInteractKit.mcp_spawn_c58_fx(id)` sync probe → `ok` + `frames=4` + `playing=true` for well / crate / tree  
- InfoPanel: `docs/evidence/g8_c58_well_rope_live.png`（取水 / 井绳吱呀）  
- Oneshot holds last frame ~2s for readability

User Godot QA still required for visual fidelity.
