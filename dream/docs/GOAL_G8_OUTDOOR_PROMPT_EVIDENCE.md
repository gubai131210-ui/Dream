# Goal G8 outdoor proximity prompt evidence

**Date:** 2026-09-13  
**Runner:** `res://tools/g8_outdoor_prompt_smoke.gd`  
**Result:** PASS (exit=0)

## What it proves

- Every outdoor area controller mounts `AreaInteractHost` (shared `InteractProximityDirector`)
- Hover wins executable target; `ProximityPrompt` (`互动`) becomes visible
- Plaza smoke: hover_wins e.g. `村公所` with prompt text `互动`

## MCP

- `docs/evidence/g8_square_outdoor_prompt.png` — live `水井/ProximityPrompt` visible=true text=互动  
- Runtime: `/root/VillageSquare/AreaInteractHost` present

## Related

- Interior parity: `GOAL_G8_INTERACT_TARGET_EVIDENCE.md`  
- Portal pulse closed: `tools/qa_portal_hover_only.py` GREEN
