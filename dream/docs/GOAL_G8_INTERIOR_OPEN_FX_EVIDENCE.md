# Goal evidence — G8_INTERIOR_FX

**Runner:** `res://tools/g8_interior_open_fx_smoke.gd`
**Result:** PASS (exit=0)

## Log excerpt

```
G8_INTERIOR_FX: start
G8_INTERIOR_FX: open_fx_hotspots=1
G8_INTERIOR_FX: activated 衣柜 fx=drawer_open
G8_INTERIOR_FX: post 衣柜 played=true anim=true
G8_INTERIOR_FX: ok=1 failures=0
G8_INTERIOR_FX: PASS
```

## Live MCP (2026-09-13)

- Scene: `res://scenes/interiors/c01_home/c01_home.tscn`
- Probe: `InteriorCraft.mcp_play_open_fx("衣柜")` → `ok=true`, `open_fx=drawer_open`, `fx=OpenFX_drawer_open`, `frames=4`, `playing=true`
- Runtime path: `/root/C01HomeInterior/InteriorWorld/衣柜/Visual/OpenFX_drawer_open`
- Shot: `docs/evidence/g8_c01_dresser_open_fx_live.png`

User Godot QA still required for visual fidelity (§7).
