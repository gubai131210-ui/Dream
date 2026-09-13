# Farm crop B research — Dream Phase0 vertical slice

> **Date:** 2026-09-13  
> **Status:** Phase0 **IMPLEMENTED** (`FarmCropKit` on farmland; Night→Day morning tick; new turnip stage + water/harvest FX). See [`GOAL_SPINE_ABD.md`](../GOAL_SPINE_ABD.md).  
> **Scope:** cozy crop loop — growth stages, watering, harvest → inventory — for a **3–5 tile** Phase0 slice on `farmland` / `farm_residential`.  
> **Trust:** official / primary wikis (Stardew Wiki, Coral Island Fandom, Fogu SoS:FoMT).  
> **Does not:** expand to full farm economy / seasons / sprinklers.

**Companion:** [`PLAYER_SPINE_A_RESEARCH.md`](PLAYER_SPINE_A_RESEARCH.md) (minimal `InventoryService` — harvest must land there).

---

## 0. Dream repo snapshot (grep-backed)

| Piece | Exists? | Role today |
| --- | --- | --- |
| `farmland_assembler._paint_crop_beds` / `_spawn_crop_visuals` | Yes | ≥6 dirt beds + `AreaCraft.spawn_crop_rows` (decorative **furrow lines**, InfoPanel hotspots only). |
| `AreaCraft.spawn_crop_rows` | Yes | Hotspot + `furrow_line_00.png` rows + `WindSway.attach(..., "crop")`. **No plant sprites, no growth state.** ColorRect furrow forbidden (`qa_no_placeholder_visuals`). |
| `AreaCraft.is_plantable` / `dirt_mask` / `mark_dirt_rect` | Yes | Dirt beds painted; `is_plantable` currently returns **false** on dirt/path/water (grass-only). Phase0 must **not** treat this as “tillable gameplay” without an explicit remap (see §4). |
| `farm_residential` | Yes | Dirt pads / door lanes; **no** `spawn_crop_rows`. Allowed Phase0 host if a small dirt patch is designated — prefer **farmland** bed cells first. |
| `DayNightWeather` | Yes (scene-local Node) | `TimeGrade` DAY/NIGHT + `WeatherKind` CLEAR/RAIN/FOG; `state_changed`; TopBar N/R. **No calendar day index, no `day_advanced` signal.** |
| `NpcRoutineRings` `sow` | Yes | NPC pose demo on farmland furrows — **visual ring only**, not crop sim. |
| Gameplay Inventory | **No** | Per Spine A: no `InventoryService` yet; do not confuse with QA sprite inventory tools. |
| B12 crop raw art | Partial | `MANIFEST.md` lists `B12_crops_wheat_corn_tomato` — decorative sheet, **not** wired as per-tile stage plants. Phase0 = **new** stage sprites (see constraints). |

**Gap in one line:** farmland has readable **beds + furrows**, Env has **day/night + rain**, but there is **no crop instance state, no water flag, no stage art as plants, and no harvest → bag**.

---

## 1. Primary inspirations

### 1.1 Stardew Valley — night growth + daily water gate

| Topic | Behavior | Source |
| --- | --- | --- |
| Stages | Each crop has `DaysInPhase[]`; each entry = days spent on that **visual sprite** before advancing. Example Potato: 1+1+1+2+1 = **6 days**, **5 growth sprites + harvest**. Parsnip (tutorial crop): 1+1+1+1 = **4 days**, 4 stages + harvest. | [Crops](https://stardewvalleywiki.com/Crops) · [Modding:Crop data](https://stardewvalleywiki.com/Modding:Crop_data) · [Potato](https://stardewvalleywiki.com/Potato) · [Parsnip](https://stardewvalleywiki.com/Parsnip) |
| Day math | Grow times **exclude planting day** (nights required). Unwatered day → **no growth that night**, plant does **not** die. | [Crops](https://stardewvalleywiki.com/Crops) |
| Watering | Must water every day until mature (single-harvest mature crops need no further water). Outdoor **rain** waters for you. | [Watering Cans](https://stardewvalleywiki.com/Watering_Cans) |
| Harvest → inventory | Mature tile → grab (or scythe); item(s) enter **player inventory** (quality stars, stack rules). | [Crops](https://stardewvalleywiki.com/Crops) · [Inventory](https://stardewvalleywiki.com/Inventory) |
| **Steal** | Per-tile state machine; growth tick at day boundary; water is a **boolean gate**, not a continuous meter. |

### 1.2 Coral Island — similar loop, planting day counted differently

| Topic | Behavior | Source |
| --- | --- | --- |
| Loop | Hoe → (fertilizer) → seed → water daily → grow → harvest (hand or scythe). Unwatered: **pause**, no wither until **season change**. Rain counts as water. | [Crop](https://coralisland.fandom.com/wiki/Crop) · [All plant](https://coralisland.fandom.com/wiki/All_plant) |
| Day math | Growth times **include** the day the seed is first planted **and watered**. 10-day crop planted day 1 → harvestable day 11 if watered days 1–10. | [Crop](https://coralisland.fandom.com/wiki/Crop) |
| Teaching crops | **Turnip** Rank F, **4 days**, stages 1–4 (1 day each) + harvest stage. **Potato** Rank F, **5 days**, stages 1–5 + harvest. | [Turnip](https://coralisland.fandom.com/wiki/Turnip) · [Potato](https://coralisland.fandom.com/wiki/Potato) · [Spring](https://coralisland.fandom.com/wiki/Spring) |
| Harvest | Manual or scythe; yield enters bag; many crops vanish after harvest (regrow subset exists — out of Phase0). | [Crop](https://coralisland.fandom.com/wiki/Crop) |
| **Steal** | Short Rank-F crops + clear stage art; rain auto-water; harvest is a first-class inventory verb. |

### 1.3 Story of Seasons: Friends of Mineral Town — explicit stage day budgets

| Topic | Behavior | Source |
| --- | --- | --- |
| Prep | Clear debris → hoe (often 3×3 seed bag) → plant → water once/day. Extra water **does not** speed growth. Rain = no need to water. | [Fogu — Growing Crops](https://fogu.com/sos3/farm/) |
| Turnip (classic teach) | Stage1 seeds **2d** → Stage2 sprout **2d** → ripe; **TOTAL 5 days**; gone once harvested. | [Fogu — Spring Crops](https://fogu.com/sos3/farm/spring_crops.html) |
| Potato | Stage1 **3d** → Stage2 **4d**; **TOTAL 8 days**. | same |
| Longer crops | e.g. Tomato 2+2+2+3 = 10d + regrow; shows multi-stage readability. | [Fogu — Summer Crops](https://fogu.com/sos3/farm/summer_crops.html) |
| **Steal** | Named stages (seeds / sprout / youth / adult) with **days-per-stage** tables — easy to port as `days_in_phase[]`. |

### 1.4 Cross-game consensus (Phase0 must keep)

1. **Tile (or plant instance) state:** crop_id + stage + watered_today + days_in_current_stage (or days_left).  
2. **≥3 readable plant silhouettes** before harvest (not soil lines alone).  
3. **Water gate:** watered → may advance on day tick; unwatered → stall.  
4. **Rain substitutes watering** (map to `DayNightWeather.WeatherKind.RAIN`).  
5. **Harvest removes plant (or resets)** and **adds item_id to inventory**.  
6. Season death / fertilizer / sprinklers / giant crops / quality stars = **later**.

---

## 2. Dream constraints (Phase0 lock)

| Constraint | Meaning |
| --- | --- |
| Footprint | **3–5 tiles only** (contiguous dirt cells inside one bed or a marked farm_residential dirt patch). Not whole-field sim. |
| Hosts | `farmland` and/or `farm_residential` only. |
| Art | **NEW plant sprites** for stages. **Forbidden:** reusing ColorRect furrows / `furrow_line_00` as “the crop plant.” Furrows may remain as **soil underlay** only. |
| Stages | Growth stages **≥3** (recommend 4 visual plant frames: seed·sprout·young·ripe). |
| Actions | **Water** action on planted tiles; **Harvest** when ripe → **Inventory** (`InventoryService.try_add` per Spine A). |
| Scope cut | No shop buy loop required if seeds are debug-granted; no energy drain; no multi-harvest; no till tool if beds pre-dirt. |

---

## 3. Recommendation (lock for implementers)

### 3.1 Crop id

**`turnip`** (item harvest id: `crop_turnip`; seed id optional Phase0: `seed_turnip`).

| Why turnip | Why not potato (Phase0) |
| --- | --- |
| SoS / Coral **teaching** crop; short loop. | Stardew potato is 6d / 5 phases — longer demo. |
| Compact round silhouette reads at 1 tile. | Leafy potato canopy harder to distinguish in 3–4 frames. |
| Coral 4-day / SoS 5-day ≈ Dream 3 watered ticks. | Potato better as Phase1 second crop. |

Stardew has no turnip; closest tutorial twin is **Parsnip** ([Parsnip](https://stardewvalleywiki.com/Parsnip)) — same “short root veg” fantasy if art direction prefers.

### 3.2 Stage table (Dream Phase0)

| Stage index | Visual | Days in stage (watered day-ticks) | Notes |
| --- | --- | --- | --- |
| 0 | `crop_turnip_stage_00` seedling | 1 | Planted + watered same day still waits for first **day tick** (Stardew-like nights). |
| 1 | `crop_turnip_stage_01` sprout | 1 | |
| 2 | `crop_turnip_stage_02` young | 1 | |
| 3 | `crop_turnip_stage_03` ripe | — | Harvestable; no further growth. |

**Total watered day-ticks to ripe:** **3** (plant day evening → morning×3).  
**Sprite count:** **4** (≥3 requirement met).  
Aligns with SoS turnip “seeds → sprout → ripe” spirit and Coral turnip’s short Rank-F loop without copying either day-count verbatim.

### 3.3 Day / tick model using `DayNightWeather`

Env today ([`ENV_H.md`](../ENV_H.md), `scripts/env/day_night_weather.gd`):

- Binary `DAY` / `NIGHT` + `state_changed(time_grade, weather)`.
- **No** global day counter.

**Phase0 recommendation — “Morning Tick” (minimal invasive):**

1. Crop sim owns a tiny `CropPlotService` (or scene-local `FarmCropKit` on farmland controller) — **not** forced into Autoload until inventory exists.  
2. On `DayNightWeather.state_changed`: when previous was `NIGHT` and new is `DAY` → emit / call **`on_morning_tick()`**.  
   - Also accept an explicit TopBar / debug **「推进一天」** if QA needs ticks without flipping N twice.  
3. Morning tick algorithm (per planted tile):  
   - If `weather == RAIN` at tick start **or** `watered` flag set → clear need; advance `days_in_stage`; if exceeded phase length → `stage++`.  
   - Else stall.  
   - Reset `watered = false` after tick (Stardew: must water again next day).  
4. Player **Water** action: sets `watered = true` + wet soil tint; optional splash FX later.  
5. Do **not** grow on every N toggle without a documented morning rule — avoid double-ticking.

**Rain:** while `WeatherKind.RAIN`, Water action may auto-succeed or morning tick treats rain as watered (match Stardew / Coral / SoS).

**Persistence:** Phase0 may keep state in memory only for the farmland scene session; if Spine A inventory is Autoload, crop bag items survive scene change even if plots reset — document that reset explicitly until save exists.

### 3.4 Inventory hook

- Harvest ripe tile → `InventoryService.try_add(&"crop_turnip", 1)` (Spine A).  
- If inventory not yet shipped: **block harvest UI** or ship InventoryService **in the same vertical slice** — do not fake “harvested” with InfoPanel-only text.  
- Toast / TopBar count strip is enough; full bag UI later.

### 3.5 Placement

- Prefer **one** existing farmland bed corner (e.g. 西蔬菜畦 / 西北麦田) — pick **3–5 dirt cells** as `CropPlot` nodes or meta on tiles.  
- Keep `furrow_line_00` underlay for bed read; plant sprites **centered on tile**, Y-sorted, feet-anchored like other props.  
- `farm_residential` optional second host: only if a 3–5 dirt rect is marked; do not plant on grass.

---

## 4. Dream hooks (where implementers should attach)

| Hook | Path / API | Use |
| --- | --- | --- |
| Bed geometry | `farmland_assembler._crop_beds` + `_spawn_crop_visuals` | Choose cells inside one bed dict; do not spawn 8 full decorative beds as gameplay. |
| Furrow visual | `AreaCraft.spawn_crop_rows` | Keep as soil; **extend or sibling** spawn for plant stage sprites — do not overload furrow texture as plant. |
| Dirt query | `dirt_mask` / `is_dirt` | Phase0 plantable = **dirt bed cells** (override or wrap `is_plantable`, which currently excludes dirt). |
| Interact | `InteractableHotspot` / `DistrictInteractKit` | Per-tile or per-plot hotspot: Empty→Plant (debug), Planted→Water, Ripe→Harvest. |
| Env | `DayNightWeather.attach_to` already on `farmland_controller` / `farm_residential_controller` | Listen `state_changed` for morning tick + rain auto-water. |
| NPC sow ring | `NpcRoutineRings` `sow` | Flavor only; must not mutate crop state unless explicitly designed. |
| Inventory | Spine A `InventoryService` | Sole harvest sink. |
| Art pipeline | `painting-asset-craft` + new paths e.g. `assets/sprites/crops/turnip/stage_0X.png` | 4 frames; nearest filter; ~1 tile tall. |

---

## 5. Ubiquitous language (Dream)

| Term | Meaning |
| --- | --- |
| Plot | One dirt tile (or 1×1 cell) that can hold a crop instance |
| CropInstance | `{ crop_id, stage, days_in_stage, watered }` |
| MorningTick | Growth evaluation when night→day (or debug Advance Day) |
| Water | Player (or rain) sets `watered` for the current day |
| Harvest | Ripe → inventory add → clear instance (furrow remains) |
| Furrow | Soil graphic only — never the plant |

---

## 6. Phase0 acceptance checklist

- [ ] Exactly **3–5** gameplay plots on `farmland` and/or `farm_residential` dirt.  
- [ ] **≥3** distinct **plant** stage sprites (new assets); furrows not used as plants.  
- [ ] Plant → Water → MorningTick×N → Ripe visible without cheating stages in editor-only.  
- [ ] Unwatered morning tick **does not** advance stage.  
- [ ] `WeatherKind.RAIN` counts as watered for that day / tick.  
- [ ] Harvest calls **Inventory** `try_add` with `crop_turnip` (or documented id); count persists across scene change if Inventory is Autoload.  
- [ ] No ColorRect crop plants; QA placeholder gates still green.  
- [ ] User local Godot QA: water + day advance + harvest feel (agent MCP smoke optional, does not close §7).

---

## 7. 禁止偷懒

1. **禁止** 用 `furrow_line_00` / ColorRect / 调色 dirt 冒充作物植株。  
2. **禁止** 只做 InfoPanel「已浇水/已收获」文案，不改 sprite stage、不进 Inventory。  
3. **禁止** 把整张 farmland 8 畦全部做成可种（Phase0 仅 3–5 tile）。  
4. **禁止** 跳过浇水门控（一键从种子跳到成熟）。  
5. **禁止** 把 QA `qa_interact_sprite_inventory` 当成 gameplay 背包。  
6. **禁止** 在未约定的情况下改写全部 `spawn_crop_rows` 装饰床为模拟田。  
7. **禁止** 依赖不存在的日历 Autoload 而不接线现有 `DayNightWeather.state_changed`（或显式 Advance Day）。  
8. **禁止** 复用旧 B12 整图当单阶段“糊上去”而不做 ≥3 stage 可读差异。  
9. **禁止** 只写研究 MD 却在 PR 里夹带半成品 GDScript 又不达本 acceptance（本文件本身 **仅研究**；实现另开任务）。  
10. **禁止** 收获后物品只存在于场景节点变量（换图丢失）——必须走 Spine A Inventory 方向。

---

## 8. Source index

| Topic | URL |
| --- | --- |
| Stardew crops overview | https://stardewvalleywiki.com/Crops |
| Stardew crop data / DaysInPhase | https://stardewvalleywiki.com/Modding:Crop_data |
| Stardew watering | https://stardewvalleywiki.com/Watering_Cans |
| Stardew potato stages | https://stardewvalleywiki.com/Potato |
| Stardew parsnip (tutorial) | https://stardewvalleywiki.com/Parsnip |
| Stardew inventory | https://stardewvalleywiki.com/Inventory |
| Coral Island crop rules | https://coralisland.fandom.com/wiki/Crop |
| Coral Island plant types | https://coralisland.fandom.com/wiki/All_plant |
| Coral Island turnip | https://coralisland.fandom.com/wiki/Turnip |
| Coral Island potato | https://coralisland.fandom.com/wiki/Potato |
| Coral Island spring list | https://coralisland.fandom.com/wiki/Spring |
| SoS:FoMT growing intro | https://fogu.com/sos3/farm/ |
| SoS:FoMT spring crops (turnip/potato) | https://fogu.com/sos3/farm/spring_crops.html |
| SoS:FoMT summer stage example | https://fogu.com/sos3/farm/summer_crops.html |

**Dream internal:** `docs/ENV_H.md`, `docs/research/PLAYER_SPINE_A_RESEARCH.md`, `scripts/areas/area_craft.gd` (`spawn_crop_rows`), `scripts/areas/farmland_assembler.gd`, `scripts/env/day_night_weather.gd`.
