# Interior foundation (C-layer)

**Status:** ACTIVE — C01 Wave A  
**Date:** 2026-09-11  
**Locks:** `SCALE.md` (`BASE_TILE=32`), `INTERIOR_LIBRARY.md`, `PHASE5.md`, outdoor cottage palette

## Diagnosis (why early interiors looked bad)

Not “too few furniture.” Foundation was wrong:

1. No modular wall structure  
2. No clear living zones / circulation  
3. Floor was procedural checkerboard or a single non-grid AI plate  
4. Warmth was a full-room orange Polygon / wash instead of wood + rug + **local** light  

## Consensus (research + project)

- Organize on **16/32 px grid**; build **walls + floor + door/window** before props  
- Circulation: **入口 → 活动区 → 休息区** with a clear aisle  
- Cozy = timber, rug, plants, **PointLight2D / soft shaft** — not a flat orange overlay  
- Match outdoor pixel language (cream walls, dark wood trim like `building_00`)

## Foundation assets

| Path | Role |
|---|---|
| `assets/sprites/interior/tiles/floor_*.png` | 32×32 plank floor |
| `…/wall_upper_*.png` | cream plaster wall |
| `…/wall_lower_*.png` | dark wainscot |
| `…/pillar_00.png` | posts |
| `…/doorstep_00.png` | south entry stone |
| `…/window_00.png` | north window frame |
| `…/rug_*.png` | entry rug quarters |
| `…/bed_00.png` | rest-zone bed |
| `tools/make_interior_foundation.py` | regenerator |

Reference mood plates (not runtime TileMap): `c01_room_backdrop_v2.png`, `c01_room_reference_cozy.png`.

## Assembler pass (`InteriorCraft`)

1. Floor fill (32 grid)  
2. North wall + side posts + doorstep  
3. Window + local light shaft  
4. Entry rug  
5. Furniture from **outdoor** props at scale **0.55**  
6. `CanvasModulate` mild + `PointLight2D` at lamp & window  
7. PatrolActor on aisle  
8. Return portal at south door  

## 禁止偷懒

- 禁止棋盘格 / 纯色块当地板  
- 禁止整屋橙色覆盖冒充温馨  
- 禁止只堆家具不建墙体结构  
- 禁止室内家具默认 scale>0.6 与室外脱节  
- 禁止门只有 InfoPanel  
- 禁止未过 foundation QA 就开 C02+ 空壳  
