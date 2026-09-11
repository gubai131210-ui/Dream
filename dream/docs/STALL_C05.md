# Stall C05 — market stall state machine

**Status:** IN PROGRESS  
**Date:** 2026-09-11  
**Locks:** [`PHASE5.md`](PHASE5.md), [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md), [`MARKET_POLISH.md`](MARKET_POLISH.md), [`PROP_ORIENTATION.md`](PROP_ORIENTATION.md)  
**Research:** [`research/STALL_C05_RESEARCH.md`](research/STALL_C05_RESEARCH.md) (agent), Nerupa open/closed stall variants, Stardew festival slot occupancy

## Goal

Same alcove slot cycles through **6 states** without moving world position:

`empty | locked | setup | open | sold_out | closed`

Acceptance: ≥3 states demonstrable on A10 (`PHASE5` item 2).

## Visual grammar (same slot)

| State | Awning | Goods | Extra |
| --- | --- | --- | --- |
| `empty` | none / faint pole stubs | none | ground bay only |
| `locked` | none | none | boarded panel + lock cue |
| `setup` | half / low opacity stripes | 1 crate mid-place | poles up |
| `open` | full striped awning | crate + barrel beside (not in front) | hotspot 营业 |
| `sold_out` | full but dull | empty crate only | 「售罄」chip |
| `closed` | collapsed cloth strip | none | poles remain |

Goods scale ≤0.50; never block awning face (`MARKET_POLISH`).

## Code ownership

| Piece | Path |
| --- | --- |
| Stall node | `scripts/market/market_stall.gd` |
| Spawn / initial states | `scripts/areas/market_street_dressing.gd` |
| Click → cycle + InfoPanel | `scripts/areas/market_street_controller.gd` |

## Asset audit (market street — name ≠ content)

| File used as | Title in dressing | Actual visual | Action |
| --- | --- | --- | --- |
| `lamp_1.png` | ~~东街灯~~ | **花盆** | **DONE** → `B11-08_pots_lamps_03` |
| `lamp_2.png` | ~~南口灯~~ / 街角花箱 | **木花箱** | **DONE** → 真灯 + 花箱改标题 |
| `lamp_0.png` | 西街灯 | 真路灯柱 | OK |
| `barrel_0.png` | 南摊货 | 横酒桶+龙头 | OK specialty；标题须 酒桶 |
| B09 切片 | 四柱摊 | `sprites/market/stall_open_*` | **DONE** OPEN/CLOSED 可用 |
| 程序化 ColorRect 棚 | 兜底 | 非 PNG | locked/setup/empty 仍可用 |

详见 [`MARKET_STALL_ASSET_AUDIT.md`](MARKET_STALL_ASSET_AUDIT.md)。[QA Stall-C05](e4ac8b0f-78b3-4e0a-8b09-b50def9b6585): **PASS**。

## 禁止偷懒

- 禁止六摊永远 `open`  
- 禁止换状态时改 `position`（必须同槽）  
- 禁止大 `sack_0` / scale=1 挡门脸  
- 禁止 `lamp_1`/`lamp_2` 继续冒充路灯  
- 禁止只改 InfoPanel 文案、视觉不换  
- 禁止复制室内 `InteriorCraft` 当室外摊  

## Demo

- 六摊初始态打散（至少含 open / locked / sold_out）  
- 点击摊位：InfoPanel 显示状态 + **循环下一态**  
