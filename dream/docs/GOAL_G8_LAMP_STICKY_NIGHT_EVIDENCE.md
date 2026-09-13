# Goal G8 — Sticky lamp night + larger sleep pillow cue

**Date:** 2026-09-13  
**Gap:** Daytime lamp glow needed night grade; auto-restore timers raced and wiped night. Sleep pillow cue was too small for §7 zoom.

## Code

- `DayNightWeather.pulse_dusk_for_lamps` → `set_time_grade(NIGHT)` sticky (no auto-restore). Return to day via **N**.
- Plaza + District lamp-on Info: `（已切夜间观灯；按 N 回白天）`
- `npc_routine_demo`: sleep pillow scale **0.55** (eat/read 0.42); pose cue hold **12s**

## MCP

| Check | Result |
| --- | --- |
| Lamp on from day | `is_night=true`, modulate r≈0.30, top bar 夜间 |
| Shot | `g8_square_lamp_night_preview.png` |
| Sleep id | `current_life_id=sleep` (+ larger pillow wiring) |

User §7 still open.
