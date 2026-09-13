# Goal G8 — C22 fish cage multi-frame splash FX

**Date:** 2026-09-13  
**Does not replace** user §7 hand-feel QA.

## Gap closed

Fish cage activate feedback was modulate `_pulse` only. Objective requires click/activate feedback and multi-frame animation where applicable.

## Change

- Generated `assets/sprites/fx/fish_splash_00..03.png` (32×24 fixed canvas) via `tools/gen_g2_interact_fx.py` (`fish_splash()` append-only).
- `fish_cage.gd`: place / ripe / collect → `_play_splash_fx()` → `FX_fish_splash` AnimatedSprite2D oneshot (pause-on-end); `mcp_splash` / `mcp_place` / `mcp_collect` report `fx`.
- `fishing_spot.gd`: bite splash prefers 4-frame sheet when present.
- `qa_interaction_frames.py`: group `fish_splash` → **GREEN** (20 groups).

## MCP evidence

| Probe | Result |
| --- | --- |
| River `FishCage_river_west_bend_cage.mcp_splash` | `ok`, frames=4, playing=true |
| Held frame | `FX_fish_splash.frame=3` visible after oneshot |
| Shots | `g8_c22_cage_splash_fx.png` + `g8_c22_cage_splash_held.png` (zoom=2) |

User §7 still required for hand-feel.
