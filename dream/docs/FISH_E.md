# Fish-E — minimal fishing loop (C18–C22)

**Status:** LANDED (code) 2026-09-11 — user Godot QA next  
**Locks:** [`PHASE5_WAVE_A2.md`](./PHASE5_WAVE_A2.md), [`PHASE5.md`](./PHASE5.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md)

## Delivered

| Piece | Path |
| --- | --- |
| Catalog / rods / fish | `scripts/fishing/fishing_catalog.gd` |
| Session cast→bite→catch | `scripts/fishing/fishing_session.gd` |
| Spot hotspot | `scripts/fishing/fishing_spot.gd` |
| Spawns | `river_assembler.gd`, `lake_assembler.gd` (append-only spots) |

## Demo

1. Hub → **河流** or **湖泊**  
2. Click a fishing spot hotspot  
3. Session cycles cast → bite → catch (placeholder fish); ≥2 rods in catalog  

## 禁止偷懒

- 禁止只有文案不能钓  
- 禁止改室内 C01–C04 / 市集摊位  
