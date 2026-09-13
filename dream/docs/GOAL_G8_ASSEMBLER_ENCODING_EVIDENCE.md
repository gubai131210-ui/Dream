# Goal G8 — Assembler Chinese title encoding repair

**Date:** 2026-09-13  
**Gap:** Source strings in farmland / farm_residential / village_residential assemblers were UTF-8 mis-saved as Latin-1 mojibake (`è´§ç®±`…). Runtime `AreaCraft.repair_user_text` masked this for hotspots, but source + any unrepaired paths stayed wrong.

## Fix

- Repaired **61** string literals via `tools/fix_assembler_mojibake.py`
- Files: `farmland_assembler.gd`, `farm_residential_assembler.gd`, `village_residential_assembler.gd`
- Hard gate: `tools/qa_assembler_encoding.py` → **GREEN**

## MCP

| Probe | Result |
| --- | --- |
| farmland `/YSortRoot/货箱` | title/desc Chinese OK after source fix |
| Sample source | `"title": "货箱"` / `"desc": "枢纽旁货箱。"` |

Does not close user §7.
