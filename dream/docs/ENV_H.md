# Env-H — 昼夜 / 天气壳（C56–C57 / H）

**Status:** DONE (Wave A2 minimal) 2026-09-11；**lamp-host expand** 2026-09-13  
**Package:** outdoor night grade + weather overlay  
**Owns:** `scripts/env/**`, this doc  
**Hook:** thin `DayNightWeather.attach_to` on **all 14 outdoor area controllers** (not Autoload)  
**Does not:** rewrite assemblers, touch interiors, Autoload into every scene, permanently own `forest_deep` CanopyTint

---

## Delivered

| ID | Intent | Shipped |
| --- | --- | --- |
| C56 | 夜间调色 | `CanvasModulate` night grade on **all outdoor areas** |
| C57 / H | 天气覆盖 | ≥1 weather: **雨** (+ **雾** veil); cycle 晴→雨→雾 |
| H | 调色/粒子资源 | Runtime streak texture + ColorRect veil (no new art pack required) |
| H+G | 路灯可读 | Outdoor lamps use radial PointLight; night grade makes glow obvious (`GOAL_G8_ENV_NIGHT_LAMP_EVIDENCE`) |

## API

`scripts/env/day_night_weather.gd` — `class_name DayNightWeather` (Node, **not** Autoload)

```gdscript
DayNightWeather.attach_to(host: Node2D, top_bar: Control = null) -> DayNightWeather
env.toggle_night()
env.cycle_weather()          # CLEAR → RAIN → FOG → CLEAR
env.set_time_grade(DayNightWeather.TimeGrade.NIGHT)
env.set_weather(DayNightWeather.WeatherKind.RAIN)
env.mcp_set_night(true)      # sync MCP probe
```

Signals: `state_changed(time_grade, weather)`

### forest_deep note

If the host already has a `CanvasModulate` (e.g. `CanopyTint`), Env **reuses** it and restores its baseline on day — apply-if-present, never frees foreign modulate.

## How to toggle (any outdoor area)

1. Open any outdoor district (广场 / 市集 / 农田 / 河湖 / 林 / 灯塔 / 车站…).
2. TopBar buttons (auto-mounted):
   - **白天 / 夜间** — toggle night grade
   - **晴 / 雨 / 雾** — cycle weather
3. Keys:
   - **N** — toggle day / night
   - **R** — cycle weather (晴 → 雨 → 雾)
   - **G** — debug grid (existing)
4. Under **夜间**, click plaza/district lamps (广场/灯塔/车站) to verify radial glow on/off.

## Files

| Path | Role |
| --- | --- |
| `scripts/env/day_night_weather.gd` | Env node + overlay + `mcp_set_night` |
| `scripts/areas/*_controller.gd` | Thin `attach_to` on all outdoor hosts |
| `scenes/areas/village_square/village_square.tscn` | Hint text mentions N/R |
| `docs/ENV_H.md` | This package doc |
| `docs/GOAL_G8_ENV_NIGHT_LAMP_EVIDENCE.md` | Night + lamp MCP evidence |

## Out of scope (later)

- Autoload global clock shared across all outdoor districts  
- Full diegetic window / street-lamp art packs beyond current prop + PointLight  
- Thunder / snow / wind particle sets  
- Seasonal map overlays (C55)

## 禁止偷懒

1. 禁止改室内场景 modulate  
2. 禁止重写 outdoor assembler  
3. 禁止永久抢走 `forest_deep` CanopyTint  
4. 禁止只写文档无 TopBar/快捷键可切换  
5. 禁止把环境 UI 堆成弹层；仅 TopBar 两按钮 + 键位  
