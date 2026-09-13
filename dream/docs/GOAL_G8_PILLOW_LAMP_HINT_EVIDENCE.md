# Goal G8 — C54 pillow deep-paint + daytime lamp N hint

**Date:** 2026-09-13  
**Gaps closed (agent):** Genre soft-pillow note; daytime lamp glow discoverability without broken auto-dusk.

## Art / code

- `tools/paint_pose_deep.py` → `paint_pillow_prop()` — denser `props/pillow_00.png` (uniq≥40; seam/stitch/shadow)
- `qa_interact_fx_coverage.py` asserts pillow uniq≥40
- Daytime lamp Info (plaza `WorldInteractKit` + District lamps): append `（白天请按 N 查看光晕）` when turning on while Env-H is day
- `DayNightWeather.pulse_dusk_for_lamps(duration_sec:=0)` — MCP sticky night helper (default no auto-restore; prior auto-timer could race)

## Gates / MCP

| Check | Result |
| --- | --- |
| `qa_interact_fx_coverage` | GREEN (pillow uniq) |
| `qa_work_pose_style` | GREEN |
| C54 sleep | `current_life_id=sleep` + `g8_c54_pillow_deep.png` |
| Night lamp glow | `pulse_dusk_for_lamps(0)` after_r≈0.3 + lamp on → `g8_square_lamp_day_dusk_pulse.png` |

User §7 still open.
