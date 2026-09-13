# GOAL G8 — Window shaft + focus corners sprite-only

**Date:** 2026-09-13  
**Does not replace** user §7.

## Change

- `interior_craft.gd`: removed Polygon2D `WindowLightShaft` fallback → `push_error` if PNG missing
- `interactable_hotspot.gd`: removed `draw_line` hover frame; FocusCorners sprites only
- `qa_no_placeholder_visuals.py`: hard-fails Polygon shaft / `draw_line(` return

## MCP (C01)

- `Foundation/WindowLightShaft` class=**Sprite2D**, texture set
- Hover `衣柜` → `FocusCorners` Node2D with 4 Sprite2D children
- Screenshot: `docs/evidence/g8_c01_window_shaft_focus_sprite.png`
