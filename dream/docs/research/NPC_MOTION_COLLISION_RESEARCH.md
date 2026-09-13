# NPC 移动速度、碰撞与场景配置（研究摘要）

**日期：** 2026-09-13  
**范围：** 走路帧速、角色差异化速度、天气/时段调速、建筑阻挡。

## 1. 高信任来源结论

### Stardew Valley 路径 / 碰撞

- NPC 路径用 A*（`PathFindController`），逐步检测 `isCollidingPosition`；日程路径还会拒绝 Buildings 层不可通过格（除非 `Passable` / `NPCPassable`）、`NoPath`、以及不可通过地形特征。[PathFindController.cs（反编译参考）](https://github.com/WeDias/StardewValley/blob/main/PathFindController.cs)
- 1.6.9 修复：NPC 不再错误避开**可通过**的地板/草皮等 terrain features（此前会绕路砸东西）。[官方 1.6.9 Changelog](https://www.stardewvalley.net/stardew-valley-1-6-9-changelog/)

### 对本项目的推导（非来源原文）

| 规则 | Dream 落地 |
|---|---|
| 建筑脚底不可走 | `AreaCraft.mark_blocked_footprint` → `blocked_mask` |
| 水不可走 | `water_mask` |
| 石路/土路/草地可走 | `is_npc_walkable` |
| 碰阻时先侧移再掉头 | `PatrolActor._try_sidestep`（轻量，非完整 A*） |
| 玩家轴滑 | `PlayerActor` 阻挡时保留自由轴向 |

## 2. 速度策略 `NpcMotionPolicy`

| 角色 | 晴天日间 px/s | 基准 FPS |
|---|---:|---:|
| 老者 ELDER | 26 | 9 |
| 工人 WORKER | 40 | 12 |
| 商贩 MERCHANT | 30 | 10 |
| 访客 VISITOR | 34 | 11 |
| 站务 GUARD | 36 | 11 |
| 主角 PLAYER | 48 | 12 |

乘数：

- 地区：`plaza 1.0` / `market 0.88` / `farmland 1.08` / `wild 0.85` …
- 天气：雨 `0.72`、雾 `0.80`
- 夜间：`0.78`
- FPS 用 `sqrt(weather×time)` 与速度配对，减轻脚底滑动

## 3. 场景 × 合适 NPC

| 场景 | 应出现 | 不应乱塞 |
|---|---|---|
| 村庄广场 | 老妇人、摊主、村长 | 田农（改到农田） |
| 农田 | 田农、灌溉工(miller)、仓前帮手、歇脚老妇 | 站长 |
| 车站 | 站长、旅客商贩、赶车农夫 | — |
| 商业街 | 商贩为主 | — |

## 4. 老妇人「只动手不动腿」

源帧长裙遮腿，侧向几乎只有手臂位移。`tools/fix_elder_woman_legs.py` 重绘下三分之一：交替脚掌落点 + 裙摆微移，QA 要求 lower_motion≥180。

## 禁止偷懒

- 禁止全图统一 32px/s、8fps
- 禁止广场继续刷农田农夫冒充市民
- 禁止只用 turn_back，不尝试侧移
- 禁止建筑 footprint 写在临时 AreaCraft 上却不交给玩家/NPC 共享的 `craft`
