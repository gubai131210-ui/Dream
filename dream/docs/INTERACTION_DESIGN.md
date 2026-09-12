# Dream 交互设计与动画资源规范

**状态：** ACTIVE — 交互阶段入口规范  
**日期：** 2026-09-12  
**适用范围：** 户外场景、室内场景、人物、动物、可调查物、可使用物、环境动态、交互反馈  
**锁定依赖：** [`SCALE.md`](SCALE.md)、[`ASSET_TAXONOMY.md`](ASSET_TAXONOMY.md)、[`NPC_ANIM.md`](NPC_ANIM.md)、[`INTERIOR_COMPOSITION.md`](INTERIOR_COMPOSITION.md)、[`INTERIOR_FOUNDATION.md`](INTERIOR_FOUNDATION.md)  
**本文件性质：** 调研结论 + Dream 项目落地规范，不是单纯的美术参考。

---

## 0. 先给结论

Dream 下一阶段的交互不能继续采用“找到一张图 → 放到场景里 → 加一个 Tween”的方式。交互视觉必须同时满足四个条件：

1. **位置稳定：** 动态帧共享固定画布、固定脚底/接触点、固定显示比例；帧变化不能带着石头、家具、地面或碰撞体一起漂移。
2. **行为可解释：** 玩家看到的每个变化都能解释为“接触、受力、开合、点燃、流动、溅起、被拾取或状态改变”，不使用无原因的闪烁和随机抖动。
3. **反馈有层级：** 先用轮廓/提示说明“可交互”，再用短促动作说明“已触发”，最后用环境或物品状态说明“结果已经发生”。
4. **风格同源：** 继续使用项目锁定的 32 px gameplay grid、3/4 视角、Nearest、像素级缩放和现有户外调色，不因为某个新动画而引入另一套透视、描边、阴影或光照语言。

本阶段的优先级不是“增加最多动画”，而是：

> **先固定锚点和状态，再让少量关键帧产生明确的物理反馈。**

### 0.2 当前修复进度（2026-09-12）

- [x] `PatrolActor`、`AmbientCritter`、室内火焰/锻炉帧按透明内容底部归一化。
- [x] 普通水面和村庄广场水面移除每格透明 Tween，只保留统一换帧时钟。
- [x] 交互提示改用稳定动画包围范围，不再读取当前帧高度。
- [x] hover 角标改为稳定焦点框，避免被误认为随机闪烁。
- [x] 瀑布场景停止额外独立石头和雾气实例；瀑布主体保留原有资源。
- [x] 增加 [`tools/qa_interaction_frames.py`](../tools/qa_interaction_frames.py) 静态回归检查。
- [ ] Godot 编辑器运行时截图验证：当前 MCP 启动场景超时，需编辑器重新连接后完成。

### 0.1 明确禁止

- 禁止用整张瀑布图移动来假装水流；岩壁、瀑布主体、池塘和水花必须分层。
- 禁止每帧改变 Sprite 的 position、scale 或父节点位置来补偿裁切误差；补偿应在离线裁切/归一化阶段完成。
- 禁止将静态物体（长椅、水井、箱子、墙、岩壁）放进动态帧序列中，让它随动画一起闪动。
- 禁止以“随机闪一下”作为默认交互反馈；反馈必须绑定到 hover、focus、press、action、impact 或 state change。
- 禁止把角色的行走路径交给单纯 Tween；角色移动、朝向、脚步动画和障碍判断必须由角色控制器拥有。
- 禁止在没有统一资源契约的情况下批量生成或导入动态帧。

---

## 1. 调研范围与主要依据

本轮调研覆盖了 Godot 官方节点文档、Godot 2D 光照与粒子教程、像素动画帧制作经验、3/4 视角室内制作经验、Y-sort 实践和项目现有文档。下面的来源不是要求项目复制某一款游戏，而是用于提取可落地的工程约束。

### 1.1 关键来源结论

| 来源 | 可迁移到 Dream 的结论 |
|---|---|
| Godot `AnimatedSprite2D` 官方文档 [1] | 多帧动画由 `SpriteFrames` 管理；`centered`、`offset`、`frame_progress` 会直接影响像素画是否变形或跳动；Godot 明确提示像素风需要避免落在像素之间。 |
| Godot 2D 粒子官方文档 [2][3] | 连续水花、尘土、火星等应交给粒子或独立 FX 层；固定 FPS、生命周期、局部/全局坐标和确定性随机种子都要明确。粒子不是物理刚体，不应拿来替代碰撞或物体运动。 |
| Godot 2D 光照官方文档 [4] | 温度和空间感来自 `CanvasModulate` + 局部 `PointLight2D` / `DirectionalLight2D` / 遮挡，而不是整屋一块橙色覆盖；灯光应挂在真实光源附近。 |
| Godot `Area2D` 官方教程 [5] | 交互范围、进入/离开、检测接触和触发信号适合由 `Area2D` 表达；Area2D 是检测区域，不是物理实体。 |
| Godot Y-sort 实践 [6] | 3/4 场景的排序点应放在物体接触地面的底部，而不是贴图中心；Sprite 的视觉偏移和 Node2D 的世界位置要分开。 |
| SLYNYRD Top Down Interiors [7] | 3/4 视角、墙高、家具、地砖和地毯应在同一套格子和投影规则下制作；家具不是独立插图，而是环境套件的一部分。 |
| 像素动画帧制作经验 [8] | 固定画布、固定调色板、关键姿势、洋葱皮、脚底锁定和帧时长比增加帧数更重要；3–4 帧的稳定循环通常胜过 12 帧的抖动循环。 |

### 1.2 对现有问题的直接解释

此前出现的“长椅附近和每个区域同一位置闪烁”，更像是通用场景坐标/临时标记/帧或热点可视化被重复放置，而不是某一只动物单独出错。此前瀑布“石头一起左右动”和“水流左右摆动”，本质上是动态内容没有以固定世界锚点拆成：

```text
固定岩壁/固定瀑布口
        ↓
垂直水流动画（同一 x 中心线）
        ↓
固定池面 + 局部水纹
        ↓
落点水花/短粒子
```

这也是本文件要求所有新交互先拆“静态锚定层”和“动态表现层”的原因。

### 1.3 从成熟项目中提取的可迁移经验

这里不复制具体游戏的美术，而只提取它们对 Dream 有用的系统规律：

- **Stardew Valley：水面是逻辑层之上的动画叠加层。** 水格的可用性、河岸邻接和水面动画不是一张不可拆的大图；瀑布等特殊流向可以排除通用水面叠加，再使用专用的水帘和落点效果。Dream 的瀑布应该采用同样的“水体 mask + 专用 overlay”思想，而不是让通用水格动画覆盖整个瀑布。
- **Animal Crossing: New Horizons：地形交互先改变结构，再做角落修饰。** 水、路、悬崖和瀑布都有邻接合法性；拐角、边缘和连接点是系统的一部分，不是最后用装饰遮住的瑕疵。Dream 的池边、水路和瀑布落点也需要先保证邻接和碰撞，再加高光、水花。
- **Spiritfarer：角色目标点要避开可操作部件。** 角色动作、环境灯光和水面氛围可以很丰富，但 NPC 的站位、梯子、门和工作目标必须先形成可靠的可达图。Dream 的 NPC/动物 Smart Object 应把站位点放在交互物旁边，而不是直接放在交互碰撞中心。
- **SLYNYRD 的 3/4 室内制作：家具、地砖、墙体和地毯来自同一套投影规则。** 交互家具的动画帧也必须遵守同一套脚底、前后遮挡和光照方向；不能只因为“这是一张新素材”就改变物体视角。

这些经验共同指向一个原则：**交互的丰富度来自状态、站位、时序和局部反馈的组合，而不是把更多动画同时播放。**

---

## 2. Dream 当前资源和代码盘点

### 2.1 已存在、可以继续复用的交互骨架

| 位置 | 当前能力 | 下一阶段应如何使用 |
|---|---|---|
| `scripts/interact/interactable_hotspot.gd` | `Area2D`、鼠标 hover、`activated` 信号、最近热点提示、碰撞范围、世界文字提示 | 保留为“发现与选择层”，不要把具体行为全部塞进 Hotspot。 |
| `scripts/interiors/interior_room_controller.gd` | 搜索最近的 `InteractableHotspot`，只显示一个临近提示；入口/出口通过 `scene_path` 处理 | 后续接入统一 `interaction_id` 和状态机，避免每个场景自己处理一套提示。 |
| `scripts/actors/patrol_actor.gd` | `AnimatedSprite2D`、方向动画、移动中的帧切换 | 继续让角色控制器拥有移动/朝向/动画，不要由场景脚本 Tween 角色 Sprite。 |
| `scripts/actors/ambient_critter.gd` | 动物 idle / walk 资源、Nearest、显示高度约束 | 增加固定脚底锚点和帧一致性检查；动物互动先做短动作，不急于做复杂 AI。 |
| `scripts/fishing/fishing_spot.gd` | 浮漂、涟漪、气泡、捕获物上浮、短 Tween | 可作为“交互阶段第一套反馈模板”，但要把随机位置限定在水面局部范围并绑定 session 状态。 |
| `scripts/areas/waterfall_assembler.gd` | 瀑布、水面 overlay、瀑布口和水池区域的组装 | 保留瀑布主体静态定位；动态水流、水花、池面涟漪分开管理。不要让 FX 节点改动主体坐标。 |
| `scripts/interiors/interior_craft.gd` | profile 驱动的室内组装、Y-sort、室内 FX、灯光和 actor | 交互物应通过 profile 数据声明，不在每个 `.tscn` 里手写随机位置。 |
| `project.godot` | 已开启 2D 顶点/变换像素吸附，默认纹理过滤为 Nearest | 保持；动态 Sprite 仍需使用统一整数网格和锚点，像素吸附不能修复裁切错误。 |

### 2.2 当前可用的动态资源

| 资源组 | 当前内容 | 风险/缺口 |
|---|---|---|
| `assets/sprites/interior/fx/fire_00..03.png` | 壁炉/火焰的 4 帧 | 需要确认画布尺寸、火焰底部和壁炉口的接触点完全一致；火光应独立于火焰图。 |
| `assets/sprites/interior/fx/forge_00..03.png` | 锻炉火焰/炉火的 4 帧 | 需要把火焰、炉体、火星和局部灯分层；炉体不能被火焰帧带动。 |
| `assets/sprites/animals/*/idle_*` | 羊、鹿、猫、牛、狗、鸡等 idle 帧 | 需要逐类检查脚底/腹部接触线，不能假设所有来源帧已经同锚点。 |
| `assets/sprites/animals/*/walk_*` | 多种动物行走帧 | 必须按动物类别建立每类 `foot_anchor`；大体型动物不可直接复用小体型动物的碰撞和排序。 |
| `assets/sprites/npc/*/walk_*` | 多个 NPC 方向行走帧，4 帧为主 | 已有 `NPC_ANIM.md` 约束，新增交互姿势要与 walk 的基准脚底一致。 |
| `assets/sprites/interior/props/*` | 室内家具、灯、壁炉、锻炉、床、桌、柜等静态素材 | 交互素材不能只改文件名；必须经过“文件名 = 画面 = 行为”的抽检。 |
| `assets/sprites/props/waterfall_*` 与 `assets/sprites/fx/*` | 瀑布主体和旧 FX | 先建立瀑布分层资源契约，再判断哪些旧 FX 可以复用；旧的水汽/雾气不是默认必需。 |

### 2.3 目前缺少的资源层

交互阶段真正缺的不是“再来一张大图”，而是以下可组合层：

- 交互焦点的非闪烁提示（角标、短促描边、按键提示的统一模板）。
- 物体的 `idle / focus / action / result / cooldown` 状态资源或程序化效果。
- 统一的 `contact_shadow` / `impact_point` / `use_point` 说明。
- 门、抽屉、箱盖、井绳、工作台部件等“局部开合”帧，而不是整物体位移。
- 瀑布落点水花、池面环形波纹、流向一致的水面高光。
- 动物与家具接触的站位、坐下、吃食、喝水、睡觉等短动作锚点。
- 资源 manifest：画布尺寸、脚底锚点、动作帧时长、碰撞范围、交互点和 z 层。

### 2.4 当前代码的优先风险清单

这是本轮交叉检查后对当前代码的定向审计，不代表已经修复：

| 文件/区域 | 风险 | 处理顺序 |
|---|---|---:|
| `scripts/actors/patrol_actor.gd` 的 `_build_frames()` | ~~透明边距脚底跳动~~ **DONE** — `get_used_rect` 归一化到固定脚底 canvas。 | ~~P0~~ |
| `scripts/actors/ambient_critter.gd` | ~~底边≠脚底~~ **DONE** — 同类 `get_used_rect` 归一化 + `TARGET_HEIGHT_PX`。 | ~~P0~~ |
| `scripts/interiors/interior_craft.gd` 的 `_spawn_anim_fx()` | ~~火焰帧主体偏移~~ **DONE** — fire/forge 按 used_rect 归一化。 | ~~P0~~ |
| `scripts/areas/waterfall_assembler.gd` 的瀑布装配 | ~~仅静态 tall/mid~~ **DONE** — `waterfall_water_00..05` AnimatedSprite2D 循环 + splash。 | ~~P0~~ |
| `scripts/areas/area_craft.gd` 的 `spawn_water_overlay()` | ~~双时钟叠加~~ **DONE** — 共享 Timer 驱动换帧；`qa_interaction_frames` 断言 single water clock。 | ~~P0~~ |
| `scripts/interact/interactable_hotspot.gd` 的 `_layout_prompt()` | ~~按当前帧高度抖动~~ **DONE** — `_cache_visual_bounds()` 用稳定 sprite/anim 包围盒。 | ~~P0~~ |
| `scripts/interact/interactable_hotspot.gd` + `InteriorRoomController` | ~~提示 A、点击 B~~ **DONE** — hover 优先 + 点击同步（`g8_interact_target_smoke`）。 | ~~P1~~ |
| `scripts/areas/area_craft.gd` 的传送点提示 | 传送点长期脉冲/文字与普通热点的最近提示并存，可能让场景交互层级过多。 | P1 |

在开始大批量增加新动画前，先关闭或隔离上述风险。否则新素材即使单帧画得正确，也会被运行时的双时钟、错误锚点或重复提示破坏。

---

## 3. 统一资源契约：每张交互图在导入前必须回答什么

任何新动态素材，无论是手绘、ImageGen 后重画、外部素材还是程序化 FX，都必须拥有一个资源契约。建议用同名 JSON 或集中 manifest 保存；第一阶段也可以先写在资源审计表中，但不能只靠口头约定。

### 3.1 最小 manifest 字段

```json
{
  "id": "waterfall_pool_splash_a",
  "kind": "fx",
  "canvas": [64, 48],
  "frames": [
    {"file": "waterfall_pool_splash_a_00.png", "duration_ms": 120},
    {"file": "waterfall_pool_splash_a_01.png", "duration_ms": 80},
    {"file": "waterfall_pool_splash_a_02.png", "duration_ms": 100}
  ],
  "pivot_px": [32, 40],
  "contact_px": [32, 40],
  "use_point_px": [32, 32],
  "z_band": "fx_front",
  "loop": true,
  "texture_filter": "nearest",
  "scale": 1.0,
  "static_layers": ["pool", "cliff"],
  "notes": "Only splash changes; pool and cliff are not part of the animation."
}
```

字段含义：

- `canvas`：所有帧必须相同；透明区域可以很大，但不能让每一帧自动裁成不同大小。
- `pivot_px`：Node2D 的世界锚点，通常是物体脚底中心或水花落点。
- `contact_px`：真正与地面、水面、炉口、桌面发生接触的像素位置。
- `use_point_px`：玩家应该站在哪里操作；它不一定等于视觉中心。
- `z_band`：`world_back`、`world_ground`、`world_front`、`fx_front` 等固定层级，不以临时 z_index 乱补。
- `duration_ms`：允许每帧不同，但必须有意图；不要用默认平均速度掩盖关键姿势。
- `static_layers`：明确哪些部分不进入动态帧，防止瀑布岩石、椅子腿、桌面一起动。

### 3.2 Dream 的默认尺寸和锚点规则

以 [`SCALE.md`](SCALE.md) 的 `BASE_TILE=32` 为唯一 gameplay grid：

- 小型 FX：32×32、48×32、64×48 等 32 px 友好的画布；不要求每张图都填满画布。
- 人物和动物：保持项目已有的 48–64 px 站立高度范围，脚底在同一世界基线。
- 家具和环境：以物体与地面的接触线作为 Y-sort 点，不能以贴图中心排序。
- 瀑布：瀑布口、垂直水流中心线、落点三者在同一固定世界坐标系；水流可以有透明边缘变化，但中心线不能横移。
- 交互碰撞：默认 1.0–1.5 tile 的交互距离，优先覆盖“玩家实际能站的位置”，不要覆盖整个美术包围盒。

---

## 4. 动态帧制作规范：如何避免“每一帧都对不上”

### 4.1 画布固定，而不是事后猜位置

正确流程是先建立模板画布，再在同一画布上画每一帧：

1. 新建固定尺寸画布；锁定背景透明、像素网格、调色板和导出尺寸。
2. 放入不会移动的参考层：脚底线、接触点、主体中心线、物体静态轮廓。
3. 只让真正需要动的部分变化。例如：火焰上缘、井绳、门板、动物四肢、水花和高光。
4. 使用洋葱皮检查前后帧；保持脚、桌腿、瀑布口、岩壁边缘、池塘边界等静态位置不变。
5. 按关键姿势先做极限帧，再补中间帧；不要从第一帧开始逐帧“凭感觉挪一点”。
6. 导出时保持所有帧同尺寸、同色板、同透明规则、同命名序列。

### 4.2 脚底、接触点和中心线必须锁定

对每个动画，至少画三条不可见参考线：

```text
顶部包围线：用于判断是否突然变高
主体中心线：用于判断是否横移
接触线：脚底 / 桌脚 / 炉口 / 水面 / 落点
```

可接受的偏差：

- 静态物体的接触点：0 px；如果是人工绘制误差，最多 1 px，并在 manifest 中说明。
- 人物/动物脚底：默认 0 px；步行时只有抬起的脚可以离开接触线，支撑脚不能滑。
- 水流中心线：0 px；水流宽度和高光可以变化，但不得左右漂移。
- 火焰、烟、火星：可以围绕发射点变化；发射点本身不动。
- 水花：落点固定；扩散半径和粒子数量变化，不移动池塘或瀑布主体。

### 4.3 推荐的离线归一化函数

如果素材来源不一致，不能在运行时直接把每帧 Sprite 的 position 来回补。应在导入前把每帧贴到统一画布：

```gdscript
func normalize_frame(source: Image, canvas_size: Vector2i, anchor_px: Vector2i) -> Image:
    var dst := Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
    dst.fill(Color.TRANSPARENT)

    var source_anchor := detect_or_read_anchor(source)
    var paste_at := anchor_px - source_anchor
    dst.blit_rect(source, Rect2i(Vector2i.ZERO, source.get_size()), paste_at)
    return dst
```

实际实现可以放在 `tools/` 里，不要求运行时使用这段示例。关键是：**每张源图先找出逻辑锚点，再将锚点映射到同一像素。** 如果是人物，锚点优先取支撑脚中点；如果是瀑布水花，锚点优先取水流落点；如果是开门动画，锚点取门轴，而不是整张门的中心。

### 4.4 运行时的安全规则

- `AnimatedSprite2D` 保存的是帧图和动画状态；Node2D 的世界位置保存的是逻辑锚点。
- 不要在 `_process` 中根据当前帧的透明包围盒重算 Node2D 位置。
- 不要对动画 Sprite 的 `position` 和 `scale` 做周期性微 Tween 来制造“活着”的感觉；像素画需要稳定的锚点。
- 如果必须改变显示偏移，使用固定的 `offset` 或每套动画的静态配置，不要每帧临时写入。
- 切换不同动画时保留必要的 `frame_progress`，避免从 idle 切 work 时出现一次突跳；Godot 官方提供了 `set_frame_and_progress()` 用于此类连续切换。[1]
- 启用项目已有的像素吸附和 Nearest，但要知道它们只能减轻亚像素抖动，不能修复不同帧画布尺寸或错误脚底。

---

## 5. 动画类型怎么选：不要把所有东西都做成 Sprite 帧

### 5.1 三种表现层

| 表现 | 适用内容 | 推荐实现 | 不应承担的职责 |
|---|---|---|---|
| 帧动画 | 火焰形状、人物脚步、动物吃食、门板开合、瀑布水帘形变 | `AnimatedSprite2D` + `SpriteFrames` | 不承担碰撞移动、世界锚点移动、主体位移 |
| 运动/位移 | 角色走路、浮漂被拉、物品上浮、掉落、门轴旋转 | 状态机 + `AnimationPlayer` / 有明确终点的 Tween | 不替代脚步帧和接触反馈 |
| 连续 FX | 火星、水滴、池面小水花、尘土、叶片、短暂闪光 | `GPUParticles2D` 或少量受控实例 | 不替代可交互主体，不承担物理碰撞 |

瀑布应拆成：

```text
WaterfallStaticRoot
├── Cliff / WaterfallMouth          固定
├── WaterColumnAnimatedSprite       固定锚点，只改水纹和透明边缘
├── PoolSurface                     固定，低幅度波纹
├── ImpactSplash                    落点固定，短循环或 one-shot
└── DropletParticles                少量、局部、受控
```

其中 `WaterColumnAnimatedSprite` 的每帧 canvas 和中心线必须一致；`Cliff` 绝不能作为它的父级 Sprite 帧的一部分重复绘制。

### 5.2 什么时候不用粒子

不要为了“有动态感”把所有场景塞满粒子。以下情况应优先使用手绘帧：

- 火焰轮廓必须有明确形状和风格。
- 水帘的主轮廓必须与瀑布口贴合。
- 门、箱、抽屉的运动需要读出铰链和接触关系。
- 动物吃草、喝水、坐下需要可读的姿势。

粒子适合补充数量感、随机性和短命反馈；不适合代替主轮廓、主动作或场景结构。[2][3]

### 5.3 时间和帧数建议

这是 Dream 的起始值，不是硬编码：

| 动作 | 帧数 | 速度/时长 | 节奏 |
|---|---:|---:|---|
| 环境 idle（火焰、水光、灯芯） | 3–5 | 4–8 fps | 平稳，首尾无跳变 |
| 动物呼吸/耳朵/尾巴 | 2–4 | 2–5 fps | 多用停顿，不要连续抖 |
| 行走 | 4–8 | 6–10 fps | 支撑脚接触、下压、通过、抬起 |
| 操作准备 | 2–4 | 6–10 fps | 短暂停顿，让玩家读到意图 |
| 接触/命中 | 1–3 | 8–15 fps | 接触帧短而清晰 |
| 水花/碎屑 one-shot | 3–6 | 8–16 fps | 先大后散，结束及时清理 |
| 门/箱/抽屉 | 3–6 | 6–12 fps | 轴心固定，开到位后停留 |

关键姿势可以多 hold 一点，中间帧快速通过；动作的重量主要来自时长和接触点，不是来自无限加帧。[8]

---

## 6. 交互状态机：从“看见”到“结果”要有层次

### 6.1 统一状态

```text
IDLE
  ↓ 进入距离/鼠标 hover
FOCUSED
  ↓ 按下交互键/点击
PRESSED
  ↓ 条件满足
ACTING
  ↓ 到达 impact / result marker
RESULT
  ↓ 动作结束
RECOVER
  ↓ cooldown 或条件变化
IDLE / LOCKED / DEPLETED
```

不是每个物体都需要每一个状态，但所有交互都必须声明：

- 触发方式：点击、交互键、进入范围、自动接触、任务条件。
- 触发范围：玩家站位和可用方向。
- 是否可打断：例如打开箱子通常不可重复打断；瀑布环境 FX 不存在“按一下停止”。
- 关键时间点：`start`、`contact`、`impact`、`result`、`finish`。
- 冷却和重复规则：例如水井取水、捕鱼咬钩、工作台制作不可每帧触发。
- 反馈层：角色动作、目标物变化、环境 FX、提示文本、音效预留。

### 6.2 交互提示

现有的最近热点提示是合理起点，但要控制噪声：

- 同一时间只显示一个主提示，优先最近且真正可执行的热点。
- 提示应锚定在物体上方的空白区，不遮住交互接触点。
- hover 高亮、可交互角标、按键提示和结果闪光必须使用不同语义；不能全部使用同一种闪烁颜色。
- 提示出现/消失可使用 80–140 ms 的淡入淡出，但不应持续缩放抖动。
- 只有状态变化时才改变提示文字，避免每帧重新生成 Label。
- 避免在物体固定位置生成临时十字框；如果需要 debug 标记，必须有 debug 开关，默认关闭。

### 6.3 交互资源定义建议

后续可以增加一个 `InteractionDefinition` Resource，或先以 profile dictionary 实现：

```gdscript
{
    "id": "well_draw_water",
    "target": "well_01",
    "verb": "use",
    "prompt": "打水",
    "range_tiles": 1.0,
    "use_point": Vector2i(0, 1),
    "facing": "up",
    "state": "ready",
    "actor_animation": "use_well",
    "target_animation": "bucket_pull",
    "fx": ["well_ripple_small", "water_drop"],
    "events": {
        "contact": 0.24,
        "result": 0.64,
        "finish": 0.92
    },
    "cooldown_sec": 0.8
}
```

这样可以把“显示什么、站哪里、什么时候变、谁拥有动画”从场景布置中分离出来。

---

## 7. 交互必须符合的物理和视觉规律

### 7.1 接触关系

- 人物坐长椅：脚/臀部落在座位接触线；长椅本身不闪，人物遮挡关系由 Y-sort 决定。
- 人物使用水井：人物站在井沿外侧，手/桶朝向井口；井口、水面和绳子的轴心不能在动画中移动。
- 人物打开箱子：箱体底部固定，箱盖围绕后侧铰链开合；不要让整只箱子向上平移。
- 人物操作工作台：人物站位、手的目标点、工作台前缘三者共线；工具或火花从接触点产生。
- 动物喝水/吃食：头部目标点、脚底基线和食槽/水盆边缘保持相对稳定；动作只改变头颈和身体重心。

### 7.2 水体和瀑布

瀑布不追求“所有东西都动”，而追求流向和落点的因果链：

1. 上游/瀑布口的水面高光先向下拉伸。
2. 水帘沿固定中心线向下，宽度可以轻微收放，但不能左右摆整块主体。
3. 落点出现短促白色水花和少量蓝色碎片，第一帧接触最亮，随后扩散和消失。
4. 池面产生 1–2 圈椭圆涟漪，中心固定在落点；涟漪由小到大、由亮到暗。
5. 水面高光与水花的速度可以不同，避免整个水面同步翻页。
6. 不默认使用雾气；只有场景氛围明确需要、并且不会遮住落点和地面接触时才加非常少量的雾。

瀑布结构的 QA 重点是“所有帧与静态岩壁/池边的接缝不变”，不是只看水流是否看起来动。

### 7.3 火、灯和阴影

- 火焰形状可以变化，但壁炉、锻炉、灯座和地面接触影不能变化。
- PointLight2D 的轻微亮度变化应绑定火焰状态，不要随机改变整个房间的明暗。
- 光源数量要少而有意义：壁炉、灯、窗光各自服务一个局部区域。
- 影子应短、方向一致、贴近物体；不要给每个小粒子单独投影。

Godot 的官方光照模型建议用 `CanvasModulate` 建立环境底色，再用 PointLight2D 等局部光源恢复真实光源附近的亮度。[4]

### 7.4 人物、动物和移动

- 角色 Sprite 的世界位置是脚底/根节点位置；动画帧只表现姿势变化。
- 行走时移动速度和步频要匹配：移动得越快，脚步周期不能仍然极慢。
- 角色方向来自移动向量；停止后保留最后朝向和 idle，不随机切面。
- 动物 idle 不应每帧换一张大幅变化的图；呼吸、耳朵、尾巴等小动作比身体整体漂移更协调。
- 任何“站在物品旁边”的交互都要定义一个 use point，禁止以视觉中心自动取最近点。

---

## 8. 当前项目的首批交互设计清单

### Wave I：先做稳定、能验证锚点的交互

1. **调查类**：长椅、水井、货箱、路标、门、室内家具。
   - 只做 focus → press → InfoPanel/状态变化。
   - 不添加持续闪烁，只使用一次短促确认反馈。
2. **门/入口类**：主角住宅、房间入口、场景传送点。
   - 统一 `use_point`、进入范围、提示和门动画；门体静态部分必须固定。
3. **水井类**：按下后角色做短动作，井绳/桶局部动，水面出现小涟漪。
   - 先不做复杂物品栏；先验证物理接触和重复触发。

### Wave II：环境反馈

1. **瀑布**：固定瀑布口 + 垂直水帘 + 固定落点水花 + 池面涟漪。
2. **捕鱼**：保留现有浮漂/气泡/涟漪；将随机点限制在水体 mask 内，确保结果不越岸。
3. **火炉/壁炉/锻炉**：火焰帧、火星、局部灯光分别管理。
4. **开合物**：箱盖、门、抽屉、柜门使用轴心开合，不用整物体上下左右漂移。

### Wave III：角色与动物 Smart Object

1. 动物靠近食槽/水盆 → 停止 → 面向目标 → 吃/喝短循环 → 离开。
2. NPC 靠近工作台 → 面向工作台 → 工具动作 → 产生少量 FX → 恢复巡逻。
3. 家中动物/角色与床、椅、桌的接触动作使用专门站位，不让通用巡逻路径穿过家具。
4. Smart Object 需要“占用状态”，同一时刻不要让两名角色在同一把椅子/同一工作台点重叠。

### Wave IV：可重复互动和持久状态

- 物品拾取、容器空/满、门开/关、火炉点燃/熄灭、水井可用/冷却、任务物品已调查等状态落入数据层。
- 场景重新进入时只恢复状态，不重复播放一整段无意义动画。
- 一次性结果必须有明确结果态；循环环境 FX 只由场景可见性和状态控制。

---

## 9. 导入、观察、重画的标准流水线

### 9.1 资源先审计，再导入

每次新增素材按以下顺序执行：

1. 记录来源、用途、是否原生像素、预计显示高度和投影方向。
2. 检查透明通道和黑底是否被正确移除。
3. 测量每帧画布尺寸、内容包围盒和锚点偏移。
4. 与同场景已有角色/家具进行 1× 显示尺寸并排观察。
5. 建立 manifest，注明静态层、动态层、碰撞层和接触点。
6. 放入临时测试场景，不直接写进正式场景。

### 9.2 导入设置

继续遵守 [`SCALE.md`](SCALE.md)：

- Compress Mode：Lossless。
- Filter：Nearest。
- Mipmaps：关闭，除非明确做远景 LOD。
- 黑底转透明后检查边缘 halo；不能只看缩略图。
- 保持项目已开启的 2D pixel snap；避免非整数 camera zoom。
- 不要把 1448×1086、1254×1254 等 AI 参考大图直接当 TileSet；先裁切、清理、归一化。

### 9.3 观察效果的临时测试场景

每类动态素材都应有一个小型 `InteractionLab` 测试场景，至少显示：

```text
左：原始帧循环
中：带脚底/接触线/中心线 overlay
右：放入真实场景比例和 Y-sort 的结果
下：碰撞框、use point、当前状态、当前 frame、frame_progress
```

测试场景需支持：暂停、逐帧、重播、显示锚点、显示碰撞、切换 1×/2×、背景切换为草地/石路/室内地板。没有这些观察能力，出现闪烁时很难判断是素材、节点、排序还是重复实例。

### 9.4 什么时候应该重画

满足以下任一条件，就不要继续靠代码补偿，应回到素材阶段：

- 同一动作的脚底或落点需要每帧手写不同 position 才能贴合。
- 静态部分被迫复制到每一帧，导致接缝或亮度不一致。
- 动画帧的透视、描边、阴影方向与邻近物品明显不同。
- 物体在 1× 显示时无法读出动作原因，只能靠文字解释。
- 帧数增加后变得更“软”或更花，但动作没有更清晰。
- ImageGen 生成的图带有不可控的小细节、边缘半透明、局部重复纹理或不同帧结构漂移。

重画时优先画“小而关键的局部层”：门轴、火焰、水花、井绳、箱盖、动物头部和脚步，而不是重新生成整张场景。

---

## 10. QA 闸门：没有通过就不能进入正式场景

### 10.1 资源级检查

- [ ] 所有帧 canvas 宽高完全相同。
- [ ] 所有帧使用相同的 anchor / pivot / 接触点。
- [ ] 透明区域没有黑边或 halo。
- [ ] 调色板、描边粗细、光照方向和投影一致。
- [ ] 文件名、manifest、画面内容和行为一致。
- [ ] 动画循环从最后一帧回到第一帧时没有跳变。
- [ ] 帧时长已明确，关键帧不是因为默认平均速度而闪过。

### 10.2 运行时检查

- [ ] 物体的静态部分不会跟随动态帧左右/上下移动。
- [ ] 接触点、脚底、落点和 use point 在 debug overlay 中稳定。
- [ ] 动态对象不会在同一场景位置重复生成。
- [ ] 一个交互目标只显示一个主提示。
- [ ] 点击、交互键和碰撞触发不会重复触发同一动作。
- [ ] 交互范围与玩家可站位置一致，不会隔墙、隔水或隔家具触发。
- [ ] 角色的 Y-sort 层级在接触家具/环境边缘时正确。
- [ ] 退出并重新进入场景后，持久状态正确恢复。
- [ ] 调试日志没有 invalid texture、missing resource、重复 signal 连接或 orphan FX。

### 10.3 特别针对当前已出现的问题

| 症状 | 先查什么 | 不能用什么掩盖 |
|---|---|---|
| 长椅、水井旁固定位置闪烁 | 是否重复实例化通用 marker / preview / hotspot Visual；是否每个区域复用了同一局部坐标；是否多个脚本重复连接 signal | 把提示改成更亮、更快的闪烁 |
| 动物上一帧出现、下一帧消失 | SpriteFrames 是否有空帧/坏路径；动画是否切换到不存在的 animation；节点是否被 queue_free；是否被错误的 visibility/scene reload 控制 | 增加透明度或随机位置 |
| 瀑布石头一起移动 | 静态石头是否被放在动画 Sprite 的纹理里；父节点是否被 Tween | 再给石头加反向 Tween |
| 瀑布水流左右摆动 | 每帧内容 bbox 是否不同；水帘锚点是否变化；是否用整张水帘做 sin(x) | 把左右摆动幅度调小到看不见 |
| 水花漂在池边 | 落点 use point 与池面坐标不一致；z band 错；水体 mask 和 FX 坐标系不同 | 加雾气遮接缝 |
| 角色脚底滑动 | walk 帧脚底锚点不一致；移动速度与帧速率不匹配 | 给角色整体上下抖动 |

### 10.4 当前项目 P0 验证顺序

1. 对 `PatrolActor`、`AmbientCritter`、室内火焰各取一个动画，显示脚底/接触点 overlay，逐帧暂停检查。
2. 暂时关闭水面 overlay 的其中一个时钟，只保留纹理切换或透明变化之一，确认是否仍有邻格不同步。
3. 对瀑布只显示静态主体和水帘，确认水帘左右中心线不动后，再打开落点水花。
4. 将 `InteractableHotspot` 的提示锚点固定到 manifest 的静态 bounds，确认提示不会跟随帧高变化。
5. 将鼠标点击和最近目标选择改为共用同一个候选目标集合后，再增加新的交互行为。

---

## 11. 推荐实现边界

### 11.1 Hotspot 只负责发现和触发

保留 `InteractableHotspot` 的职责：

- 碰撞/范围检测。
- hover 和最近目标选择。
- 显示统一提示。
- 发出 `activated` 信号。

将以下职责放到独立的行为组件或状态机：

- 是否可使用、是否 cooldown、是否已经完成。
- 玩家站位与朝向。
- 角色动作和目标物动作的同步。
- impact/result 时刻。
- 物品变化、场景状态、任务状态。
- FX、灯光、粒子和音效。

### 11.2 交互事件应由语义驱动

不要写大量“第 3 帧就生成水花”的脆弱逻辑；使用语义事件：

```gdscript
interaction_started.emit(definition.id)
interaction_contact.emit(definition.id)
interaction_result.emit(definition.id, result)
interaction_finished.emit(definition.id)
```

具体帧可以变化，但 `contact`、`result` 和 `finished` 的语义不变。对需要精确帧的动作，可由 `AnimationPlayer` marker、`frame_changed` 或 AnimationTree 状态回调触发；不要让业务代码散落在多个 Tween callback 中。

### 11.3 选择 Tween、AnimationPlayer 还是粒子

- **Tween：** 短促、单次、数值连续变化，如浮漂轻微下沉、提示淡入、物品上浮。
- **AnimationPlayer：** 多节点协同，如人物伸手 + 门轴 + 灯光 + FX，要求可读、可暂停、可复用。
- **AnimatedSprite2D：** 像素手绘帧，尤其是人物姿势和主轮廓变化。
- **GPUParticles2D：** 水滴、火星、尘土、少量碎屑；固定生命周期和局部坐标要明确。[2][3]
- **状态机：** 交互可用性、重复触发、冷却、打断和持久状态。

---

## 12. 实施顺序

### P0：交互资产基线

- [ ] 建立 `interaction_id` 命名约定。
- [ ] 建立动态资源 manifest 模板。
- [ ] 写一个离线 frame normalize / audit 工具，至少检查尺寸和锚点字段。
- [ ] 在测试场景中加入 anchor、contact、use point、collision overlay。
- [ ] 对现有 fire、forge、animal idle、NPC walk 做一次抽检。

### P1：调查与使用

- [ ] 统一最近热点提示和交互输入。
- [ ] 长椅、水井、货箱、门做四个最小交互样例。
- [ ] 确认不会重复生成提示、FX、signal 或临时 marker。

### P2：环境动态

- [ ] 重整瀑布为静态主体 / 水帘 / 池面 / 落点水花四层。
- [ ] 将捕鱼、火焰、锻炉都改为“静态锚点 + 动态局部”的样例。
- [ ] 逐帧截图检查接缝、落点和 z-sort。

### P3：角色与动物

- [ ] 建立动物类别的脚底基线和 use point。
- [ ] 实现一个动物 Smart Object：靠近食槽、面向、吃、退出。
- [ ] 实现一个 NPC 工作台 Smart Object：靠近、操作、结果 FX、恢复巡逻。

### P4：持久化和性能

- [ ] 交互结果进入场景/存档状态。
- [ ] 场景离屏时暂停或降低环境 FX。
- [ ] 统一清理 one-shot FX 和临时提示节点。
- [ ] 运行一轮全场景资源路径、重复 signal、帧尺寸、帧锚点和运行时错误检查。

### 与现有阶段计划的关系

本文件不替换 `PHASE5_WAVE_A2.md` 的场景扩展顺序，也不要求立刻重新装修已锁定的 C01–C04 室内。它提供的是下一阶段交互资产和行为的共同入口：先在测试场景中验证，再接入 profile 和正式场景。

---

## 13. Sources

以下链接是本文件中工程和动画结论的主要依据，访问日期为 2026-09-12：

1. [Godot Engine — AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html) — `SpriteFrames`、frame progress、offset、pixel snap 与循环信号。
2. [Godot Engine — GPUParticles2D](https://docs.godotengine.org/en/stable/classes/class_gpuparticles2d.html) — 粒子发射、生命周期、固定 FPS、局部/全局坐标、粒子不与 PhysicsBody2D 碰撞。
3. [Godot Engine — 2D particle systems](https://docs.godotengine.org/en/stable/tutorials/2d/particle_systems_2d.html) — 2D 粒子系统和 flipbook 等适用场景。
4. [Godot Engine — 2D lights and shadows](https://docs.godotengine.org/en/stable/tutorials/2d/2d_lights_and_shadows.html) — CanvasModulate、PointLight2D、DirectionalLight2D、LightOccluder2D 和光照性能注意事项。
5. [Godot Engine — Using Area2D](https://docs.godotengine.org/en/stable/tutorials/physics/using_area_2d.html) — Area2D 的范围检测、进入/离开信号和交互区域用法。
6. [KidsCanCode — Using Y-Sort](https://kidscancode.org/godot_recipes/4.x/2d/using_ysort/index.html) — 3/4 视角中按地面接触点进行排序的实践。
7. [SLYNYRD — Pixelblog 35: Top Down Interiors](https://www.slynyrd.com/blog/2021/11/30/pixelblog-35-top-down-interiors) — 3/4 视角室内、16×16 设计网格、墙体/楼梯/地毯/家具套件化经验。
8. [SpriteGen — How to Animate Pixel Art](https://spritegen.io/guides/how-to-animate-pixel-art/) — 固定画布、关键姿势、洋葱皮、脚底锁定、帧时长和循环检查；这是辅助经验来源，不替代 Godot 官方文档。
9. [RPG Maker Official Blog — Mapping: Interior](https://www.rpgmakerweb.com/blog/tutorial-mapping-interior) — 室内地图先建立墙体、地面、入口和功能区，再放家具的制作思路。
10. [GameMaker — How To Make Pixel Art for 2D Games](https://gamemaker.io/en/blog/make-pixel-art-2d-games) — 像素画比例、调色和统一视觉语言的辅助参考。
11. [Stardew Valley Wiki — Modding:Maps](https://stardewvalleywiki.com/Modding:Maps) — 水体属性、地图层和特殊水面动画的资料；项目内的 [`research/games/stardew-valley.md`](research/games/stardew-valley.md) 已整理为 Godot 转译笔记。
12. [Animal Crossing: New Horizons terrain research / NHSE](https://github.com/kwsch/NHSE/wiki) — 邻接、地形单元、旋转和合法组合的反向工程资料；用于理解水边/瀑布不能只靠贴图填色。
13. [Thunder Lotus / Toon Boom — Animating the afterlife in Spiritfarer](https://www.toonboom.com/thunder-lotus-games-on-animating-the-afterlife-in-spiritfarer) — 角色帧动画、转场动作、环境氛围和运行时灯光分层的制作经验。

---

## 14. 一句话验收标准

> 玩家按下交互键后，能看出谁在动、什么被接触、结果在哪里发生；而画面中所有没有参与这次交互的物体，都应该稳定地留在原地。
