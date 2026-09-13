# 主角 + NPC 走路动画

## 主角（Player）

| 项 | 值 |
|---|---|
| 脚本 | `scripts/actors/player_actor.gd` |
| 精灵 | `assets/sprites/npc/player/walk_{dir}_{0-7}.png` |
| 重建 | `python tools/rebuild_farmer_player_cutouts.py`（从 `gen_npc_farmer_v5` 真正抠灰白底 + 拉满 48×56） |
| 控制 | WASD / 方向键，32 px/s，8 fps 走路循环 |
| 分组 | `"player"` |
| 相机 | `PlayerBootstrap` autoload → `CameraController.set_follow_target()` |

## 白底 / 体型过小（已修）

AI sheet 的**灰白棋盘格**曾被烤进 farmer/player 帧（非纯白，旧 edge-white QA 漏检），角色缩在卡片里显得又小又脏。重建后：

- 棋盘/近白板全部透明
- 轮廓高度 ≈54/56 px（与 elder_woman 同级）
- work_poses 从干净 farmer 重绘；演示缩放 1.45

## 相机跟随

- `CameraController.follow_enabled` 为 true 时平滑跟随主角，键盘平移关闭。
- 中键拖拽与滚轮缩放仍可用。
- Hub / QA 场景不生成主角（地图导航模式）。

## NPC

- 巡逻：`PatrolActor` + `NpcWalkFrames.build(id)`
- 帧路径：`assets/sprites/npc/{id}/walk_{down,left,right,up}_{0-3|0-7}.png`
- 8 帧包：farmer、player
- QA：`python tools/qa_npc_white_plates.py`（含 farmer/player 灰板+高度门禁）

## 禁止偷懒

- 禁止只清 RGB≥235 的纯白，放过棋盘灰板
- 禁止无 walk 帧只 tween 位移
- 禁止主角用相机位置冒充玩家 proximity
- 禁止 Hub 场景生成可走路主角
