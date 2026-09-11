# Market stall / street asset audit

**Status:** ACTIVE — post C05 code; art follow-up  
**Date:** 2026-09-11  
**Agents:** [Market stall assets](34e4ebc1-5f22-4118-9977-5e8b1f7b2024) · [Stall research](cf2510a6-7892-4a78-a15a-8f05e2c6fb90)  
**Related:** [`STALL_C05.md`](STALL_C05.md), [`MARKET_POLISH.md`](MARKET_POLISH.md), [`PROP_ORIENTATION.md`](PROP_ORIENTATION.md)

## Verdict

C05 **状态机已进 A10**（程序化棚 + 换货）。  
真棚摊图在 **`assets/raw/B09-04_awnings.png`（未切片）**；B11 箱货多名实不符。灯具 P0 已在 dressing 改线。

## Name ≠ content

### Lamps (P0 — dressing fixed)

| Path | Was used as | Visual | Status |
| --- | --- | --- | --- |
| `lamp_1.png` | 东街灯 | 花盆 | 已改用 `B11-08_pots_lamps_03` |
| `lamp_2.png` | 南口灯 | 花箱 | 已改用真灯；原图改标花箱 |
| `lamp_0.png` | 西街灯 | 路灯 | OK |

### B11-02 crates (P1)

| Path | Named | Visual | Use for C05 |
| --- | --- | --- | --- |
| `_03` | crate | 空 stall/bin 底座 | empty / locked base |
| `_04` | crate | **木板柜台/摊面**（曾当蔬果货） | stall_face，勿当蔬果 |
| `_05` | crate | 宝箱 | 勿当摊货 |
| `_06` | crate | **蔬果满箱** | open 蔬果摊首选 |
| `_08` | crate | 纸箱 | 风格冲突，慎用 |
| `_10/_11` | crate | 木板材 | setup 用，勿当货箱 |

### Raw gold

| Path | Visual | Gap |
| --- | --- | --- |
| `raw/B09-04_awnings.png` | 完整四柱摊 + 墙棚 + 落帘/卷棚 | 切到 `sprites/market/` |

## Fix order (remaining)

1. ~~路灯名实~~ DONE  
2. ~~C05 六态同槽机~~ DONE  
3. ~~蔬果摊改 `_06`~~ + **B09 切片进 `sprites/market/`**，OPEN/CLOSED 可用真棚体  
4. Remap B11-02 常量名（stall_face / produce_crate / lumber）  
5. 可选：空摊/锁定专用 B09 变体，减少 ColorRect 残留  

## 禁止偷懒

- 禁止继续用 `_04` 木板冒充蔬果货  
- 禁止无视 B09 真棚只堆 ColorRect  
- 禁止花盆冒充路灯  
- 禁止六摊永远 open  
