# Area framework — 广场 / 住宅 / 农场 / 农田 / 市集

**Status:** LOCKED (craft parameters)  
**Date:** 2026-09-10  
**Scope:** 各场景类型的**空间语法**（开敞度、路宽、密度、锚点、水体角色、地面生态、NPC 图）。不是玩法类型标签。  
**Skills:** `.cursor/skills/realistic-scene-craft/` · `.cursor/skills/painting-asset-craft/`  
**Research:** `docs/research/SYNTHESIS.md` · `practitioners/district-spatial-grammar.md`

> 布局单调的根因通常是：**五类场景共用同一套「中心石板 + 北侧房子 + 西侧河」参数**。  
> 本文件规定每类场景必须有**可测的参数差**；assembler 禁止只改坐标不换骨架。

---

## 1. Village skeleton（全村共享）

跨场景一致的现实规则（来自村镇程序化研究与 Ostriv / ACNH / Stardew craft）：

| 规则 | 含义 |
| --- | --- |
| **中心高密度** | 广场/市集附近建筑最密；向外变稀（农场在外围） |
| **路网分级** | 主路宽、支路窄、田间小径更窄；禁止全图同宽石板 |
| **功能按距离** | 市政/喷泉/井 → 近中心；住宅 → 中环；农舍/田 → 外环 |
| **门对公共空间** | 南向门美术 → 建筑在路/广场**北侧**；门前有 apron（土/石） |
| **水有角色** | 广场：西缘河廊；住宅：小池/支流；农场：灌溉蜿蜒；农田：渠+桥 |
| **步行图** | NPC 只走 walk graph；停留点在锚点（井、门、摊位） |

参考：

- Minecraft ACO 村落：中心密、农场外置、主路宽于支路 — [CWI PDF](https://ir.cwi.nl/pub/35899/35899.pdf)
- Ostriv：弯路、变路宽、田可贴住宅外缘 — [gameplay.tips Ostriv](https://gameplay.tips/guides/8156-ostriv.html)
- Galin et al. village skeleton（seed + road）— [2012 PDF](https://perso.liris.cnrs.fr/egalin/Articles/2012-villages.pdf)
- FoMT：农场极开敞田 + 北缘建筑带；Rose Plaza 硬铺最大开敞 — `docs/research/games/story-of-seasons.md`
- Coral Island：**西农 → Garden Lane 绿缓冲 → 铺装镇心** — `docs/research/games/coral-island.md`
- Portia：双广场 + Main Street 脊；工坊在城墙外 — `docs/research/games/my-time-at-portia.md`
- RF4：广场度中心 + 东商店廊 + 西住宅 + 北交通脊 + 城堡后田 — `docs/research/games/rune-factory-4.md`

---

## 2. District parameter table（Dream 锁定）

单位：tile（`BASE_TILE=32`）。地图默认约 **40×30**。

| 参数 | A09 广场 plaza | A08 村庄住宅 | A02 农场住宅 | A03 农田 | A10 市集/商业街 |
| --- | --- | --- | --- | --- | --- |
| **开敞核心** | 大正方形石板 ≥8×6 | 小口袋广场 ≤4×4 或无 | 庭院土坪，非石板中心 | 中心土 hub + 田块矩阵 | **长条**石街（E–W 长、N–S 窄） |
| **主路面** | stone | stone 支路 + dirt 入户 | **dirt** 主，stone 少 | dirt / 田埂 | stone 主街 |
| **主路宽** | 3–4 | 2 | 2 | 2（桥带 3–5） | 3 |
| **支路/入户** | 2 dirt spur | 1–2 dirt | 1 dirt | 1 田埂 | 1–2 侧巷 |
| **建筑密度** | 低–中（少而大） | **高**（多栋紧凑） | 低（1–3 栋+畜舍） | 极低（1–2 仓棚） | 中（沿街店铺） |
| **建筑朝向** | 北侧朝南对广场 | 北侧朝南对**巷** | 朝庭院/主土路 | 朝 hub | 北/东侧朝南对街 |
| **功能锚点** | 井/喷泉、市政、教堂位 | 巷口灯、小井、口袋广场 | 农舍门、畜栏、小塘 | 仓棚、风车位、田标签 | 摊位列、店铺门 |
| **围栏** | 无（或仅河边） | 院篱可选 | **整园围栏** + inset build | **田块小篱** + 外栏 | 无整园栏 |
| **水体角色** | 西缘 meander 河廊 + 桥 | SE **小池/卵形塘** | 小塘或短支流 | **灌溉 meander** + 1–2 桥 | 可选短西缘河，不抢街 |
| **植被** | 岸柳；广场内少树 | 院树密、巷边少 | 果树/点缀，田外林带 | 林缘在 PLAY 外；田内无大树 | 街树稀，摊位道具密 |
| **草生态权重** | 路旁 mowed 强 | meadow 院 + mowed 巷 | meadow + weed 扰动 | meadow；田床=dirt 矩形 | mowed 街旁；少 tall |
| **NPC 图** | 广场环线 + 门前 | 巷道环线 + 门前 idle | 门↔畜栏↔塘 | hub↔田角（少） | 沿街来回 + 摊位停留 |
| **道具语法** | 井、长椅、灯 | 信箱、花箱、矮篱 | 木桶、草料、工具 | 作物床、袋、篱柱 | 箱、桶、篷、灯 |
| **禁止同构** | 禁止变成「农田矩阵」 | 禁止中央大石板广场 | 禁止市政喷泉作中心 | 禁止北排住宅街景 | 禁止正中大广场（用长街） |

### 一眼可辨（silhouette test）

缩到 1/8 截图仍应能分辨：

1. **广场** — 大块亮石板 + 北侧大屋顶  
2. **住宅** — 多屋顶网格 + 窄巷  
3. **农场住宅** — 围栏框 + 1 大屋顶 + 空庭  
4. **农田** — 多矩形色块田床  
5. **市集** — 水平亮带（街）+ 摊位点列  

任一场景缩略图与另一类混淆 → **骨架失败**，不是「缺贴图」。

---

## 3. Pass order per district（差异点）

共享总序仍是：masks → ground → water → path → buildings → props → trees → actors → FX。  
**差异在 mask 语义：**

| District | 关键 mask 差异 |
| --- | --- |
| Plaza | `path_mask` = 大矩形 civic；`water` = 西廊 meander |
| Residential | `path_mask` = 巷网 + 小口袋；`water` = SE 池；lots 网格 |
| Farm home | `path_mask` = 土字/环庭；`fence` 外框；`pond` 可选 |
| Farmland | `crop_beds[]` 矩形组；`irrigation` meander；hub 环路 |
| Market | `path_mask` = **条带**非方块；stall slots 沿街 |

---

## 4. Anti-monotony（反单调）

1. **节奏**：开敞 → 密建 → 开敞（住宅巷口放大，广场中央放大，农田用田床重复制造「另一种节奏」）。  
2. **材料对比**：石 / 土 / 草 / 水 面积比每区不同（见表）。  
3. **频率**：广场少大锚点；住宅多中频屋顶；农田高频矩形。  
4. **路宽阶梯**：同图内至少两种路宽。  
5. **生态距离场**：`dpath` / `dbank` / `dedge` 权重按区改阈值（见 `reference-formulas.md` zone profiles）。  
6. **禁止**：五区共用同一 `cx(ty)` 河公式且同一 plaza Rect。

---

## 5. Assembler checklist（验收）

每个新/改 assembler：

- [ ] 填上表对应列，并在脚本头注释写明 district id  
- [ ] 缩略 silhouette test 通过  
- [ ] 主路材料与宽度符合表  
- [ ] 水体角色符合表（不是随便一条西河）  
- [ ] 建筑朝向 + 全精灵 AABB ⊆ build zone  
- [ ] NPC 路径表面偏好符合表  
- [ ] 未复制粘贴广场骨架只改坐标  

---

## 6. Scene map（当前）

| ID | District | Assembler |
| --- | --- | --- |
| A09 | plaza | `village_square_assembler.gd` |
| A08 | residential | `village_residential_assembler.gd` |
| A02 | farm_home | `farm_residential_assembler.gd` |
| A03 | farmland | `farmland_assembler.gd` |
| A10 | market | `market_street_assembler.gd` |

---

## 禁止偷懒

- 禁止五区共用同一中心石板 + 北排房 + 西直河模板  
- 禁止住宅区画成「迷你广场」  
- 禁止农田不画 ≥6 田床却称农田  
- 禁止市集画成正中大广场  
- 禁止只换贴图不换路宽/密度/锚点  
- 禁止文档与 assembler 头注释不一致  

更新本文件时同步：`LAYOUT.md`、`SYNTHESIS.md`、`realistic-scene-craft` skill。

---

## 室内与特殊区域

本文件的 district 参数表 **只约束室外壳层**。可进入室内、地下、钓鱼玩法场景、昼夜天气等见：

- [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md)（C 类目录与优先 10）  
- [`ASSET_TAXONOMY.md`](ASSET_TAXONOMY.md)（A–H 分层）  
- [`PHASE5.md`](PHASE5.md)（室外壳层完成后再启动）

禁止把室外开敞度/路宽表直接套到室内房间布局。
