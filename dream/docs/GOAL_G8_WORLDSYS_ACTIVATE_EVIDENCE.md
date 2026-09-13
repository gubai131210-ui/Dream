# Goal evidence — G8_WORLDSYS

**Runner:** `res://tools/g8_worldsys_activate_smoke.gd`  
**Result:** PASS (failures=0)  
**Refreshed:** 2026-09-13 — includes `mcp_clear` / `mcp_unlock` probes

## Log excerpt

```
G8_WORLDSYS: start
G8_WORLDSYS: activated sit_bench
G8_WORLDSYS: activated well_water
G8_WORLDSYS: activated shake_tree
G8_WORLDSYS: activated notice_board
G8_WORLDSYS: activated crate_search
G8_WORLDSYS: activated lamp_toggle
G8_WORLDSYS: activated feed_critter
G8_WORLDSYS: activated read_sign
G8_WORLDSYS: gates=3 breakables=4
G8_WORLDSYS: mcp_clear weed { "ok": true, "id": "weed", "cleared": 1, "remaining_nodes": 3 }
G8_WORLDSYS: mcp_unlock locked_door { "ok": true, "id": "locked_door", "unlocked_count": 1, "sprite_alpha": 0.45… }
G8_WORLDSYS: activated brk:rock
G8_WORLDSYS: activated brk:stake
G8_WORLDSYS: activated brk:crate
G8_WORLDSYS: activated gate:fallen_log
G8_WORLDSYS: activated gate:boulder
G8_WORLDSYS: ok=13 failures=0
G8_WORLDSYS: PASS
```

Notes: `brk:weed` / `gate:locked_door` are exercised via MCP probes (not re-activated after clear/unlock).

User Godot QA still required (§7).
