# Story of Seasons / Harvest Moon — 场景 CRAFT 技术笔记

> Scope: **craft only**（空间骨架、路网、开敞度、功能锚点、水岸、地面铺装、建筑朝向、NPC 动线、规则/程序丰富度、素材绘制顺序）。  
> **不含**类型标签、玩法综述、剧情梗概。  
> 面向：Godot 4 TileMap 村镇项目 Dream。  
> 主线样本：**Friends of Mineral Town（2D）** + **A Wonderful Life / PoOT（3D→2D 可迁移布局）**。  
> 信任优先级：开发者访谈 / 官方攻略书经 wiki 标注引用 / Ushi No Tane（Fogu）地图与日程 / 高引用地图结构页。证据弱处标 **[low confidence]**。

---

## Techniques

### 1. 农场 vs 村落广场 vs 住宅区（骨架、路网、开敞度、锚点）

#### 农场（Farm）— 大开敞 + 固定设施岛 + 可塑田块

- **FoMT**：农场是**固定尺寸**封闭场景，内含农舍、畜舍、禽舍与大块耕地；耕地约 **25×43** 格，是画面与玩法的主开敞面。障碍（石/杂草/树桩）先清后耕。  
  来源：[Fogu — Your New Farm](https://fogu.com/sos3/farm/)、[Fogu MFoMT — Planting Seasonal Crops（43×25）](https://fogu.com/hm5/profit/seasoncrops.php)
- **出入口轴向**：农场**向北进村**、**向南进林** → 村庄在农场“北侧功能带”，田野占中南部开敞。  
  来源：[Fogu — Town Layout](https://fogu.com/hm5/town_layout.php)
- **设施锚点（不可当装饰乱摆）**：畜舍在**北入口右侧**；小型禽舍在农场**左下**；水车/饲料与禽舍相邻。农舍与畜舍形成“北缘建筑带”，田块在南侧大空地。  
  来源：[GameFAQs Building/Furnishing Guide](https://gamefaqs.gamespot.com/gba/589702-harvest-moon-friends-of-mineral-town/faqs/29518)
- **PoOT（3D，布局可迁）**：农场嵌在**森林拓荒**里——非一马平川空地；桥/瓦砾分区解锁；破败设施需修复后才能用。导演明确：把农场放进森林是为了“历史感 + 与自然相连”。  
  来源：[Eurogamer — Nakano interview](https://www.eurogamer.net/story-of-seasons-pioneers-of-olive-town-hopes-to-bring-new-life-to-the-series)、[Ranchstory — Your Farm (PoOT)](https://wiki.ranchstory.farm/index.php/Your_Farm_(Story_of_Seasons:_Pioneers_of_Olive_Town))（页脚引用官方ガイドブック）
- **开敞度**：农场 = **高开敞（田）+ 低密度建筑岛**；路网弱于村，以“田埂/围栏/设施间短走道”为主，而不是广场辐射路。

#### 村落广场（Plaza / Square）— 高开敞硬铺 + 礼仪/集会锚点

- **Rose Plaza（FoMT）**：镇东侧、南北镇区之间的**大石质广场**；多数节日在此；有告示板、垃圾桶；晴天下午村民聚集聊天。通往 **Mineral Beach** 的路从广场接出。  
  来源：[Ranchstory — Rose Plaza](https://ranchstory.miraheze.org/wiki/Rose_Plaza_(Story_of_Seasons:_Friends_of_Mineral_Town))（标注参考官方コンプリートガイド）、[Tartarus — Rose Square](https://tartarus.rpgclassics.com/hmfomt/town.shtml)、[LadiesGamers — Mineral Town map](https://ladiesgamers.com/the-map-of-mineral-town-in-story-of-seasons-fomt/)
- **Olive Town Plaza（PoOT）**：镇中心；**Olive Hall + Museum** 坐镇；左 Park、右 Harbor、北 Forest → 广场是**四向辐射的拓扑中心**，不是住宅死胡同。  
  来源：[Ranchstory — Olive Town Plaza](https://ranchstory.miraheze.org/wiki/Olive_Town_Plaza_(Story_of_Seasons:_Pioneers_of_Olive_Town))、[Marvelous Europe — Olive Town Map](https://marvelouseurope.github.io/SOSPOOT/page17.html)
- **开敞度**：广场 = **最大硬质开敞**；功能锚点是**厅/馆/告示/节日台/垃圾桶/摊位角**（Van 摊在广场一角），周边建筑**围合但不填满**中心。

#### 住宅 / 商业区 — 中等开敞、沿路串珠、分区簇

- **FoMT 南北分区**：  
  - **Northside**：民宅 + 市政/社交（Mayor、Ellen、Library、Church、Clinic、General Store、Inn、Winery…）  
  - **Southside**：畜牧/工艺（Yodel Ranch、Poultry、Forge）— 评论明确南区为“最下段路 + 四栋：三商一宅”。  
  - **Central**：Rose Plaza + Beach 廊道。  
  来源：[Ranchstory Rose Plaza 导航表](https://ranchstory.miraheze.org/wiki/Rose_Plaza_(Story_of_Seasons:_Friends_of_Mineral_Town))、[LadiesGamers map + Southside comment](https://ladiesgamers.com/the-map-of-mineral-town-in-story-of-seasons-fomt/)
- **路网**：窄硬质主路串门面；广场是“呼吸口”；住宅不是网格式大街区，而是**沿主路一侧或两侧贴路**。  
- **AWL 谷地（3D→2D）**：首次做成**整张连续谷地图**（无切屏镇图）；居住点沿谷地散落（Villa、Inn、Bar、Yurt…），**不是 FoMT 那种紧凑街廓**；河与桥成为骨架。  
  来源：[Ranchstory — Forget-Me-Not Valley (AWL)](https://ranchstory.miraheze.org/wiki/Category:Forget-Me-Not_Valley_(Harvest_Moon:_A_Wonderful_Life))、[Harvest Moon Paradise — valley west→east listing](https://harvestmoonparadise.com/hmpb/page.php?id=66)

| 区型 | 开敞度 | 路网 | 典型锚点 |
| --- | --- | --- | --- |
| 农场 | 田野极开敞 | 弱路 + 围栏边界 | 农舍/畜舍/水塘/田块 |
| 广场 | 硬铺极开敞 | 广场即节点，向海滩/南北镇放射 | 告示板、厅/馆、节日空地、垃圾桶/摊 |
| 住宅商业 | 中开敞（院/门前） | 沿主路串珠 | 店门、民宅门、教会 |

**Godot TileMap**

1. 三套 mask：`farm_field` / `plaza_stone` / `street`；开敞度用“无建筑格占比”约束，不要三区同密度。  
2. 农场：北缘 `building_band` + 南部大 `tillable`；村：`plaza` 矩形/异形硬铺 + 周围 `door_apron`。  
3. 分区用 named slots（Poultry / Forge / Civic cluster），对齐 FoMT North/South 簇。

---

### 2. 水流 / 灌溉 / 池塘边缘怎么铺

#### 系列常态：离散水体 + 工具灌溉，不是田间渠网

- **FoMT**：作物灌溉靠 **浇水壶**；水壶在农场 **Fish Pond / watering hole（马厩旁）** 取水；另有温泉、山湖、女神泉、海滩等**独立水体场景**，不是贯通全镇的灌溉渠。  
  来源：[Fogu — farm / Fish Pond & watering hole](https://fogu.com/sos3/farm/)、[Tartarus — Hot Spring / Lake / Beach](https://tartarus.rpgclassics.com/hmfomt/town.shtml)
- **岸线语义**：湖/泉 = 功能锚（冬冻可进湖矿、温泉回体、海滩钓鱼/捡草）；岸边用**场景切换或固定岸 tile**，不是程序 SDF。 **[low confidence]** 对 GBA 原作岸 tile 具体 bitmask（未见公开 tileset 规范）。

#### PoOT：池塘/湖是可交互地形岛 + 边缘放置点

- 农场 Area 2/3 有 **Pond / Lake**；抽水泵须放在池塘边缘的**方形放置点**；抽干出宝箱后池水会**回填清澈水**，数日后又变浑 → 岸边是“机位点 + 状态循环”，不是一次性装饰坑。  
  来源：[Polygon — water pump / edge placement](https://www.polygon.com/story-of-seasons-pioneers-of-olive-town-guides/22339999/water-pump-how-where-find-draining-unlock/)、[Ranchstory — Treasures (pond/lake)](https://wiki.ranchstory.farm/index.php/Your_Farm_(Story_of_Seasons:_Pioneers_of_Olive_Town))
- 社区布局文：空地可刷出小塘/石；铺路或建结构可**压制刷出**；保留塘作视觉 highlight。  
  来源：[GameRant — rocks/ponds as highlights / paths dictate spawn](https://gamerant.com/story-of-seasons-pioneers-of-olive-town-guide-design-best-farm-layout/)（二手玩家观察；与 Polygon/Ranchstory 交叉后用于“边缘可停留、可压制”）

#### AWL：河是谷地脊骨

- Forget River / Forget Bridge / 瀑布区 / Turtle Pond（**高草环绕池塘**）→ 水 = **线性走廊 + 局部宽池**；岸边用植被带暗示湿缘。Remake 在瀑布附近加浅滩，方便两岸通行（布局层“可涉水捷径”）。  
  来源：[Harvest Moon Paradise — river/bridge/waterfall/turtle pond](https://harvestmoonparadise.com/hmpb/page.php?id=66)、[TV Tropes AWL remake shallow path](https://tvtropes.org/pmwiki/pmwiki.php/AntiFrustrationFeatures/StoryOfSeasonsAWonderfulLife) **[low confidence]**（二次汇编；与 Paradise 河桥结构交叉）

**Godot TileMap**

1. `water` 掩码 + `bank`（邻水一圈 damp/reed）；**禁止**在水掩码上种树。  
2. 灌溉用“井/塘 refill 点”自定义数据，不必画田间明渠（与 FoMT 一致）。  
3. 池塘边缘预留 `pump_slot` / 钓鱼点；大河用蜿蜒 mask + 桥跨格；AWL 式浅滩 = `ford` 可走水格。  
4. 岸过渡：泥/沙/石 terrain-set；海滩单独 `sand` biome 贴 Mineral Beach。

---

### 3. 最底层草地 / 沙地 / 耕地如何铺开、防单调

#### 耕地 = 大块同源土 + 运行时状态，不是一张花纹大图

- FoMT 主地面是**大片 dirt 田**；锄头把格变成可种；种子袋覆盖 **3×3**；未锄格不能长。  
  来源：[Fogu farm](https://fogu.com/sos3/farm/)、[Fogu MFoMT planting](https://fogu.com/hm5/profit/seasoncrops.php)
- **杂物回潮**：清完后，夏/冬风暴会把石块等**再带回田里** → 单调靠“干净田 ↔ 杂物斑”时间变化打破。  
  来源：[Fogu MFoMT — storms bring rocks back](https://fogu.com/hm5/profit/seasoncrops.php)

#### 草 = 邻接扩散规则（反平铺核心）

- 东南角有野生饲料草；草种一格即可；**每日早晨 25%** 向相邻**空田格**蔓延；不需浇水；**木材/石/围栏占格阻断**蔓延。  
  来源：[Fogu — Grass 25% spread / lumber contain](https://fogu.com/sos3/farm/)
- 玩家用围栏切“作物带 / 牧草带” → 视觉分区靠**规则边界**，不是手绘大草地贴图。

#### 沙 / 野地 / 森林底

- **Mineral Beach**：沙地场景；可钓鱼、捡季节草、遛狗。  
  来源：[Tartarus — Mineral Beach](https://tartarus.rpgclassics.com/hmfomt/town.shtml)
- **PoOT**：各 Farm Area 野草/花/树种**分区域 + 分季节**表；未采野菜可跨季残留若干。森林覆地是默认“未开拓”底。  
  来源：[Ranchstory — Natural Resources table](https://wiki.ranchstory.farm/index.php/Your_Farm_(Story_of_Seasons:_Pioneers_of_Olive_Town))、[Eurogamer — farm in forest](https://www.eurogamer.net/story-of-seasons-pioneers-of-olive-town-hopes-to-bring-new-life-to-the-series)
- **季节换皮**：MFoMT 农场外景有春夏秋冬整图资源 → 同布局换地面色板/植被密度。  
  来源：[Spriters Resource — Farm Map Summer/Autumn](https://www.spriters-resource.com/game_boy_advance/hmmfomt/asset/185304/)

#### 广场防单调

- Rose Plaza：**石铺大面** + 季节摊位/节日布置/告示板点缀；不是碎草噪声填满。  
  来源：[Ranchstory Rose Plaza](https://ranchstory.miraheze.org/wiki/Rose_Plaza_(Story_of_Seasons:_Friends_of_Mineral_Town))

**Godot TileMap**

1. 底层：`dirt_fill`（少变体 seamless）→ 上层 `tilled` / `grass_tuft` / `sand`。  
2. 草用 **邻接扩散或烘焙距离带**（对齐 25% 规则），禁止单 tile 无限平铺。  
3. 用 `path`/`fence` 占格切断扩散，制造作物岛与牧草岛。  
4. 广场用硬铺 + 稀疏 prop；野地用分 biome 资源表（Area1/2/3 思路）。

---

### 4. 房子朝向与门对路关系

#### 农场：门朝作业面，北向连村

- 结构事实：村在北、田在主体开敞区；畜舍贴北入口；玩家主要在田与畜舍间折返。  
  来源：[Fogu town north/south exits](https://fogu.com/hm5/town_layout.php)、[GameFAQs building positions](https://gamefaqs.gamespot.com/gba/589702-harvest-moon-friends-of-mineral-town/faqs/29518)
- **朝向推断（可迁移规则）**：农舍门应朝**田/院**（作业面），北侧留出村口通道；畜舍/禽舍门朝向可到达的院落走道，而不是背对田。 **[low confidence]**（官方未发表“door facing”规范；由地图拓扑与建筑位反推）
- **AWL Remake**：农舍周边布局为工作流服务——工具棚删减、出荷/订购挪到室外，缩短门↔作业动线。  
  来源：[Ranchstory News — Nintendo Dream interview (Hoshina)](https://ranchstory.news.blog/2023/03/06/translated-story-of-seasons-a-wonderful-life-interview-from-nintendo-dream/)

#### 村镇：门贴路 / 朝广场

- 店与民宅沿主路与 Rose Plaza 周边布置；广场是节日与下午社交点 → 门应能**一步上路或望见广场**。  
  来源：[LadiesGamers labeled map](https://ladiesgamers.com/the-map-of-mineral-town-in-story-of-seasons-fomt/)、[Tartarus location list](https://tartarus.rpgclassics.com/hmfomt/town.shtml)
- Olive Town：Hall/Museum 在 Plaza；住宅（如 Marcos’ House、Iori’s Residence）嵌在商业带与岸线之间，仍服务**广场—港口—公园**主轴。  
  来源：[Marvelous Europe map list](https://marvelouseurope.github.io/SOSPOOT/page17.html)
- **2D 精灵朝向**：经典俯视建筑多画成**南立面可见（门在南）**；布局上就把“路/广场放在门前南侧或建筑北侧留空”。 **[low confidence]**（通例观察；与 Spriters 外景一致但无官方 facing 文档）

**Godot TileMap**

1. 建筑 metadata：`facing` + `door_cell`；门前 1–2 格 `apron` 必须可走且优先 `street`/`dirt_yard`。  
2. 农场：农舍门朝 `tillable`；北缘留 `exit_to_town`。  
3. 村：门朝 `street` 或 `plaza`；禁止门贴地图外缘或背对主路。

---

### 5. NPC / 村民走动路径与停留点

#### 日程图 = 室内锚 → 步行段 → 室外停留 → 步行回

- **Sasha（FoMT）**：多数日子在店后门工作至约 13:00 → **步行至 Rose Plaza** 与 Manna、Anna 聚会 → 16:00 回店；雨天则 13–16 改在店前。周二闭店走访 Yodel / Poultry / Ellen。  
  来源：[Fogu — Sasha schedule](https://fogu.com/sos3/mineral_town/villagers/sasha.html)
- **时间粒度**：步行段常约 **40–60 游戏分钟**（例：Sasha 13:00–13:40 在路上）。  
  来源：[GamerZenith — Sasha timetable](https://gamerzenith.com/guides/sasha-hmfomt/)（与 Fogu 交叉）
- **Rose Plaza = 主停留点**：节日独占；日常下午社交；告示板信息锚。  
  来源：[Tartarus Rose Square](https://tartarus.rpgclassics.com/hmfomt/town.shtml)、[Ranchstory Rose Plaza](https://ranchstory.miraheze.org/wiki/Rose_Plaza_(Story_of_Seasons:_Friends_of_Mineral_Town))

#### 路径约束

- 行人走**村内路径**；无永久住所者（Cliff、Won）友谊/垃圾逻辑绑定“一般村路”而非某宅。  
  来源：[Fogu Town Layout — Cliff/Won](https://fogu.com/hm5/town_layout.php)
- 查找：PoOT / AWL remake 地图显示角色当前所在 → 设计上假设 NPC **可定位到锚点**，不是纯随机漫游。  
  来源：[Supercheats — Olive Town map portraits](https://www.supercheats.com/story-of-seasons-pioneers-of-olive-town-walkthrough-guide/olive-town-map)

**Godot TileMap / Navigation**

1. 稀疏 `ScheduleAnchor`：Home / ShopCounter / PlazaBench / Beach。  
2. `NavigationRegion` 仅含 street + plaza + 门前 apron；草地权重更高（少走）。  
3. 到达后短距 idle，不全图 roam；雨天切换 indoor 锚。  
4. 广场预留 **聚会簇**（2–4 站位点），对齐下午三人组。

---

### 6. 是否用数学 / 程序（噪声、距离场、规则）增加丰富度

| 机制 | 类型 | 证据 | 可迁移 |
| --- | --- | --- | --- |
| 草每日 25% 邻接蔓延 | **局部规则 / 随机** | [Fogu grass](https://fogu.com/sos3/farm/) | `rng < 0.25` 向空邻格 |
| 围栏/木/石占格阻断蔓延 | **占用掩码** | 同上 | `occupied` 挡扩散 |
| 风暴回投石块 | **季节事件刷怪** | [Fogu storms](https://fogu.com/hm5/profit/seasoncrops.php) | 季节 tick 在空田刷 `debris` |
| 田块星级升级 | **全局田参数** | [Fogu field level](https://fogu.com/sos3/farm/) | 区域属性，非噪声贴图 |
| 池塘抽干→回填→再浑 | **状态机** | [Polygon pump](https://www.polygon.com/story-of-seasons-pioneers-of-olive-town-guides/22339999/water-pump-how-where-find-draining-unlock/) | `pond_state` enum |
| 空地刷草/树/小塘；路阻断 | **占用抑制刷怪** | [GameRant layout](https://gamerant.com/story-of-seasons-pioneers-of-olive-town-guide-design-best-farm-layout/) **[low confidence]** 具体概率 | `if !path && empty: spawn` |
| 分 Area 野资源表 | **查表** | [Ranchstory resources](https://wiki.ranchstory.farm/index.php/Your_Farm_(Story_of_Seasons:_Pioneers_of_Olive_Town)) | biome id → loot table |
| FoMT/Mineral 镇图 | **手摆权威布局** | 地图 wiki / Fogu | 主骨架手摆，细节规则补 |

- **未见**官方公开用 Perlin/单纯距离场生成 Mineral Town 街廓的一手说明。主镇与田形状是**作者布局**；丰富度来自**日更规则 + 季节 + 占用**，不是开局噪声地图。 **[low confidence]** 对引擎内部是否用噪声做装饰抖动。  
- 和田 GDC：农地“一点点变整齐”本身是动机反馈——布局上应让**荒→耕→齐**可读。  
  来源：[4Gamer — Wada GDC 2012 postmortem](https://www.4gamer.net/games/141/G014187/20120313028/)

**Godot**

1. 手摆：河、广场、主路、建筑 slot。  
2. 规则层：草蔓延、debris、pond FSM、path 抑制 spawn。  
3. 可选：距路距离场只用于**草密度/湿岸 tint**，不要用噪声生成主路网。

---

### 7. 素材绘制顺序（先画什么）

> 系列**缺少**像 ConcernedApe 那样公开的“先画 dirt tile”访谈。以下分：**(A) 可核对的生产/资源事实**；**(B) 从场景结构反推的绘制/装配顺序 [low confidence]**。

#### (A) 有来源

- 季节农场外景以**整层地面换装**存在（同布局多季节图）→ 先锁定布局与填充分层，再做季节变体。  
  来源：[Spriters Resource farm maps](https://www.spriters-resource.com/game_boy_advance/hmmfomt/asset/185304/)
- PoOT/FoMT 官方ガイド被 Ranchstory 大量引用，说明场景与设施以**清单+地图**生产，而非纯程序。  
  来源：[Ranchstory PoOT farm refs](https://wiki.ranchstory.farm/index.php/Your_Farm_(Story_of_Seasons:_Pioneers_of_Olive_Town))、[Ranchstory Rose Plaza refs](https://ranchstory.miraheze.org/wiki/Rose_Plaza_(Story_of_Seasons:_Friends_of_Mineral_Town))
- AWL remake 图像方针：保留写实氛围，同时融入系列近年明亮卡通方向 → **光影/氛围先于细节花活**。  
  来源：[Nintendo Dream via Ranchstory News](https://ranchstory.news.blog/2023/03/06/translated-story-of-seasons-a-wonderful-life-interview-from-nintendo-dream/)

#### (B) 建议装配 / 绘制顺序 **[low confidence — craft inference]**

对齐可玩结构与本节 1–5，而非玩法说明书：

1. **锁定格网与分区骨架**（farm band / plaza / street / water mask）  
2. **Fill 地面**（dirt / grass fill / sand / plaza stone）— 少变体、可 seamless  
3. **岸与 biome 过渡**（damp、沙砾、石岸）  
4. **路与广场硬铺**（含门前 apron）  
5. **建筑 footprint + 南立面门**（先门朝向，后屋顶装饰）  
6. **围栏 / 田状态**（tilled、crop、grass tuft）  
7. **功能 prop**（告示板、井、摊、桥）  
8. **树与野点**（仅 plantable）  
9. **季节 tint / 换页**  
10. **NPC 锚点与路径最后校准**

运行时绘制（引擎）：地面层 → 水 → 路 → 建筑基座 → Y-sort 角色/道具 → 屋顶/树冠。

---

## Agent-transferable rules（Godot 4）

1. **三区不同骨架**：农场大 tillable + 北建筑带；广场硬铺开敞 + 节日锚；住宅沿街串珠。  
2. **水 = 掩码 + bank**；灌溉用塘/井点，不默认画渠。  
3. **草用邻接规则反单调**；path/fence 占格切断。  
4. **门朝路/田/广场**；door_cell + apron 强制可走。  
5. **NPC = 日程锚 + 沿路步行 + 广场停留簇**；雨天换室内锚。  
6. **手摆主骨架，规则补丰富度**；慎用噪声生成路网。  
7. **先 fill/岸/路/门向建筑，后 prop/季节**；atlas Nearest + 接缝纪律见仓库 `docs/SEAMLESS.md`。

---

## Sources

### Primary / high-trust

| 主题 | URL |
| --- | --- |
| FoMT 农场尺寸、鱼塘、锄地、草 25% 蔓延 | https://fogu.com/sos3/farm/ |
| FoMT 村北/南出口与住户表 | https://fogu.com/hm5/town_layout.php |
| MFoMT 田 43×25、风暴回石 | https://fogu.com/hm5/profit/seasoncrops.php |
| Sasha 日程与 Rose Plaza 步行 | https://fogu.com/sos3/mineral_town/villagers/sasha.html |
| Nakano：农场置于森林的设计意图 | https://www.eurogamer.net/story-of-seasons-pioneers-of-olive-town-hopes-to-bring-new-life-to-the-series |
| Nakano：周边区域与 Olive 地形协调 | https://www.siliconera.com/interview-pioneers-of-olive-town-and-encouraging-a-pioneering-spirit/ |
| AWL remake 农舍周边动线调整、画面方针 | https://ranchstory.news.blog/2023/03/06/translated-story-of-seasons-a-wonderful-life-interview-from-nintendo-dream/ |
| 和田 GDC：农地变整齐的反馈感 | https://www.4gamer.net/games/141/G014187/20120313028/ |
| Olive Town 官方地图点位表 | https://marvelouseurope.github.io/SOSPOOT/page17.html |
| PoOT 农场/池塘宝藏（引官方ガイド） | https://wiki.ranchstory.farm/index.php/Your_Farm_(Story_of_Seasons:_Pioneers_of_Olive_Town) |
| Rose Plaza（引官方コンプリートガイド） | https://ranchstory.miraheze.org/wiki/Rose_Plaza_(Story_of_Seasons:_Friends_of_Mineral_Town) |
| Olive Town Plaza 四向拓扑 | https://ranchstory.miraheze.org/wiki/Olive_Town_Plaza_(Story_of_Seasons:_Pioneers_of_Olive_Town) |
| AWL 连续谷地图 | https://ranchstory.miraheze.org/wiki/Category:Forget-Me-Not_Valley_(Harvest_Moon:_A_Wonderful_Life) |
| 池塘边缘水泵放置与回填 | https://www.polygon.com/story-of-seasons-pioneers-of-olive-town-guides/22339999/water-pump-how-where-find-draining-unlock/ |

### Map / layout structure

| 主题 | URL |
| --- | --- |
| Mineral Town 编号地图与 Rose Square 职能 | https://tartarus.rpgclassics.com/hmfomt/town.shtml |
| SoS FoMT 标注地图与南区定义 | https://ladiesgamers.com/the-map-of-mineral-town-in-story-of-seasons-fomt/ |
| AWL 谷地西→东锚点（河/桥/瀑布/池） | https://harvestmoonparadise.com/hmpb/page.php?id=66 |
| FoMT 农舍/畜舍/禽舍相对位置 | https://gamefaqs.gamespot.com/gba/589702-harvest-moon-friends-of-mineral-town/faqs/29518 |
| 季节农场外景资源 | https://www.spriters-resource.com/game_boy_advance/hmmfomt/asset/185304/ |

### Secondary（交叉用，单独断言已标 low confidence）

| 主题 | URL |
| --- | --- |
| Sasha 分钟级步行表 | https://gamerzenith.com/guides/sasha-hmfomt/ |
| PoOT 路阻断刷怪 / 塘作 highlight | https://gamerant.com/story-of-seasons-pioneers-of-olive-town-guide-design-best-farm-layout/ |
| AWL remake 浅滩捷径 | https://tvtropes.org/pmwiki/pmwiki.php/AntiFrustrationFeatures/StoryOfSeasonsAWonderfulLife |
| PoOT 地图角色定位 UI | https://www.supercheats.com/story-of-seasons-pioneers-of-olive-town-walkthrough-guide/olive-town-map |

---

*Research date: 2026-09-10. CRAFT-only. Prefer Fogu / developer interviews / official-guide-cited wikis when conflict.*
