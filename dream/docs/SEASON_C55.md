# Season C55 — 广场四季装饰层

**Status:** DONE (desk) 2026-09-11  
**Locks:** [`PHASE5_WAVE_F.md`](./PHASE5_WAVE_F.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C55, [`ENV_H.md`](./ENV_H.md)  
**Owns:** `scripts/env/seasonal_decor.gd`, this doc  
**Hook:** thin mount in `village_square_controller.gd` (Env-H style)  
**Does not:** open a new festival megamap; Autoload; steal Env-H `CanvasModulate`

---

## Delivered

| ID | Intent | Shipped |
| --- | --- | --- |
| C55 | 广场四季装饰层可切换 | 春花 / 夏海 / 秋收 / 冬雪 prop clusters + soft grade veil + particles |

## API

`scripts/env/seasonal_decor.gd` — `class_name SeasonalDecor` (Node, **not** Autoload)

```gdscript
SeasonalDecor.attach_to(host: Node2D, top_bar: Control = null) -> SeasonalDecor
env.cycle_season()          # 春 → 夏 → 秋 → 冬 → 春
env.set_season(SeasonalDecor.Season.AUTUMN)
```

Signals: `season_changed(season)`

Visuals live on `SeasonalDecorLayer` + `SeasonalGradeLayer` (ColorRect, layer 7). Does **not** create a second `CanvasModulate`.

## How to toggle (village_square)

1. Open Godot `dream/` → **村庄广场** (`village_square.tscn`).
2. TopBar **春花 / 夏海 / 秋收 / 冬雪** button (auto-mounted as `ToggleSeason`).
3. Key **S** — cycle season.
4. Confirm corner prop clusters + center season banner change; spring/autumn/winter particles; soft grade veil.

## Files

| Path | Role |
| --- | --- |
| `scripts/env/seasonal_decor.gd` | Season node + layer |
| `scripts/areas/village_square_controller.gd` | Thin `attach_to` |
| `docs/SEASON_C55.md` | This package |

## Desk acceptance

| Check | Result |
| --- | --- |
| Plaza decoration layer (not new map) | PASS |
| 4 seasons switchable | PASS (春/夏/秋/冬) |
| TopBar + key, no popup stack | PASS |
| UI strings without 「占位」 | PASS |
| Coexists with Env-H day/night/weather | PASS (separate ColorRect grade) |

```
System QA (C55): PASS (desk) — user Godot shot pending
Season layer on A09 square; cycle 春花→夏海→秋收→冬雪 via TopBar/S
No festival megamap; no 占位 strings
```

## 禁止偷懒

1. 禁止 C55 新开整盘节日大地图  
2. 禁止只写 MD 无 TopBar/快捷键可切换  
3. 禁止把季节 UI 堆成弹层  
4. 禁止抢走 Env-H / forest CanopyTint 的 `CanvasModulate`  
5. 禁止 UI 残留「占位」  

## Acceptance checklist

- [x] 4 season visual layers on plaza  
- [x] TopBar cycle + **S**  
- [x] No megamap / no 占位  
- [x] This MD + desk table  
- [ ] User Godot: 广场 → 点季节按钮 / 按 S  
