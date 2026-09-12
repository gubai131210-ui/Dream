# Goal evidence — G8_C62_SECRET

**Runner:** `res://tools/g8_c62_secret_smoke.gd`  
**Result:** PASS (exit=0)  
**Date:** 2026-09-13

## What it proves

- `SecretPassageChain` on `forest_deep` mounts `WorldPortal_树洞密道`
- Portal has `DoorFacade` + `DoorstepCue` + `DoorArchCue`
- Façade uses `ruin_arch_00.png` (chain `facade` field via `WorldSpawnUtil.make_portal(..., facade_path)`)
- `SceneRouter.change_to` enters `c16_cave_entry`

## Log excerpt

```
G8_C62: start
G8_C62: facade=res://assets/sprites/props/ruin_arch_00.png
G8_C62: path=res://scenes/interiors/c16_cave_entry/c16_cave_entry.tscn
G8_C62: entered res://scenes/interiors/c16_cave_entry/c16_cave_entry.tscn
G8_C62: PASS
```

## MCP

- Scene: `forest_deep.tscn` · runtime_root `/root/ForestDeep`
- Live node: `/root/ForestDeep/YSortRoot/SecretPassageRoot/WorldPortal_树洞密道`
- Children: `DoorFacade`, `DoorstepCue`, `DoorArchCue`
- Shot: `docs/evidence/g8_c62_secret_portal.png`

User Godot QA still required for visual fidelity of the ruin-arch secret cue.
