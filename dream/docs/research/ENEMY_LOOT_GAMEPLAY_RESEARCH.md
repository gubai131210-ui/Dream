# Enemy loot gameplay research — Dream（cozy 村 · 无战斗现状）

> **Date:** 2026-09-13  
> **Scope:** cozy / farming / exploration 2D（或同类型循环）如何设计「可攻击、掉材料」的敌对物；对照 Dream 当前 **无战斗**，已有 breakables / fishing / chests / DayNightWeather / 矿洞·洞穴·遗迹·下水道。  
> **Trust:** 优先官方 wiki / 工作室访谈 / 经交叉验证的 datamine；二级攻略标明。  
> **Does not:** 改游戏代码、定战斗数值表、画敌人 sprite。

---

## 0. Dream 语境（为何要研究）

| 已有 | 含义 |
| --- | --- |
| Hotspots / `WorldInteract` | 点击交互：摇树、喂鸟、木箱、路灯等（C58） |
| Breakables（C59） | 可清除障碍 → 清场感 + FX，**无 HP / 无反击** |
| Chests（C61） | 隐藏奖励点 |
| Fishing | 湖/水岸采集环 |
| DayNightWeather | 户外时段/天气钩子 |
| C17 Mine / C16 Caves / C29 Ruins / C31 Sewer | **已有「危险感空间」壳**，尚未挂敌对 AI |
| 广场 / 农场 / 车站 | **安全家园幻想** 的主舞台 |

**问题：** 若引入「打怪掉料」，如何保留 cozy，又让森林/矿/遗迹/下水道产生**可选张力**与**材料闸门**？

---

## 1. 对照游戏（≥6 + 对比项）

每条结构：循环角色 · 攻击模型 · 掉落哲学 · 安全区 vs 战斗区 · 失败态 · 如何护住 cozy。

### 1.1 Stardew Valley — Mines（经典「矿洞可选战斗」）

| 维度 | 设计 |
| --- | --- |
| **循环角色** | 农场日环为主；矿洞是 **深度推进 + 矿石/宝石 + 怪物材料** 的副环。梯子可来自砸石**或**杀怪（杀怪省体力）。 |
| **攻击模型** | 接触伤害；部分追击/弹道。农场地怪可选（Wilderness / 神社开关）。城镇日间无战斗。 |
| **掉落哲学** | **双轨：** 岩石→矿石/晶球；怪物→正式「Monster Loot」（Slime、Bug Meat、Bat Wing、Solar/Void Essence）兼卖店、制作闸门（诱饵、炸弹、戒指等）。 |
| **安全 vs 战斗** | 农场/镇默认安全；矿/骷髅洞/火山等才见血条。健康条主要在危险区显示。 |
| **失败态** | HP=0 → 昏倒：丢金 + 可能丢物（Marlon 可赎回一件）。体力/2AM 昏倒惩罚更轻。**无永久死亡**。 |
| **护 cozy** | 战斗可完全延后；失败只伤当日进度；怪物材料多半是**增效/奢侈配方**而非「没有就种不了田」。 |

**Sources:** [The Mines](https://stardewvalleywiki.com/The_Mines) · [Monsters](https://stardewvalleywiki.com/Monsters) · [Monster Loot](https://stardewvalleywiki.com/Monster_Loot) · [Combat](https://stardewvalleywiki.com/Combat) · [Health](https://stardewvalleywiki.com/Health)

---

### 1.2 Rune Factory 4 — 「战斗=生活技能」

| 维度 | 设计 |
| --- | --- |
| **循环角色** | 镇内农/社交与野外战斗**同主角身份**；怪物材料直接喂锻造/炼金/烹饪。 |
| **攻击模型** | 野外区域即战场；镇内 Selphia 为 hub。可驯服怪进 Monster Barn → **日产出材料 + 农活**，把「打」转成「养」。 |
| **掉落哲学** | **强 crafting gate：** 甲壳、结晶、Boss 专属掉落等；每怪最多多条独立掉落检定；装备可提高掉率（Clover / Happy Ring 等，经 datamine）。 |
| **安全 vs 战斗** | 城镇安全；出城即遭遇。地牢/道路分区抬难度。 |
| **失败态** | 战斗失败/倒地惩罚存在，但核心幻想是「能打也能种」；驯服把威胁转成资产。 |
| **护 cozy** | 怪物可读成「可交涉的邻居」；掉落与日常生产闭环，而非纯刷怪游戏。 |

**Sources:** [Bestiary (Ranch Story)](https://ranchstory.miraheze.org/wiki/Bestiary_(Rune_Factory_4)) · [Monsters (RF4)](https://therunefactory.fandom.com/wiki/Monsters_(RF4)) · [Drop rates PSA + Datamining Compendium](https://www.reddit.com/r/runefactory/comments/hdwcb8/rf4_psa_drop_rates_and_boosts/)

---

### 1.3 Coral Island — 四矿井 + 可选战斗难度

| 维度 | 设计 |
| --- | --- |
| **循环角色** | 矿洞推层解锁下一元素矿；怪物掉落服务 **Combat 技能树、陷阱、香气、神庙供品**。 |
| **攻击模型** | 矿内仇恨追击；设置可改为 **hit-to-aggro**，降低「被围殴」压力。 |
| **掉落哲学** | Monster Essence + 种类专属（Slime Goop、Bat Wings、Cursed Fragment…）→ 制作与博物馆/供品；同时砸岩石仍是主矿石源。 |
| **安全 vs 战斗** | 岛上农场/镇无战斗；战斗绑在 Cavern 四矿。 |
| **失败态** | HP/Energy 耗尽可结束当日（与同类型 farm-sim 昏倒同族）。 |
| **护 cozy** | 战斗可选强度；陷阱/诱饵技能树给「非硬刚」解法；矿洞奖励节奏（每 10 层箱、每 5 层电梯）降低挫败。 |

**Sources:** [Cavern](https://coralisland.fandom.com/wiki/Cavern) · [Combat](https://coralisland.wiki/wiki/Combat) · [Monster Loot](https://coralisland.wiki/wiki/Monster_Loot) · [TheGamer monsters overview](https://www.thegamer.com/coral-island-complete-guide-to-monsters-and-enemies/)（二级）

---

### 1.4 Sun Haven — 矿洞敌人 + 可选难度/无敌

| 维度 | 设计 |
| --- | --- |
| **循环角色** | 矿石层阶 + 战斗技能树并行；另有 Combat Dungeon / Boss Arena 给**自愿硬核**玩家。 |
| **攻击模型** | 矿内越深越强；弩等远程降低入门门槛。早期战斗可视为可选。 |
| **掉落哲学** | 矿石主轨来自节点；敌人提供战斗 XP 与材料；Boss（如 Dizzy）给稀有/图鉴向掉落。 |
| **安全 vs 战斗** | 镇/农场相对安全；矿/森林可遇敌；竞技场是显式「约战」。 |
| **失败态** | 常规血量压力；官方 Starter Guide 明确可开 **无敌 / 延长白天** 等舒适选项。 |
| **护 cozy** | **难度与危险可配置**；战斗不是唯一身份；远程与设置把「打不过」变成「可以绕」。 |

**Sources:** [Sun Haven Mines](https://sunhaven.wiki.gg/wiki/Sun_Haven_Mines) · [Combat](https://sunhaven.wiki.gg/wiki/Combat) · [Guide:Starter Guide](https://sunhaven.wiki.gg/wiki/Guide:Starter_Guide) · [Mining](https://sunhaven.wiki.gg/wiki/Mining)

---

### 1.5 Graveyard Keeper — 地牢一次性清场 + 炼金材料

| 维度 | 设计 |
| --- | --- |
| **循环角色** | 墓地经营/尸体加工为主；地牢是 **任务材料 + 稀有矿脉 + 炼金粉末** 的侧线。 |
| **攻击模型** | 逐层清怪才开下层；怪**不刷新**（离开后受伤怪回满血）。 |
| **掉落哲学** | 果冻/翅/钉/粉末等偏 **炼金与任务闸**；深层银金矿脉才是长期资源。坛罐破坏物与怪掉落并存。 |
| **安全 vs 战斗** | 工作区/村庄逻辑安全；地牢是显式「下潜」。 |
| **失败态** | 倒地惩罚轻（攻略常写可故意倒地快速出洞）；强调准备食物/装备。 |
| **护 cozy（灰暗风）** | 战斗不主导日环；「清完就安全」让地牢变成可征服的静态空间，减少无限刷怪焦虑。 |

**Sources:** [Dungeon](https://graveyardkeeper.fandom.com/wiki/Dungeon) · [Monsters](https://graveyardkeeper.fandom.com/wiki/Monsters) · [Neoseeker dungeon loot table](https://www.neoseeker.com/graveyard-keeper/walkthrough/The_Dungeon)（二级交叉）

---

### 1.6 Moonlighter — 「夜潜日卖」：掉落=商品

| 维度 | 设计 |
| --- | --- |
| **循环角色** | **昼：开店卖货 / 夜：地牢捡物**。敌人掉落与箱子共同填满背包，卖出升级武器与店铺。 |
| **攻击模型** | 房间刷怪；可清房间后「占用地牢」；部分门不锁便于风筝。超时出现 Wanderer 碾压房间与战利品。 |
| **掉落哲学** | **loot = SKU**：部件/装备主题跟地牢走；箱子常出高价物。战斗是进货手段。 |
| **安全 vs 战斗** | 镇白天安全；地牢在村内门后但夜间才是冒险身份。治疗池/营地房间无刷怪。 |
| **失败态** | HP=0 → 吐出地牢，**丢背包大部（口袋保留）** + 恢复 12 小时。惩罚对准「这趟进货」而非永久角色。 |
| **护 cozy** | 身份是商人而非英雄；失败损失可预期；白天经营缓冲战斗挫败。 |

**Sources:** [Dungeons](https://moonlighter.fandom.com/wiki/Dungeons) · [Enemies](https://moonlighter.fandom.com/wiki/Enemies) · [Combat](https://moonlighter.fandom.com/wiki/Combat) · [How to play guide](https://moonlighter.fandom.com/wiki/How_to_play_guide_for_Moonlighter) · [Wikipedia:Moonlighter](https://en.wikipedia.org/wiki/Moonlighter_(video_game))

---

### 1.7 Dredge — 威胁但不「经典砍杀」（对照项）

| 维度 | 设计 |
| --- | --- |
| **循环角色** | 昼安全捕捞；夜/黑暗推高 **Panic** → 幻觉威胁、船体损伤风险；**Aberration 鱼**是高价/任务材料，主要来自扰动水面而非「打怪掉」。 |
| **攻击模型** | 非武器砍怪：环境/生物撞击、恐惧压力； Leviathan 等在越界/高 Panic 开海可即死。有 Passive 模式削弱威胁。 |
| **掉落哲学** | 「材料」=鱼/异变鱼/遗物；危险换 **稀有渔获**，不是尸体零件表。 |
| **安全 vs 战斗** | 码头/灯光明亮处降 Panic；黑暗远海是危险口袋。 |
| **失败态** | 船体毁坏/被吞 → 掉进度与货舱风险，但仍是**航行失败**叙事。 |
| **护 cozy** | 保留探索紧张却不要求操作型战斗；玩家可用短途夜钓、回港、灯光控制风险。 |

**Sources:** [Panic](https://dredge.wiki.gg/wiki/Panic) · [Aberrations](https://dredge.wiki.gg/wiki/Aberrations) · [Leviathan](https://dredge.wiki.gg/wiki/Leviathan)

---

### 1.8 Fields of Mistria — 矿内专属怪 + 家具/烹饪材料

| 维度 | 设计 |
| --- | --- |
| **循环角色** | 与 Stardew 同族：梯子来自岩石或杀怪；怪仅在 Mines。 |
| **攻击模型** | 敌对接触；特殊层需清光才开梯；生物群系分区（Upper / Tide / Deep Earth / Lava）。 |
| **掉落哲学** | Monster Fang / Shell / Powder / Sap 等明确进 **家具、烹饪、铺装、Dragon-Forged**；另有「可爱」向：Friend-Shaped 宠物皮肤掉落。 |
| **安全 vs 战斗** | 镇/农场无怪；矿内才有。 |
| **失败态** | HP=0 → 昏倒结束当日。 |
| **护 cozy** | 怪物美术偏可爱；掉落喂装饰与生活配方；技能可双倍掉落 / 宠物皮肤，把杀戮读成「收集」。 |

**Sources:** [The Mines](https://fieldsofmistria.wiki.gg/wiki/Mines) · [Monsters](https://fieldsofmistria.wiki.gg/wiki/Monsters) · [Monster Loot](https://fieldsofmistria.wiki.gg/wiki/Monster_loot) · [Combat](https://fieldsofmistria.wiki.gg/wiki/Combat)

---

### 1.9 Spiritfarer — 无战斗对照（护 cozy 的极端）

| 维度 | 设计 |
| --- | --- |
| **循环角色** | 照料灵魂：种、煮、建、钓；材料来自采集与工艺，**不来自击杀**。 |
| **攻击模型** | 无。 |
| **掉落哲学** | N/A（无敌掉落表）。 |
| **安全 vs 战斗** | 全图无战斗失败。 |
| **失败态** | 官方访谈：无 game over、无严酷进度损失。 |
| **护 cozy** | 工作室明确用 **tend and befriend** 替代 **maim and kill**；紧张感来自告别叙事与平台移动，不是血条。 |

**Sources:** [Red Bull × Thunder Lotus interview](https://www.redbull.com/int-en/spiritfarer-developer-thunder-lotus-games-interview) · [GamesIndustry.biz](https://www.gamesindustry.biz/spiritfarer-wants-to-talk-to-you-about-death) · [PC Gamer / Guérin on care](https://www.pcgamer.com/spiritfarer-is-a-serene-boat-adventure-about-compassion-in-the-face-of-death/)

---

### 1.10 补充：Story of Seasons / 旧 Harvest Moon「软害虫」（非战斗掉料）

| 维度 | 设计 |
| --- | --- |
| **循环角色** | 现代 SoS（如 3DS）野生动物偏 **投喂交友送礼**，非击杀掉料。 |
| **旧作害虫** | 部分旧 HM：野狗夜扰未关畜、地鼠吃作物——**资源损耗事件**，不是战斗掉落环。 |
| **对 Dream 启发** | 「有害但不战斗」可走 **驱逐/投喂/围栏**，与 breakables/hotspot 同族。 |

**Sources:** [Wikipedia:Story of Seasons — pests note](https://en.wikipedia.org/wiki/Story_of_Seasons) · [FoGU wild animals (SoS)](https://fogu.com/sos1/activities/wild-animals.php) · [Wildlife (SoS) wiki](https://harvestmoon.fandom.com/wiki/Wildlife_(SoS))

---

## 2. 横向对照表

### 2.1 敌对物在循环中的角色

| 游戏 | 主环 | 敌对物角色 | 掉落主要去向 |
| --- | --- | --- | --- |
| Stardew | 农 | 可选矿洞推进助推器 | 制作增效 / 公会卖 |
| RF4 | 农+战一体 | 材料工厂 + 可驯服劳动力 | 装备/炼金硬闸 |
| Coral Island | 农 | 矿内障碍 + Combat 树 | 陷阱/供品/制作 |
| Sun Haven | 农+多区 | 矿内风险与 XP | 装备/技能；Boss 稀有 |
| Graveyard Keeper | 经营 | 侧线清图任务 | 炼金/任务；深层矿 |
| Moonlighter | 店 | **进货** | 上架出售 |
| Dredge | 渔 | 环境压力（非砍杀掉料） | 异变鱼高价/任务 |
| FoM | 农 | 矿内专属材料源 | 家具/烹饪/装饰 |
| Spiritfarer | 照料 | （无） | — |

### 2.2 攻击 / 仇恨模型谱系

| 模式 | 代表 | 玩家感受 |
| --- | --- | --- |
| 接触伤害 + 追击 | Stardew / FoM / Coral | 经典矿洞 |
| 可配置仇恨（hit-to-aggro） | Coral Island 设置 | 降低突然被围 |
| 清房/清层才前进 | Moonlighter / GYK / FoM 特殊层 | 节奏像「关卡」 |
| 不刷新清图 | GYK；Moonlighter 已杀不刷 | 「征服感」 |
| 压力条/环境威胁 | Dredge Panic | 紧张但不要求连招 |
| 无攻击 | Spiritfarer | 纯 cozy |

### 2.3 掉落哲学：Junk vs Gate

| 类型 | 含义 | 例子 |
| --- | --- | --- |
| **Junk / 卖钱** | 低决策，清包压力 | 廉价果冻、重复零件 |
| **Crafting soft gate** | 没有也能玩，有则更强/更美 | Stardew Bat Wing→避雷针；FoM Sap→家具 |
| **Crafting hard gate** | 卡主线或关键装备 | RF4 锻造链；部分神庙供品 |
| **Quest token** | 叙事取货 | GYK Bloody Nails；Dredge 异变鱼 pursuit |
| **Shop SKU** | 掉落=商品差异化 | Moonlighter 地牢主题物 |
| **Alt acquisition** | 同材料可砸罐/挖矿/养鱼获得 | Stardew 精华也可鱼塘；GYK 血桶可制作 |

**可复用规则：** cozy 项目应默认 **soft gate + 替代获取**；hard gate 只放在显式「冒险口袋」。

### 2.4 安全区契约（护 cozy 的核心）

几乎所有成功样本共享：

1. **家园/广场/车站 = 零敌对**（或仅可选开关，如 Stardew 农场怪）。  
2. **危险有门：** 矿口、地牢门、夜航、森林深处——玩家「走进去」才开战。  
3. **失败可恢复：** 昏倒结束日 / 丢本趟战利品 / 回入口；不做永久死亡。  
4. **主环不依赖击杀：** 种田、钓鱼、社交在无战斗下仍完整（Spiritfarer 极端证明）。

---

## 3. 可复用设计模式（给实现者）

| ID | 模式名 | 做法 | Dream 贴合度 |
| --- | --- | --- | --- |
| P1 | **Zone-gated threat** | 仅 C17/C16/C29/C31/forest_deep 等挂威胁 | ★★★★★ |
| P2 | **Breakable-first loot** | 先扩展 C59 式可打物掉料，再加移动 AI | ★★★★★ |
| P3 | **Soft pest** | 夜袭作物/粮袋；驱赶/投喂/围栏，不扣玩家 HP | ★★★★☆ |
| P4 | **Encounter pocket** | 遗迹侧廊/下水道岔路：静态或短程敌，清完变安全 | ★★★★★ |
| P5 | **Dual track resources** | 矿石来自挖；「生物材料」来自敌/害虫；关键配方可双源 | ★★★★☆ |
| P6 | **Fail = day tax** | HP 空 → 送回入口 + 少量货币/体力惩罚，不删档 | ★★★★☆ |
| P7 | **Comfort toggles** | hit-to-aggro / 无敌 / Passive 模式（学 Coral / Sun Haven / Dredge） | ★★★☆☆ |
| P8 | **Loot as furniture flavor** | 材料喂装饰与生活配方（FoM），少喂「DPS 数值」 | ★★★★★ |
| P9 | **Time-of-day threat** | 仅 Night + 特定区（接 DayNightWeather）；白日同图安全 | ★★★★★ |
| P10 | **No combat path** | 全内容可用钓鱼/箱子/breakable/NPC 交换绕过 | ★★★★★ |

### 材料表建议骨架（逻辑，非数值定案）

| 材料族 | 获取 A（安全） | 获取 B（威胁） | 用途倾向 |
| --- | --- | --- | --- |
| 纤维/树脂 | 摇树、砍灌木 | 林中害虫驱赶掉落 | 绳、灯、家具 |
| 甲壳/碎骨 | 湖岸捡、渔获加工 | 下水道/遗迹口袋 | 装饰、黑市换票 |
| 矿尘/晶屑 | C17 挖掘 hotspot | （可选）矿内活动岩怪 | 工具、轨道道具 |
| 「夜露」类 | 雨夜采集 | 夜间森林压力事件 | 灯、列车夜行相关 |

---

## 4. Dream 推荐方案

### 方案 A — Soft pests（软害虫 / 可驱赶生物）

**一句话：** 农场/粮仓/湖岸出现可交互「害虫」；用已有 hotspot 动词（拍、喂、洒水、围栏）解决，掉少量材料，**不攻击玩家 HP**。

| | |
| --- | --- |
| **Pros** | 最贴 cozy；零战斗系统债；复用 C58/C59；可接 DayNightWeather（仅夜出）。 |
| **Cons** | 「打怪掉料」满足感弱；难撑遗迹/下水道的冒险幻想。 |
| **偷谁** | 旧 HM 害虫事件 + SoS 投喂野生 + Spiritfarer 无杀。 |

### 方案 B — Encounter pockets（遭遇口袋）⭐ 建议主路线

**一句话：** 广场/车站/农场永远安全；仅在 **forest_deep / C16 / C17 / C29 / C31** 放置短遭遇：可移动或驻守的「可打物」，打掉掉材料，清完该口袋变安全（学 GYK/Moonlighter 清房）。

| | |
| --- | --- |
| **Pros** | 保留家园幻想；利用已有危险空间文档；可与箱子/breakable 同屏；Phase 可切片。 |
| **Cons** | 需要最小 HP/击退/掉落表；要做安全契约文档防以后漏怪进镇。 |
| **偷谁** | Stardew/FoM 分区 + GYK 清层 + Coral 可选仇恨 + FoM 家具向掉落。 |

### 方案 C — Full combat（完整战斗环）

**一句话：** 武器栏、技能树、刷怪层、Boss——类 RF4 / Sun Haven 主战。

| | |
| --- | --- |
| **Pros** | 长期深度、装备成长。 |
| **Cons** | 与当前「无战斗」代码/ UX / 叙事落差大；易破坏车站日常节奏；实现与平衡成本最高。 |
| **何时考虑** | 方案 B 验证「玩家想要更多」且材料经济已稳定之后。 |

### 建议优先级

**Phase 0 → B 的最小切片；并行可做 A 的夜袭害虫作农场风味。不做 C。**

---

## 5. Suggested Phase 0 slice（贴合现有系统）

**目标：** 在不引入完整 Combat 技能树的前提下，验证「危险区打一下掉料」是否有趣，且 **零污染** 广场/车站。

### 5.1 范围（做）

| 项 | 说明 |
| --- | --- |
| **场所** | 优先 **C29 Ruins 东侧 cache 廊** 或 **C31 Sewer pipe 岔口** 二选一（已有「藏宝/黑市」叙事）；次选 C17 挖点旁 1 个驻守物。 |
| **实体** | 1 种 `LootCritter`：低速或驻守，接触轻伤 **或** 仅反击不追出口袋（hit-to-aggro）。 |
| **攻击玩家手段** | 复用/延伸交互：持「杆/铲」热点或点击 3 次=击破（可先不做独立武器 UI）。 |
| **掉落** | 1–2 种新材料 id，用途限：**1 个装饰配方或黑市兑换提示**（soft gate）。 |
| **替代获取** | 同材料也可从该区 breakable 坛/箱低概率出（P5）。 |
| **时段** | 可选：仅 `DayNightWeather` Night 加强刷新；日间口袋空或休眠。 |
| **失败** | HP 空 → 传送口袋入口 + 短 InfoPanel「吓了一跳…」，**不丢背包**（比 Stardew 更温柔）。 |
| **安全契约** | 单元测试/文档断言：`village_*` / `station` / farm 组装器 **零** `LootCritter` 生成。 |

### 5.2 范围（禁止做）

- 不进广场刷怪、不进列车车厢打架。  
- 不做 20 种怪图鉴、不做 Boss、不做装备栏。  
- 不让主线种田/钓鱼/车票强依赖击杀掉落。  
- 不改 Assembler 大重构；用 kit/controller 薄挂载（学 C58–C62 / ENV_H 风格）。

### 5.3 验收（玩家手测 — 中文路径请本机 Godot）

1. 车站 → 深林 → 遗迹（或住宅井 → 下水道）：能遇到 1 处可清除生物。  
2. 清除后获得材料；InfoPanel 说清用途。  
3. 回广场/农场：无敌对、无血条常驻 UI。  
4. 故意「失败」一次：回入口，日环仍可继续。  
5. 关掉威胁或走安全路径：仍能玩完当天（钓鱼/箱子/breakable）。

### 5.4 与现有文档锚点

| 文档 | 用法 |
| --- | --- |
| [`WORLD_C58_C62.md`](../WORLD_C58_C62.md) | hotspot / breakable / chest 交互语法 |
| [`ENV_H.md`](../ENV_H.md) | Night 刷新钩子 |
| [`MINE_C17.md`](../MINE_C17.md) / [`CAVES_C16.md`](../CAVES_C16.md) | 挖点旁驻守物 |
| [`RUINS_C29.md`](../RUINS_C29.md) | 侧廊 cache 口袋 |
| [`SEWER_C31.md`](../SEWER_C31.md) | 管道岔口 + 黑市材料叙事 |
| [`PHASE5_WAVE_C.md`](../PHASE5_WAVE_C.md) | 危险空间门户已存在 |

---

## 6. 禁止偷懒 checklist（给后续实现 agent）

执行任何「敌人掉落」相关任务时，**禁止**只做表面工作：

1. **禁止**在广场 / 车站 / 农舍门前刷可伤玩家的怪「先看看效果」。  
2. **禁止**只加血条 UI 却不写安全区契约与生成白名单。  
3. **禁止**掉落材料没有任何 sink（配方/兑换/展示）——禁止纯 junk 刷屏。  
4. **禁止**把关键进度（车票、主线门、钓鱼解锁）做成「必须击杀」。  
5. **禁止**照搬完整 Stardew 矿 120 层 / RF 战斗数值当 Phase 0。  
6. **禁止**用一个巨大 `CombatManager` 吞掉现有 hotspot/breakable；应 **kit 化** 扩展。  
7. **禁止**失败惩罚删除存档或清空全部背包（Moonlighter 级惩罚需另开设计评审）。  
8. **禁止**只有代码没有：安全区列表、材料双源表、玩家验收步骤。  
9. **禁止**美术未定就先做 10 种敌人；Phase 0 **一种**剪影 + 一种掉落即可。  
10. **禁止**忽略 DayNightWeather：若声称「夜间更危险」必须真挂钩。  
11. **禁止**改完不跑子 agent / 人工对照本清单与 §5 验收。  
12. **禁止**未获用户明确要求就 `git commit` / 强推与本任务无关的资产大清洗。

---

## 7. 结论（给制作人）

- 类型共识：**家园零威胁 + 显式口袋里的可选威胁 + 可恢复失败 + 材料偏生活/装饰 soft gate**。  
- Dream 最省债且最贴现有壳的路径是 **方案 B（Encounter pockets）**，用 C29/C31/C17 做 Phase 0；农场侧可点缀 **方案 A**。  
- **方案 C** 推迟到经济与身份叙事明确需要「冒险者」之后。  
- Spiritfarer / Dredge 提醒：张力不必等于砍杀；若 Phase 0 手感破坏日常，应退回害虫/压力事件而非加武器栏。

---

## 8. Source index（URL）

| 主题 | URL |
| --- | --- |
| Stardew Mines | https://stardewvalleywiki.com/The_Mines |
| Stardew Monsters | https://stardewvalleywiki.com/Monsters |
| Stardew Monster Loot | https://stardewvalleywiki.com/Monster_Loot |
| Stardew Combat / Health | https://stardewvalleywiki.com/Combat · https://stardewvalleywiki.com/Health |
| RF4 Bestiary | https://ranchstory.miraheze.org/wiki/Bestiary_(Rune_Factory_4) |
| RF4 Monsters | https://therunefactory.fandom.com/wiki/Monsters_(RF4) |
| Coral Cavern / Combat / Loot | https://coralisland.fandom.com/wiki/Cavern · https://coralisland.wiki/wiki/Combat · https://coralisland.wiki/wiki/Monster_Loot |
| Sun Haven Mines / Combat / Starter | https://sunhaven.wiki.gg/wiki/Sun_Haven_Mines · https://sunhaven.wiki.gg/wiki/Combat · https://sunhaven.wiki.gg/wiki/Guide:Starter_Guide |
| Graveyard Keeper Dungeon / Monsters | https://graveyardkeeper.fandom.com/wiki/Dungeon · https://graveyardkeeper.fandom.com/wiki/Monsters |
| Moonlighter Dungeons / Enemies / Combat | https://moonlighter.fandom.com/wiki/Dungeons · https://moonlighter.fandom.com/wiki/Enemies · https://moonlighter.fandom.com/wiki/Combat |
| Dredge Panic / Aberrations / Leviathan | https://dredge.wiki.gg/wiki/Panic · https://dredge.wiki.gg/wiki/Aberrations · https://dredge.wiki.gg/wiki/Leviathan |
| Fields of Mistria Mines / Monsters / Loot | https://fieldsofmistria.wiki.gg/wiki/Mines · https://fieldsofmistria.wiki.gg/wiki/Monsters · https://fieldsofmistria.wiki.gg/wiki/Monster_loot |
| Spiritfarer interviews | https://www.redbull.com/int-en/spiritfarer-developer-thunder-lotus-games-interview · https://www.gamesindustry.biz/spiritfarer-wants-to-talk-to-you-about-death |
| Story of Seasons pests / wildlife | https://en.wikipedia.org/wiki/Story_of_Seasons · https://fogu.com/sos1/activities/wild-animals.php |
