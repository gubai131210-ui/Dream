# Interior territory grammar（领地 / 围合 / 体量）

**Status:** ACTIVE — Wave B 空间可读性  
**Date:** 2026-09-11  
**Locks:** [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`INTERIOR_ROOM_BRIEFS.md`](./INTERIOR_ROOM_BRIEFS.md)  
**Skill:** [`.cursor/skills/interior-territory-craft/SKILL.md`](../.cursor/skills/interior-territory-craft/SKILL.md)

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
  { rect:[x0,y0,x1,y1], prop_h, prop_v, scale?:1, title, desc, gaps:[[tx,ty],...] }
]
```

- `rails`：畜栏朝过道的隔栏线（谷仓）；`axis=h`→正视，`axis=v`→侧视  
- `enclosures`：南北 `prop_h`、东西 `prop_v`；`gaps` 南门开口  
- Craft：`InteriorCraft._spawn_territory` / `_spawn_fence_segment`  

## Wave B 房间清单

| profile | Boundary | Mass |
| --- | --- | --- |
| `c03_barn` | 东西 `rails` 划 stall / aisle | 北 `grain_stack` + 栏后 `hay_stack` |
| `c03_coop` | `enclosures` 低鸡栏 + 南 gaps | （笔内既有巢/槽即可） |
| `c02_farmer` | — | 门厅 `grain_stack` |
| `c02_merchant` | — | `cargo` 货箱叠高偏移 |

## 资产

| 文件 | 用途 |
| --- | --- |
| `stall_rail_00.png` / `stall_rail_v_00.png` | 畜栏隔栏 |
| `pen_fence_00.png` | 鸡舍低围栏段 |
| `grain_stack_00.png` | 粮垛体量 |
| `hay_stack_00.png` | 干草垛体量 |

生成：`tools/gen_interior_territory_props.py`

## Fence family lock

| Rule | Why |
| --- | --- |
| **H / V = 同一栅栏两视角** | 正视（rails along X）与侧视（foresorten）共享柱粗、横档数、木色 |
| **32px 瓦片段 + step=1 + scale=1** | 段间接缝；禁止 step=2 留洞 |
| **enclosure 用 `prop_h` + `prop_v`** | 南北正视、东西侧视；禁止四边同一张图 |
| **只有 `gaps` 允许开口** | 南门通道；别处禁止视觉空隙 |

Stall = 三档高栏；Pen = 两档低栏；同家族不同高度。

生成：`tools/gen_interior_territory_props.py`（含 `_diag_fence_h_seamless.png`）

## 禁止偷懒

- 禁止只用干草/食槽**语义暗示**畜栏、却不画隔栏  
- 禁止鸡 ambient 在无围栏空地上当「鸡圈」交差  
- 禁止两个平铺粮袋冒充「存粮区」（必须有垂直堆叠或成排重复）  
- 禁止为填空在通廊撒箱  
- 禁止把边界物做成挡死南门（鸡栏必须 `gaps` 对齐门轴）  
- 禁止只改文案/hint、不改 `rails`/`enclosures`/mass 道具  
- 禁止正视/侧视做成两套不同栅栏设计  
- 禁止 step>1 或 scale<1 造成栏间空洞  

## Related

- Composition clusters: [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md)  
- Room briefs: [`INTERIOR_ROOM_BRIEFS.md`](./INTERIOR_ROOM_BRIEFS.md)  
- Code: `interior_craft.gd`, `interior_profiles.gd`  
