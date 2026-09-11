# Interior territory grammar（领地 / 围合 / 体量）

**Status:** ACTIVE — Wave B 空间可读性  
**Date:** 2026-09-11  
**Locks:** [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`INTERIOR_ROOM_BRIEFS.md`](./INTERIOR_ROOM_BRIEFS.md)  
**Skill:** [`.cursor/skills/interior-territory-craft/SKILL.md`](../.cursor/skills/interior-territory-craft/SKILL.md)  
**Acceptance (after every change):** [`.cursor/skills/interior-visual-qa/SKILL.md`](../.cursor/skills/interior-visual-qa/SKILL.md)  

## 问题诊断

功能簇做对后，玩家仍觉「科学感知怪」：  
不是单纯数量少，而是 **缺领地边界（enclosure）与库存体量（mass）**。  
鸡在空房啄食 ≠ 鸡圈；干草旁站牛 ≠ 畜栏；两个粮袋 ≠ 存粮区。

设计理念确认：室内是 **可逛真场景**（非点门只弹 InfoPanel）；点物件只补文案，**不负责补空间逻辑**。

## 三层语法（强制）

| 层 | 含义 | 实现 |
| --- | --- | --- |
| **Cluster** | 一簇一事（已有） | `clusters` |
| **Boundary** | 区界可读：栏/半墙/围笔 | `rails` / `enclosures` |
| **Mass** | 垂直/重复堆叠读「库存」 | `grain_stack` / `hay_stack` / 货箱叠偏移 |

优先顺序：**区界 → 体量 → 再微调数量**。禁止为「显得满」均匀撒点。

## Profile schema 扩展

```text
rails: [
  { axis: "v"|"h", tx|ty, a0, a1, step?:1, prop, scale?:1, title, desc }
]
enclosures: [
  {
    rect:[x0,y0,x1,y1], prop_h, prop_v,
    corners:{nw,ne,sw,se},
    scale?:1, title, desc, gaps:[[tx,ty],...]
  }
]
```

- `rails`：畜栏隔栏；`axis=h`→正视，`axis=v`→侧视  
- `enclosures`：南北 `prop_h`、东西 `prop_v`、四角 `corners`；`gaps` 南门  
- Craft：先角后边，避免硬接留洞  

## Wave B 房间清单

| profile | Boundary | Mass |
| --- | --- | --- |
| `c03_barn` | 左右 stall enclosure + 四角（过道 gaps） | 北 `grain_stack` + 栏后 `hay_stack` |
| `c03_coop` | 满间笔 + 四角 + 南 gaps | 巢/槽/栖木铺开 |
| `c02_farmer` | — | 门厅 `grain_stack` |
| `c02_merchant` | — | `cargo` 货箱叠高偏移 |
| `c04_grocery` | — | 货架层 + 米垛 |
| `c04_smith` / `c04_tavern` | — | 废料/酒桶叠 |

## 资产

| 文件 | 用途 |
| --- | --- |
| `stall_rail_00.png` / `stall_rail_v_00.png` | 畜栏隔栏（同套板条） |
| `pen_fence_00.png` / `pen_fence_v_00.png` | 鸡栏正视/侧视（同套板条） |
| `pen_corner_{nw,ne,sw,se}_00.png` | 鸡栏四角 |
| `grain_stack_00.png` / `hay_stack_00.png` | 粮垛 / 干草垛 |

生成：`tools/gen_interior_territory_props.py`

## Scene-fit variants（种类适配）

同一功能类（灯 / 凳 / 箱）在不同房间必须用 **场景变体**，不是复用家用件。

| 场景 | 灯 | 禁止 |
| --- | --- | --- |
| 住宅 / 老人宅 / 商贾 / 铁匠宅 | `lamp_indoor_00` 家用台灯/壁灯 | 铁壳仓灯 / 锻工灯 |
| 鸡舍 / 谷仓 | `lamp_farm_00` 铁壳吊油灯 | 布罩家用台灯 |
| 杂货店 | `lamp_shop_00` 吊罩店灯 | 家用台灯 |
| 铁匠铺 | `lamp_smith_00` 锻工铁壁灯 | 家用台灯 |
| 酒馆 | `lamp_tavern_00` 烛灯 | 家用台灯 |

规则：功能对 ≠ 产品对。需要时 **自画变体**（`install_scene_fit_*.py` / GenerateImage）。全房间铺开见 [`INTERIOR_WAVE_C.md`](./INTERIOR_WAVE_C.md)。

## Fence family lock

| Rule | Why |
| --- | --- |
| **H / V = 同一栅栏两视角** | 同板条数/厚度/木色；禁止正视竖条、侧视横梯混用 |
| **四角专用 `corners`** | nw/ne/sw/se 转角件，禁止 H∩V 硬接留洞 |
| **32px 瓦片 + step=1 + scale=1** | 段间接缝 |
| **只有 `gaps` 允许开口** | 南门；别处禁止空隙 |
| **鸡舍笔区铺满可用面积** | 禁止房间中央小圈、四周空地 |

生成：`tools/gen_interior_territory_props.py`（含 `_diag_pen_family.png`）

## 禁止偷懒

- 禁止只用干草/食槽**语义暗示**畜栏、却不画隔栏  
- 禁止鸡 ambient 在无围栏空地上当「鸡圈」交差  
- 禁止两个平铺粮袋冒充「存粮区」  
- 禁止为填空在通廊撒箱  
- 禁止围栏堵死南门  
- 禁止只改文案不改 `rails`/`enclosures`  
- 禁止正视/侧视做成两套不同栅栏  
- 禁止 step>1 或旧 V 资产残留（重生时必须覆盖 `*_v_00.png`）  
- 禁止无四角拐角硬拼  
- 禁止鸡舍小笔四周大片空地  
- 禁止家用台灯出现在鸡舍/谷仓（必须用农场灯变体）  
- 禁止「功能同类」就复用同一 PNG 跨场景  

## Related

- Composition clusters: [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md)  
- Room briefs: [`INTERIOR_ROOM_BRIEFS.md`](./INTERIOR_ROOM_BRIEFS.md)  
- Code: `interior_craft.gd`, `interior_profiles.gd`  
