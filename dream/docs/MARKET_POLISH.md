# Market street polish (A10) — multi-agent brief

**Trigger:** User screenshot — barrels block stalls / wrong scale; mixed benches; few NPCs; layout too much like village square.

## Locked goals

1. **Street, not square:** Elongated E–W cobble street with side stall alcoves; avoid large centered plaza + 4-way cross like A09.
2. **Stall goods:** Small scale (≤0.5), beside/under awning — never in front of awning face. Prefer `B11-01_barrels_*` / `B11-02_crates_*` smaller cuts. No giant `sack_0` as stall face.
3. **Benches by zone (one style per zone):**
   - Market street / plaza stone → `bench_1` only
   - West river / bridge approach → `bench_2` only  
   - North shop door dirt → `bench_0` only
4. **NPCs:** ≥6 patrol actors; use `npc_00`–`npc_02` + `idle_frame_*` with `flip_h` / distinct routes (buyer / vendor / porter / visitor). Titles unique.
5. Keep `BUILDING_PLACEMENT` + AreaCraft; portals unchanged.

## Ownership

| Agent | Owns |
|---|---|
| Layout | `market_street_assembler.gd` masks, path/dirt, buildings, trees, portals, assemble() wiring |
| Dressing | NEW `market_street_dressing.gd` — stalls, plaza props, actors; assembler calls it |

## 禁止偷懒

- 禁止继续用大十字广场冒充商业街  
- 禁止木桶/货箱默认 scale=1 挡在棚前  
- 禁止同一功能区混用不同板凳款  
- 禁止只有 3 个相同观感 NPC  
- 禁止改 Hub / 其他场景 assembler  
