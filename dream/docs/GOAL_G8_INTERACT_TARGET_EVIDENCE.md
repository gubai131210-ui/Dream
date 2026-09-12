# Goal evidence — G8_INTERACT_TARGET

**Runner:** `res://tools/g8_interact_target_smoke.gd`  
**Result:** PASS (exit=0)  
**Date:** 2026-09-13

## What it proves

Shared executable target on interiors (`InteriorRoomController`):

1. Mouse **hover** wins over nearest proximity for the 「互动」prompt  
2. **Click** syncs prompt to the activated hotspot  
3. `get_executable_interact_target()` exposes the shared selector

Closes INTERACTION_DESIGN §2.4 P1 (“提示 A、点击 B”).

## Log excerpt

```
G8_TARGET: start
G8_TARGET: nearest_or_none=null
G8_TARGET: hover_wins=灶台
G8_TARGET: click_sync=厨架
G8_TARGET: PASS
```

User §7 Godot hand-feel QA still required for Goal complete.
