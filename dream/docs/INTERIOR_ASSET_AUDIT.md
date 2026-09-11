# Interior asset naming audit (filename ≠ visual)

**Status:** BLOCKER before Phase 5 Wave A remainder (Stall-C05…)  
**Date:** 2026-09-11  
**Method:** Multi-agent Read of gameplay PNGs vs `interior_profiles.gd` + titles  
**Agents:** [Asset naming audit](52b9262b-583e-407b-afa0-b6ba6c4ed915) · [Next-phase docs](c50cca65-b08a-49d8-866b-63fdbd984cde) · [Next-layer research](ee18a4c7-c126-44cb-be01-7d02f0f65065)  
**Related:** [`PHASE5.md`](PHASE5.md), [`INTERIOR_COMPOSITION.md`](INTERIOR_COMPOSITION.md), [`research/INTERIOR_NEXT_LAYER_RESEARCH.md`](research/INTERIOR_NEXT_LAYER_RESEARCH.md)

## Verdict

**多数室内 specialty 道具文件名与画面错位。**  
路径几乎都存在（0 missing Resource），但 **代码以为在用 X，实际渲染的是 Y**。  
文档下一阶段是 **继续 Wave A 余下包（先 Stall-C05）**，不是另起 Wave B——但 **P0 remap 必须先过闸**。

**结论：先 remap（优先）+ 只重生缺口，再开 Stall-C05。**

## Critical mismatches (used in profiles)

| Filename (code uses) | Title in profile | Actual visual | Severity |
| --- | --- | --- | --- |
| `counter_00.png` | 柜台 | 药罐/调料架（竖柜） | **P0** 店没柜台 |
| `shelf_grocery_00.png` | 货架 | **圆桌** | **P0** |
| `trough_00.png` | 食槽/水槽 | **蔬菜篮** | **P0** |
| `nest_00.png` | 巢箱 | **书桌+羽毛笔** | **P0** |
| `hay_00.png` | 干草 | **红十字急救箱** | **P0** |
| `roost_00.png` | 栖木 | **开盖金币箱** | **P0** |
| `basket_00.png` | 菜筐 | **木凳** | **P0** |
| `dresser_00.png` | 衣柜 | **单人床** | **P0** ↔ bed_single |
| `bed_single_00.png` | 单人床 | **三屉衣柜** | **P0** ↔ dresser |
| `notice_00.png` | 告示板 | **干草捆** | **P0** 真 hay |
| `mug_shelf_00.png` | 杯架 | **T 形立柱**（可当栖木候选） | **P1** |
| `medicine_00.png` | 药箱 | **工具挂架（锤钳）** | **P1** |
| `coin_chest_00.png` | 钱箱 | **放三杯的小桌** | **P1** |
| `ledger_00.png` | 账桌 | **告示板** | **P1** |
| `tool_rack_00.png` | 工具架 | **带龙头/杯的柜台** | **P1** 可暂代店柜 |
| `rocking_00.png` | 摇椅 | **凳**（无摇椅形） | **P1** 需重生 |
| `table_dining_00.png` | 饭桌 | 桌+椅合成块 | **P2** |

## Outdoor used indoors

| Path | Visual | Issue |
| --- | --- | --- |
| `barrel_0` / `barrel_1` | keg / upright barrel | OK；「水桶」语义偏桶非专用 |
| `crate_*` / `sack_*` | match | OK |
| `lamp_0` | 室外灯柱+草 | 室内壁灯违和 → 建议室内灯变体 |
| `lamp_1` | **花盆** | **P0** 不能当「台灯」 |

## Mostly OK (keep)

`fireplace_00`, `forge_00`, `stove_00`, `bar_00`, `anvil_00`, `shelf_00`, `table_round_00`, `stool_00`, `bed_double_00`, `herbs_00`

## Orphans / duplicates

| File | Notes |
| --- | --- |
| `stool_bar_00` | 画面=巢箱+蛋 → remap 源 |
| `table_pub_00` | 画面=水槽 → remap 源 |
| `shelf_pantry_00` / `extra_10` | **字节级** = `shelf_00` |
| `table_indoor_00` | **字节级** = `table_dining_00` |

## Likely swap map (rename first, regenerate gaps)

```text
stool_bar_00          → nest_00
table_pub_00          → trough_00
notice_00             → hay_00
hay_00                → medicine_00
medicine_00           → tool_rack_00
tool_rack_00          → counter_00 (shop short counter)
counter_00            → shelf family / archive
shelf_grocery_00      → archive (round table dup) OR table_round_alt
trough_00             → basket_00
basket_00             → stool family
roost_00              → coin_chest_00
coin_chest_00         → mug_shelf_00
mug_shelf_00          → roost_00 (T-post perch) OR coat_rack
nest_00               → ledger_00 (writing desk)
ledger_00             → notice_00
dresser_00            ↔ bed_single_00
```

**仍缺 / 建议重生（remap 后）：**

1. 真·多层杂货货架（非药罐柜）  
2. 真·摇椅  
3. 室内壁灯 / 台灯（替换 lamp_0 草柱、lamp_1 花盆）  
4. 可选：更长杂货柜台（若 `tool_rack`→counter 不够长）  
5. 可选：光桌（无烤进椅子）替换 `table_dining`  

## Gate before Stall-C05

`PHASE5.md` 余下包顺序：Stall → Fish → Mine → Well → Lighthouse → Forest → Env-H。  
**追加：** 本审计 P0 remap（+ lamp_1）通过「文件名=画面」抽检后，才开 C05。

## 禁止偷懒

- 禁止只改中文 title 不改文件/路径  
- 禁止未看图就整批重生  
- 禁止把 `extra_10` 当新内容  
- 禁止 Wave A 余下包与 remap 抢路径未文档化  
- 禁止跳过 P0（巢/槽/草/柜台/床柜对调/台灯）直接做摊位状态机  

## Apply order (await user confirm)

1. **Asset-Remap** — swap map + 更新 profiles 常量  
2. **Gap-Gen** — 仅缺口：grocery shelf / rocking / indoor lamps  
3. **QA-Visual** — 逐文件核对 + `qa_interior_prop_quality.py`  
4. **Stall-C05** — 用户确认 C01–C04 观感后再开  
