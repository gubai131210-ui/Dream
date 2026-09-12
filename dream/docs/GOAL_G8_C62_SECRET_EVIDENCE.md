# Goal evidence — G8_C62_SECRET

**Runner:** `res://tools/g8_c62_secret_smoke.gd`  
**Result:** PASS (exit=0) — **full chain** forest → cave → waterfall → lake  
**Date:** 2026-09-13

## What it proves

- Hop0 `forest_deep`: `WorldPortal_树洞密道` · façade `ruin_arch_00` · Sprite2D cues · enters `c16_cave_entry`
- Hop1 `c16_cave_entry`: secret portal · façade `door_facade_00` · enters `waterfall`
- Hop2 `waterfall`: secret portal · façade `door_facade_00` · enters `lake`
- `WorldSpawnUtil.make_portal(..., facade_path)` carries CHAIN_A `facade` fields

## Log excerpt

```
G8_C62: start full chain
G8_C62: hop0 facade=res://assets/sprites/props/ruin_arch_00.png
G8_C62: hop0 entered res://scenes/interiors/c16_cave_entry/c16_cave_entry.tscn
G8_C62: hop1 facade=res://assets/sprites/props/door_facade_00.png
G8_C62: hop1 entered res://scenes/areas/waterfall/waterfall.tscn
G8_C62: hop2 facade=res://assets/sprites/props/door_facade_00.png
G8_C62: hop2 entered res://scenes/areas/lake/lake.tscn
G8_C62: PASS full chain
```

## MCP

- Forest secret: `docs/evidence/g8_c62_secret_portal.png`
- Cave interior after hop: `docs/evidence/g8_c16_cave_entry_idle.png`
- Live: `/root/ForestDeep/YSortRoot/SecretPassageRoot/WorldPortal_树洞密道` (+ DoorFacade/step/arch)

User Godot QA still required for visual fidelity.
