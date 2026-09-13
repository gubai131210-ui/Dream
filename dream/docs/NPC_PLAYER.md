# 主角 + NPC 走路动画

## 主角（Player）

| 项 | 值 |
|---|---|
| 脚本 | `scripts/actors/player_actor.gd` |
| 精灵 | `assets/sprites/npc/player/walk_{dir}_{0-7}.png` |
| 生成 | `python tools/generate_protagonist_pack.py`（从 farmer_v5 英雄配色） |
| 控制 | WASD / 方向键，32 px/s，8 fps 走路循环 |
| 分组 | `"player"` |
| 相机 | `PlayerBootstrap` autoload → `CameraController.set_follow_target()` |

## 相机跟随

- `CameraController.follow_enabled` 为 true 时平滑跟随主角，键盘平移关闭。
- 中键拖拽与滚轮缩放仍可用。
- Hub / QA 场景不生成主角（仅可玩户外+室内）。

## NPC

- 巡逻：`PatrolActor` + `NpcWalkFrames.build(id)`
- 帧路径：`assets/sprites/npc/{id}/walk_{down,left,right,up}_{0-3|0-7}.png`
- 8 帧包：farmer、player（检测 `walk_down_4.png` 存在）
- 白底清理：`python tools/regenerate_npc_packs.py`
- QA：`python tools/qa_npc_white_plates.py`、`python tools/qa_scene_presentation.py`

## 禁止偷懒

- 禁止无 walk 帧只 tween 位移
- 禁止主角用相机位置冒充玩家 proximity
- 禁止跳过 edge-white 抠图就进 production
- 禁止 Hub 场景生成可走路主角（地图导航模式）
