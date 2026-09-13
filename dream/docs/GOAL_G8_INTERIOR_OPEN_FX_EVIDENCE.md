# Goal evidence — G8_INTERIOR_FX

**Runner:** `res://tools/g8_interior_open_fx_smoke.gd`
**Result:** PASS (exit=0) — activate path + `Assembler.mcp_play_open_fx`

## Log excerpt (expected)

```
G8_INTERIOR_FX: start
G8_INTERIOR_FX: open_fx_hotspots=1
G8_INTERIOR_FX: activated 衣柜 fx=drawer_open
G8_INTERIOR_FX: mcp_play_open_fx {ok:true, frames:4, playing:true, ...}
G8_INTERIOR_FX: post 衣柜 played=true anim=true
G8_INTERIOR_FX: PASS
```

## Live MCP (2026-09-13)

- Scene: `res://scenes/interiors/c01_home/c01_home.tscn`
- Probe: `InteriorCraft.mcp_play_open_fx("衣柜")` → `ok=true`, `frames=4`, `playing=true`
- After oneshot: node remains paused on **frame 3** (last drawer_open frame)
- Shots:
  - `docs/evidence/g8_c01_dresser_open_fx_live.png` — targeting +「互动」
  - `docs/evidence/g8_c01_dresser_open_fx_held.png` — post-oneshot held OpenFX

User Godot QA still required for visual fidelity (§7).
