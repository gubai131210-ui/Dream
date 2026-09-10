# Coral Island — 场景/环境 CRAFT 技术笔记

> Scope: **农场 / 城镇 / 住宅 / 海滩等区域的布局区分、水体边缘、地面过渡、建筑朝向、NPC 动线、程序化/规则丰富地面、素材组装顺序**。不含类型标签 / 玩法综述 / 约会经济。  
> 工作室：Stairway Games（UE4）。面向：Godot 4 TileMap 村镇项目。  
> 信任优先级：Stairway 官方博客 / Kickstarter 官方文案 / Epic Unreal 访谈 / 经交叉验证的 wiki 地理描述。证据不足处标 **[low confidence]**。

---

## Techniques

### 1. 区域如何在布局上区分（路网 / 开放空间 / 密度 / 功能节点）

官方把岛屿切成 **7 个具名区域**；农场在地图 **左侧（西）**、城镇外围。区域不是“同一调色盘换贴图”，而是用 **地表材质 + 路网等级 + 开放空间类型 + 功能节点簇** 同时换档。

| 区域 | 官方可读布局信号 | 密度 / 路网 | 功能节点 |
| --- | --- | --- | --- |
| **Farm** | 可垦开阔地；初始有农舍、shipping bin、温室地基、**不可移动池塘** | 低密度；玩家自建路；网格玩法主导 | 耕作、畜舍、加工机 |
| **Garden Lane**（缓冲带） | 农场西 ↔ 城镇东之间的 **绿色过渡带**；民居（Millie/Yuri） | 低于城镇铺装；草/树/觅食主导 | 住宅、河岸、椰子等 |
| **Starlet Town** | “heart”；**宽敞** + **butterfly garden** | **铺装路径** 密度最高；广场/店面聚集 | 商店、诊所、馆、咖啡等市民服务 |
| **Woodlands** | 曾属森林，现 **驯化、亲家庭**；沿河走可见 School / Taco Truck / 住宅；居民是“宁可安静夜晚、也不要城镇铺装路”的人 | **河岸线性路网**；铺装弱于镇中心 | 学校、轻食、郊区住宅 |
| **Hillside** | 夹在 Forest 与 Woodlands 之间；绿 + 私密 | 中低密度；坡地/葡萄园尺度 | Vineyard、Carpenter（Joglo 风） |
| **Beach** | **白沙** 海岸线；滩上觅食/野生；周末排球 | 开放沙滩面 > 街巷；**码头/栈桥** 作硬边缘 | Coral Inn（码头上）、Beach Shack、Diving 入口 |
| **Lake** | 木桥 → 古寺；叙事上是水源与沃土源头 | 水缘 + 桥 + 仪式空地 | Lake Temple、**Alun-Alun Square**（节日广场） |
| **Forest / Lookout** | 废墟/神秘 vs 灯塔导航与日落眺望 | 低铺装、高自然障碍 | Cavern、Lighthouse、观光 |

来源：[Kickstarter 项目页 — 7 areas / 区域文案](https://www.kickstarter.com/projects/coralisland/coral-island-reimagining-the-farm-sim-game)、[Map wiki（与 Kickstarter 同文）](https://coralisland.fandom.com/wiki/Map)、[Farm — west of town；固定池塘](https://coralisland.fandom.com/wiki/Farm)、[Garden Lane — green between farm & town](https://coralisland.fandom.com/wiki/Garden_Lane)、[Alun-Alun Square — 湖东节日场](https://coralisland.fandom.com/wiki/Alun-Alun_Square)

**可迁移的布局语法（高置信）**

1. **西农 → 绿缓冲 → 铺装镇心**：不要让耕地直接贴主街；中间留 Garden Lane 式草地/住宅带。  
2. **铺装强度 = 市民化程度**：镇心强铺装；Woodlands 明确用“along the river / prefer quiet over paved”对比镇心。  
3. **每区一个开放空间类型**：蝶园（日常休闲）≠ Alun-Alun（仪式/节日，平时可关闭）≠ 沙滩排球空地 ≠ 湖桥仪式轴。  
4. **功能节点跟地貌绑定**：Inn/Diving 在 pier；学校在河岸郊区；木匠在山坡；神庙在湖对岸。

**节日路引道具（高置信）**  
节日日在岛上摆 **umbul-umbul / penjor** 类竖旗：一是宣告节日，二是 **把玩家导向节日区**——开放空间靠临时导向物补强，而不是永久加宽马路。  
来源：[November 2021 Dev Update](https://blog.stairwaygames.com/post/november-2021-dev-update)

---

### 2. 水体边缘、沙滩 / 草地过渡

**已公开的一手事实**

- 海岸定位为 **white sand beach along coastline**；海滩专属拾取、钓鱼、周末家庭排球。  
  来源：[October 2020 Dev Update — Beach Environment Showcase](https://blog.stairwaygames.com/post/coral-island-october-2020-dev-update)
- 钓鱼水域分 **rivers / lakes / ocean**；湖区用 **wooden bridge** 进入神庙轴。  
  来源：[July 2020 Dev Update](https://blog.stairwaygames.com/post/july-2020-dev-update)、Kickstarter Lake 文案
- 农场有 **若干固定池塘**（不可移），水缘是作者预留的硬特征，不是玩家整平原。  
  来源：[Farm wiki](https://coralisland.fandom.com/wiki/Farm)
- 天气会改环境读感（雨、风）；日夜用 **动态实时光照**（感谢 BlackSquid Production 定制灯光）。  
  来源：[July 2020](https://blog.stairwaygames.com/post/july-2020-dev-update)、[April 2020 — Lighting](https://blog.stairwaygames.com/post/april-2020-dev-update)

**未公开 / 弱证据（标 [low confidence]）**

- 未找到 Stairway 公开的 **沙↔草自动过渡 bitmask / SDF / landscape layer blend** 公式。从海滩 showcase 与热带设定只能推断：沙滩是 **大面材质带**，内侧接草地/小径，外侧接海浪/码头硬边；过渡更像 **手摆材质带 + 道具（贝壳、蟹、排球网）**，而非 Stardew 式 16px 岸砖表。 **[low confidence]**  
- 河岸在 Woodlands 被写成 **walk alongside the river** 的线性体验走廊，暗示河是 **路径对齐的景观轴**，不是纯装饰水坑。 **[low confidence：路径对齐是文案推断]**  
- 水动画/着色器实现未见源码级公开。 **[low confidence]**

**Godot 可落地（对齐本仓库 `LAYOUT.md` / `SEAMLESS.md`）**

1. 海：宽沙带 mask → 内侧 damp/草 → 外侧水；码头用硬矩形 pier 打断柔边。  
2. 河：蜿蜒 mask + 平行岸步行带（Woodlands 读感）。  
3. 湖：桥跨 + 对岸仪式节点；节日广场与日常镇心分离。  
4. 农场地塘：预埋不可移水洞，强迫路网绕行。

---

### 3. 建筑朝向

**已公开**

- 美术支柱：**playful / pleasant / rich**；夸张圆润造型 + “fruity” 本地色；有面向 concept / 3D / **level artists** 的 art guide（含 large/medium shape 比例教程）。建筑探索 **晚于 gameplay 验证**（pipeline 先验证玩法资产）。  
  来源：[Damas Nawanda — Co-Art Director](https://blog.stairwaygames.com/post/swag-crew-damas-nawanda-co-art-director)
- 外立面会为 **storytelling** 大改版；木匠屋明确参考印尼 **Joglo** 屋顶语汇。  
  来源：[April 2021 Dev Update](https://blog.stairwaygames.com/post/april-2021-dev-update)
- Art Director（David Lojaya）负责含 **town、ocean** 在内的视觉方向。  
  来源：[Unreal Engine 访谈 — Putera](https://www.unrealengine.com/en-US/developer-interviews/coral-island-inside-the-chill-farm-sim-reinventing-the-genre)
- 农场可放置物：社区实践称放置时朝向跟玩家面朝方向走（部分物不可转）。 **[low confidence — 非一手技术文档]**

**未见公开“门必须朝南 / 不可 yaw”硬规则。** 可观察的布局习惯（交叉文案，非引擎 API）：

| 观察 | 朝向含义 | 置信 |
| --- | --- | --- |
| Inn 坐在 pier 上 | 立面对 **海/码头步行轴** | 文案 + 海滩 showcase |
| 镇心店面沿铺装聚集 | 门对 **主街/广场** | Kickstarter “heart / paved” 对比 |
| Woodlands 宅沿河 | 门对 **河岸步行带**，非镇心广场 | Kickstarter Woodlands |
| Alun-Alun 独立节日场 | 仪式面朝广场空地，不与日常店面抢轴 | wiki |

**Godot：** 继续锁门面朝主步行轴（plaza / quay / river walk）；区域换轴，不换“门对人流”原则。不要假设 Coral Island 有 ACNH 式不可旋转地契——它是 **3D 松散美术 + 网格玩法**（见 §5）。

---

### 4. NPC 路径 / 日程

**已公开（高置信）**

- 目标：角色比“静态立牌”更活；每人有 **daily routines**，随 **季节、天气、玩家进度** 变化。开发截图显示 Mayor Connor 有多份条件日程文件。  
  来源：[May 2020 Dev Update](https://blog.stairwaygames.com/post/may-2020-dev-update)
- NPC 有职业 + 爱好；到达后播 **activity animation**（例：Theo 白天渔夫，周末酒馆表演）。  
  来源：[October 2020 — NPC Activity Animation](https://blog.stairwaygames.com/post/coral-island-october-2020-dev-update)
- 日程锚点与区域功能绑定（博客角色简介反复出现）：Beach Shack 下棋、Coral Inn 工作、学校工作日、湖边周末、酒馆夜晚等。  
  来源：各月 Character Reveals（如 [April 2020](https://blog.stairwaygames.com/post/april-2020-dev-update)、[July 2020](https://blog.stairwaygames.com/post/july-2020-dev-update)）

**未公开（[low confidence]）**

- 无公开 A* / NavMesh / 跨区加载策略说明。  
- 无公开“贴石板路权重”类数值（对比 Stardew `stone > wood > dirt > grass`）。从区域文案只能推断 NPC **优先出现在职业节点与铺装/河岸步行带上**。

**Godot 可落地**

- Resource：`{time, weather?, season?, area, anchor, facing, activity_anim}`。  
- 锚点放在功能节点（店、码头、学校、酒馆），少用全图随机 wander。  
- 区域切换用稀疏图：Farm ↔ Garden Lane ↔ Town ↔ Beach / Woodlands / Lake。

---

### 5. 程序化 / 规则丰富地面（公开部分）

Coral Island 的核心拆法是：**世界美术松散 3D，玩法仍是网格。**

**Grid & Tile Editor Overlay（一手，高置信）**

- “Grids and tiles govern many gameplay elements… **but the game is not created in a tile-like manner** because of our loose 3D art.”  
- 引擎内自研 **grid overlay**：2D 网格画在世界空间，**Z 投影到地表**；选中格存为 **2D index → data table**，供 gameplay 读。  
  来源：[April 2020 — Grid & Tile Editor Overlay](https://blog.stairwaygames.com/post/april-2020-dev-update)

**Smart Tile（一手，高置信）**

- 耕地格 **contextually aware of surroundings**；用于视觉反馈，也可拼图案。  
- 公开数字：**16 different textures** → 强烈对应 **4 邻接 bitmask（0–15）** 自动拼接。  
  来源：[April 2020 — Smart Tile System](https://blog.stairwaygames.com/post/april-2020-dev-update)
- 更早预告 smart tile **and grass system**。  
  来源：[March 2020](https://blog.stairwaygames.com/post/march-2020-dev-update)
- 玩家侧有 **tile visual guide**（默认可关）标示当前交互格。  
  来源：[May 2020](https://blog.stairwaygames.com/post/may-2020-dev-update)

**环境草 vs 玩法草（中高置信）**

- Alpha 后期才“finally have grass”；环境草 **分批铺满地图**（仍在 applying across the map）。  
  来源：[November 2021 — Revamped grass](https://blog.stairwaygames.com/post/november-2021-dev-update)
- 同一更新：砍草掉落 `grass` → Mill → `fodder`。→ **视觉草地层** 与 **资源草地** 可分开演进。

**农场轮廓**

- 农场平面被调成接近 **工作室 logo 形状**，并兼顾玩法。→ 可玩区轮廓是 **作者造型**，不是噪声大陆生成。  
  来源：[April 2020 — Farm Layout Improvements](https://blog.stairwaygames.com/post/april-2020-dev-update)
- Coop 占位示例：**7×4 tiles**（网格足迹）。  
  来源：[October 2020 — Ranching](https://blog.stairwaygames.com/post/coral-island-october-2020-dev-update)

**未见（高置信否定）**

- 无公开“整岛 Perlin/水位场主生成”文档；岛区是 **手摆分区 + 局部规则（smart till / grass）**。  
- 沙草过渡算法未公开。 **[low confidence if guessing]**

---

## Math / procedural（实现备忘）

```text
# Dual representation (Coral Island lesson)
art_surface  = authored 3D / painted mesh (not forced to tile cells)
play_grid    = 2D indices projected onto surface Z → DataTable
gameplay reads play_grid; art is free within cell footprints

# Smart till (documented: 16 textures)
mask = 0
if neighbor_N is till: mask |= 1
if neighbor_E is till: mask |= 2
if neighbor_S is till: mask |= 4
if neighbor_W is till: mask |= 8
texture_index = mask   # 0..15

# Zone grammar (layout, not engine code)
paving_strength:  Town > GardenLane > Woodlands ≈ Hillside > Forest/Beach sand sheet
open_space_type:  plaza_daily | plaza_festival | beach_court | lake_ritual | farm_clearing
buffer:           Farm --green--> Town   (Garden Lane)
river_as_axis:    Woodlands circulation hugs river
pier_hard_edge:   Beach Inn + Diving on pier geometry

# NPC (documented behavior, not path costs)
schedule_key = (npc, season?, weather?, player_flags?) → list of (time, place, activity)
```

---

## Asset pipeline notes（组装顺序）

### 官方描述的生产顺序（一手）

1. **主题 / lookdev**：定 “never-ending holiday…”；多版 lookdev；选中后进 Unreal 验证（部分效果因性能未进最终版）。  
2. **Gameplay-first 资产**：先做玩法重、周转快的概念与资产；**建筑探索可后置**，与玩法并行。  
3. **拆美术支柱 → Art Guide**：playful / pleasant / rich；dos/don’ts、shape 比例教程；给 concept、3D、**level artists** 共用。  
4. **一致性**：checklist + paintover 反馈。  
   来源：[Damas Nawanda 访谈](https://blog.stairwaygames.com/post/swag-crew-damas-nawanda-co-art-director)

5. **引擎**：Unreal + **Blueprints** 快速原型。  
   来源：[Unreal 访谈](https://www.unrealengine.com/en-US/developer-interviews/coral-island-inside-the-chill-farm-sim-reinventing-the-genre)

6. **灯光**：动态日夜；外部合作定制灯光（BlackSquid Production）。  
   来源：[April 2020](https://blog.stairwaygames.com/post/april-2020-dev-update)

7. **工具反馈**：清杂物用 **Alembic** 动画（数据重但运行相对轻）。  
   来源：[March 2020](https://blog.stairwaygames.com/post/march-2020-dev-update)

8. **网格工具**：世界摆松散 3D → 叠 grid overlay 写 data table → smart till / 建筑 footprint。  
   来源：[April 2020](https://blog.stairwaygames.com/post/april-2020-dev-update)

9. **环境草晚于结构**：先有可玩分区与建筑，再全图铺环境草（2021-11 仍在铺）。  
   来源：[November 2021](https://blog.stairwaygames.com/post/november-2021-dev-update)

10. **建筑叙事改版**：旧外观 → 新概念 → 引擎内 WIP（例：Joglo 木匠屋）。  
    来源：[April 2021](https://blog.stairwaygames.com/post/april-2021-dev-update)

### 二手管线（未经理官方确认，低置信）

- 第三方文章称 Maya 定比例 → ZBrush 有机雕刻 → 手动 retopo → Substance Painter bake/贴图（干净饱和非写实）。  
  来源：[foro3d 二次整理](https://foro3d.com/2026/mayo/coral-island-el-pipeline-artistico-para-un-paraiso-tropical-en-ue4.html) **[low confidence / secondary]**

### 建议的场景组装 pass（Dream 映射）

```text
1. Macro zones + buffers (Farm | GardenLane | Town | Beach | River-Woodlands | Lake)
2. Circulation spines (paved town graph vs river walk vs pier)
3. Water masks (ocean strip, river meander, lake, farm ponds)
4. Ground ecology (sand belt, mowed near path, meadow yards, damp banks)
5. Path / plaza paving by zone strength
6. Building slots facing walk axes (+ culture-specific roof language if any)
7. Functional props (shops, volleyball, bridge, festival poles)
8. Environment grass / foliage pass (can lag behind structure)
9. NPC schedule anchors on nodes
10. Lighting / weather overlays
```

对齐本仓库 assembler：`masks → ground → water → path → buildings → props → actors → FX`。

---

## Agent-transferable rules（给 Godot 4 村镇）

1. **先分区再铺砖**：西农 / 绿缓冲 / 强铺装镇心 / 河岸住宅 / 白沙海滨 / 湖桥仪式——用密度与开放空间类型区分，不靠换一张草皮。  
2. **Woodlands 规则**：住宅区可用 **河为动线轴**、弱铺装；与镇心“paved pathways”做对比。  
3. **海滩规则**：宽沙 + pier 硬边 + 周末空地节点（排球）；Inn/Diving 挂在 pier。  
4. **双层地表**：松散美术（或大块贴图）+ **投影网格 data** 驱动耕作/寻路；不要强迫所有艺术对齐格子缝。  
5. **耕地用 16 态邻接** 丰富地表；环境草可另 pass、多变体，避免单 tile 平铺。  
6. **建筑面朝所在区的主步行轴**（街 / 河岸 / 码头），用叙事立面区分区身份（如 Joglo = 工匠坡地）。  
7. **NPC = 条件日程文件 + 职业锚点 + 到达动画**；路径算法可自研，但锚点必须落在功能节点。  
8. **节日广场与日常广场拆开**；可用临时导向道具（umbul-umbul）拉人流。  
9. **水：作者预埋洞（池塘）+ 区级水体身份（河轴/湖桥/海岸沙带）**；沙草过渡无公开算法时，用手摆过渡带 + damp bank。  
10. **组装顺序**：zone → spine → water mask → ecology → paving → buildings → props → foliage → NPC → light。

---

## Sources

### Primary / high-trust

| 主题 | URL |
| --- | --- |
| 7 区域文案、农场在左、Woodlands vs paved town | https://www.kickstarter.com/projects/coralisland/coral-island-reimagining-the-farm-sim-game |
| Smart tile（16 textures）、grid overlay、动态光、农场轮廓 | https://blog.stairwaygames.com/post/april-2020-dev-update |
| Smart tile & grass 预告、Alembic 清杂 | https://blog.stairwaygames.com/post/march-2020-dev-update |
| NPC 条件日程 | https://blog.stairwaygames.com/post/may-2020-dev-update |
| 河/湖/海钓鱼；雨风环境 | https://blog.stairwaygames.com/post/july-2020-dev-update |
| 白沙海滩 showcase；Theo 活动动画；coop 7×4 | https://blog.stairwaygames.com/post/coral-island-october-2020-dev-update |
| Joglo 木匠立面改版 | https://blog.stairwaygames.com/post/april-2021-dev-update |
| 环境草全图铺设；umbul-umbul 导向；Woodlands 开放 | https://blog.stairwaygames.com/post/november-2021-dev-update |
| Art pillars、art guide、gameplay-first → 建筑后置 | https://blog.stairwaygames.com/post/swag-crew-damas-nawanda-co-art-director |
| UE + Blueprints；Disney 向美术；Lojaya 环境方向 | https://www.unrealengine.com/en-US/developer-interviews/coral-island-inside-the-chill-farm-sim-reinventing-the-genre |

### Community wiki（地理交叉验证，非引擎源码）

| 主题 | URL |
| --- | --- |
| 区域列表（与 Kickstarter 对齐） | https://coralisland.fandom.com/wiki/Map |
| 农场西侧、固定池塘 | https://coralisland.fandom.com/wiki/Farm |
| Garden Lane 绿缓冲 | https://coralisland.fandom.com/wiki/Garden_Lane |
| 海滩 / pier / Diving | https://coralisland.fandom.com/wiki/Beach |
| Alun-Alun 节日广场 | https://coralisland.fandom.com/wiki/Alun-Alun_Square |

### Secondary（低置信）

| 主题 | URL |
| --- | --- |
| Maya/ZBrush/Substance 管线转述 | https://foro3d.com/2026/mayo/coral-island-el-pipeline-artistico-para-un-paraiso-tropical-en-ue4.html |

---

*Research date: 2026-09-10. CRAFT-only. Prefer Stairway / Kickstarter / Unreal quotes; mark layout inferences from copy as [low confidence] when no technical dump exists.*
