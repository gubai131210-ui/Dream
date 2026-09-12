# Dream 交互·场景·素材统称（GOAL）

**Status:** ACTIVE — Goal 执行中  
**Date:** 2026-09-13  
**Locks:** [`ASSET_TAXONOMY.md`](ASSET_TAXONOMY.md) A–H · [`INTERACTION_DESIGN.md`](INTERACTION_DESIGN.md) · [`PHASE5.md`](PHASE5.md) · [`WORLD_C58_C62.md`](WORLD_C58_C62.md) · [`INTERIOR_LIBRARY.md`](INTERIOR_LIBRARY.md)  
**Skills:** `painting-asset-craft` · `realistic-scene-craft` · `interior-territory-craft` · `interior-visual-qa`

---

## 0. 目标终态（不可缩小）

1. **所有已列交互**有正式像素外观 + 可触发反馈 +（适用时）多帧动画；禁止以菱形/纯 Info 作为最终交付。  
2. **所有可玩场景**（户外 A 区 + 室内 C 系列）门面/道具/室内装配到位，传送可进可出。  
3. **统称文档**（本文件）为权威清单与验收门。  
4. **多团队流水线**（下节）对每一批新素材跑完全部门禁。  
5. 证据：MCP/本地 Godot 运行时截图或无 ERROR 冒烟 + `tools/qa_interaction_frames.py`。

---

## 1. 统称表（编号语言）

| 统称 | 英文/代码 | 覆盖 | 权威源 |
| --- | --- | --- | --- |
| **层 A–H** | Asset Taxonomy | 参考/室外/室内/地下/玩法/事件/交互/环境 | `ASSET_TAXONOMY.md` |
| **区** | District / Area | 广场、住宅、农场、市集、林、河、瀑、湖、站… | `AREA_FRAMEWORK.md` + assemblers |
| **室** | Interior Cxx | C01–C52 等可进室内 | `INTERIOR_LIBRARY.md` · `SceneRouter` |
| **交** | Interact G / C58 | 坐/井/摇树/告示/箱/灯/喂鸟/路牌… | `WorldInteractKit` |
| **破** | Breakable C59 | 碎石/桩/草/破箱 | `BreakablesKit` |
| **门** | Gate C60 | 倒木/巨石/锁门 | `ProgressGates` |
| **箱** | Chest C61 | 隐藏宝箱 | `HiddenChests` |
| **密** | Secret C62 | 密道链 | `SecretPassageChain` |
| **季** | Season C55 | 春夏秋冬装饰层 | `SeasonalDecor` |
| **环** | Routine C53/C54 | NPC 工作/生活环 | `npc_routine_*` |
| **钓** | Fish E | 钓点/竿/鱼 | `FISH_E.md` |
| **境** | Env H | 昼夜天气 | `ENV_H.md` |
| **动** | Anim frame | idle/focus/action/result | `INTERACTION_DESIGN.md` §2–3 |

---

## 2. 多团队与 Agent 角色

| 团队 | Agent 角色 | 职责 | 禁止偷懒 |
| --- | --- | --- | --- |
| **ArtGen** | 绘图 | 按 `SCALE.md` / `painting-asset-craft` 出 sheet | 禁止整张 A 参考图糊进场景 |
| **Slice** | 裁剪 | 按 cell/帧格切开 | 禁止不固定画布就切 |
| **Cutout** | 抠图 | 去底、规范透明边 | 禁止透明边导致脚底乱跳 |
| **Import** | 导入 | `.import` / Nearest / UID | 禁止坏 `metadata={{` sidecar |
| **StyleQA** | 风格检验 | 3/4、描边、调色同源 | 禁止另一套透视混入 |
| **CanonQA** | 可续科学性 | 受力/开合/流向可解释 | 禁止无原因闪烁 |
| **GenreQA** | 品类对照 | Stardew/ACNH/Spiritfarer 可迁移规律 | 禁止抄图；只迁移系统规律 |
| **CohereQA** | 导入一致性 | 与现有 props/室内套件一致 | 禁止单件漂色 |
| **AnimQA** | 动态帧 | pivot/contact/时长；跑 `qa_interaction_frames.py` | 禁止整物位移冒充动画 |

并行时：**文件所有权互斥**（户外 assembler / 室内 profile / `scripts/world/**` / `assets/sprites/props/**`）。

---

## 3. 验收门（每批素材）

```text
[ ] 绘图画布与 pivot 写入 manifest 或审计表
[ ] 裁剪后帧尺寸一致
[ ] 抠图后脚底线对齐（AnimQA）
[ ] 导入 Nearest + 可 load
[ ] StyleQA + CohereQA 签字
[ ] CanonQA：状态变化可解释
[ ] GenreQA：不破坏邻接/站位规则
[ ] 引擎内整数缩放目视
[ ] 交互：hover → action → result 三层反馈
```

---

## 4. 执行波次（本 Goal）

| Wave | 内容 | 完成判据 |
| --- | --- | --- |
| **G0** | 本统称 + 全量缺口盘点 | 文档落地；inventory 可引用 |
| **G1** | 广场 C58–C60 菱形→正式 prop 精灵 + 基础反馈 | 标记关闭时仍可见可点；灯可亮灭 |
| **G2** | C58 action 短动画（摇树叶、井绳、箱盖、鸟） | ≥4 类有帧或程序化 FX |
| **G3** | C55 季节装饰真素材（非 ColorRect 簇） | S 切换可见季节 prop |
| **G4** | 全区 G 层铺开（市集/农场/林至少各 2 交互） | 非仅广场 |
| **G5** | 入口立面/传送可发现性（无依赖 debug 菱形） | hover 标签或门脸 |
| **G6** | 室内家具局部开合 + 火焰锚点回归 | fire/forge + ≥3 开合 |
| **G7** | 钓鱼/NPC 环姿态与站点抛光 | C22 评估；fish ring 接线 |
| **G8** | 全场景冒烟 + 帧 QA + 用户 Godot QA 清单清空 | 证据齐全 |

### 禁止偷懒（Goal 级）

- 禁止只改文案/只加 InfoPanel 冒充「交互做完」  
- 禁止用 debug 菱形当最终美术  
- 禁止只做广场、声称「所有场景」  
- 禁止跳过 AnimQA / StyleQA 批量灌图  
- 禁止把时间「做满 8h」当成完成标准（完成标准是终态，不是工时）  
- 禁止未更新本统称进度表就宣称 Wave 完成  

---

## 5. 当前缺口快照（2026-09-13）

详见会话 inventory（explore）：广场 WorldSys **逻辑已通、美术不足**；室内 Wave A–F **desk 丰富、用户 QA 未清**；真正缺的是 **动层 + 全区 G + 入口可发现性**。

| 优先级 | 缺口 |
| --- | ---:|
| P0 | C58/C59/C60 正式精灵与反馈 |
| P0 | 交互动画层 idle/focus/action/result |
| P1 | C55 季节真素材 |
| P1 | 入口立面 / 传送可发现 |
| P1 | 用户 Godot QA Waves A2–F |
| P2 | C53 职业姿态；钓鱼 C22；全区 G |

---

## 6. 进度

| Wave | Status |
| --- | --- |
| G0 | **DONE** — 本统称落地；缺口 inventory 完成 |
| G1 | **DONE (code)** — C58/C59/C60 prop 精灵 + 灯/脉冲；广场 MCP smoke 无 ERROR |
| G2 | **DONE (code)** — `leaf_fall` / `well_rope` / `crate_lid` / `bird_peck` 固定画布帧已接线；StyleQA 抛光仍开放 |
| G3 | **DONE (code)** — C55 四季改用真实 prop；层与 TopBar 默认可见（不依赖 demo overlay） |
| G4 | **DONE (code)** — 市集/农田/深林各 ≥2 DistrictInteractKit prop 交互 |
| G5 | **DONE (code)** — 户外/室内/WorldSys 传送增加常显门阶+拱门 cue；hover 显名 |
| G6–G8 | PENDING |

## Related

- [`INTERACTION_DESIGN.md`](INTERACTION_DESIGN.md)  
- [`WORLD_C58_C62.md`](WORLD_C58_C62.md)  
- [`PHASE5.md`](PHASE5.md) · Wave A–F locks  
- `dream/.cursor/skills/painting-asset-craft/SKILL.md`
