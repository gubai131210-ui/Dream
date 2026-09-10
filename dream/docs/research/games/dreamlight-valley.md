# Disney Dreamlight Valley — Scene Craft Research

**Scope:** environment / village layout / decorate-mode craft only（Plaza·biome 分区、路径与开敞空间、锚点建筑、水体岸线、朝向约束、铺装反单调、官方布局规则）。不含迪士尼 IP 风格、经济循环、角色剧情。  
**Goal:** transferable rules for a Godot 2D/2.5D hub-and-biome village（TileMap layers、placement agents、path paint）。  
**Trust priority:** Gameloft / official patch notes & site quotes → Creative Director interviews → curated wiki topology（交叉验证）→ high-signal community craft only when it documents **engine constraints**.

---

## Techniques

### 1. Plaza / biome / residential-like clusters — 如何分区

**硬拓扑：Plaza 为地理与叙事中心**

| Node | Role | Direct links (base Valley) |
|------|------|----------------------------|
| **Plaza** | Spawn / rebuild hub；**唯一**接 Dream Castle 的 biome | Peaceful Meadow、Sunlit Plateau、Forest of Valor |
| **Peaceful Meadow** | 南侧「二级枢纽」 | Plaza、Glade of Trust、Dazzle Beach、Forest of Valor |
| **Forest of Valor** | 东侧桥接 | Plaza、Peaceful Meadow、Frosted Heights（+ Beach 侧坡道） |
| **Sunlit Plateau** | 西侧草原 | Plaza、Forgotten Lands |
| **Glade of Trust** | 西南沼泽 | Peaceful Meadow、Dazzle Beach |
| **Dazzle Beach** | 南海岸 | Peaceful Meadow、Forest of Valor、Glade of Trust |
| **Frosted Heights** | 东北雪区 | Forest of Valor only |
| **Forgotten Lands** | 西北暗林 | Sunlit Plateau only |

来源：[Plaza wiki](https://dreamlightvalleywiki.com/Plaza)、[Peaceful Meadow](https://dreamlightvalleywiki.com/Peaceful_Meadow)、[Forest of Valor](https://dreamlightvalleywiki.com/Forest_of_Valor)、[Sunlit Plateau](https://dreamlightvalleywiki.com/Sunlit_Plateau)、[Glade of Trust](https://dreamlightvalleywiki.com/Glade_of_Trust)、[Dazzle Beach](https://dreamlightvalleywiki.com/Dazzle_Beach)、[Frosted Heights](https://dreamlightvalleywiki.com/Frosted_Heights)、[Forgotten Lands](https://dreamlightvalleywiki.com/Forgotten_Lands)。

**分区语义（官方宣传口径，craft 可读）**

- **Plaza**：游戏起点；资源/工具/角色开场；「曾经幸福、需重建」的中心开敞区（[NintendoSoup — 官方 biome 预告文案](https://nintendosoup.com/four-disney-dreamlight-valley-biomes-detailed/)）。
- **Peaceful Meadow**：官方 GIF 强调多家 **unique hat-topper 住宅** 落位 → 默认「居住集群」可读性落在 Meadow，而非全部塞进 Plaza。
- **Glade / Beach**：强大气与岸线差异（雾沼 vs 沙滩），用 **palette + 资源 + critter** 锁身份，不是仅换贴图名。
- 每个 biome 有 **Wishing Well**（快旅锚点）；Plaza Well 默认可用，其它需解锁/修复 → 「每区一个 civic 锚点」是地图语法。

**住宅 / 服务建筑如何「成簇」**

- Villager houses：多数可迁到 Valley **任意陆地**；部分 **water-only**（见 §3）。玩家房初始在 Plaza 西北象限，可迁陆地任意处（[Player's House wiki](https://dreamlightvalleywiki.com/Player%27s_House)、[Villagers' Houses wiki](https://dreamlightvalleywiki.com/Villagers%27_Houses)）。
- **固定/准固定 civic anchors**（不可当普通 prop 随意抹掉语义）：Dream Castle、各 biome Wishing Well、Scrooge 店、Chez Remy / Tiana’s Palace、Goofy 等 stalls。Emotional Rescue 起部分 stalls 可放到更多 expansion biomes，但 **放置后不可再移除**（官方补丁：[Emotional Rescue notes via ComicBook 全文转载](https://comicbook.com/gaming/news/disney-dreamlight-valley-ddv-patch-notes-inside-out-emotional-rescue-update/)）。
- **Floating Islands**：与地面 biome **同主题/氛围的平行空白板**（非迷宫）；约 **65×65** decorate squares + Well；经 biome Wells / 地图快旅接入（Creative Director 侧说明：[GameScout / Showcase 转述](https://gamescout.co.uk/2024/11/disney-dreamlight-valley-to-get-floating-islands/)；Sauveur：「clean slate… same theme and ambiance」[Nox / Showcase](https://www.bignox.com/blog/noxplay1730257672vsDFajx3uKWeRcllkfTQs/)）。

**官方 level-design 反思（可直接当布局规则）**

Josh Labelle（Creative Director）对 *A Rift in Time*：Eternity Isle「twists and turns」过多 → **难导航、难 decorate**；未来 biome 要 **simpler / easier to decorate**，并有 **better and more visible landmarks**（[Polygon 访谈](https://www.polygon.com/24214028/disney-dreamlight-valley-tiana-gameloft-montreal-q-a/)）。

**Godot 可落地**

1. 世界图 = **中心 Plaza 节点** + 2–3 级 spoke；外围 leaf biome 只挂一条边（Frosted / Forgotten 模式）。  
2. 每 biome 强制 1 个 **Well/plaza-scale 锚点** + 可选 residential pocket（Meadow 式）。  
3. 迷宫式岔路与 decorate 预算冲突时，优先 **可见地标 + 可铺路径的开敞面**。

---

### 2. 路径宽度、开敞空间、锚点建筑

**路径不是「地板贴花」，是免费连通层**

- Landscaping 含 paths / fencing / underbrush / trees / rocks（[GameRant outdoor guide](https://gamerant.com/disney-dreamlight-valley-ddv-how-decorate-village-outdoor-decor-scenery-guide/)）。
- **Paths & ordinary fences 不计入** Valley item limit（600 unique / 3000 total；可升到 1200 / 6000 on stronger platforms）→ 设计上鼓励用路径做 **大尺度动线与开敞铺装**，用家具/ greenery 做 **密度**（[Item Limit wiki](https://dreamlightvalleywiki.com/Item_Limit)；[GameRant](https://gamerant.com/disney-dreamlight-valley-ddv-how-decorate-village-outdoor-decor-scenery-guide/)）。
- 已达 item limit 时仍可 **延长已有 path/fence**（wiki）→ 路径是「永远可加的骨架」。

**几何与放置工具演进（官方）**

| Era | Rule |
|-----|------|
| 早期 | Path 轴对齐 tile；bordered 与 non-bordered 是 **不同 craft 配方**，不互 overlay（社区验证：2023-06 borders 帖） |
| Lucky Dragon (2024-06) | **Replace all connected** path/fence 样式（库存够时）；controller 更易逐格 cardinal 铺（[官方 Lucky Dragon notes](https://disneydreamlightvalley.com/en/news/update-june-26-2024) / [Destructoid 转载](https://www.destructoid.com/disney-dreamlight-valley-lucky-dragon-patch-notes/)） |
| Sew Delightful (2024-12) | Fix：**non-bordered path 北缘 blunt edge**（[Sew Delightful notes](https://devtrackers.gg/dreamlight-valley/p/eb933bc5-sew-delightful-update-patch-notes)）→ 官方承认路径轮廓方向敏感 |
| Mysteries of Skull Rock (2025) | Paths：**Straight ↔ Diagonal** toggle；Furniture Mode **grid expanded**（[IGN 补丁摘要](https://www.ign.com/wikis/disney-dreamlight-valley/Mysteries_of_Skull_Rock_Update_Patch_Notes)） |
| Emotional Rescue (2025-08) | Fences：**Line ↔ Diagonal**；大物体放置瞄准改进（[ComicBook 全文转载官方 notes](https://comicbook.com/gaming/news/disney-dreamlight-valley-ddv-patch-notes-inside-out-emotional-rescue-update/)） |

**开敞空间与锚点**

- Plaza 默认读作 **大开敞 + Castle/Well 双核**；Castle 紧邻 Well（Plaza wiki）。
- 官方预告刻意拍 Plaza 日落开敞面、Meadow 上多户落位 → **中心广场留空 + 住宅外溢到邻 biome** 是默认构图，不是全塞中心。
- 路径与大型物体：**部分物体不能压在 path 上 / 会裁掉下方 path**（fountain 等）→ 出现锯齿空隙；社区稳定 workaround = **灌木/围栏环遮缝** 或 **接受草缝做坐席带**（[ScreenRant 汇总社区解法](https://screenrant.com/disney-dreamlight-valley-pathway-design-fix/)）。Craft 含义：锚点建筑周围预留 **soft ring**，不要假设 path 可贴齐 footprint。
- 门前 path：社区反复验证需把 path **延伸进建筑 footprint 下方** 才能视觉接到门（引擎不自动对齐门宽）— 记作 **constraint**，非推荐 playbook。

**社区动线启发式（非官方，但与拓扑一致）**

先铺 **入口↔入口** 主干（尤其 Meadow 左右入口经 Plaza 接 Forest / Plateau），再铺 **Castle stairs ↔ Well ↔ Meadow** 中轴，再在开敞处做 fountain/ seating 中心件（[r/DreamlightValley plaza thread](https://www.reddit.com/r/DreamlightValley/comments/16lfn7p/how_did_you_design_your_plaza/)）。

**Godot 可落地**

1. Path 层 **不计入** prop budget；先画 graph：hub spokes → leaf dead-ends。  
2. 主路视觉宽度 ≥ 建筑门廊；次路可变窄；Plaza 留一块 **无建筑 footprint** 的开敞。  
3. 大锚点周围自动留 1 ring **non-path / shrub mask**，避免硬切铺装。  
4. Path 支持 **正交 + 对角/圆角模式**；边沿要做 **方向一致的 lip**（官方修过 north blunt）。

---

### 3. 水体与岸线

**Biome 原生水 = 身份边界，不是全局可挖 heightfield**

- Beach = 海岸；Glade = 沼泽/荷塘氛围；Meadow / Plateau / Frosted = 池塘与溪流渔点；**不可**像 ACNH 那样自由改河道拓扑，decorate 靠 **移动默认植被 + 摆 landscaping 水件**。
- 官方修过「blockers/materials spawn over water surfaces」（Sew Delightful）→ 岸线逻辑上应 **排斥陆地刷怪/障碍**。

**可摆水体家具 / River Kit（模块化岸线）**

- Never Land River Kit 等：Pond、Water Square、Straight Bank、Bank Corner Bridge、Large Water Pool… **模块拼接水道**；标注 placement footprint（例：Never Land Pond **20×20**）（[Never Land Pond wiki](https://dreamlightvalleywiki.com/Never_Land_Pond)）。
- **跨片规则（高置信社区，多次复现）**：水上放置类似柜台 — **物体不能跨多个 water piece**；要放 water house，先放 **最大单片水面**，再围拼河岸（[r/DreamlightValley river kit](https://www.reddit.com/r/DreamlightValley/comments/1rkqt28/water_river_kit/)）。
- Sew Delightful：部分 pond-like 家具（Relaxing Oasis、Watering Hole）开放 **可放 water-based furniture / landscaping 的子区域**（[Sew Delightful notes](https://devtrackers.gg/dreamlight-valley/p/eb933bc5-sew-delightful-update-patch-notes)）。

**Water houses**

- Ariel / Ursula / Donald 等：wiki 分类为 **Water Houses** — 只能落在合格水面上，不能当陆地皮（[Villagers' Houses](https://dreamlightvalleywiki.com/Villagers%27_Houses)）。
- 社区：Meadow 最大塘、Glade 废墟旁大水面是合法自然落点；River Kit 上曾出「放上后搬不走 / 地图图标丢失」类 bug；官方 Emotional Rescue 修过 Floating Island 上 Never Land River Kit 房屋无法移除（ComicBook 转载 notes）→ **水上建筑 = 特殊碰撞域**，测试要单独回归。

**水下 decorate（Keepsake Sea，开发者口述）**

- Labelle / Wignall（MiceChat）：家具模式下 **水下平台可沿指南针平移，且可调海拔** → 首次强调 **垂直轴 decorate**（[MiceChat D23 访谈](https://www.micechat.com/443303-new-disney-dreamlight-valley-the-keepsake-sea/)）。
- Gamescom 访谈对照：把垂直水下与主世界 **16-point rotation** 并列，都是「给玩家更立体的建造自由度」（[GameReactor 访谈页](https://www.gamereactor.eu/video/824923/Wanna+be+a+mermaid+or+a+pirate+Perhaps+both+-+Disneys+Dreamlight+Valley+The+Keepsake+Sea+Gamescom+2026+Interview/)）。

**Godot 可落地**

1. 原生河湖 = **固定 mask + 岸线过渡带**；玩家「挖河」用 **可拼接 water props**，不要改整图 navigation 拓扑。  
2. Water prop 用 **单连通碰撞岛**；大建筑只允许锚在 `area >= footprint` 的单 mesh/单 tile island。  
3. 岸线预留 bank / reeds / lily 模块；禁止 spawnables 刷在 `water` 格。  
4. 进阶：水下/多层用 **可动 platform + Y offset**，与地面 2D 铺装分系统。

---

### 4. 家具 / 建筑朝向约束

| Constraint | Effect |
|------------|--------|
| **早期 4-way snap** | 门、长椅、摊位易与 path 网格「社交距离」感；门前 path 难齐 |
| **16-point rotation**（Sew Delightful） | Houses、landscaping、furniture 可 22.5° 步进；官方文案：「rotate houses, landscaping items, and furniture」；初版 **不含 fences/paths**（[Sew notes](https://devtrackers.gg/dreamlight-valley/p/eb933bc5-sew-delightful-update-patch-notes)；[GameRant 功能说明](https://gamerant.com/disney-dreamlight-valley-sally-sew-delightful-update-building-changes/)） |
| **Path/Fence 对角模式** | 朝向问题拆成第二通道：物件 yaw vs 路径边走向 |
| **Land vs Water house** | 硬类型约束，比 yaw 更优先 |
| **Oversized footprints** | 社区高频：部分房屋/灌木 collision 远大于可视体积 → 强制间距、难 clutter（约束存在即可，数值因物而异） |
| **Group Mode**（Puppy Love） | 多选移动/旋转；**成组旋转仍为 4-point**（[官方 Puppy Love notes](https://disneydreamlightvalley.com/en/news/update-feb-11-2026)） |
| **Presets + Mirage**（Path of the Hero） | 保存/复制整段 decorate；缺件用 Mirage 占位（[官方 Path of the Hero notes](https://disneydreamlightvalley.com/en/news/update-jun-03-2026)） |

**朝向 craft 含义**

- DDV **不是** ACNH「建筑永不 yaw」：后期明确把 **房屋可斜放** 当卖点 → 村镇可读性靠 **path graph + landmarks**，不靠统一门朝南。  
- 但仍有 **功能面**：门需要可达；water house 需要水面；stall 放置后锁定。  
- 室内：墙面物角度曾错显（Sew 修复）→ wall-mounted 与 floor yaw 分通道。

**Godot 可落地**

1. 默认允许建筑 **N 步进 yaw**（8 或 16），但 **door cell 必须落在 nav mesh**。  
2. Path 边与建筑 yaw **解耦**（对角 path ≠ 必须对角门）。  
3. 每个 prefab 声明 `placement_domain = land|water|pond_furniture` + `footprint`（可 > visual）。  
4. 组移动时可降精度旋转（4-way），单件精修用细步进。

---

### 5. 地面铺装防单调（路径、草地变体）

**路径材料族**

- Craft「Fences & Paving」：Brick / Muddy / Loose Gravel / Leaf-Strewn / Stone Slab / Asphalt / Ancient / Gem & Opal… 且多数有 **with Border** 成对版本（[Landscaping wiki 列表](https://dreamlightvalleywiki.com/Landscaping)；[TheGamer borders 指南](https://www.thegamer.com/disney-dreamlight-valley-paths-roads-borders-how-to-get/)）。
- **Path vs Road** 命名并存（Ancient Tile Path / Road 等）→ 窄步道 vs 宽街两种视觉权重。
- Border 用途：在不增加 item count 的前提下给铺装 **清晰边缘**（社区评价与 item-limit 策略一致）。
- 官方修 Leaf-Strewn **border–fill 空隙**、non-bordered **北缘钝角** → 铺装可读性依赖 **连续 lip / 无缝边**。

**生物群系地面 / 植被变体**

- Landscaping 按 biome 分包：`Plaza Dwarf Birch/Maple/Fern…`、`Peaceful Meadow Reeds/Flower Bush…`、`Sunlit Plateau Grass…`（Landscaping wiki）→ **同功能不同 albedo**，跨区混用会破分区。
- 默认可移走的：trees / rocks / bushes；**不可家具移除**：野生花/草药等 forageable，须采集（[GameRant](https://gamerant.com/disney-dreamlight-valley-ddv-how-decorate-village-outdoor-decor-scenery-guide/)）。
- 官方 Meadow 文案：发光莲等 **dynamic lighting**，晨昏改变可读性（[NintendoSoup](https://nintendosoup.com/four-disney-dreamlight-valley-biomes-detailed/)）→ 地面反单调不只靠 UV 变体，还有 **时段光照响应**。
- Item limit 把「满地 underbrush」变成昂贵噪声；**path 免费 + foliage 收费** → 成熟 decorate 往往是 **大铺装骨架 + 稀疏点景**，而非全图草簇。

**Godot 可落地**

1. Path atlas：`fill` + `border/lip` + 可选 `diagonal` 套；同材质多色/多磨损变体。  
2. 草地：biome tint 表 + 至少 3 密度档（path 邻接短草 / 中原 / 边缘高草）。  
3. Budget：path 无限；tree/rock/bush 计入 cap → assembler 优先铺路再撒点景。  
4. 可选昼夜 `modulate`/emission 让同 tile 不「死贴」。

---

### 6. 官方 / 开发者谈及的布局规则（摘录）

| Source | Rule (craft paraphrase) |
|--------|-------------------------|
| Josh Labelle — [Polygon](https://www.polygon.com/24214028/disney-dreamlight-valley-tiana-gameloft-montreal-q-a/) | 少无谓曲折；**易 decorate**；**地标清晰可见**；秘密点要有意义 |
| Sauveur — Floating Islands Showcase（[转述](https://www.bignox.com/blog/noxplay1730257672vsDFajx3uKWeRcllkfTQs/)） | 每 biome 平行 **clean-slate** 同主题空间，滚动放出 |
| Floating Islands explainer（[GameScout](https://gamescout.co.uk/2024/11/disney-dreamlight-valley-to-get-floating-islands/)） | Wells 连接空岛；~**65×65** decorate 平面 |
| Official biome blurbs（[NintendoSoup](https://nintendosoup.com/four-disney-dreamlight-valley-biomes-detailed/)） | Plaza = 重建中心；Meadow = 多户落位展示；Glade/Beach = 强差异氛围 |
| Sew Delightful notes | **16-point** 旋转房屋/景观/家具；pond 家具可承水景；修 path 北缘 |
| Skull Rock / Emotional Rescue notes | Path 然后 Fence 的 **对角模式**；放大编辑网格；大件瞄准 |
| Lucky Dragon notes | 连通 path/fence **整段换皮** |
| Item limit（官方意图经 wiki 引 release notes） | Unique/Total 双 cap **为性能与清晰反馈**；撞 cap 禁止再放 |
| Labelle/Wignall — [MiceChat](https://www.micechat.com/443303-new-disney-dreamlight-valley-the-keepsake-sea/) | 水下地形可水平+垂直重排 |
| Manea Castet — parks（[ComicBook 访谈](https://comicbook.com/gaming/amp/news/disney-dreamlight-valley-interview-new-characters-roadmap/)） | 灵感来自公园 **标志性单品**，目标不是在 Valley 复刻整座乐园 → craft 上 = **图标级锚点**，非主题园区堆砌 |

---

## Transfer checklist → Dream

| DDV craft | Dream action |
|-----------|--------------|
| Plaza hub + spoke biomes | `LAYOUT`：中心广场节点；leaf 区单入口；每区 1 well-scale 锚点 |
| Meadow-style housing spill | 住宅簇放在邻区开敞袋，Plaza 留 civic 空地 |
| Free path budget | Path 层不计 prop cap；先画入口图再摆建筑 |
| Soft ring at big anchors | Fountain/店铺周围自动 shrub/grass seam |
| Land/water placement domains | Building data 必填 domain + footprint |
| Modular water pieces | 河道具单岛碰撞；禁跨片落大建筑 |
| 16-point yaw + door nav | 斜放允许，门格必须可达 |
| Biome foliage packs | 同功能多 biome 变体，禁止无表跨区乱涂 |
| Landmark-first (Labelle) | 生成/手摆顺序：锚点 → 主干路 → 建筑 → 点景 |
| Clean-slate parallel pads | 可选「空岛/扩建坪」= 无原生 clutter 的 decorate 沙盘 |

---

## Sources（URL）

### First-party / developer

- [Sew Delightful Update Patch Notes (devtrackers / official text)](https://devtrackers.gg/dreamlight-valley/p/eb933bc5-sew-delightful-update-patch-notes)
- [Lucky Dragon Update Patch Notes](https://disneydreamlightvalley.com/en/news/update-june-26-2024)
- [Emotional Rescue Update Patch Notes（ComicBook 全文转载）](https://comicbook.com/gaming/news/disney-dreamlight-valley-ddv-patch-notes-inside-out-emotional-rescue-update/)
- [Puppy Love Update Patch Notes](https://disneydreamlightvalley.com/en/news/update-feb-11-2026)
- [Path of the Hero Update Patch Notes](https://disneydreamlightvalley.com/en/news/update-jun-03-2026)
- [Josh Labelle — Polygon Q&A (landmarks / decorateable biomes)](https://www.polygon.com/24214028/disney-dreamlight-valley-tiana-gameloft-montreal-q-a/)
- [Joshua Labelle & Riley Wignall — MiceChat Keepsake Sea (underwater platforms)](https://www.micechat.com/443303-new-disney-dreamlight-valley-the-keepsake-sea/)
- [GameReactor — Keepsake Sea interview page (16-point / vertical decorate)](https://www.gamereactor.eu/video/824923/Wanna+be+a+mermaid+or+a+pirate+Perhaps+both+-+Disneys+Dreamlight+Valley+The+Keepsake+Sea+Gamescom+2026+Interview/)
- [Manea Castet — ComicBook interview (park icons ≠ full park rebuild)](https://comicbook.com/gaming/amp/news/disney-dreamlight-valley-interview-new-characters-roadmap/)
- [Official biome reveal copy via NintendoSoup](https://nintendosoup.com/four-disney-dreamlight-valley-biomes-detailed/)

### Curated reference (topology / systems; cross-check)

- [Plaza](https://dreamlightvalleywiki.com/Plaza) · [Peaceful Meadow](https://dreamlightvalleywiki.com/Peaceful_Meadow) · [Forest of Valor](https://dreamlightvalleywiki.com/Forest_of_Valor) · [Sunlit Plateau](https://dreamlightvalleywiki.com/Sunlit_Plateau) · [Glade of Trust](https://dreamlightvalleywiki.com/Glade_of_Trust) · [Dazzle Beach](https://dreamlightvalleywiki.com/Dazzle_Beach) · [Frosted Heights](https://dreamlightvalleywiki.com/Frosted_Heights) · [Forgotten Lands](https://dreamlightvalleywiki.com/Forgotten_Lands)
- [Landscaping](https://dreamlightvalleywiki.com/Landscaping) · [Item Limit](https://dreamlightvalleywiki.com/Item_Limit) · [Villagers' Houses](https://dreamlightvalleywiki.com/Villagers%27_Houses) · [Player's House](https://dreamlightvalleywiki.com/Player%27s_House) · [Never Land Pond](https://dreamlightvalleywiki.com/Never_Land_Pond)
- [IGN — Mysteries of Skull Rock patch summary (diagonal paths)](https://www.ign.com/wikis/disney-dreamlight-valley/Mysteries_of_Skull_Rock_Update_Patch_Notes)
- [GameScout — Floating Islands ~65×65](https://gamescout.co.uk/2024/11/disney-dreamlight-valley-to-get-floating-islands/)
- [GameRant — outdoor decorate / item limits](https://gamerant.com/disney-dreamlight-valley-ddv-how-decorate-village-outdoor-decor-scenery-guide/)
- [GameRant — 16-point rotation feature writeup](https://gamerant.com/disney-dreamlight-valley-sally-sew-delightful-update-building-changes/)
- [TheGamer — bordered paths craft](https://www.thegamer.com/disney-dreamlight-valley-paths-roads-borders-how-to-get/)

### Constraint-documenting community (marked secondary)

- [ScreenRant — path break around fountains](https://screenrant.com/disney-dreamlight-valley-pathway-design-fix/)
- [Reddit — plaza pathing between biome gates](https://www.reddit.com/r/DreamlightValley/comments/16lfn7p/how_did_you_design_your_plaza/)
- [Reddit — water house on single river-kit piece](https://www.reddit.com/r/DreamlightValley/comments/1rkqt28/water_river_kit/)

---

## Out of scope（刻意未写）

- 迪士尼美术风格、角色 IP、Star Path / 经济 / 钓鱼小游戏数值  
- Eternity Isle / Storybook Vale 完整地图 walkthrough（仅引用 Labelle 对「曲折 vs 可 decorate」的教训）  
- 具体 Moonstone 商店导购与非布局向家具图鉴
