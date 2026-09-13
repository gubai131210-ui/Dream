# Env-H — outdoor night grade + weather (visual layer)

Global state lives in Autoload **`WorldEnvState`** (see `WORLD_SIM_LOOP.md`).
`DayNightWeather` is the **per-outdoor visual** that pulls/pushes that Autoload.

| Pack | Role | Status |
| --- | --- | --- |
| H | Night CanvasModulate + weather overlay | Shipped; **global persist** |
| H+G | 路灯可读 | **所有户外 `lamp_0` 路灯**挂径向 PointLight；夜间能量补偿 CanvasModulate（`OutdoorLampKit`） |
| H+W | 建筑雨雪 | `WeatherBuildingFx` 檐滴 / 溅水 / 积雪 |

## Conventions

- `lamp_0` = 真灯柱 → `OutdoorLampKit` 自动挂 `LampLight`（`lamp_1`/`lamp_2` 是花盆/花箱，禁止当灯）
- 夜间 `ENERGY_NIGHT≈1.55`、`TEX_SCALE≈1.05`（补偿 CanvasModulate，但避免半屏白光）
- 天气循环：`CLEAR → RAIN → SNOW → FOG`（`R`）；昼夜 `N` —— 均为 **全局**
- 室内：不挂 Env 视觉（保持干燥），但 Autoload 状态保留，出门后继续
- 沉浸 UI：户外 TopBar 隐藏；`[ ]` 切图 · `M` Hub · `F11` 全屏

## Related

- Full closed loop: `docs/WORLD_SIM_LOOP.md`
- Schedule / animals: Autoload `ScheduleDirector`
