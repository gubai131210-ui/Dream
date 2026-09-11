# Research notes: Stall C05 (supplement)

**Date:** 2026-09-11  
**Full brief:** [`../STALL_C05.md`](../STALL_C05.md)

## Findings (web)

| Source | Takeaway |
| --- | --- |
| [Nerupa Shop Bundle](https://nerupastudios.itch.io/shop-bundle) | Ships **open/closed** stall variants on shared footprint |
| [Starbird Outdoor Market](https://www.deviantart.com/starbirdresources/art/Outdoor-Market-Tileset-RMMV-710607926) | Market tiles expand alcove/goods vocabulary; same-slot mapping |
| [Stardew Modding: Festival data](https://stardewvalleywiki.com/Modding:Festival_data) | Festival vendor **slots** are fixed positions; occupancy ≠ 6-state art machine |
| Dream `MARKET_POLISH.md` | Goods ≤0.5 scale; never block awning face |

## Apply to Dream

Wave A C05 uses **procedural awning + prop swap** (no licensed RTP). Six states on `MarketStall` same `position`. Fix `lamp_1`/`lamp_2` mislabeled as lights before polish art.

## 禁止偷懒

- 禁止六摊永远 open  
- 禁止换态挪坐标  
- 禁止花盆冒充路灯  
