# Market stall / street asset audit

**Status:** ACTIVE — C05 gate  
**Date:** 2026-09-11  
**Related:** [`STALL_C05.md`](STALL_C05.md), [`MARKET_POLISH.md`](MARKET_POLISH.md), [`PROP_ORIENTATION.md`](PROP_ORIENTATION.md)

## Verdict

无专用 `stall_*.png` / `awning_*.png`；现摊位 = **程序化棚布 + B11 箱桶**。  
室外 **灯具命名错位** 比摊位缺图更急：`lamp_1`/`lamp_2` 不是灯。

## Name ≠ content (verified Read)

| Path | Used as | Visual | Severity |
| --- | --- | --- | --- |
| `props/lamp_1.png` | 东街灯 | 陶瓷花盆+花 | **P0** |
| `props/lamp_2.png` | 南口灯 | 木花箱 | **P0** |
| `props/lamp_0.png` | 西街灯 | 木杆路灯 | OK |
| `B11-08_pots_lamps_00.png` | （未接市集） | 灯柱 | 可用真灯 |
| `B11-08_pots_lamps_03.png` | （未接） | 弯臂灯柱 | 可用真灯 |
| `B11-08_pots_lamps_06.png` | （未接） | 铁杆街灯 | 可用真灯 |
| `barrel_0.png` | 南摊 | 横酒桶 | OK specialty |
| `B11-02_crates_boxes_*` | 摊货 | 木箱 | OK（小 scale） |

## Online / industry note

RPG Maker market packs (Starbird outdoor market, Nerupa shop bundle) ship **open/closed stall variants** as separate tiles on the **same footprint** — validates C05 same-slot swap. Dream Wave A uses procedural awning + goods layers instead of licensed RTP sheets.

Sources: [Nerupa Shop Bundle](https://nerupastudios.itch.io/shop-bundle) (open/closed), [Starbird Outdoor Market](https://www.deviantart.com/starbirdresources/art/Outdoor-Market-Tileset-RMMV-710607926), [Stardew Festival data](https://stardewvalleywiki.com/Modding:Festival_data) (slot occupancy ≠ 6-state art, but fixed vendor slots).

## Fix order

1. Remap market street lamps to real lamp PNGs  
2. Ship C05 state machine on existing awning/goods  
3. Optional later: painted awning PNG sheet  

## 禁止偷懒

- 禁止不看图把 `lamp_1` 当灯  
- 禁止为交差生成整张市集 atlas 却不修灯  
- 禁止 C05 只写枚举不换 Visual 子节点  
