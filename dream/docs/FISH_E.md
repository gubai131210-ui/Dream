# Fish-E — fishing loop (C18–C22 minimal)

**Status:** DONE (minimal Wave A2)  
**Date:** 2026-09-11  
**Locks:** [`PHASE5.md`](PHASE5.md), [`PHASE5_WAVE_A2.md`](PHASE5_WAVE_A2.md), [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md) C18–C22, [`SCALE.md`](SCALE.md)  
**Skill:** `realistic-scene-craft` (append-only shore markers; no district rebuild)

## Goal

Outdoor **cast → wait → bite → reel → catch** at ≥2 water sites, with ≥2 rods. Not InfoPanel-only text.

| C | Delivered (minimal) |
| --- | --- |
| C18 | River + lake site tables (`site_id` fish pools) |
| C19 | Spot FX: ripple ring / bubbles / splash (+ optional water_frame) |
| C20 | `FishingSession` phase loop + bite-window QTE (click 收杆) |
| C21 | 竹竿 + 铁竿 (`FishingCatalog`, session 换竿) |
| C22 | Deferred (cage/net) — not required for Wave A2 Done-when |

## Ownership

| Piece | Path |
| --- | --- |
| Catalog | `scripts/fishing/fishing_catalog.gd` |
| Spot hotspot | `scripts/fishing/fishing_spot.gd` |
| Minigame UI | `scripts/fishing/fishing_session.gd` |
| Package doc | `docs/FISH_E.md` |
| Art | `assets/sprites/fishing/*.png` |
| Portal host (append) | `scripts/areas/river_assembler.gd`, `lake_assembler.gd` |
| Thin InfoPanel wire | `river_controller.gd`, `lake_controller.gd` |

**Do not:** edit interior profiles C01–C04, market, other interiors, SceneRouter constants.

## Sites

| Scene | Hub | Spot ids | Fish pool highlights |
| --- | --- | --- | --- |
| `scenes/areas/river/river.tscn` | 总览 → 河流 | `west_bend`, `bridge_south` | 河鲦 / 溪鳟 / 水草 |
| `scenes/areas/lake/lake.tscn` | 总览 → 湖泊 | `east_dock`, `south_shore` | 湖鲈 / 锦鲤 / 水草 |

Spots sit on **bank dirt** (assembler clears water cells). Visual: buoy post + idle ring.

## Rods

| Id | Name | Behavior |
| --- | --- | --- |
| `bamboo` | 竹竿 | Slower bite (`wait_mul` 1.15), baseline rare |
| `iron` | 铁竿 | Faster bite (0.75), +uncommon weight |

Switch with **竿：…（点换）** before cast or after result. Selection persists in `FishingCatalog.current_rod_id` for the run.

## Loop

1. Click buoy hotspot → `FishingSession` CanvasLayer opens  
2. **准备** — 可换竿 → 点「抛竿」  
3. **抛竿** (~0.55s)  
4. **等待** (1.1–2.2s × rod) — bubbles / ripple  
5. **咬钩** (~1.35s window) — click **收杆！**  
6. **拉扯** → roll fish from site table → **渔获** (or **脱钩** if late)  
7. Close panel; InfoPanel / spot copy shows last result  

## 禁止偷懒

1. 禁止只有 InfoPanel 文案、无 cast→bite→catch  
2. 禁止单地点 / 单竿交差  
3. 禁止改 C01–C04 / market / 他人目录  
4. 禁止大改河湖布局（只追加钓点）  
5. 禁止把钓点放进水格  
6. 禁止未写本 MD 声称 DONE  

## Demo（用户本地 Godot）

1. 打开项目 `dream/`，运行主场景  
2. Hub → **河流**  
3. 找到岸边红色浮漂钓点（西湾 / 桥南），点击  
4. 会话内可先点换竿（竹竿 ↔ 铁竿），再点 **抛竿**；咬钩时立刻点 **收杆！**  
5. 确认弹出渔获名（河鲦/溪鳟/水草）  
6. Hub → **湖泊**，东码头或南岸再钓一轮，确认湖鲈/锦鲤池不同  
7. 故意不收杆一次，确认 **脱钩**  

中文路径下请用户本机测；agent 不强制 Godot CLI。

## Acceptance checklist

- [x] ≥2 outdoor sites (river + lake)  
- [x] Cast → bite → catch (or miss)  
- [x] ≥2 rods  
- [x] `docs/FISH_E.md`  
- [ ] User Godot QA (pending)
