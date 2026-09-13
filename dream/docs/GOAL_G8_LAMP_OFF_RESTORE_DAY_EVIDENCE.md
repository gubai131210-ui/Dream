# GOAL G8 — Lamp-off restores sticky night

**Date:** 2026-09-13  
**Does not replace** user §7.

## Change

- `DayNightWeather._lamp_forced_night` + `restore_day_from_lamps()`
- Daytime lamp-on still sticky night; **lamp-off** restores day when night was lamp-forced
- Manual N night left alone (not lamp-forced)
- WIK + DIK copy: 「关灯或按 N 回白天」；§7 square expect updated

## MCP

1. `mcp_set_night(false)` → day  
2. `mcp_activate(lamp_toggle)` ×2 → lamp on, `is_night()==true`  
3. `mcp_activate(lamp_toggle)` → lamp off, `is_night()==false`  
4. Screenshot: `docs/evidence/g8_lamp_off_restores_day.png`
