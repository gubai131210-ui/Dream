# Stardew Valley — 场景/环境 CRAFT 技术笔记

> Scope: **2D farm/town/tile 场景制作手法**（水、地面、建筑朝向、NPC 动线、程序化细节、绘制顺序）。不含类型标签/玩法综述。  
> 面向：Godot 4 TileMap 村镇项目。  
> 信任优先级：官方 wiki / ConcernedApe 访谈 / 反编译或高引用游戏代码 / 经 wiki 交叉验证的 modding 文档。

---

## Techniques

### 1. Water / rivers / ponds（边缘、动画、深度、河岸）

**逻辑标记 ≠ 美术边框**

- 水格由 **Back 层** tile 属性 `Water` 标记；加载时扫全图写入 `waterTiles[,]` 布尔掩码。有水才启用水系统。  
  来源：[Modding:Maps — Water tile property](https://stardewvalleywiki.com/Modding:Maps)、[GameLocation 反编译（waterTiles 扫描）](https://github.com/osheroff/stardew-valley/blob/master/StardewValley/GameLocation.cs)
- `Water = T`：正常水逻辑 **且** 画动画叠加层。  
- `Water = I`（大写 i）：水逻辑相同，**不画** 动画叠加（适合自定义瀑布/流向贴图）。  
  来源：[Modding:Maps](https://stardewvalleywiki.com/Modding:Maps)、[Chucklefish 论坛（瀑布贴图与 Water 叠加冲突）](https://community.playstarbound.com/threads/waterfall-tilesheet-w-animation.132102/)

**动画叠加（深度感的核心）**

- 叠加贴图取自 `LooseSprites/Cursors`（`Game1.mouseCursors`），源矩形约 `(waterAnimationIndex * 64, 2064, 64, 64)`。  
  来源：[FishPondColoring/WaterBox.cs（读官方字段）](https://github.com/jokthefoo/StardewMods/blob/main/FishPondColoring/WaterBox.cs)、[GameLocation.drawWater](https://github.com/brexeprogram/Stardew-Valley/blob/main/GameLocation.cs)
- 帧：`waterAnimationIndex = (index + 1) % 10`，约每 **200ms** 一切换 → 10 帧循环。  
- 滚动：`waterPosition` 每帧累加；户外常用 `sin(t) + 1` 调制速度，封顶后对 **64px（1 tile）** wrap。北缘水格用 `waterPosition` 裁剪 UV，制造 **水面缓慢漂移**。  
- 棋盘交错：`(x+y)%2` 与 `waterTileFlip` 在 y=2064 与 2064+128 两行源图间切换，打破整片同相动画。  
- 着色：`waterColor` 默认约 `White * 0.33`；按季节改 tint（如春 `120,200,255*0.5`，夏更青，秋偏粉，冬偏紫）。叠加以半透明乘到水上 → **“深度/浑浊”靠 tint，不是额外 mesh**。  
  来源：[GameLocation 水更新与 drawWater](https://github.com/brexeprogram/Stardew-Valley/blob/main/GameLocation.cs)

**河岸 / 池边观感**

- **美术边**：河岸是 Back 上 dirt/grass/stone **过渡 tile**（悬崖、泥滩、沙），不是程序生成 SDF。  
- **逻辑边**：`waterTiles` 南北邻接决定是否画“顶边裁剪”第二道水条（南无水格额外 draw 一段滚动条），视觉上边缘更“湿”。  
- 垂钓气泡等是 **TemporaryAnimatedSprite** 点缀，不是水体本身。  
  来源：[StackExchange 气泡](https://gaming.stackexchange.com/questions/256960/what-do-ripples-on-the-water-indicate)、[TemporaryAnimatedSprite](https://github.com/WeDias/StardewValley/blob/main/TemporaryAnimatedSprite.cs)

**Godot 可落地**

1. TileMap `water` 自定义数据 = 布尔掩码。  
2. 第二层 `CanvasItem`/`MultiMesh` 用共享 atlas 动画 + 全局 `water_phase`。  
3. 调制色按“季节/天气”改 `modulate`。  
4. 河岸用 terrain-set 过渡；瀑布用 **无动画贴图** 且不要叠全局水 shader。

---

### 2. Ground：草 / 土 / 路 分层、过渡、反重复

**层职责（永久 vs 可移除）**

| 层 | 画什么 | 对玩家 |
| --- | --- | --- |
| **Back** | 地形、水体、**永久路/广场砖** | 可走；`Type=Dirt/Stone/Grass/Wood` 驱动脚步声与寻路偏好 |
| **Paths** | 可移除路径标记、草/石/树桩等生成标记 | 运行时生成物；Paths 本身常不可见 |
| **Buildings** | 碰撞体、建筑占位 | 默认墙；`Passable=T` 才可走 |

来源：[Modding:Maps — layers](https://stardewvalleywiki.com/Modding:Maps)

**路径 / 地板自动拼接**

- `Flooring` 用 **8 邻接 bitmask**（N/S/E/W + 四对角）选 sprite；同 `whichFloor` 才互连。  
- 数据驱动 `ConnectType`：  
  - `Default` — 大片铺装，处理内角  
  - `Path` — 窄路，**忽略内角**（更像走道）  
  - `CornerDecorated` — 装饰角  
  - `Random` — **不互连**，放置时随机选 tile → 碎石/踏脚石反平铺  
- 可选 `ShadowType`：`None` / `Square` / `Contoured`（贴合路径轮廓阴影）。  
  来源：[Modding:Floors and Paths](https://stardewvalleywiki.com/Modding:Floors_and_Paths)、[Flooring.cs neighborMask](https://github.com/veywrn/StardewValley/blob/3ff171b6e9e6839555d7881a391b624ccd820a83/StardewValley/TerrainFeatures/Flooring.cs)

**草的“反平铺”是运行时密度，不是一张大图**

- 每格草最多 **4 tufts**；每日生长 1–3 tufts；65% 额外生长检定；满格向四邻 25% 扩散 1–2 tufts。  
- 草只向 **可耕作土** 扩散，不向纯装饰绿砖扩散；路径/篱笆阻断。  
- Paths 层 index **22** + 地图属性可在新年批量刷草。  
  来源：[Grass wiki — Propagation](https://stardewvalleywiki.com/Grass)、[Modding:Maps — SpawnGrassFromPathsOnNewYear](https://stardewvalleywiki.com/Modding:Maps)

**季节 tilesheet**

- 户外共用一套布局，换 `spring/summer/fall/winter_*` tilesheet；mod 实践建议先用 **winter** 校对路径接缝（对比度高）。  
  来源：[Tutorial: Making a New Area](https://stardewmodding.wiki.gg/wiki/Tutorial:_Making_a_New_Area)

**Godot 可落地**

- `TileMapLayer`：`ground`（永久）→ `paths`（autotile / random）→ `decor_spawn`（标记层）。  
- Terrain peers 做草↔土↔路；踏脚石用 **无连接 + 多变体权重**。  
- 反重复：≥3–4 变体 + 偶发 deco（碎石、杂草 tuft）+ 距离道路的生态分区（与本仓库 `SEAMLESS.md` 的 mowed/meadow/damp 一致）。

---

### 3. Building orientation & placement vs paths / plaza

**碰撞与绘制拆层（朝向真实感的根基）**

- 建筑 **下层/基座** 放 **Buildings**（挡人）；**屋顶/上层** 放 **Front**（玩家从南走近时挡在人前，从北走时被挡）。  
  来源：[Map Patches tutorial — Back/Buildings/Front](https://stardewmodding.wiki.gg/wiki/Tutorial:_Map_Patches_and_Warps)、[Adding Map Patches Using Tiled](https://stardewmodding.wiki.gg/wiki/Adding_Map_Patches_Using_Tiled)
- 门：Buildings 上 `Action` 含 `Door` / `Passable`，或显式 `Passable` / `NPCPassable`，否则 NPC 日程寻路视为不可达。  
  来源：[PathFindController.isPositionImpassableForNPCSchedule](https://github.com/WeDias/StardewValley/blob/main/PathFindController.cs)
- 可放置建筑另有 `CollisionMap`（`X` 挡 / `O` 通），门口常留前排可走格。  
  来源：[Modding:Buildings — CollisionMap](https://stardewvalleywiki.com/Modding:Buildings)

**与道路/广场的关系（可观察的布局规则 + 代码偏好）**

- 永久广场/主路画在 **Back**（`Type=Stone/Wood`），NPC 寻路 **更偏好** 石 > 木 > 土 > 草（见下节）。→ 村镇主街用 stone/wood 类型，旁支用 dirt，草地留作院子。  
- 建筑正面朝向广场/主路；门前留 1–2 tile 缓冲；篱笆/路径阻断草蔓延，形成“打理过的前院”。  
- Back 上 `NoPath` 可禁止 NPC 抄近道（保护花坛/演出区）。  

**Godot 可落地**

- 建筑场景：`StaticBody2D` 只罩基座；精灵 Y-sort；门用 `NavigationObstacle` 缺口。  
- 铺装 `custom_data: surface = stone|wood|dirt|grass` 喂给 Navigation 权重。

---

### 4. NPC walking / schedules / pathfinding（“活的”读感）

**日程数据驱动，不是行为树漫游**

- 每人一份 schedule；键优先级：节日/约会 → 雨天 → 季节+星期 → 季节 → 默认 `spring`。  
- 条目：`时间 [地图] X Y [朝向] [动画] [对话]`；`a` 前缀 = **到达时刻**（倒推出发）。  
- 到达后可播 `animationDescriptions`（坐下、吹笛、睡觉）；特殊 `square_X_Y_facing` = 在目标为中心的矩形内 **随机走动 + 偶停朝向** → “闲逛”感。  
  来源：[Modding:Schedule data](https://stardewvalleywiki.com/Modding:Schedule_data)、[Custom NPC tutorial](https://stardewmodding.wiki.gg/wiki/Tutorial:_Making_a_Custom_NPC)

**寻路**

- 日程路径：A*（4 邻接），代价 ≈ `g + terrainPreference + manhattan`，同轴直行额外 **-2**（偏好少转弯）。  
- `getPreferenceValueForTerrainType`：`stone -7`, `wood -4`, `dirt -2`, `grass -1`（数值越低越优先）。→ NPC **自然贴着石板路走**。  
- 不可走：Buildings 墙、`NoPath`、warp 格、部分 terrain feature；门需可通行标记。  
  来源：[PathFindController.cs](https://github.com/WeDias/StardewValley/blob/main/PathFindController.cs)
- 控制器按路径段转向、可 pause；多 NPC 同向碰撞时互让。  
  来源：[NPCController.cs](https://github.com/WeDias/StardewValley/blob/main/NPCController.cs)

**Godot 可落地**

- `NavigationRegion2D` + 按 `surface` 设 `travel_cost`。  
- Resource：每日时间轴 `{time, map, tile, face, idle_anim}`；到达后 `WanderInRect` 状态。  
- 少用纯随机游走；用 **稀疏锚点 + 时段** 即可读成“有生活”。

---

### 5. Math / noise / procedural（已文档化部分）

| 手法 | 作用 | 来源 |
| --- | --- | --- |
| `sin(t)` 调制 `waterPosition` | 水面流速起伏 | GameLocation 水更新 |
| `(x+y)%2` + flip 行 | 水动画相位错开 | drawWater |
| `% 10` 帧、200ms | 水波周期 | 同上 |
| 8-bit neighbor mask → drawGuide | 地板/路径 autotile | Flooring.cs |
| 草 tuft 计数 + 日更概率（65%、邻格 25%） | 有机蔓延、反平铺 | Grass wiki |
| A* + 地形权重 + 直行偏置 | NPC 贴路 | PathFindController |
| `Random` ConnectType | 踏脚石无连接变体 | FloorsAndPaths |
| `Game1.random` 刷草/杂草 | 日更杂乱度 | Farm/GameLocation 日更 |

**未见（在高信任源中）**：大范围 Perlin 地形生成作为主地图手段；城镇地图基本是 **手摆 tile + 局部随机生成物**。

---

## Math/procedural（实现备忘）

```text
# Water overlay (概念)
every frame:
  waterAnimationTimer -= dt_ms
  if timer <= 0: index = (index+1)%10; timer = 200
  waterPosition += outdoors ? (sin(t_sec)+1)*0.15 : 0.1
  if waterPosition >= 64: waterPosition -= 64
draw each water cell:
  src = Rect(index*64, 2064 + checkerboard_row, 64, 64)  # + scroll crop on N edge
  color = seasonal_waterColor  # ~0.33–0.5 alpha

# Flooring autotile
neighborMask = OR of (N=1,S=4,E=2,W=8,NE=16,NW=32,SE=64,SW=128) if same floor
spriteIndex = drawGuide[neighborMask]

# Pathfinding priority (lower better)
priority = g + pref(Type) + manhattan + (aligned_with_prev ? -2 : 0)
pref: stone=-7, wood=-4, dirt=-2, grass=-1, else 0

# Grass richness
tufts ∈ [0,4]; daily grow; full tile → 4-neighbors 25% spawn 1–2 tufts on diggable
```

---

## Asset pipeline notes

**作者工具链（一手）**

- 程序：C# / XNA / Visual Studio；地图：**xTile**；美术：**Paint.NET**；音频：Reason。  
  来源：[Road to the IGF — ConcernedApe](https://www.gamedeveloper.com/design/road-to-the-igf-concernedape-s-i-stardew-valley-i-)、[Polygon — Paint.NET](https://www.polygon.com/24099974/concernedape-stardew-valley-eric-barone-sherpa-trucker-jacket-buckwheat-pillow/)

**绘制顺序（艺术家/关卡）**

1. ConcernedApe 自述第一张画的是 **dirt tile**（从地面单位砖开始，不是先画建筑）。  
   来源：[mentalnerd — ConcernedApe pixel art interview](https://mentalnerd.com/blog/getting-started-pixel-art-interview/)
2. 地图层从后到前：`Back` → `Buildings` →（实体 Y-sort）→ `Front` → `AlwaysFront`。  
3. 实体 depth 常用 `(standingY 或 position.Y + offset) / 10000`；越大越靠前。GPU 抓帧也显示：先铺地面，再按屏上远近（上方先画）排物体，天气全屏叠加。  
   来源：[Modding:Maps](https://stardewvalleywiki.com/Modding:Maps)、[TemporaryAnimatedSprite layerDepth](https://github.com/WeDias/StardewValley/blob/main/TemporaryAnimatedSprite.cs)、[hlsl.co.uk GPU capture](http://www.hlsl.co.uk/blog/2018/7/19/what-can-we-learn-from-gpu-frame-captures-stardew-valley)
4. 高物体：**碰撞/排序锚在脚底 1 tile**，艺术向上伸出。  

**Tile / atlas / 接缝**

- 标准 **16×16** tile；显示常 ×4 → 64px 逻辑格。  
- Tilesheet **顺序敏感**：自定义 sheets 名加 `z_` 前缀，避免打乱原版 index。宽 >200 tile 曾有分层问题。  
- 动画在 Tiled Tile Animation Editor；帧时长毫秒，宜一致。  
- 水叠加与地形 sheet **分离**（Cursors 全局动画 vs outdoorsTileSheet 静帧岸边）→ 换季重绘岸，不重做水波。  
- 接缝实践：导出带属性的 tileset；季节表对齐；避免 AI 草块 vignette（参见本仓库 `docs/SEAMLESS.md`）。

---

## Agent-transferable rules（给 Godot 4 村镇）

1. **水 = 掩码 + 全局叠加动画 + 季节 tint**；岸用 terrain 过渡；特殊水流用独立帧动画并关闭全局叠加。  
2. **永久地面 / 可移除物 / 碰撞** 三层分离（对齐 Back / Paths / Buildings）。  
3. **广场与主路** 标 `stone`/`wood` surface，让 Navigation 权重引导 NPC；院子用 dirt/grass。  
4. **路径 autotile**：大广场用内角规则；窄路用无内角；碎石用 random 变体。  
5. **草用多 tuft/多变体 + 邻接扩散或烘焙生态带**，禁止单 tile 无限平铺。  
6. **建筑**：碰撞只占基座；屋顶 Y-sort/Front；门前留空；正面朝广场。  
7. **NPC**：稀疏日程锚点 + A*/Navigation 贴路 + 到达后短距 wander；不要全图随机 walk。  
8. **绘制**：先 dirt/terrain atlas → 路 → 建筑基座 → 角色/道具（Y-sort）→ 屋顶/树冠 → 天气；atlas 无黑边、整数缩放。  
9. **属性驱动行为**：`Water`、`Type`、`NoPath`、`Passable` 比“看起来像路”更重要。  
10. **16px 网格纪律**：所有碰撞、寻路、门偏移对齐 tile；艺术可越界，逻辑锚点不越界。

---

## Sources

### Primary / high-trust

| 主题 | URL |
| --- | --- |
| 地图层、Water、Type、Paths 生成 | https://stardewvalleywiki.com/Modding:Maps |
| 地板 ConnectType / Shadow | https://stardewvalleywiki.com/Modding:Floors_and_Paths |
| NPC 日程格式与 square_ 闲逛 | https://stardewvalleywiki.com/Modding:Schedule_data |
| 草 tuft 扩散（指向 game code） | https://stardewvalleywiki.com/Grass |
| 建筑 CollisionMap | https://stardewvalleywiki.com/Modding:Buildings |
| ConcernedApe 工具链（xTile, Paint.NET） | https://www.gamedeveloper.com/design/road-to-the-igf-concernedape-s-i-stardew-valley-i- |
| ConcernedApe 仍用 Paint.NET | https://www.polygon.com/24099974/concernedape-stardew-valley-eric-barone-sherpa-trucker-jacket-buckwheat-pillow/ |
| 先画 dirt tile；16×16 | https://mentalnerd.com/blog/getting-started-pixel-art-interview/ |

### Code / reverse-engineering（高引用，非官方发布）

| 主题 | URL |
| --- | --- |
| 水动画 / drawWater / waterColor | https://github.com/brexeprogram/Stardew-Valley/blob/main/GameLocation.cs |
| waterTiles 加载 | https://github.com/osheroff/stardew-valley/blob/master/StardewValley/GameLocation.cs |
| 水帧矩形用法（mod 读官方字段） | https://github.com/jokthefoo/StardewMods/blob/main/FishPondColoring/WaterBox.cs |
| Flooring 8 邻接 | https://github.com/veywrn/StardewValley/blob/3ff171b6e9e6839555d7881a391b624ccd820a83/StardewValley/TerrainFeatures/Flooring.cs |
| A* + 地形偏好 | https://github.com/WeDias/StardewValley/blob/main/PathFindController.cs |
| NPC 路径执行 | https://github.com/WeDias/StardewValley/blob/main/NPCController.cs |
| layerDepth Y 排序 | https://github.com/WeDias/StardewValley/blob/main/TemporaryAnimatedSprite.cs |

### Secondary（技巧交叉验证）

| 主题 | URL |
| --- | --- |
| 层用法 / 建筑上下层拆分 | https://stardewmodding.wiki.gg/wiki/Tutorial:_Map_Patches_and_Warps |
| 季节 tilesheet 校对路径 | https://stardewmodding.wiki.gg/wiki/Tutorial:_Making_a_New_Area |
| Water 叠加 vs 自定义瀑布 | https://community.playstarbound.com/threads/waterfall-tilesheet-w-animation.132102/ |
| GPU 帧：先地面后 Y 排序 | http://www.hlsl.co.uk/blog/2018/7/19/what-can-we-learn-from-gpu-frame-captures-stardew-valley |
| 钓鱼波纹 | https://gaming.stackexchange.com/questions/256960/what-do-ripples-on-the-water-indicate |

---

*Research date: 2026-09-10. Decompiled repos mirror game behavior; prefer wiki + ConcernedApe quotes when conflict.*
