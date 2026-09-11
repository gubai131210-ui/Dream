# Env-H — 昼夜 / 天气壳（C56–C57 / H）

**Status:** DONE (Wave A2 minimal) 2026-09-11  
**Package:** outdoor night grade + weather overlay  
**Owns:** `scripts/env/**`, this doc  
**Hook:** thin mount in `village_square_controller.gd` only  
**Does not:** rewrite assemblers, touch interiors, Autoload into every scene, permanently own `forest_deep` CanopyTint

---

## Delivered

| ID | Intent | Shipped |
| --- | --- | --- |
| C56 | 夜间调色 | `CanvasModulate` night grade on `village_square` |
| C57 / H | 天气覆盖 | ≥1 weather: **雨** (+ **雾** veil); cycle 晴→雨→雾 |
| H | 调色/粒子资源 | Runtime streak texture + ColorRect veil (no new art pack required) |

## API

`scripts/env/day_night_weather.gd` — `class_name DayNightWeather` (Node, **not** Autoload)

```gdscript
DayNightWeather.attach_to(host: Node2D, top_bar: Control = null) -> DayNightWeather
env.toggle_night()
env.cycle_weather()          # CLEAR → RAIN → FOG → CLEAR
env.set_time_grade(DayNightWeather.TimeGrade.NIGHT)
env.set_weather(DayNightWeather.WeatherKind.RAIN)
```

Signals: `state_changed(time_grade, weather)`

### forest_deep note

If the host already has a `CanvasModulate` (e.g. `CanopyTint`), Env **reuses** it and restores its baseline on day — apply-if-present, never frees foreign modulate.

## How to toggle (village_square)

1. Open **村庄广场** (`village_square.tscn`).
2. TopBar buttons (auto-mounted):
   - **白天 / 夜间** — toggle night grade
   - **晴 / 雨 / 雾** — cycle weather
3. Keys:
   - **N** — toggle day / night
   - **R** — cycle weather (晴 → 雨 → 雾)
   - **G** — debug grid (existing)

## Files

| Path | Role |
| --- | --- |
| `scripts/env/day_night_weather.gd` | Env node + overlay |
| `scripts/areas/village_square_controller.gd` | Thin `attach_to` hook |
| `scenes/areas/village_square/village_square.tscn` | Hint text mentions N/R |
| `docs/ENV_H.md` | This package doc |

## Out of scope (later)

- Autoload global clock shared across all outdoor districts  
- Diegetic window / street lamps (C56 full art)  
- Thunder / snow / wind particle sets  
- Seasonal map overlays (C55)

## 禁止偷懒

1. 禁止改室内场景 modulate  
2. 禁止重写 outdoor assembler  
3. 禁止永久抢走 `forest_deep` CanopyTint  
4. 禁止只写文档无 TopBar/快捷键可切换  
5. 禁止把环境 UI 堆成弹层；仅 TopBar 两按钮 + 键位  
