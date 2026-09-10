# My Time at Portia — 工坊城镇分区 CRAFT 技术笔记

> Scope: **工坊城镇场景组装手法**（分区差异、主路/支路与门廊朝向、地形/水体过渡、NPC 走动与停留、可迁移的关卡规则）。不含类型标签/玩法综述。  
> 主样本：**My Time at Portia**（Pathea / Unity 3D）。**Sandrock** 仅作同系列分区对照。  
> 面向：Godot 4 TileMap 村镇 / hub 项目（Dream）。  
> 信任优先级：官方 wiki 区位描述 / Pathea 一手概念图与访谈 / 经 wiki 交叉验证的日程与基建任务。

**为何选 Portia 为主：** 双广场 + Main Street 脊梁 + 城墙外工坊/农场/河岸分层，wiki 区位与日程记录更完整；Sandrock 沙漠主街/Oasis 可对照“工坊在城外、广场为枢纽”同一语法。

---

## Techniques

### 1. Zone types — 商业街 / 广场 / 住宅 / 作坊 / 农场

Portia 不是单一“镇子大广场”，而是 **双枢纽 + 城墙阈值 + 河岸生产带**：

| 区类型 | 代表 | 布局差异（craft） |
| --- | --- | --- |
| **Gate / civic plaza** | Peach Plaza | 紧贴 **城墙内侧**、玩家工坊北侧入口；中心 **纪念雕像（Peach）**；环绕 **Commerce Guild（商业委托枢纽）+ A&G Construction + Town Hall**；旁有 **Happy Apartments**（多层住宅）与通向 Park 的 **草径支路** |
| **Leisure / retail plaza** | Central Plaza | 城东第二广场；中心 **Wishing Tree**；环绕 **零售店 + Research Center + School + Portia Times + Higgins' Workshop +（后期）Museum**；配 **长椅 / 秋千 / 跷跷板 / 对练空地** → 闲逛与约会密度最高 |
| **Main commercial spine** | Main Street | 连接两广场，贯穿 **West / East Gate**；沿街混合 **餐厅（Round Table）/ 花店 / 部分住宅门脸**；另有 **skywalk** 俯瞰 Park 与 Central Plaza |
| **Soft green pocket** | Park | 在 Town Hall / Happy Apartments **背后**，不占主广场；树荫草地；日常几乎只有 Isaac 下棋 → **故意低流量负空间** |
| **Player workshop** | Workshop | **城墙外** gated yard；小院 + 一级房 + Assembly / Worktable；可扩地、可搬站；生产噪音与占地与城内广场隔离 |
| **Rival workshop** | Higgins' Workshop | 放在 **Central Plaza 内**、近 Wishing Tree / 东门；门外可见 crafting stations → “城里作坊” vs “城外作坊”的对比读感 |
| **Farm / ranch** | Sophie's Ranch | 工坊 **正西**；麦田、畜栏、Farm Store；节奏是 **田地劳作 ↔ 进城吃饭/闲逛** |
| **Satellite across water** | South Block | **Portia River 南岸**；桥修好后才出现的旅人休息/贸易卫星城 → 水体是硬分区边界 |

来源：[Map（archive）](https://mytimeatportia-archive.fandom.com/wiki/Map)、[Peach Plaza](https://mytimeatportia.fandom.com/wiki/Peach_Plaza)、[Central Plaza（archive）](https://mytimeatportia-archive.fandom.com/wiki/Central_Plaza)、[Workshop](https://mytimeatportia.fandom.com/wiki/Workshop)、[Higgins' Workshop](https://mytimeatportia.fandom.com/wiki/Higgins%27_Workshop)、[Park](https://mytimeatportia.fandom.com/wiki/Park)、[Main Street](https://mytimeatportia.fandom.com/wiki/Main_Street)

**分区一句公式：**  
`城外工坊门槛 → Gate Plaza（委托/市政）→ Main Street → Leisure Plaza（零售/社交）`；农场贴工坊侧翼；河对岸卫星区靠 **桥 span** 解锁。

**Sandrock 对照（同语法，沙漠材质）：** Workshop 在 **outskirts**；**Martle's Square** 为市政/火边会枢纽；**Main Street** 商业主街连 Oasis / Station；**Back Street / Uptown** 为次级街巷。来源：[Workshop (Sandrock)](https://mytimeatsandrock.fandom.com/wiki/Workshop)、[Martle's Square](https://mytimeatsandrock.fandom.com/wiki/Martle%27s_Square)、[Main Street (Sandrock)](https://mytimeatsandrock.fandom.com/wiki/Main_Street)

---

### 2. Main road vs side path；建筑朝向 / 门廊对街

**主路**

- Main Street = **唯一贯通双门的主轴**；NPC 跨区通勤默认走这条“硬铺装脊”。  
- Round Table 卡在 **Peach Plaza ↔ Main Street 交界** → 高访频率节点贴主轴，不当死胡同。  
  来源：[Main Street](https://mytimeatportia.fandom.com/wiki/Main_Street)、[The Round Table](https://mytimeatportia.fandom.com/wiki/The_Round_Table)

**支路 / 次级图**

- Happy Apartments 旁 **草径 → Park**（软地面支路，不抢主街）。  
- Peach Plaza **西向漫游线**：Church 山丘、Cemetery、Abandoned Ruins、Civil Corps、Clinic（边缘公共服务 + 遗迹，不塞进主商业街）。  
- Main Street **skywalk / 阳台**：第二层观景路径，俯瞰 Park 与 Central Plaza（垂直支路）。  
  来源：[Peach Plaza](https://mytimeatportia.fandom.com/wiki/Peach_Plaza)、[Main Street](https://mytimeatportia.fandom.com/wiki/Main_Street)、[Park](https://mytimeatportia.fandom.com/wiki/Park)

**朝向与门廊（可观察规则）**

- 广场建筑 **环心布置**：Peach 以雕像为心，Guild / A&G / Town Hall **门脸朝广场**；Central 以 Wishing Tree 为心，店铺与 Higgins 作坊 **朝开阔广场/树**，近东门。  
- 玩家工坊：**门外门槛朝城门/Peach Plaza 进镇方向**；院内站台可在 yard AABB 内重摆，但 **gate 朝向城镇入口固定**。  
- Higgins 作坊门外机器露天 → “工作门廊”朝广场人流，制造偶遇与竞争读感。  
- Pathea 一手概念 **「Portia Street」** 强调沿街小细节（招牌、道具、门廊尺度），不是只摆体块。  
  来源：[Peach Plaza](https://mytimeatportia.fandom.com/wiki/Peach_Plaza)、[Workshop](https://mytimeatportia.fandom.com/wiki/Workshop)、[Higgins' Workshop](https://mytimeatportia.fandom.com/wiki/Higgins%27_Workshop)、[Portia Street — Pathea DeviantArt](https://www.deviantart.com/patheagames/art/Portia-Street-679959689)

**Dream 可落地**

- 命名槽位：`gate_plaza` / `main_spine` / `leisure_plaza` / `workshop_lot` / `farm_west`。  
- 南向门美术 → 门廊槽在广场北缘（与 `LAYOUT.md` 一致）。  
- 主路 `surface=stone`；草径/后院 `dirt|grass`；禁止把高访商店只挂在死胡同。

---

### 3. Terrain transition & water

**水体角色（边界 + 景点，不是装饰蓝条）**

| 水体 | 相对城镇 | craft 作用 |
| --- | --- | --- |
| **Portia River** | 城南田野带 | 分隔城镇/工坊北岸与沙漠、South Block；**硬分区** |
| **Bassanio Falls** | 城东 | 瀑布注入河流；上方 Heights / 废工厂 → **高差过渡** |
| **Duck Pond** | Ranch 西 | 大水面约会/停留锚点；非运河 |
| **Harbor / ocean** | 工坊西南 | 码头、后期航线；港城读感 |
| **Amber Island** | 河/海侧 | 需 **指定桥位** 的 Wooden Bridge Heads + Body 组装 |

来源：[Map Areas](https://mytimeatportia-archive.fandom.com/wiki/Map)、[Bassanio Falls](https://mytimeatportia.fandom.com/wiki/Bassanio_Falls)、[Duck Pond](https://mytimeatportia.fandom.com/wiki/Duck_Pond)、[Amber Island](https://mytimeatportia.fandom.com/wiki/Amber_Island)、[Bridge to Amber Island](https://mytimeatportia.fandom.com/wiki/Mission:_Bridge_to_Amber_Island)

**过渡与跨水组装**

- 城内 → 城墙门 → 墙外草地田野 → 河岸 →（桥）对岸。地面材质随区变化，不是一色草铺满。  
- **桥是关卡道具 + 世界标记**：Amber Island 桥在 **designated spot** 放置部件；Portia Bridge 分多段委托（塔/梁等），完成后解锁南岸 Dee-Dee 与 South Block 叙事。  
  来源：[Bridge to Amber Island](https://mytimeatportia.fandom.com/wiki/Mission:_Bridge_to_Amber_Island)、[The Portia Bridge](https://mytimeatportia.fandom.com/wiki/Mission:_The_Portia_Bridge)  
- 一手城镇剪影：**「A Town by the Sea」** — Pathea 标明为最终城镇设计（东望港城）。  
  来源：[A Town by the Sea — Pathea](https://www.deviantart.com/patheagames/art/A-Town-by-the-Sea-681556378)  
- 命名动机：导演称世界 **围绕 port（港口）**，与 Portia 词根呼应。  
  来源：[Xbox Wire — Zhi Xu](https://news.xbox.com/en-us/2019/04/11/talking-about-farming-pink-cats-and-relic-hunting-with-team-behind-my-time-at-portia/)

**Dream 可落地**

- 河 = meander **mask** + bank ring（对齐 `LAYOUT.md` / `SEAMLESS.md`）。  
- 桥 = 平行河岸锚点 + span 长度规则；禁止“路直接画进水里”。  
- 工坊/农场用地在 **水北 / 城外**；广场在 **墙内抬升或平整铺装**。

---

### 4. NPC walking & lingering

**日程 = 稀疏时空锚点，不是全图随机游**

- 每人按星期/时段：`离开居所 → 工作域 → 通勤 → 停留点（吃饭/社交/闲逛）→ 回家`。  
- **Emily（农场代表）**：7:00 离 Farm Store → 7:30 **麦田劳作** → 9:00 赴 Peach Plaza **Round Table** → 店内 **wandering** → 回鸡场/牧场；午后可 **Wander Peach Plaza**；归途 **Stops several times**（路径上短停）。  
  来源：[Emily — Schedule](https://mytimeatportia.fandom.com/wiki/Emily)  
- **Phyllis**：诊所工作 ↔ Peach Plaza 听布道 ↔ Central Plaza 停留。  
  来源：[Phyllis](https://mytimeatportia.fandom.com/wiki/Phyllis)  
- **Nora**：Happy Apartments → Church / Peach Plaza 传教 → Round Table → 关系推进后可改在 **Duck Pond** 等点。  
  来源：[Nora](https://mytimeatportia.fandom.com/wiki/Nora)

**停留道具与空间**

- Central Plaza：**bench + swing + seesaw + Wishing Tree 树下椅 + spar 空地** = 高密度 linger 家具。  
- Peach Plaza / Round Table = **餐饮与社交 magnet**（多角色日程汇合）。  
- Park = **低密度 linger**（几乎专属 Isaac）→ 证明不是每个绿块都要塞 NPC。  
  来源：[Central Plaza](https://mytimeatportia-archive.fandom.com/wiki/Central_Plaza)、[Park](https://mytimeatportia.fandom.com/wiki/Park)、[Wishing Tree](https://mytimeatportia.fandom.com/wiki/Wishing_Tree)

**路径现实**

- 社区与 wiki 均强调：日程时间为 **估计**；NPC 会因卡住/延迟迟到；关系或任务可改锚点。  
  来源：[Emily schedule caveat](https://mytimeatportia.fandom.com/wiki/Emily)、[Steam schedule thread](https://steamcommunity.com/app/666140/discussions/0/1694923613864980858/)  
- 地图显示 NPC 实时位置（好友肖像升级；室内半透明）→ 运行时仍走 **可导航图**。  
  来源：[Map](https://mytimeatportia.fandom.com/wiki/Map)

**Dream 可落地**

- Resource：`{time, zone, anchor, face, idle}`；到达后 `WanderInRect` / 店内 wander。  
- 通勤贴 `main_spine`；linger 只放在 plaza furniture / 餐厅 / 树下椅。  
- 归途允许 **1–3 个路边短停锚**（Emily “stops several times”）。  
- 禁止全图 random walk；Park 类口袋可只挂 0–1 个固定闲人。

---

### 5. Level / scene assembly — transferable rules

Portia 是 **手摆 Unity 开放城**（非 Stardew 式 tile 属性层），但组装语法可迁移：

1. **先锁城镇剪影与海/河关系**（Pathea「A Town by the Sea」定稿），再填街景细节（「Portia Street」）。  
2. **双广场 + 主街脊** 作为导航骨架；支路/skywalk/草径为辅。  
3. **工坊 lot = 墙外可扩展围栏 AABB**；城内只放展示型/竞争型作坊。  
4. **世界突变靠“指定放置点”**：桥部件、Dee-Dee Stop、路灯、博物馆等在 **map marker** 组装，不是自由刷。  
   来源：[Dee-Dee Transport System](https://mytimeatportia.fandom.com/wiki/Dee-Dee_Transport_System)、[Bridge missions](https://mytimeatportia.fandom.com/wiki/Mission:_Bridge_to_Amber_Island)  
5. **委托竞争可改世界完成度**（Higgins 会抢城市基建委托）→ 设计上预留“槽位必被填满”，玩家或 NPC 填均可。  
6. 引擎：Unity 3D 第三人称；艺术目标为 **Ghibli 式明亮** + Harvest Moon / Dark Cloud / Future Boy Conan 参照（后启示录但不灰暗）。  
   来源：[Wikipedia — Unity](https://en.wikipedia.org/wiki/My_Time_at_Portia)、[VentureBeat — Zifei Wu](https://venturebeat.com/games/my-time-at-portia-marks-team17s-first-ever-partnership-with-a-chinese-developer/)、[Xbox Wire — Zhi Xu](https://news.xbox.com/en-us/2019/04/11/talking-about-farming-pink-cats-and-relic-hunting-with-team-behind-my-time-at-portia/)、[Telegraph art gallery](https://www.telegraph.co.uk/gaming/features/time-portia-release-date-exclusive-artwork/)

**与 Dream pass 对齐**

```text
masks (walls / water / path) 
→ ecological ground (plaza stone / street / yard / farm / bank)
→ water + bridge spans
→ plaza furniture + door-facing buildings
→ workshop/farm fenced lots
→ NPC schedule anchors on spine + linger props
→ optional infrastructure markers (lights, stops)
```

---

## Math / procedural（实现备忘）

Portia **不以噪声生成主城**；程序感来自 **日程图 + 指定槽位填充**。可抽象：

```text
# Town graph (conceptual)
nodes = {WorkshopGate, PeachPlaza, MainStreet, CentralPlaza, Farm, Park, BridgeN, BridgeS}
edges = MainStreet spine + west_meander + grass_spur_to_Park + skywalk
prefer_travel_cost: stone_spine < dirt_spur < grass_yard

# NPC day
for event in schedule:
  pathfind(event.anchor) along prefer edges
  on_arrive: idle | wander(rect) | sit(bench) for dwell_time
  optional: roadside_pause(count=1..3) on long farm↔plaza trips

# Infrastructure slots
slot.active = story_flag
player_or_rival.place(assembly_prefab) at slot.world_pose
# river crossing only if bridge_span.valid(bank_N, bank_S)
```

**未见高信任源：** 主城 Perlin 街区生成；建筑自由 yaw；无桥硬穿河。

---

## Asset pipeline notes

| 层 | Portia 做法（一手/高信任） | Dream 映射 |
| --- | --- | --- |
| 城镇总构图 | 概念定海/城剪影（A Town by the Sea） | 先锁 plaza + river + workshop lot |
| 街景 | 概念强调小道具与沿街细节（Portia Street） | props 在门廊/主街，不堆广场中心 |
| 风格 | Ghibli 色彩 + 轻松后启示录（Xu / Wu / Telegraph） | 明亮分区材质，忌灰雾铺满 |
| 运行时城建 | Assembly 预制件落在 **世界标记** | `instance` 到 named markers |
| 工坊内 | Yard 网格扩地；站台可搬但在围栏内 | `FARM_BUILD_ZONE` / lot AABB |

引擎确认：Unity（[Wikipedia](https://en.wikipedia.org/wiki/My_Time_at_Portia)）。无公开与 Stardew 同级的 tile 属性白皮书 → **区位与日程以 wiki + 官方概念为准**。

---

## Agent-transferable rules（给 Godot 4 村镇）

1. **双枢纽：** Gate/civic plaza（委托+市政）与 Leisure/retail plaza（树+店+闲逛家具）用 **一条主街** 连接。  
2. **工坊在墙外 gated lot**；城内最多一个展示/竞争作坊朝广场。  
3. **农场贴工坊侧翼**，用田地纹理与畜栏，不塞进主广场。  
4. **门廊/店面朝广场中心或主街**；支路用草径/山路，不替代主轴。  
5. **河/海是硬边界**；跨水只经 **双岸锚点桥**；可另做瀑布高差与池塘停留点。  
6. **Park 等口袋绿地可低 NPC 密度**；把 linger 预算给 Central 类广场家具。  
7. **NPC = 日程锚点 + 主路通勤 + 到达后短距 wander/sit**；长通勤可路边短停。  
8. **基建用 named world slots**（桥、站点、灯），故事旗标激活，禁止自由刷穿地形。  
9. **组装顺序：** 墙/水/路 mask → 铺装与生态草 → 桥 → 朝向建筑 → 围栏工坊/农场 → 家具 → NPC。  
10. **先剪影后细节：** 港口/河城外轮廓锁定后再铺街景小 props（对齐 Pathea 概念流程）。

### Anti-lazy（禁止偷懒）

- 禁止单广场塞满商店+工坊+农场+住宅。  
- 禁止工坊院子与市政广场混成同一无围栏平面。  
- 禁止直线运河替代蜿蜒河岸 / 指定桥位。  
- 禁止建筑背对主街/广场中心“填空旋转”。  
- 禁止 NPC 全图随机游荡替代日程图。  
- 禁止把 Park 级负空间填满摊位。  
- 禁止无双岸锚点的“漂浮桥砖”。

---

## Sources

### Primary / first-party

| 主题 | URL |
| --- | --- |
| 最终城镇剪影概念 | https://www.deviantart.com/patheagames/art/A-Town-by-the-Sea-681556378 |
| 沿街细节概念 | https://www.deviantart.com/patheagames/art/Portia-Street-679959689 |
| 官方站点（工坊/社区定位） | https://portia.pathea.net/ |
| Zhi Xu：港口命名、Ghibli/Conan 美术与放松目标 | https://news.xbox.com/en-us/2019/04/11/talking-about-farming-pink-cats-and-relic-hunting-with-team-behind-my-time-at-portia/ |
| Zifei Wu：Conan/Nausicaä、Dark Cloud 2、Harvest Moon 等影响；动态 NPC | https://venturebeat.com/games/my-time-at-portia-marks-team17s-first-ever-partnership-with-a-chinese-developer/ |
| Pathea 美术灵感图集（Ghibli / Stardew / Dark Cloud） | https://www.telegraph.co.uk/gaming/features/time-portia-release-date-exclusive-artwork/ |
| 引擎 Unity、工坊继承叙事（百科汇总一手元数据） | https://en.wikipedia.org/wiki/My_Time_at_Portia |

### High-trust location / schedule (community wiki, cross-checked)

| 主题 | URL |
| --- | --- |
| 分区总表（双广场、河田、Ranch、Harbor…） | https://mytimeatportia-archive.fandom.com/wiki/Map |
| Peach Plaza 环心建筑 | https://mytimeatportia.fandom.com/wiki/Peach_Plaza |
| Central Plaza 零售/闲逛家具 | https://mytimeatportia-archive.fandom.com/wiki/Central_Plaza |
| Main Street / 门 / skywalk | https://mytimeatportia.fandom.com/wiki/Main_Street |
| Workshop 墙外 gated yard | https://mytimeatportia.fandom.com/wiki/Workshop |
| Higgins 城内作坊 | https://mytimeatportia.fandom.com/wiki/Higgins%27_Workshop |
| Park 低流量 | https://mytimeatportia.fandom.com/wiki/Park |
| Round Table 主轴交界 | https://mytimeatportia.fandom.com/wiki/The_Round_Table |
| Emily 农场↔广场日程 | https://mytimeatportia.fandom.com/wiki/Emily |
| Nora / Phyllis 锚点 | https://mytimeatportia.fandom.com/wiki/Nora · https://mytimeatportia.fandom.com/wiki/Phyllis |
| 桥与指定放置 | https://mytimeatportia.fandom.com/wiki/Mission:_Bridge_to_Amber_Island · https://mytimeatportia.fandom.com/wiki/Mission:_The_Portia_Bridge |
| Dee-Dee 世界标记站点 | https://mytimeatportia.fandom.com/wiki/Dee-Dee_Transport_System |
| Bassanio Falls / Duck Pond / Amber Island | https://mytimeatportia.fandom.com/wiki/Bassanio_Falls · Duck_Pond · Amber_Island |

### Series parallel (Sandrock)

| 主题 | URL |
| --- | --- |
| Workshop outskirts | https://mytimeatsandrock.fandom.com/wiki/Workshop |
| Martle's Square hub | https://mytimeatsandrock.fandom.com/wiki/Martle%27s_Square |
| Main Street 商业脊 | https://mytimeatsandrock.fandom.com/wiki/Main_Street |

### Secondary

| 主题 | URL |
| --- | --- |
| 日程延迟现实 | https://steamcommunity.com/app/666140/discussions/0/1694923613864980858/ |
| Happy Apartments 区位 | https://www.neoseeker.com/my-time-at-portia/facilities/Happy_Apartments |

### Confidence

- **High：** 双广场 + Main Street；工坊在墙外；河为硬边界；桥/站点指定槽；日程锚点 + plaza linger 家具；Pathea 城镇/街景概念与访谈影响。  
- **Medium：** 具体门廊法线角度（3D 观察归纳，无官方 facing API）；skywalk 作为“第二层步行图”的迁移强度。  
- **Low：** 内部寻路代价表、地表材质权重精确数值（未公开反编译级文档）。

---

*Research date: 2026-09-10. Craft only for Dream. Cross-ref: `docs/LAYOUT.md`, `docs/SEAMLESS.md`, `docs/BUILDING_PLACEMENT.md`, `docs/research/SYNTHESIS.md`.*
