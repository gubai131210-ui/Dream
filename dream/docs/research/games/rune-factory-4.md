# Rune Factory 4 / RF4 Special — 村镇分区 CRAFT 技术笔记

> Scope: **Selphia 村镇空间骨架与场景可读性手法**（分区、路网/广场、河湖与桥、门朝向、NPC 日程动线、地面分层与防重复）。不含战斗/恋爱数值/订单经济综述。  
> 面向：Godot 4 TileMap 村镇项目（RF4 本体为 3D 场景屏，规则做**空间语法迁移**，非照搬引擎层）。  
> 信任优先级：任天堂《社长が讯く》/ Marvelous 官方材料 → 经交叉验证的 wiki·Ranch Story 区位 → Omnigamer 挖矿表 → 高引用攻略 FAQ（标二级）。弱证据标 **[low confidence]**。

---

## Techniques

### 1. 广场 / 住宅 / 农场 / 商店街 — 空间骨架差异

Selphia 不是单屏开放城，而是 **命名分区 + 屏间出口** 的图结构。Ranch Story 把城镇户外分为至少：Observatory、Airship Way、Dragon Lake、Housing Area、Town Square、Melody Street；攻略与事件 FAQ 用同一套地名做导航。

| 分区 | 功能身份 | 空间读感（可观察） | 关键锚点建筑 |
| --- | --- | --- | --- |
| **Town Square（广场）** | 市政/社交枢纽 | 开敞；城堡正面；通往东西南北的度中心 | Selphia Castle 正面、出门南向平原 |
| **Melody Street（东）** | 商店街 | 街廊式：出广场东口即店面带 | Sincerity General Store、Carnation's、Margaret's House |
| **Housing Area（西，下台阶）** | 住宅 + 服务 | 比广场更“巷道”；诊所/铁匠/住宅并置 | Tiny Bandage Clinic、Blacksmith "Meanderer"、Forte's House；北穿路径接 Airship Way |
| **Airship Way（北脊）** | 交通/住宿/餐饮 | 东西向干道；西端旅馆、途中餐厅、飞艇停靠 | Bell Hotel、Porcoline's Kitchen、Airship、Telecommunicator |
| **Dragon Lake（西南/西端）** | 水岸游憩 | 开阔水面 + 可站立沙岸；事件常在此开场 | 钓鱼教程默认湖；非广场喷泉 |
| **Farm（城堡背后）** | 生产田 | 与市政立面分离：从城堡后门进田；田北上接 Airship Way | 可扩展田块、Monster Barn；清空后刷树桩/石 |

**骨架规则（高置信）**

1. **一个度中心广场** 连接异功能街廊，而不是把商店和农田摊在同一开敞面。  
2. **商店街 = 东廊、住宅服务 = 西廊**（相对 Town Plaza 的左右分工在 wiki 与多篇定位攻略一致）。  
3. **农场藏在城堡背后**，玩家从“住/政”穿到“田”，再北出到交通脊 — 生活轴与生产轴分层。  
4. **旅馆/餐厅挂在北脊**，不挤占广场开敞面；从 Housing 北穿（铁匠与 Forte 宅之间）可到 Bell Hotel。  
5. 区与区之间常用 **台阶 / 窄径 / 命名出口** 做心理边界（Town Square 西出下台阶进 Housing）。

来源：[Ranch Story — Selphia 分区](https://ranchstory.miraheze.org/wiki/Category:Selphia_(Rune_Factory_4))、[Selphia（Fandom 区位描述）](https://therunefactory.fandom.com/wiki/Selphia)、[Selphia Castle — 农场在城堡后、北上 Airship Way](https://therunefactory.fandom.com/wiki/Selphia_Castle)、[Guide Strats — Melody 东出 / Housing 西出台阶](https://guidestrats.com/rf4-sincerity-general-store/)、[Guide Strats — Bell Hotel 路径](https://guidestrats.com/rf4-bell-hotel/)、[Guide Strats — 农场北上飞艇](https://guidestrats.com/rf4-floating-empire-location/)、[IGN Locations — 镇内空屋与有限野外田](https://www.ign.com/wikis/rune-factory-4/Locations)

**Godot 可落地**

- 用 **多 `TileMap` 屏或单一大图 + `zone_id` 自定义数据** 实现命名分区；广场格 `zone=plaza`，商店街 `zone=retail`，住宅 `zone=housing`，田 `zone=farm`，北脊 `zone=transit`，湖岸 `zone=waterfront`。  
- 组装顺序建议：先锁 **plaza 矩形开敞** → 东 retail 单列店门 → 西 housing 服务带 → 北 transit 走廊 → 城堡北侧 farm → 西/西南 lake。

---

### 2. 路网与广场开敞度

**广场**

- Town Square 是事件、闲逛、出城南门的 **开敞汇合面**（幽灵事件、婚姻相关过场等多处“走到广场/南出口”触发）。  
- 广场 **不是纯石板死面**：Omnigamer 挖矿显示 Town Square 搜索点含 Rock（极常）、Green Grass（很常）— 开敞面上混有草/石可交互点，避免“空停车场”感。

**路网**

- 功能街（Melody / Housing / Airship）是 **窄于广场的通道**，建筑贴边、门开向通道。  
- 连接型路径：Housing 内 **铁匠与 Forte 宅之间的北向窄径** → Airship Way（旅馆），说明次级巷道专门服务“到北脊”。  
- 出城：广场南 → Castle Gate / Selphia Plain（野外图另起一层桥闸，见下节）。

**可读性启发（玩家 FAQ 路径即路网证明）**

Karin18 的晨间巡查路径编码了图：房间 → 广场 → 西 → 北进旅馆 → 餐厅 → 南进 Melody（花店/杂货）→ 回广场进城堡管家区 → 再西诊所/铁匠/Forte 宅。这是一条 **覆盖所有命名区锚点的 Hamilton 式环**，说明布局为“少环、多锚点、广场可折返”。

来源：[Karin18 Town Event FAQ — 巡查路径](https://gamefaqs.gamespot.com/3ds/635388-rune-factory-4/faqs/69308)、[Ranch Story Town Square / 搜索点](https://ranchstory.miraheze.org/wiki/Category:Selphia_(Rune_Factory_4))、[Omnigamer Datamining Compendium](https://docs.google.com/spreadsheets/d/1UPdNZGUyHLMOTYWqz5KJYCnR0ZnsMENifPi4UAVZeV8/)、[Ghost 事件四区：Airship / Melody / Housing / Town Square](https://guidestrats.com/rf4-walkthrough-part-4/)

**Godot 可落地**

1. 广场：中心留 **≥ 一段无建筑开敞**（事件舞台）；周边建筑退线。  
2. 主路用 `surface=stone`，巷道 `dirt`，广场边缘可混 `grass` 装饰格。  
3. Navigation：广场 travel_cost 低；禁止 NPC 穿花坛可用 `NoPath` 等价自定义数据。

---

### 3. 河流与桥、建筑门朝向

#### 3.1 镇内水：湖主导，河次之

- **Dragon Lake**：镇内主钓鱼水体；攻略明确在 **褐色沙地** 站立抛竿，站在草上浮漂常弹回岸 — 即 **水缘有专用沙岸带**，不是草直接贴水。湖在城镇西南端，西过诊所一带可达。  
- **Housing Area 内有河**：同一攻略对比“湖抛竿空间大、河抛竿空间更挤” — 镇内存在 **窄河道** 与 **开敞湖** 两套水语法。  
- **广场喷泉/浅水 ≠ 可钓鱼面**（浮漂弹开）— 装饰水与可玩水分离。  
- 湖区搜索点独有 Pike/Squid 等鱼相关项，且 Rock/Green Grass 极常 — 水岸生态与广场不同。

#### 3.2 镇外桥：廊道闸门

Selphia Plain 的桥是 **剧情解锁的跨屏连接器**，不是自由造景：

| 桥/闸 | 作用 |
| --- | --- |
| Volkanon Bridge（Plain West） | 调查 Obsidian Mansion 任务后可建/通行 |
| Mush Span 一带桥 | 通向 Water Ruins / Plain East |
| Cerezo / Sercerezo 桥 | Leon 救出后 Doug 告知才可用 |
| 南向倒木闸 | Volkanon 清障后才进 Water Ruins 路线 |

规则迁移：**桥 = 平行河岸锚点 + 任务/进度门**；桥面宽对应可走带，河宽保持“廊道”而不是散漫水洼。

#### 3.3 门朝向

- RF4/Special 为 **固定相机 3D 场景**；店面与住宅入口面向所在街的走道（Siliconera 官方截图巡礼：铁匠、诊所、杂货、花店立面均朝玩家接近路径可读）。  
- 城堡三门朝向 Town Square 一侧（市政立面）；城堡各段另有后门通农场。  
- **[low confidence]** 未找到公开的“全部门必须南向”硬编码；更像是 **立面朝向所属道路中心线**，与 ACNH 的全局南门锁不同。迁移时：门法线指向最近主路/广场，而不是任意 yaw。

来源：[Guide Strats — 沙岸抛竿 / Housing 河 / 湖地图标注](https://guidestrats.com/rf4-fishing-rod/)、[GameFAQs — Dragon Lake 在镇西诊所外](https://gamefaqs.gamespot.com/3ds/635388-rune-factory-4/answers/358578-where-is-selphia-dragon-lake)、[Ranch Story — Dragon Lake 搜索点含鱼](https://ranchstory.miraheze.org/wiki/Category:Selphia_(Rune_Factory_4))、[Selphia Plain 桥解锁表](https://therunefactory.fandom.com/wiki/Selphia_Plain)、[World Map 桥注](https://therunefactory.fandom.com/wiki/User_blog:Snowsiren/World_Map_(RF4))、[Water Ruins 路径含桥](https://guidestrats.com/rf4-water-ruins-location/)、[Siliconera — Selphia 店面截图巡礼](https://www.siliconera.com/rune-factory-4-screenshots-take-you-on-a-tour-of-selphia-city/)、[Selphia Castle — 后门通农场](https://therunefactory.fandom.com/wiki/Selphia_Castle)

**Godot 可落地**

1. 湖：`water` 掩码 + 环带 `sand`/`damp`；草不直接贴可钓深水。  
2. 装饰喷泉用无 `fishable` 标记的浅水或 prop。  
3. 窄河宽约 2–3 tile、湖开口 ≥ 广场级开敞。  
4. 桥：河宽 3–5、两岸各留可走锚；可选 `story_gate`。  
5. 建筑：门朝 `nearest_road_or_plaza`；城堡/市政正面朝 plaza。

---

### 4. NPC 日程动线

#### 4.1 设计意图（一手）

《社长が讯く》中，はしもとよしふみ强调：不要无名店员重复同一句台词；要让每个有名字的人因时间、季节、天气改变行动与台词；目标是“小而丰富的小宇宙”，玩家起床会想“今天下雨了，那个人会在做什么”。岩田侧用霍比特人村落类比。

→ 场景层含义：**日程可见性依赖可预测的地点锚点 + 天气/时段分支**，而不是全图布朗运动。

#### 4.2 可观察的锚点模式（高置信行为，非完整时刻表 dump）

| 模式 | 例子 |
| --- | --- |
| **职场时段锁门** | 杂货店平日 9:00–18:00、假日缩短；铁匠类似；浴场 10:00–22:00 |
| **住→职→晚间社交** | Forte：早巡城/训练，夜晚在餐厅演奏（角色页与攻略一致） |
| **事件覆写日程** | Town Events 把人拉到 Dragon Lake、Melody、Housing 诊所前、Airship、广场等 **区级舞台** |
| **清晨迁移动画可读** | FAQ：约 6:15 若有人朝某区奔跑，多半是事件日 — NPC 使用区际路径而非瞬移到最终点 **[观察级；实现细节 low confidence]** |
| **地图 UI 暴露位置** | Special/3DS 可用键打开镇图看到角色精灵所在屏 — 布局必须让“人在哪一区”有意义 |

完整逐小时官方表：**未在一手源公开**；Fandom 角色 Schedule 节常为空或不全 → 迁移时用 **稀疏锚点**（家 / 店柜台 / 广场 / 湖岸 / 餐厅二楼）即可，不必复刻全表。

来源：[社长が讯く vol.19 — RF4](https://www.nintendo.co.jp/3ds/interview/creators/vol19/index.html)、[Nintendo Everything 英文摘要](https://nintendoeverything.com/iwata-asks-rune-factory-4-details/)、[Siliconera GDC — 活人村落哲学](https://www.siliconera.com/rune-factory-producer-talks-design-philosophy-at-gdc/)、[Forte 早巡与夜演奏](https://therunefactory.fandom.com/wiki/Forte)、[杂货营业时间](https://guidestrats.com/rf4-sincerity-general-store/)、[浴场时间](https://guidestrats.com/rf4-bell-hotel/)、[Karin18 — 6:15 奔跑与巡查环](https://gamefaqs.gamespot.com/3ds/635388-rune-factory-4/faqs/69308)、[Neoseeker Town Events 区级舞台](https://www.neoseeker.com/rune-factory-4/walkthrough/Town_Events)、[Town Events (RF4) wiki](https://therunefactory.fandom.com/wiki/Town_Events_(RF4))

**Godot 可落地**

- Resource：`{time, zone_or_marker, face, weather_branch}`。  
- 图：plaza / retail / housing / transit / waterfront / farm 节点 + 出口边。  
- 日常：店员站柜台时段；离岗回住宅；晚间 1 个社交枢纽（餐厅/旅馆）。  
- 事件：临时把参与者 `warp_or_path` 到区级 marker，结束后恢复日程。

---

### 5. 地面分层与防重复

RF4 镇景是 **手摆 3D 地面材质 + 可搜索点**，不是 Stardew 式公开 autotile 规范。可迁移的是 **分区材质语义 + 交互点密度表**。

| 区类型 | 地面读感（证据） | 防平铺手段 |
| --- | --- | --- |
| Town Square | 开敞；Rock + Green Grass 搜索极常 | 草/石点缀打碎大铺装 |
| Melody / Housing / Airship | 路径感；Branch Uncommon 等路边物 | 街旁杂物/可搜点，非整街同贴图 |
| Dragon Lake | Rock/Grass + 沙岸抛竿带 + 鱼影 | 沙/草/水三带；湖面鱼影运动 |
| Farm | 田块网格；清空后刷树桩与石 | 生产格与刷宝格交替，避免永久空土 |

Omnigamer 表被 Ranch Story 引用为 Search Spot 一手数据 — **按区配置不同掉落权重** 本身就是“地面有地方差异”的数据层。

季节：镇外有四季固定田（Airship 网络）；**[low confidence]** 镇内地表是否季节换贴图未在挖矿笔记中单独证实，Special 主要为画质/系统增强。

来源：[Ranch Story 各区 Search Spots + Omnigamer 引用](https://ranchstory.miraheze.org/wiki/Category:Selphia_(Rune_Factory_4))、[Omnigamer 表](https://docs.google.com/spreadsheets/d/1UPdNZGUyHLMOTYWqz5KJYCnR0ZnsMENifPi4UAVZeV8/)、[Reddit 挖矿说明](https://www.reddit.com/r/runefactory/comments/he3uu4/rf4_datamining_compendium_values_for_everything/)、[Guide Strats — 农场刷木材石材](https://guidestrats.com/rf4-lumber-material-stone-farming/)、[IGN — 有限野外季节田](https://www.ign.com/wikis/rune-factory-4/Locations)

**Godot 可落地**

- 层：`ground`（永久材质）→ `deco_spawn`（按 `zone_id` 权重刷草/石/枝）→ `paths`。  
- 广场：石板 + 低频草/石 deco；湖岸：强制 sand ring；街廊：dirt/stone 条带 + branch 类 prop。  
- 多变体 atlas + 区表，禁止单草 tile 全镇平铺。

---

### 6. 可迁移到 TileMap 的规则（给 Dream）

1. **分区图优先于单屏美化**：`plaza | retail | housing | transit | waterfront | farm` 六类，出口命名。  
2. **功能不混面**：商店街单侧或双侧店门；住宅+诊所/铁匠在另一廊；田在市政体块背后；旅馆/餐厅在交通脊。  
3. **广场开敞度**：度中心、可作事件舞台；南向或主出口通向野外。  
4. **高差/台阶** 作为区界信号（Square ↔ Housing）。  
5. **水双语法**：开敞湖 + 沙岸可钓；窄河次之；装饰喷泉不可钓。  
6. **桥是闸门**：两岸锚点 + 可选剧情锁；对齐本仓库 `LAYOUT.md` 的 3–5 宽廊道。  
7. **门朝路/朝广场**，城堡正面朝 plaza；后门通生产区。  
8. **NPC = 稀疏锚点日程 + 区图寻路**；事件覆写到区级 marker；营业时间锁柜台。  
9. **地面按区配 deco 权重表**（广场草石、湖岸沙、街旁枝），对齐 `SEAMLESS.md` 生态带。  
10. **组装 pass**：zones → plaza 开敞 → 街廊路 → 水/沙岸 → 桥闸 → 建筑门朝向 → deco 表 → NPC 锚点。

对齐 Dream 现有：`LAYOUT.md`（蜿蜒河、北侧宅、桥带）、`SEAMLESS.md`（生态草）、广场组装器 — RF4 贡献的是 **多分区骨架** 与 **湖岸沙带 / 职场时段锚点**，不是新的水 shader。

---

## Math/procedural（实现备忘）

```text
# Zone graph (概念)
nodes = {plaza, retail_E, housing_W, transit_N, waterfront_SW, farm_behind_castle}
edges = plaza-retail, plaza-housing (stairs), plaza-south_gate,
        housing-transit (alley), farm-transit, housing-waterfront, ...

# Door facing
door_normal = normalize(nearest_walkable_centroid(plaza_or_road) - building_foot_center)

# Lake bank
for cell in water_neighbors:
  if depth_ok: prefer sand else damp_grass
fishable = water AND NOT decorative_fountain

# Bridge gate
span_ok = water_width in [3,5] AND land_anchor_W AND land_anchor_E AND story_flag

# Deco spawn (zone table sketch)
plaza:   rock=very_common, green_grass=very_common
lake:    rock=very_common, green_grass=very_common, fish_items=uncommon
street:  branch=uncommon, herbs=common
```

未见高信任源：村镇主地形用 Perlin 大范围生成；Selphia 为 **设计师分区手摆**。

---

## Asset pipeline notes

- 原作：**3D 场景 + 角色模型**（3DS 立体视强化在《社长が讯く》中明确为表现重点），不是 16×16 像素 TileMap。  
- 迁移到 Dream：只借 **平面分区语法与门/路/水关系**；屋顶 Y-sort、tile 接缝仍跟本仓库艺术家/工程师笔记。  
- 官方视觉参考：Siliconera 2012 店面巡礼截图；Marvelous RF4 官网/博客（角色与世界宣传，非关卡 GDD）。

---

## Agent-transferable rules（摘要）

1. 先画 **六区图**，再填装饰。  
2. 广场开敞；东店西宅；北交通；田在城堡后；湖在西/西南。  
3. 湖要沙岸；河要窄；喷泉不可钓。  
4. 桥 = 锚点 + 闸。  
5. 门朝路/广场。  
6. NPC 锚点日程 + 事件拉到区舞台。  
7. 地面 deco **按区权重**，破平铺。

---

## Sources

### Primary / high-trust

| 主题 | URL |
| --- | --- |
| 社长が讯く『ルーンファクトリー４』（时间/天气影响行动、小宇宙） | https://www.nintendo.co.jp/3ds/interview/creators/vol19/index.html |
| 同上（3DS 立体视与表现） | https://www.nintendo.co.jp/3ds/interview/creators/vol19/index4.html |
| Iwata Asks 英文摘要 | https://nintendoeverything.com/iwata-asks-rune-factory-4-details/ |
| GDC 设计哲学（活人村） | https://www.siliconera.com/rune-factory-producer-talks-design-philosophy-at-gdc/ |
| 官方店面截图巡礼 | https://www.siliconera.com/rune-factory-4-screenshots-take-you-on-a-tour-of-selphia-city/ |
| Marvelous RF4 官网（系列入口） | https://www.marv.jp/special/game/3ds/runefactory4/ |
| Omnigamer 挖矿总表（Search Spot 等） | https://docs.google.com/spreadsheets/d/1UPdNZGUyHLMOTYWqz5KJYCnR0ZnsMENifPi4UAVZeV8/ |

### Location / layout（交叉验证 wiki · 攻略）

| 主题 | URL |
| --- | --- |
| Selphia 分区与 Search Spots | https://ranchstory.miraheze.org/wiki/Category:Selphia_(Rune_Factory_4) |
| RF4 Special 分区目录 | https://ranchstory.miraheze.org/wiki/Category:Selphia_(Rune_Factory_4_Special) |
| Selphia 东西廊描述 | https://therunefactory.fandom.com/wiki/Selphia |
| 城堡 / 农场 / Airship 关系 | https://therunefactory.fandom.com/wiki/Selphia_Castle |
| Plain 桥解锁 | https://therunefactory.fandom.com/wiki/Selphia_Plain |
| World Map 桥注 | https://therunefactory.fandom.com/wiki/User_blog:Snowsiren/World_Map_(RF4) |
| Melody 东出杂货店 | https://guidestrats.com/rf4-sincerity-general-store/ |
| Housing 台阶与 Bell Hotel | https://guidestrats.com/rf4-bell-hotel/ |
| 湖沙岸 / Housing 河 / 抛竿 | https://guidestrats.com/rf4-fishing-rod/ |
| 农场北上飞艇路 | https://guidestrats.com/rf4-floating-empire-location/ |
| Water Ruins 桥廊 | https://guidestrats.com/rf4-water-ruins-location/ |
| 四区幽灵事件 | https://guidestrats.com/rf4-walkthrough-part-4/ |
| IGN Locations | https://www.ign.com/wikis/rune-factory-4/Locations |

### NPC / events（二级但高引用）

| 主题 | URL |
| --- | --- |
| Karin18 晨间巡查环与 6:15 奔跑 | https://gamefaqs.gamespot.com/3ds/635388-rune-factory-4/faqs/69308 |
| Town Events 区舞台 | https://therunefactory.fandom.com/wiki/Town_Events_(RF4) |
| Neoseeker Town Events | https://www.neoseeker.com/rune-factory-4/walkthrough/Town_Events |
| Forte 日程叙述 | https://therunefactory.fandom.com/wiki/Forte |
| Dragon Lake 区位 Q&A | https://gamefaqs.gamespot.com/3ds/635388-rune-factory-4/answers/358578-where-is-selphia-dragon-lake |
| Omnigamer Reddit 说明 | https://www.reddit.com/r/runefactory/comments/he3uu4/rf4_datamining_compendium_values_for_everything/ |

---

### Confidence legend

| 标记 | 含义 |
| --- | --- |
| （无标记） | 多源交叉或官方/挖矿直接支持 |
| **[low confidence]** | 单源观察、缺公开代码、或从截图推断 |

*Research date: 2026-09-10. RF4 Special 沿用 Selphia 分区骨架；craft 结论以区位与官方设计访谈为准，不以 Special 画质差异另立体系。*
