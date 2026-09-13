# World Sim Loop — 全局环境 · 沉浸画面 · 天气建筑 · 日程闭环

## Research（外部参照）

### 天气 × 建筑（雨/雪落在屋顶上）
- Godot / 行业常见做法：雨粒子 + **屋顶遮挡**（SDF/`LightOccluder2D` 或区域遮罩）+ **檐下滴水** + 地面溅水；斜面径流（gameidea Rainy Shader Pack；Unity GPU Rain roof occlusion）。
- 像素风：分层雨幕 + 屋檐 drip loop + 积雪 modulate（PVFX Rain Field / Dripping Runoff）。
- **本项目落地**：`WeatherBuildingFx` 扫描 `/buildings/` 精灵，雨天檐下 drip + 脚底 splash；雪天屋顶积雪 tint + 落雪沉降粒子。室内无雨雪。

### NPC / 动物日程（闭环）
- Stardew：`Data/Schedules` 按 **季节/雨天/日期** 选表，条目为 `时刻 → 地图 → 坐标 → 朝向 → 行为`；雨天 `rain` 表优先，夜间回家睡觉动画。
- **本项目落地**：`WorldEnvState`（全局昼夜/天气/季节）→ `ScheduleDirector` 按角色表驱动 `patrol_actors` / `ambient_critters`（劳作 / 躲雨 / 进棚 / 回家睡觉），切图后仍服从同一状态。

## 架构

```
WorldEnvState (Autoload) ──state_changed──► DayNightWeather (per outdoor)
        │                                      ├ CanvasModulate night
        │                                      ├ rain/snow/fog overlay
        │                                      └ OutdoorLampKit
        ├──────────────────────────────────► WeatherBuildingFx (eave drip / snow cap)
        ├──────────────────────────────────► ScheduleDirector (NPC/animal presence & goals)
        └──────────────────────────────────► TrainService (reads night/weather)

PlayChrome / DreamUI ── hide TopBar text ──► MapTravelKit ( [ ] M Esc N R F11 )
```

## 操作（沉浸模式）

| 键 | 作用 |
| --- | --- |
| `[` / `]` | 上/下一张户外地图 |
| `M` | 世界总览 Hub |
| `Esc` | 连接总览 / Hub |
| `N` | 昼夜（全局） |
| `R` | 天气循环 晴→雨→雪→雾（全局） |
| `F11` | 全屏切换 |
| 左键 | 调查物件（InfoPanel） |

## 禁止偷懒（执行 agent 必读）

1. **禁止**只改当前场景的 `DayNightWeather` 本地变量却不写 Autoload —— 切图后必须仍是夜晚/雨天。
2. **禁止**只藏 Hint 文字却保留一整排 TopBar 按钮 —— 画面要留给游戏；调试入口用快捷键 / Hub。
3. **禁止**键盘切图绕过 `SceneRouter.change_to` —— 必须走 spawn 连续。
4. **禁止**只做全屏雨粒子、不给建筑挂檐滴/积雪 —— 雨雪必须在屋顶/檐口有动态反馈。
5. **禁止**只做一个 demo NPC 的 K/L 环 —— `ScheduleDirector` 要覆盖户外 `patrol_actors` + 农场动物，并按雨夜进棚/回家。
6. **禁止**室内也下大雨 —— 室内保持干燥；户外状态进门后仍保留，出门恢复视觉。
7. **禁止**只写文档不改 `project.godot` autoload / 不接 `attach_to`。
8. **禁止**天气循环仍停在「晴→雨→雾」无雪 —— 必须含 `SNOW`。
9. **禁止**把 QA/§7 验收条在正式游玩时仍常驻屏幕（仅 `dream_user_qa_return` 武装时显示）。
10. **禁止**声称闭环完成却无静态 QA + headless smoke。

## 验收

- 广场设夜间 → 切到农田/车站仍是夜间；雨/雪同理。
- 无 TopBar 大字/导航条；`[` `]` 可切图。
- 雨天建筑檐下有滴水；雪天屋顶有积雪感。
- 夜间/雨天：村民趋向室内锚点或隐藏进家；动物进棚逻辑触发。
