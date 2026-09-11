# Clinic C08 — 医馆（前台 + 诊室）

**Status:** DONE  
**Date:** 2026-09-11  
**Locks:** [`PHASE5_WAVE_B.md`](./PHASE5_WAVE_B.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-visual-qa`, `interior-territory-craft` (medicine shelf mass), reuse props (no new paint this pass)

## Goal

Civic interior **C08 医馆**: readable **前台候诊** + **诊室药柜** (≥2 clusters). Enter from square portal 「进入医馆」; return to square.

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c08_clinic"` |
| This doc | `docs/CLINIC_C08.md` |
| Scene (Lead-seeded) | `scenes/interiors/c08_clinic/c08_clinic.tscn` (`profile_id = c08_clinic`) |
| Outdoor portal (Lead) | Square `building_04` → `SceneRouter.C08_CLINIC_PATH` |

Do **not** edit assemblers, router, peer `c0X_*` profiles, or C01–C04 polish.

## Layout grammar

| Cluster | Anchor | Verb | Key members |
| --- | --- | --- | --- |
| `front` | (7, 7) | 挂号 / 候诊 | `counter` south-face · `ledger` · `notice` · dual `stool` wait · `lamp_shop` |
| `exam` | (19, 6) | 检查 / 配药 | `bed_single` · dual `shelf` jar mass · dual `medicine` · dual `herbs` · `lamp_indoor` |

- `return_path` = square (`SQ`)
- Door aisle `door_tx0`–`door_tx1` = **11–14** clear (front east ≤8, exam west ≥17)
- Soft cool modulate `Color(0.82, 0.90, 0.92)` — not grocery warm / smith orange
- Lamps: **shop** at desk + **indoor** at exam — never smith/tavern
- Silhouette ≠ grocery: **no produce baskets**; east = exam bed + jar shelves, not dual grocery aisles
- Optional doctor: `actor` id `merchant` titled **医师**, route `front`↔`exam` with staff/approach stands

## Interact-ready

| Use-point | Free approach |
| --- | --- |
| Counter (patient) | `(0, 2)` relative to `front` — between counter and waiting stools |
| Counter (staff) | actor stand `[0, 0]` north of counter |
| Exam bed | actor / player stand `[-2, 1]` west of bed; east mass stays against wall |

Rug under waiting stop (`ox/oy` 6, 11) west of door band.

## Demo path

1. Hub → **广场**
2. North-row **医馆** door → 「进入医馆」
3. South door / TopBar **返回室外** → square
4. Visual: west desk+stools, east bed+药罐架体量, cool wash, physician patrol

## Interior Visual QA

```
Interior Visual QA: PASS
Place: Reality | Peer | Scene-fit | Territory | Composition | Ensemble | Interact-ready
Art: Style | Craft | Set-complete | Bleed | FX
Assembly: Multi-view | Splice | Y-sort | Corridor
Meta: Name≠pixels | Size | Profile-wire
Escalation: none
Blockers: none (user Godot playtest for collider/prompt polish)
```

| Gate | Evidence |
| --- | --- |
| Reality | 3s read: reception west + exam bed + hanging herbs / jar shelves = clinic |
| Peer | vs `c04_grocery` (dual grocery shelves + south baskets) — clinic is L-split desk/exam, jar `shelf_00` + `medicine`/`herbs`, **no baskets** |
| Scene-fit | `lamp_shop` front + `lamp_indoor` exam; no smith/tavern lamps |
| Territory | Medicine **mass**: stacked shelves + dual medicine chests + dual herb hangs (no enclosure needed) |
| Composition | Two verbs (`front`, `exam`); satellites \|d\|≤3; rug under wait |
| Ensemble | Primary counter, secondary exam; center door corridor open ≥30% |
| Interact-ready | Counter south approach + bed west approach; staff≠patient side |
| Corridor | Door 11–14 clear south→north |
| Profile-wire | All prop paths exist under `assets/sprites/interior/props/` |
| Name≠pixels | `medicine_00` = red-cross chest; `herbs_00` = hanging bundles; `shelf_00` = jar cabinet |

## 禁止偷懒

1. 禁止只改 hint/MD、不写满 `clusters`  
2. 禁止堵死南门廊道 11–14  
3. 禁止菜筐当医馆主视觉（≠杂货）  
4. 禁止锻工灯 / 酒馆烛灯进医馆  
5. 禁止诊室只有单药箱、无药架/晾草体量  
6. 禁止柜台前无患者站位、诊床侧无接近格  
7. 禁止改 `village_square_assembler` / `scene_router` / 其他 `c0X_*`  
8. 禁止中文路径强跑 Godot CLI；交付后用户本地测  

## Commit

`Enrich C08 clinic front desk and exam room.`
