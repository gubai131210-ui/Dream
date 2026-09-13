# Goal G8 — C58 lamp_toggle multi-frame spark FX

**Date:** 2026-09-13  
**Does not replace** user §7 hand-feel QA.

## Gap closed

`lamp_toggle` was the last C58 interact with light/modulate state only (no multi-frame activate FX). District `*lamp*` incorrectly reused `board_rustle`.

## Change

- Generated `assets/sprites/fx/lamp_spark_00..03.png` (24×32) via `gen_g2_interact_fx.py` (`lamp_spark()` append-only).
- `world_interact_kit.gd`: toggle + `mcp_spawn_c58_fx(lamp_toggle)` → `FX_lamp_spark`.
- `district_interact_kit.gd`: `id.contains("lamp")` → `lamp_spark` (not board_rustle).
- `g8_c58_fx_smoke.gd` includes lamp case; `qa_interaction_frames` group `lamp_spark` → **GREEN** (21 groups).

## MCP evidence

| Probe | Result |
| --- | --- |
| `WorldInteractKit.mcp_spawn_c58_fx("lamp_toggle")` | ok, fx=FX_lamp_spark, frames=4 |
| Held | `FX_lamp_spark.frame=3` visible |
| Shot | `docs/evidence/g8_c58_lamp_spark_held.png` (zoom=2) |

User §7 still required.
