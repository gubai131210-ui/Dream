# Interior Wave C — scene-fit + territory rollup

**Status:** SHIPPED 2026-09-11  
**Locks:** [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`.cursor/skills/interior-territory-craft/SKILL.md`](../.cursor/skills/interior-territory-craft/SKILL.md)  
**Post-change QA:** [`.cursor/skills/interior-visual-qa/SKILL.md`](../.cursor/skills/interior-visual-qa/SKILL.md) — Place/Art/Assembly/Meta 全闸（区界·构成·Y-sort·通廊·工艺·成套·接线）  

## Goal

把鸡舍迭代沉淀的规则铺到 **全部 Wave A 室内**：区界/体量 + **场景种类适配**（功能对 ≠ 产品对）。

## Lamp matrix（强制）

| Profile | Lamp asset | 禁止 |
| --- | --- | --- |
| `c01_home` / `c02_elder` / `c02_farmer` / `c02_merchant` / `c02_blacksmith_home` | `lamp_indoor_00` | 仓灯/锻工灯 |
| `c03_barn` / `c03_coop` | `lamp_farm_00` | 家用台灯 |
| `c04_grocery` | `lamp_shop_00` | 家用台灯 |
| `c04_smith` | `lamp_smith_00` | 家用台灯 |
| `c04_tavern` | `lamp_tavern_00` | 家用台灯 |

## Territory rollup

| Profile | Boundary | Mass |
| --- | --- | --- |
| `c01_home` | — | 厨区加储物架+米袋 |
| `c02_farmer` | — | 门厅粮垛（既有） |
| `c02_merchant` | — | 货箱叠高（既有） |
| `c03_barn` | 左右 stall **enclosure + 四角**（过道开口） | 粮垛/草垛 |
| `c03_coop` | 满间笔 + 四角（既有） | 巢/栖铺开 |
| `c04_grocery` | — | 货架层+米垛+多筐 |
| `c04_smith` | — | 废料箱叠 |
| `c04_tavern` | — | 吧后酒桶/酒窖箱叠 |

## Tools

- `tools/install_scene_fit_props.py` — farm lamp + pen corners  
- `tools/install_scene_fit_wave_c.py` — shop/smith/tavern lamps + stall corners  
- `tools/gen_interior_territory_props.py` — fence/mass family  

## 禁止偷懒

- 禁止跨场景复用同一灯 PNG  
- 禁止谷仓只有直线隔栏、无四角 enclosure  
- 禁止杂货/酒馆/铁匠仍挂 `lamp_indoor_00`  
- 禁止只改文案不改 profile/资产  
