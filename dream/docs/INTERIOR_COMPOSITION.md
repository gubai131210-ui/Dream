# Interior composition (摆放构成)

**Status:** ACTIVE — 布局第二关（道具已过质量闸后）  
**Date:** 2026-09-11  
**Locks:** `INTERIOR_ROOM_BRIEFS.md`, `INTERIOR_FOUNDATION.md`, `INTERIOR_DIAGNOSIS.md`

## 问题诊断

玩家观感「一堆物品像垃圾扔满地」= **缺少功能簇（functional clusters）**：  
相关物没有相邻、没有朝向对位、NPC 路线不访问工作点。美术修好后，布局仍像随机撒点。

## 调研结论（游戏 + 室内设计）

| 来源 | 规则 | 应用到 Dream |
| --- | --- | --- |
| RPG Maker「Clumpings」 | 小道具成坨贴桌/厨台，不单件散落 | `clusters.members` 相对偏移 ≤2–3 格 |
| RPG Maker Interior tutorial | 店：柜台隔顾客/店主；床不进营业厅 | 杂货南柜北主；宅/店分区 |
| Stardew 宅内实践 | 先定房间用途，用地毯定义区 | `rug` 锚在对话/用餐簇下 |
| Emily Henderson 客厅 | 座位间距约交谈距离；茶几在膝前 | 凳/椅围桌或围炉，间距 1–2 格 |
| NKBA 厨房工作三角 | 灶–洗涤/储物–备餐短距，主通道不穿三角 | 灶+厨架+水桶同簇，中轴通廊空出 |
| 空间规划焦点 | 大件锚点 + 负空间；勿全贴墙一圈 | 壁炉/柜台/床为锚；留 2 格通廊 |
| Smart Object / NPC | 家具提供使用点，NPC 去工作点 | `actor.route` 走簇锚点，不画空矩形 |

## 构成语法（强制）

1. **一簇一事**：每个 `cluster` 只表达一个行为（烤火、做饭、用餐、睡觉、结账、锻打、饮酒…）。  
2. **锚 + 卫星**：先放锚点大件，卫星相对 `dx/dy` 贴靠（典型 |d|≤3）。  
3. **对位**：凳面对桌子/壁炉；店主在柜台北，顾客在南；畜栏食槽朝过道。  
4. **通廊**：南门到北墙至少 2 格宽空带，禁止簇堵门。  
5. **人–物**：`actor.route` 必须经过 ≥2 个簇锚点（老人可茶区↔床）。  
6. **动物**：ambient 落在相关簇旁（猫在壁炉簇，狗在门厅簇，鸡在巢箱旁）。  
7. **地毯**：只铺在对话/用餐/店前停步区，不铺空地。

## 房间簇清单（Wave A）

| profile | 必有簇 |
| --- | --- |
| `c01_home` | `kitchen` · `hearth_talk` · `sleep` · 门厅可并入 kitchen 边缘 |
| `c02_elder` | `tea` · `sleep`（极简） |
| `c02_farmer` | `mudroom` · `dining` · `sleep` |
| `c02_merchant` | `ledger` · `cargo` · `sleep` |
| `c02_blacksmith_home` | `home_tools` · `living` · `sleep` |
| `c03_barn` | `stall_w` · `stall_e` · `aisle_feed` |
| `c03_coop` | `nests` · `feed` · `roost` |
| `c04_grocery` | `shelf_w` · `shelf_e` · `counter`（含筐贴柜） |
| `c04_smith` | `forge` · `anvil_quench` · `wait` |
| `c04_tavern` | `bar` · `party_a` · `party_b` · `hearth` |

## Profile schema

```text
clusters: [
  { id, anchor:[tx,ty], members:[ {path, dx, dy, scale?, title, desc} ] }
]
actor.route: [[tx,ty], ...]  # 优先取各簇 anchor / 使用点
ambient: [{species, cluster, dx?, dy?}] 或显式 tx/ty 贴簇
rug: 对齐 hearth_talk / dining / counter 前
```

实现：`InteriorCraft` 展开 `anchor+(dx,dy)`；无 `clusters` 时回退旧 `props`。

## 禁止偷懒

- 禁止把道具按房间均匀撒点（「填空」）  
- 禁止凳离桌/炉 ≥4 格还叫用餐/烤火  
- 禁止 NPC 只绕空地矩形、从不靠近工作点  
- 禁止店床同厅、谷仓无过道畜栏对  
- 禁止只改标题不改 `clusters`  

## Related

- Research: RPG Maker Clumpings / Interior mapping · Emily Henderson living rules · NKBA kitchen triangle · Smart objects  
- Code: `interior_profiles.gd`, `interior_craft.gd`  
- **Territory (区界/体量):** [`INTERIOR_TERRITORY.md`](./INTERIOR_TERRITORY.md) — rails / enclosures / grain stacks after clusters  

