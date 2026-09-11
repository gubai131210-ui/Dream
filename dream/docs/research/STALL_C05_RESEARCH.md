# Research: Stall C05 multi-state market stalls

**Date:** 2026-09-11  
**Brief:** [`../STALL_C05.md`](../STALL_C05.md) · Audit: [`../MARKET_STALL_ASSET_AUDIT.md`](../MARKET_STALL_ASSET_AUDIT.md)

## Findings (primary / high-trust)

| Source | Takeaway |
| --- | --- |
| [Stardew Modding: Festival data](https://stardewvalleywiki.com/Modding:Festival_data) | Festival **slots** are fixed map positions; shop open/stock is data, not a 6-frame atlas FSM |
| [Nerupa Shop Bundle](https://nerupastudios.itch.io/shop-bundle) | Ships **open/closed** stall variants on shared footprint |
| [Starbird Outdoor Market](https://www.deviantart.com/starbirdresources/art/Outdoor-Market-Tileset-RMMV-710607926) | Outdoor market tile vocabulary (alcove + goods) |
| RPG Maker event pages (industry pattern) | One event slot; **highest matching page graphic** = FSM |
| SoS / bazaar-likes (secondary) | Pad → setup → sell → sold-out → close on a schedule |

## Filename pitfalls

- `awning_*` that bakes full goods → cannot sold_out cleanly  
- `crate_*` that is actually stall face / chest / lumber (Dream B11-02)  
- `lamp_*` that is a flower pot (Dream lamp_1/2)  
- Vendor baked into PNG → hard to empty/closed  

## Apply to Dream C05

1. Fixed alcove `position`; swap Structure / Awning / Goods / Sign layers (`MarketStall`)  
2. Demo ≥3 states; six enums: empty|locked|setup|open|sold_out|closed  
3. Prefer sliced `raw/B09-04_awnings.png` over forever ColorRect  
4. Open 蔬果货用 `B11-02_crates_boxes_06`（蔬果箱），勿用 `_04` 木板面  

## 禁止偷懒

- 禁止六摊永远 open  
- 禁止换态挪坐标  
- 禁止花盆冒充路灯  
- 禁止 `_04` 木板冒充蔬果  
- 禁止无视 B09 真棚只交 ColorRect  
