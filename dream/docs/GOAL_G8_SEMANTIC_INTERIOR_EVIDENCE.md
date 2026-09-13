# Goal evidence — G8 semantic interior props

**Date:** 2026-09-13  
**Painter:** `tools/paint_semantic_interior_props.py` + `tools/paint_civic_notice_boards.py`  
**QA:** `tools/qa_semantic_interior_props.py` → GREEN

## Replacements

| Room | Cluster | Was (proxy) | Now |
| --- | --- | --- | --- |
| C07 school | blackboard / desks | notice / table_dining | `blackboard_00` / `school_desk_00` |
| C10 church | altar | counter_00 / notice_00 | `altar_00` / `scripture_plaque_00` |
| C08 clinic | front | notice_00 | `clinic_fee_board_00` |
| C40 museum | exhibit | notice_00 | `exhibit_guide_00` |
| C43 bath / soak change | bath / change | notice_00 | `bath_rules_00` |
| C44 inn | lobby | notice_00 | `inn_rate_board_00` |
| C11 station | waiting | table_dining | `waiting_bench_00` |
| C25 river hide | reed | hay_00 | `reed_clump_00` |
| C31 sewer | pipe_run | barrel_* | `sewer_pipe_00` |

## MCP

- `g8_c07_school_semantic.png`
- `g8_c10_church_altar.png`
- `g8_c10_scripture_plaque.png`
- `g8_c08_clinic_fee_board.png`
- `g8_c40_exhibit_guide.png`
- `g8_c43_bath_rules.png`
- `g8_c44_inn_rate_board.png`
- `g8_c11_station_benches.png`
- `g8_c25_river_hide_reed.png`
- `g8_c31_sewer_pipes.png`

User §7 Godot QA still required for Goal complete.
