# Fields of Mistria — 场景/环境 CRAFT 技术笔记

> Scope: **2D 村镇/农场/瓦片场景制作手法**（布局骨架、水岸、建筑朝向、NPC 动线、贴图反重复、公开制作流程、可迁移规则）。不含类型标签/玩法综述。  
> 面向：Godot 4 TileMap 村镇项目 Dream。  
> 信任优先级：官方站点与团队仓库 / wiki.gg 一手页面 / 经交叉验证的地图与日程数据。证据不足标 **[low confidence]**。

---

## Techniques

### 1. 城镇中心 / 住宅带 / 农场：布局骨架差异

FoM 把世界切成 **多区域房间**（farm / town / corridor），用连接口与桥作图论边，而不是一张无尽连续大地图。

| 带 | 开敞 / 密度 / 路 | 锚点 | 证据 |
| --- | --- | --- | --- |
| **城镇中心（Mistria）** | 高建筑密度；南北 **主路** 贯通南入口；中部开敞空间给喷泉/市集 | **大喷泉**（Blacksmith 西、Bathhouse 东）；南段 **Inn ↔ General Store** 夹主路；北端 **Manor 山丘** | [wiki.gg Mistria](https://fieldsofmistria.wiki.gg/wiki/Mistria)；[TechRaptor 编号图](https://techraptor.net/gaming/guides/fields-of-mistria-map-and-locations) |
| **住宅/边缘带** | 低密度；木栅栏院子；在「城南门外」沿主路外侧 | **Celine 小屋**（城与农场之间）+ 对侧 **Balor 货车**；小屋有季节花圃 | [wiki.gg Celine's Cottage](https://fieldsofmistria.wiki.gg/wiki/Celine%27s_Cottage)；[Mistria § Balor / Celine](https://fieldsofmistria.wiki.gg/wiki/Mistria) |
| **农场** | 大开敞可耕地；建筑稀疏且可搬（农舍除外）；河作东界 | 固定 **Farmhouse + Shipping/Mailbox 两侧**；东侧 **Caldarus 神像**；河对岸扩张 + **Starter Farm Bridge** | [wiki.gg Farm](https://fieldsofmistria.wiki.gg/wiki/Farm)；[Escapist 扩张](https://www.escapistmagazine.com/how-to-build-farm-expansion-in-fields-of-mistria/) |
| **走廊区（Eastern Road / Narrows）** | 中低密度；线状路径 + 少量 POI；水岸长 | 东：木匠铺、桥、池塘、许愿井；西：博物馆、矿洞、河岸小屋 | [Eastern Road](https://fieldsofmistria.wiki.gg/wiki/The_Eastern_Road)；[The Narrows](https://fieldsofmistria.wiki.gg/wiki/The_Narrows) |

**骨架读法（可迁移）**

1. **北高南低的权力/仪式轴**：Manor 在「最北山丘」+ 东西园（西园大池塘 + 石碑；东园季节花 + **河** + 凉亭）。  
2. **中部对称 civic pair**：喷泉两侧各一服务建筑（铁匠 / 浴场），把开敞广场钉死。  
3. **南商业夹道**：主路西 Inn、东杂货店；再东南 Mill。  
4. **城外缓冲住宅带** 再接到 Farm（Farm 在 Mistria **正南**）。  
5. **桥 = 进度门 + 图边**：Eastern Road 桥修复解锁周六市集；农场扩张赠桥跨河。

**路宽 / 确切瓦片密度** — 公开文档无数值。TechRaptor 把 Fountain 与 Town Square 分列，暗示喷泉区与更南的广场是两块开敞面，而非单格路口。**[low confidence]** 对具体「路宽 = N tile」的视觉估测。

**Godot 可落地**

- 用 `RegionBand` 枚举：`CIVIC` / `RESIDENTIAL_BUFFER` / `FARM` / `CORRIDOR`，每带不同 `building_density`、`open_plaza_min`、`path_prefer`。  
- 先锁 **3 个锚点**：北仪式建筑、中喷泉/广场、南主路夹道商店；再铺住宅缓冲；农场另场景或另 mask。  
- 桥作为 `GraphEdge` 资源：`from_region` / `to_region` / `repair_flag`，断桥则 NPC 日程走备用支（见 §4 周六前后日程分叉）。

---

### 2. 河流 / 河岸 / 草地分层

**水类型是逻辑枚举，不是「看起来蓝」**

| 类型 | 出现区位 | 备注 |
| --- | --- | --- |
| **Pond** | Manor 西园大池；Eastern Road 南部「larger pond」；Deep Woods | 社区描述：能看见大部分岸线的封闭水体 **[low confidence 形态学]** |
| **River** | Farm、Mistria、Eastern Road、Narrows | Farm 河上 **2 个** 主动钓鱼点（grandwiki 计数） |
| **Ocean** | Western Ruins、Sweetwater Farm、Beach | 西/南边界海域；部分不可潜水 |
| **装饰水** | 城镇喷泉 | **可浇不可钓** |

来源：[wiki.gg Fishing § Locations](https://fieldsofmistria.wiki.gg/wiki/Fishing)；[Manor Gardens](https://fieldsofmistria.wiki.gg/wiki/Manor_House)；[grandwiki fish planner](https://fieldsofmistria.grandwiki.com/fish/)（非官方但与 wiki 水类一致，点位计数标 **[low confidence]** 至交叉验证）。

**河岸与互动层**

- **钓鱼目标格**：蓄力显示方形预览；非法格红 X — 水体可走/可游 ≠ 可钓。  
- **阴影鱼群** 在水面游动；偶发 **School** 团块。  
- **Dive Hole**：水中「暗洞」可游近潜水；与河岸贴图独立。  
- Errol 小屋 **沿河**；Manor 东园有 **river**，西园有 **large pond** — 同一庄园双水体语法。  
- Farm：**河在东侧划界**；扩张解锁河对岸地块 + 桥。

**草地 / 可耕地分层（农场）**

- 可耕地 = 可见 **dirt patches**；铲可在 dirt ↔ 非农草之间切换；锄后下种。  
- 碎片（草/石/枝）与树会再生；不毁作物但占建造/种树格。  
  来源：[wiki.gg Farm § Crops / Debris](https://fieldsofmistria.wiki.gg/wiki/Farm)

**城镇草地反重复公开规则** — 未见官方「草变体 ID / 距离场」文档。季节换外观（小屋外景四季图）是确定手段（见 §5）。

**Godot 可落地**

1. `WaterKind` 自定义数据：`pond|river|ocean|decor`；`fishable` / `diveable` 布尔。  
2. 钓鱼点 = 稀疏 `Marker2D` / 单元格集合，**不要**对整条河每格可钓。  
3. Farm：`tillable` mask 与 `meadow` 分离；河 mask 蜿蜒 + bank 环 + 桥跨。  
4. Manor 式双水体：仪式区可同时有 **封闭塘** 与 **过境河**。

---

### 3. 建筑朝向与门对公共空间

**已证实的公共前场行为**

- 铁匠：**铁砧在建筑外侧**，玩家在喷泉旁公共空间锻造。  
- 木工台：Bell Tower **东侧小院**，Ryis/Hayden 常在此公开作业。  
- 周六市集：摊位在 **镇中心 / 喷泉一带**（任务文案「around the big fountain」）。  
- Inn / General Store：**隔主路相对** — 门厅语义朝向共享道路。  
- Celine 住宅：木栅栏围 **私密前庭花圃**；日程大量使用 `Town: Celine's Garden` / `Cottage Bench` 等户外锚点。

来源：[Mistria](https://fieldsofmistria.wiki.gg/wiki/Mistria)；[Quests — Greet the Vendors](https://fieldsofmistria.wiki.gg/wiki/Quests)；[Celine/Schedule](https://fieldsofmistria.wiki.gg/wiki/Celine/Schedule)。

**门朝向角度** — 像素精灵默认朝南/朝相机的硬规则 **未** 见官方声明。从「喷泉两侧建筑 + 主路夹店」可推断门对公共开敞，但 **精确 facing 向量 [low confidence]**。

**Godot 可落地**

- Civic 建筑：`door_facing = TOWARD_PLAZA_OR_MAIN_PATH`；生产互动 props（砧、工作台）放在 **door 前 apron**，勿埋进后巷。  
- 住宅：`fenced_yard` + 季节作物格；门可对小路，但保留 1 格以上前庭。  
- 农舍：固定 footprint；附属建筑可搬 — 对应 Dream 的 `FARM_BUILD_ZONE` 与可重放置蓝图。

---

### 4. NPC 动线

**日程 = 时间戳 → 命名目的地（非自由漫游）**

以 Celine 为例（春季晴日）：

| 时间 | 目的地（摘录） |
| --- | --- |
| 06:00 | `Town: Celine's Garden` / `Cottage Bench` / 室内 |
| 中段 | `General Store: Shift`、`Eastern Road: Routine`、`Hayden's Farm: Chores`、`Clinic: …`、`Beach: Picnic Bench` |
| 晚间 | `Inn: North Table` / `Bar` → `Celine's Room` |

- **季节表** × **星期** 分表。  
- **雨天**：独立 4 套 `Rainy Day #1…#4` + 冬季变体，由 rainy **tracker/counter** 轮换 — 不是简单「全员躲雨」。  
- **剧情门控分叉**：周六在 `Repair the Bridge` 前后走不同表（修桥后出现 `Town: Routine` 市集向）。  
- **周收敛**：周五夜全员 Inn；周六市集全员 + 外来摊主围喷泉。  
- 实时地图显示村民位置（评测常见点；与日程系统一致）。

来源：[Celine/Schedule](https://fieldsofmistria.wiki.gg/wiki/Celine/Schedule)；[Mistria Events](https://fieldsofmistria.wiki.gg/wiki/Mistria)；[官方 Team — Ward Archibald: NPC Schedule Implementation](https://www.fieldsofmistria.com/team)；[grandwiki map — villager schedule playback](https://fieldsofmistria.grandwiki.com/map/)。

**路径几何** — 公开资料给的是 **目的地标签**，不给 A\* 代价或「只走路砖」的代码。跨区日程（Farm ↔ Town ↔ Beach ↔ Eastern Road）暗示存在 **可走图边**。**[low confidence]** 路权优先级数值。

**Godot 可落地**

```text
ScheduleEntry { tod: float, destination_id: StringName }
ScheduleSet { season, weekday, weather_key, entries[] }
# weather_key = sunny | rainy_0..n
# destination_id resolves to Marker2D / indoor slot
```

- 步行图只连 `path`/`plaza`/`bridge`；事件日把多 NPC `destination_id` 写到同一广场/酒馆。  
- 桥未修：禁用边 + 换 schedule 变体（对齐修桥前后表）。

---

### 5. 贴图 / 瓦片防重复手法

**有公开证据的手法**

| 手法 | 证据 | 置信 |
| --- | --- | --- |
| **季节换装地表/建筑外观** | Celine 小屋外景 Spring/Summer/Fall/Winter 分图；Manor 东园花季；果树按季结果 | 高 |
| **季节花圃 / 灌木产出** | 小屋花园按季种花；东园玫瑰夏 / 蔷薇果冬 | 高 |
| **玩家路径材料多样性** | 博物馆解锁 Color Paving Stones 等铺路（社区指南） | 中（玩法 wiki / 粉丝站） |
| **大量独立精灵而非巨型平铺贴图** | 官方称 farming RPG with *tons* of Sprites；Aseprite→引擎批量导入 | 高（流水线） |
| **16×16 逻辑格** | 玩家量建筑像素推得 tile=16 | **[low confidence]** |
| **调色板限色 / color ramp** | 第三方文章归纳 | **[low confidence]** — 非一手 |

未找到官方「草瓦片 8 变体 + 哈希选格」说明。反重复主要靠：**季节层、点缀 props、水体阴影/潜水点、碎片再生、手绘 POI**，而非公开的程序噪声公式。

**Godot 可落地**

- 草地：生态距离场选变体（Dream `mowed/meadow/tall/damp`）— 这是 **迁移推断**，不是 FoM 源码。  
- 建筑/住宅：准备 **季节 palette swap** 或季节 atlas 页。  
- 路径：多种 `Flooring` 材料 ID；广场用大块铺装，住宅带用碎石/土。

---

### 6. 公开美术 / 关卡制作流程

**概念 → 像素 → 引擎**

1. **早期环境概念**：Matt Cummings 三张定调 — homestead / bustling village / forest（2019 官方博文）。  
2. **角色与环境概念**：Yuko Ota（Character & Environment Concept Artist）。  
3. **主像素与动画**：Alina Sechkin（Lead Pixel Artist & Animator）+ Emma Suen-Lewis、Kerrie Lake 等。  
4. **管线**：Aseprite → GameMaker 资源；Jonathan Spira 开源支撑库  
   - [yy-typings](https://github.com/NPC-Studio/yy-typings)（YY/YYP 类型；为「海量 Sprite」服务；私有 Aseprite→GMS2 工具未公开）  
   - [yy-boss](https://github.com/NPC-Studio/yy-boss)（更高层资源 CRUD；已支持 **Sprites / Tilesets / Rooms** 等）  
5. **招聘口径**（历史 JD）：像素资产在 Aseprite 制作，并 **导入/落地到 GameMaker + 内部工具**。  
6. **关卡数据**：社区编辑器指向游戏目录 `starting_farms` 下 **`farm.json`** — 农场初始布局数据驱动（非官方文档，**[low confidence]** 格式细节）。  
7. **叙事落地分工**：Edward/Ward Archibald — Dialogue & Cutscene + **NPC Schedule Implementation**（日程是正式系统职责，不是装饰 AI）。

来源：[Concept Art: A First Look](https://www.fieldsofmistria.com/post/grow-your-blog-community)；[Team](https://www.fieldsofmistria.com/team)；[yy-typings README](https://github.com/NPC-Studio/yy-typings)；[yy-boss](https://github.com/NPC-Studio/yy-boss)；[Mistria-Editor 说明](https://github.com/brysonwood/Mistria-Editor)。

**Godot 对照**

- 概念草图锁定 **三条带**（农宅 / 热闹镇心 / 林缘）再画 tile。  
- 用脚本批量导入 sprite（类比 yy-boss），TileSet / 场景分房间。  
- 农场初始布局用 JSON/Resource，勿写死在单一场景。

---

## 可迁移数学 / 规则（摘要）

仅列有证据支撑或明确可推导者：

| ID | 规则 | 来源强度 |
| --- | --- | --- |
| R1 | `WaterKind ∈ {pond, river, ocean, decor}`；`decor`（喷泉）不可钓 | 高 |
| R2 | 可钓 ≠ 全水域：稀疏 **spot** + 预览格合法性 | 高 |
| R3 | 农场扩张 = 河对岸地块 + 桥实体/配方 | 高 |
| R4 | 日程：`(season, weekday, weather_variant) → [(tod, destination_id)]` | 高 |
| R5 | 雨天用 **轮换 tracker**，不是单表 | 高 |
| R6 | 周事件强制 **多 NPC → 单锚点**（Inn / Fountain） | 高 |
| R7 | 桥/楼梯修复 = 图边启用 + 可选 schedule 变体 | 高 |
| R8 | Civic 轴：北仪式丘 → 中喷泉对称店 → 南主路夹店 → 城外住宅缓冲 → 农场 | 高（布局描述） |
| R9 | 庄园双水体：西 **pond** + 东 **river** | 高 |
| R10 | 逻辑格 ≈ 16px **[low confidence]**；路宽无公开式 | 低 |

---

## Godot Dream 对照清单

- [ ] 村镇场景分 `CIVIC` / `RESIDENTIAL_BUFFER` / `FARM`（可与 corridor 分场景）  
- [ ] 喷泉/广场两侧成对服务建筑；主路南段对店  
- [ ] 水 mask + `WaterKind` + 稀疏 fish/dive 点  
- [ ] 河作农场东界；桥为边；bank 用 damp  
- [ ] 门对公共路径；生产 props 在 apron  
- [ ] NPC：`destination_id` 日程 + 天气 tracker + 周五/周六收敛  
- [ ] 季节 atlas / 花圃变体；勿指望 FoM 公开草噪声公式  

---

## Sources（URL）

**官方**

- https://www.fieldsofmistria.com/post/grow-your-blog-community  
- https://www.fieldsofmistria.com/team  
- https://www.fieldsofmistria.com/presskit  
- https://github.com/NPC-Studio/yy-typings  
- https://github.com/NPC-Studio/yy-boss  

**高信任社区 wiki / 数据**

- https://fieldsofmistria.wiki.gg/wiki/Mistria  
- https://fieldsofmistria.wiki.gg/wiki/Farm  
- https://fieldsofmistria.wiki.gg/wiki/Manor_House  
- https://fieldsofmistria.wiki.gg/wiki/Fishing  
- https://fieldsofmistria.wiki.gg/wiki/Celine%27s_Cottage  
- https://fieldsofmistria.wiki.gg/wiki/Celine/Schedule  
- https://fieldsofmistria.wiki.gg/wiki/The_Eastern_Road  
- https://fieldsofmistria.wiki.gg/wiki/The_Narrows  
- https://fieldsofmistria.wiki.gg/wiki/Quests  

**交叉验证（次级，已标置信）**

- https://techraptor.net/gaming/guides/fields-of-mistria-map-and-locations  
- https://www.escapistmagazine.com/how-to-build-farm-expansion-in-fields-of-mistria/  
- https://fieldsofmistria.grandwiki.com/map/  
- https://fieldsofmistria.grandwiki.com/fish/  
- https://github.com/brysonwood/Mistria-Editor  

---

*Research date: 2026-09-10. Scope = craft only.*
