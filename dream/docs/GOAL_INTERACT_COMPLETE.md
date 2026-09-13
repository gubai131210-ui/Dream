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

> 本轮（地标/门脸/破/栅/垄/棚布）**Agent 门禁**已签；「引擎内整数缩放目视」仍需用户 §7 手感确认。

```text
[x] 绘图画布与 pivot 写入 manifest 或审计表 — `paint_landmark_props.py` + GOAL_TEAM_SIGNOFF
[x] 裁剪后帧尺寸一致 — 单帧 prop；`qa_interaction_frames` 多帧组 GREEN
[x] 抠图后脚底线对齐（AnimQA）— work_poses / interaction frames GREEN；NPC white-plate GREEN
[x] 导入 Nearest + 可 load — `.import` sidecars；inventory GREEN
[x] StyleQA + CohereQA 签字 — `qa_landmark_style` + `qa_work_pose_style` + TEAM_SIGNOFF
[x] CanonQA：状态变化可解释 — C58/C59/C60/C22 smokes + Genre/Canon agent PASS
[x] GenreQA：不破坏邻接/站位规则 — outdoor props 路径禁 interior；orphan Visual GREEN
[ ] 引擎内整数缩放目视 — **用户 §7**（Agent MCP：plaza `CameraController.zoom=(1,1)` + `g8_square_zoom1_work_pose_v2.png`）
[x] 交互：hover → action → result 三层反馈 — focus_corners + activate/open FX smokes + MCP
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

## 5. 当前缺口快照（2026-09-13 晚）

代码侧 G0–G7 与大部分 G8 残留已关；**权威阻塞**仍是用户本机 Godot QA（§7）。

| 优先级 | 缺口 |
| --- | ---:|
| P0 | **用户 Godot QA Waves A2–F + §7 勾选** |
| P1 | 姿态/摊位 ArtGen 继续抛光（非阻塞） |
| P2 | tomyud1 MCP 截图证据（**全户外 + 多室内**；C62/C58 FX 冒烟 PASS；仍不代替 §7） |

---

## 6. 进度

| Wave | Status |
| --- | --- |
| G0 | **DONE** — 本统称落地；缺口 inventory 完成 |
| G1 | **DONE (code)** — C58/C59/C60 prop 精灵 + 灯/脉冲；广场 MCP smoke 无 ERROR |
| G2 | **DONE (code)** — `leaf_fall` / `well_rope` / `crate_lid` / `bird_peck` 固定画布帧已接线；StyleQA 抛光仍开放 |
| G3 | **DONE (code)** — C55 四季改用真实 prop；层与 TopBar 默认可见（不依赖 demo overlay） |
| G4 | **DONE (code)** — 全区 ≥2 DistrictInteractKit（含瀑/灯塔/坡田/林口/农场住宅/湖屋） |
| G5 | **DONE (code)** — 户外/室内/WorldSys 传送增加常显门阶+拱门 cue；hover 显名 |
| G6 | **DONE (code)** — 室内 coin_chest/dresser 自动开合帧；C61 箱盖；C12/C14「占位」文案清除；fire/forge QA 仍 GREEN |
| G7 | **DONE (code)** — bobber；C22；pose×4；drawer StyleQA；C05 摊位默认真棚 PNG |
| G8 | **IN PROGRESS** — smoke 72/72；activate/portal/open FX；**MCP 截图已落**；**用户 Godot QA 仍待** |

### G8 已知残留（不可假装清零）

| 残留 | 位置 | 处理方向 |
| --- | --- | --- |
| ~~ColorRect 轨枕/铁轨~~ | `station_assembler.gd` | **DONE** → `track_sleeper/rail` |
| ~~ColorRect 栅栏柱~~ | farmland / farm_residential | **DONE** → `fence_post_00` |
| ~~bridge label_proxy~~ | village_square | **DONE** → `bridge_plank_00` |
| ~~程序门阶多边形~~ | area_craft / WorldSpawnUtil / interior | **DONE** → `doorstep_mat` + `door_arch_cue` |
| ~~作物床 ColorRect 垄线~~ | area_craft crop beds | **DONE** → `furrow_line_00` |
| ~~摇树 Polygon 占位~~ | WorldInteractKit | **DONE** → `trees/grounded/tree_00` |
| ~~孤岛传送无门脸~~ | museum/bath 等 portal | **DONE** → `door_facade_00` on all portals |
| ~~完整独立建筑 façade sheet~~ | 博物馆/浴场 | **DONE** → `facade_museum_00` / `facade_bath_00` |
| ~~drawer_open PIL~~ | interior dresser | **DONE** → StyleQA 48×40 开合帧 |
| ~~NPC 职业姿态 sheet~~ | C53 work rings | **DONE (minimal)** → `npc/work_poses/{sow,smith,stall,cook}` |
| ~~C59 木桩/杂草错用桶袋~~ | BreakablesKit | **DONE** → `breakable_stake/weed` |
| ~~C05 摊位 ColorRect 棚~~ | MarketStall | **DONE** → 默认 `stall_open_wood_00`（ColorRect 仅 fallback） |
| ~~C05 摊位 ColorRect 立柱~~ | MarketStall `_add_poles` | **DONE** → `stall_pole_00`（ColorRect 仅 fallback） |
| ~~钓鱼浮漂下 Polygon 水环~~ | `fishing_spot.gd` / `fish_cage.gd` | **DONE** → `fx/fish_ring_00.png`（Polygon 仅 fallback） |
| ~~室内窗光 Polygon 光柱~~ | `interior_craft.gd` | **DONE** → `fx/window_light_shaft_00.png`（Polygon 仅 fallback） |
| ~~hover 仅 draw_line 角标~~ | `interactable_hotspot.gd` | **DONE** → `fx/focus_corners_00.png` + 修复 enter 时 `queue_redraw` |
| ~~农夫 walk 不透明白底盘~~ | `assets/sprites/npc/farmer` | **DONE** → 提升 `farmer_v2` 后经 `farmer_v5` 8 帧；`qa_npc_white_plates` GREEN |
| ~~室内 actor 缺 mayor/miller 包~~ | `interior_profiles` | **DONE** → `npc/mayor` + `npc/miller`（recolor 正式包） |
| ~~C53/C54 按钮被 demo 开关隐藏~~ | square/market/farmland controllers | **DONE** → TopBar 工作/生活环常显；仅 status strip 仍 demo 门控 |
| ~~DistrictInteract 串用 interior/props~~ | `district_interact_kit.gd` | **DONE** → 拷贝至 `sprites/props/`；QA 禁 interior 路径 |
| ~~工作姿态/季节/藏宝箱室外串味~~ | routine / seasonal / hidden_chests | **DONE** → anvil/stove/花床/灯串/粮垛/coin_chest 进 outdoor props；QA 禁 interior |
| ~~地标热区空 Visual~~ | 巨树/遗迹/芦苇/墓园/市集桥/瀑/洞口/渡口 | **DONE** → `attach_hotspot_prop` + reed/ruin/grave 精灵；瀑 cascade reparent |
| ~~站台轨道/湖屋/渡口船~~ | station / lake_house / lake ferry | **DONE** → rail+sleeper / house reparent / `boat_skiff_00`；orphan Visual QA |
| ~~地标/门脸/棚布低色阶~~ | reed/ruin/grave/boat/door_facade/awning | **DONE** → 重绘至 painted 色密度；`qa_landmark_style` GREEN |
| ~~civic façade / 破 / 栅 / 桥 / 垄~~ | bath/museum/stake/weed/fence/bridge/furrow | **DONE** → 同批次重绘 + StyleQA 地板 |
| 季节 grade ColorRect | seasonal_decor | 保留为环境罩（非交互占位） |
| Env-H / 钓鱼 UI ColorRect | day_night veil / session dim | 环境与 UI 罩，非世界交互占位 |
| 姿态/摊位 ArtGen 抛光 | work_poses / market | **StyleQA GREEN**（32×48×4，uniq≥80）；awning PNG |
| ~~室内语义代理（祭坛/课桌/候车椅/黑板/芦苇/管道）~~ | C07/C10/C11/C25/C31 | **DONE** → dedicated props + `qa_semantic_interior_props` GREEN |
| ~~提示A/点击B 目标分裂~~ | InteriorRoomController | **DONE** → hover 优先 + click sync；`g8_interact_target_smoke` PASS |
| ~~C05 EMPTY/LOCKED 代理图~~ | MarketStall | **DONE** → `stall_empty_bay_00` / `stall_locked_board_00` |
| ~~B11-02 货箱名实~~ | market dressing | **DONE** → produce/stall_face/lumber/bin aliases；蔬果禁 `_04` |
| ~~瀑布仅静态 tall/mid~~ | `waterfall_assembler.gd` | **DONE** → `waterfall_water_00..05` `WaterfallAnim` 循环；MCP `g8_waterfall_anim.png` |
| ~~传送门常驻 arch 脉冲~~ | area_craft / WorldSpawnUtil / interior_craft | **DONE** → hover 高亮 only；`qa_portal_hover_only` GREEN |
| ~~户外无邻近「互动」~~ | outdoor controllers | **DONE** → `AreaInteractHost` + smoke/MCP |
| ~~C04 候坐 / C07 讲台代理~~ | smith wait / school lectern | **DONE** → `waiting_bench` / `lectern_00`；QA 扩 wait+lectern |
| ~~C06 会议桌/公告板 · C11 时刻表~~ | town hall / station | **DONE** → `meeting_table` / `civic_board` / `timetable` |
| ~~C28 根桌/木钉梯/根须垛代理~~ | giant tree interior | **DONE** → `root_table` / `peg_ladder` / `root_mass` |
| ~~C29 碑刻 / C28 树皮符 / C11 票价牌~~ | ruins / tree / station | **DONE** → `ruin_stele` / `bark_glyph` / `fare_board` |
| ~~C10 经文牌~~ | church altar | **DONE** → `scripture_plaque_00`（非 notice）；MCP `g8_c10_scripture_plaque.png` |
| ~~C08/C40/C43/C44 告示特化~~ | clinic/museum/bath/inn | **DONE** → `clinic_fee` / `exhibit_guide` / `bath_rules` / `inn_rate` |
| ~~室内全部 notice_00 代理~~ | all interior markers | **DONE** → 0×`_m(P_NOTICE)`；13 专用牌 + QA 硬禁 |
| ~~farmer 仅 4 帧（qa_scene_presentation RED）~~ | `npc/farmer` | **DONE** → 提升 `farmer_v5` 8 帧；presentation GREEN；MCP `g8_farmland_farmer_8frame.png` |
| ~~C60 锁门共用门脸~~ | ProgressGates locked_door | **DONE** → `gate_locked_door_00`（铁锁+横闩；禁 door_facade） |
| ~~C59 杂草/C60 倒木低密度~~ | breakable_weed / gate_log | **DONE** → 重绘 uniq≥60；StyleQA 抬地板 |
| 用户 Godot QA Waves A2–F | 本机点击/进出/动画 | **仍待用户确认**（见 §7） |

## G8 证据

- [`GOAL_G8_MCP_RUNTIME_EVIDENCE.md`](GOAL_G8_MCP_RUNTIME_EVIDENCE.md) — 广场/C01 MCP 截图 + 运行时节点  
- [`GOAL_G8_SMOKE_EVIDENCE.md`](GOAL_G8_SMOKE_EVIDENCE.md) — headless load matrix（全户外 + 全 C 室内 + hubs）  
- [`GOAL_G8_INTERACT_ACTIVATE_EVIDENCE.md`](GOAL_G8_INTERACT_ACTIVATE_EVIDENCE.md) — 广场 C58×8 激活冒烟  
- [`GOAL_G8_INTERIOR_OPEN_FX_EVIDENCE.md`](GOAL_G8_INTERIOR_OPEN_FX_EVIDENCE.md) — C01 衣柜 drawer_open（headless + `mcp_play_open_fx` live）  
- [`GOAL_G8_PORTAL_CUE_EVIDENCE.md`](GOAL_G8_PORTAL_CUE_EVIDENCE.md) — 广场门户 façade/门阶  
- [`GOAL_G8_ANIM_FX_EVIDENCE.md`](GOAL_G8_ANIM_FX_EVIDENCE.md) — 工作姿态×4 + 摇树 leaf_fall  
- [`GOAL_G8_BATH_PORTAL_EVIDENCE.md`](GOAL_G8_BATH_PORTAL_EVIDENCE.md) — 浴场 façade + SceneRouter 进门  
- [`GOAL_G8_C62_SECRET_EVIDENCE.md`](GOAL_G8_C62_SECRET_EVIDENCE.md) — 密道门脸 + 进洞冒烟 + MCP 截图  
- [`GOAL_G8_SEMANTIC_INTERIOR_EVIDENCE.md`](GOAL_G8_SEMANTIC_INTERIOR_EVIDENCE.md) — 室内语义专用 prop  
- [`GOAL_G8_INTERACT_TARGET_EVIDENCE.md`](GOAL_G8_INTERACT_TARGET_EVIDENCE.md) — 室内提示/点击共享目标  
- [`GOAL_G8_WATERFALL_ANIM_EVIDENCE.md`](GOAL_G8_WATERFALL_ANIM_EVIDENCE.md) — 瀑布水体 AnimatedSprite 循环 + MCP  
- [`GOAL_G8_OUTDOOR_PROMPT_EVIDENCE.md`](GOAL_G8_OUTDOOR_PROMPT_EVIDENCE.md) — 户外邻近「互动」+ hover 胜出  
- [`GOAL_G8_C58_FX_EVIDENCE.md`](GOAL_G8_C58_FX_EVIDENCE.md) — C58 well_rope/crate_lid/leaf_fall/bird_peck 多帧  
- [`GOAL_G8_C59_BREAKABLES_EVIDENCE.md`](GOAL_G8_C59_BREAKABLES_EVIDENCE.md) — C59 桩/草精灵 + `mcp_clear`  
- [`GOAL_G8_C60_GATES_EVIDENCE.md`](GOAL_G8_C60_GATES_EVIDENCE.md) — C60 锁门解锁 + 倒木重绘  
- [`GOAL_G8_C22_FISH_CAGE_EVIDENCE.md`](GOAL_G8_C22_FISH_CAGE_EVIDENCE.md) — C22 河/湖渔笼 place/ready MCP + dual-site smoke  
- [`GOAL_G8_WAVE_D_EVIDENCE.md`](GOAL_G8_WAVE_D_EVIDENCE.md) — Wave D 七室内 idle MCP  
- [`GOAL_G8_WAVE_E_EVIDENCE.md`](GOAL_G8_WAVE_E_EVIDENCE.md) — Wave E 五室内 idle MCP  
- [`GOAL_G8_WAVE_DE_PORTAL_EVIDENCE.md`](GOAL_G8_WAVE_DE_PORTAL_EVIDENCE.md) — Wave D/E portal enter smoke + live C32/C46  
- [`GOAL_TEAM_SIGNOFF.md`](GOAL_TEAM_SIGNOFF.md) — 多团队角色签收表  
- `tools/qa_interaction_frames.py` — 17 groups GREEN  
- `tools/qa_portal_hover_only.py` — GREEN  
- `tools/qa_semantic_interior_props.py` — GREEN（zero `_m(P_NOTICE)` + full notice taxonomy）  
- `tools/qa_no_placeholder_visuals.py` — GREEN  
- `tools/qa_interact_sprite_inventory.py` — GREEN（kits + focus/open FX）  
- `tools/qa_work_pose_style.py` — GREEN（C53 pose sheets）  
- `tools/qa_semantic_interior_props.py` — GREEN（祭坛/候车椅/黑板/课桌/芦苇/管道）  

---

## 7. 场景清单（可玩区 + 室内壳）与用户 QA

> **Agent MCP 列** = 本机 MCP 截图/激活证据（不代替手感）。**用户勾选** = 你本机 Godot 确认后才勾。  
> **引擎入口：** 世界总览顶栏 **「§7验收」** → [`GOAL_USER_QA_CHECKLIST.md`](GOAL_USER_QA_CHECKLIST.md) / `scenes/qa/user_qa_checklist.tscn`

### 户外区（assembler 场景）

| 区 | 场景 | 交互/门面要点 | Agent MCP | 用户勾选 |
| --- | --- | --- | --- | --- |
| 广场 | `village_square` | C58×8、C59、C60、门脸、摇树叶、工作环姿态 | [x] idle+井/灯；activate；worldsys；anim FX；**C53 按钮常显**；浴场 portal enter PASS | [ ] |
| 市集 | `market_street` | 木棚摊位、DistrictInteract | [x] `g8_market_idle.png` 木棚可见 | [ ] |
| 农田 | `farmland` | 垄线、栅栏、DistrictInteract | [x] `g8_farmland_idle.png`；farmer 白底盘已替换 | [ ] |
| 住宅 | `village_residential` | 门阶/拱门、DistrictInteract | [x] `g8_residential_idle.png` | [ ] |
| 农场住宅 | `farm_residential` | 栅栏、DistrictInteract | [x] `g8_farm_residential_idle.png` | [ ] |
| 林口/深林 | `forest_entrance` / `forest_deep` | DistrictInteract；C62 树洞密道 | [x] idle + landmarks；**C62** `g8_c62_secret_portal.png` + smoke PASS | [ ] |
| 河/湖 | `river` / `lake` | bobber + fish_ring + C22 鱼笼 | [x] river+lake ready 截图；`g8_c22_fish_cage_smoke` river+lake **ok=6 PASS** | [ ] |
| 瀑/灯塔/坡田 | `waterfall` / `lighthouse` / `hill_farm` | DistrictInteract + 门脸 + 瀑水循环 | [x] idle + **`g8_waterfall_anim.png`**（`WaterfallAnim` playing） | [ ] |
| 车站/湖屋 | `station` / `lake_house` | 轨枕精灵、门脸 | [x] `g8_station_idle.png` + `g8_lake_house_idle.png` | [ ] |

### 室内（抽样必测）

| 室 | 要点 | Agent MCP | 用户勾选 |
| --- | --- | --- | --- |
| C01 家 | dresser/chest 开合帧、返回门 | [x] idle + dresser OpenFX held | [ ] |
| C02 商贾 | coin_chest 开合帧 | [x] `g8_c02_chest_lid_held.png`（chest_lid frame=3） | [ ] |
| C06 议事厅 | 门户进出 | [x] `g8_c06_town_hall_idle.png`；镇长 walk 帧已补 | [ ] |
| C40/C43 博物/浴 | 立面可发现 → 进门 | [x] 博物馆进门 + `g8_c40_museum_idle`；浴场 façade enter PASS；室内 idle | [ ] |
| Wave D 农商七包 | C32/C33/C37–39/C51–C52 可进可出 | [x] idle + **market→C32 enter** MCP；`g8_wave_de_portal_smoke` PASS | [ ] |
| Wave E 垂直/院 | C46–C50 二楼/阁楼/屋顶/后院/地窖 | [x] idle + **C01→C46 enter** MCP；smoke 含 C50 | [ ] |
| Wave A2–F 其余已锁室 | 按 PHASE5 进出各一次 | [x] 抽检 C04/C07/C09–C12/C16–C17/C28–C30/C44 idle；72/72 load；**C62 全链 PASS** | [ ] |

### 本机 QA 步骤（请你跑，避免中文路径 CLI 损文件）

1. 编辑器打开 `dream/`，进世界总览，点顶栏 **「§7验收」**。  
2. 按清单「跳转」逐项手测，勾选「通过」。  
3. 或手动：广场 C58–C60 / K；市集棚；河/湖笼；瀑布动画；C01 开合+二楼；C62 密道。  
4. 清单全部通过后，在 Cursor 回复 **「§7 已勾」**（或回填本表用户勾选）。

勾选结果回填本表或口头确认后，G8 才可标 DONE。

---

## 8. 目标要求 ↔ 证据映射（完成审计）

| # | 要求 | 证据 | 状态 |
| --- | --- | --- | --- |
| 1 | 已列交互正式像素 + 反馈 + 多帧 | C58 activate 8/8；sprite inventory GREEN；focus/叶/绳/盖/鸟帧；qa_interaction_frames GREEN；MCP InfoPanel/OpenFX；语义 prop QA | **PROVEN（代码+MCP）**；§7 手感确认仍待 |
| 2 | 全户外+室内门面/道具/可进出 | load smoke 72/72；portal cue 12；MCP 进门+多室内 idle；C62 全链 | **PROVEN（加载+MCP 进门）**；§7 全表进出仍待 |
| 3 | 统称权威 | 本文件 + `ASSET_TAXONOMY` 回链 | **PROVEN** |
| 4 | 多团队流水线门禁 | §2 角色表；[`GOAL_TEAM_SIGNOFF.md`](GOAL_TEAM_SIGNOFF.md)；Style/Anim/Cohere + Genre/Canon；qa_* GREEN；语义+目标同步 | **PROVEN（本轮批次）** |
| 5 | MCP/运行时交互动画证据 | [`GOAL_G8_MCP_RUNTIME_EVIDENCE.md`](GOAL_G8_MCP_RUNTIME_EVIDENCE.md) + activate/open FX/anim/target smokes | **PROVEN** |

**结论：** Agent 侧五条要求已有可复核证据；在 §7 用户本机勾选确认前，**不得**将 Goal 标 complete（项目验收门）。

---

- [`INTERACTION_DESIGN.md`](INTERACTION_DESIGN.md)  
- [`WORLD_C58_C62.md`](WORLD_C58_C62.md)  
- [`PHASE5.md`](PHASE5.md) · Wave A–F locks  
- `dream/.cursor/skills/painting-asset-craft/SKILL.md`
