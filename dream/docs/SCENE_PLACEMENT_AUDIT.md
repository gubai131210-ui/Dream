# Scene Placement Audit — multi-agent deep pass

**Date:** 2026-09-13  
**Agents:** water scenes · village/farm · forest/station · placement fixes · rock taxonomy

## Findings (summary)

| Severity | Issue | Status |
|---|---|---|
| P0 | Waterfall bench/moss/reeds mid-pool | **Fixed** — south rim / banks |
| P0 | Lake isle boat + aquarium mid-water | **Fixed** — south/west shore |
| P0 | Hidden chests in pool / lake water | **Fixed** |
| P1 | Lake-house props inside house AABB / dock footprint | **Fixed** |
| P1 | `footprint_ok` ignored `blocked_mask` (trees/props through buildings) | **Fixed** |
| P1 | Single moss rock pack reused on coast/terrace | **Fixed** — biome families |
| P2 | Hill farm rocks oversized + on sheds | **Fixed** — terrace family + scale |
| P2 | Residential pond rocks never spawned | **Fixed** |
| P2 | Lighthouse rocks dead code | **Fixed** — called + coastal family |

## Rock taxonomy (deep module: `RockCatalog`)

| Family | Path | Use |
|---|---|---|
| `forest_moss` | legacy `props/rock_00–05` | Forest / damp shade only |
| `coastal` | `props/rocks/coastal/` | Lighthouse, pier, salt lip |
| `terrace` | `props/rocks/terrace/` | Hill farm lips (dry sandstone) |
| `cobble` | `props/rocks/cobble/` | Plaza / station ballast (ready) |
| `river_bank` | `props/rocks/river/` | River / waterfall banks |

Scale lock: shore **target_h ≈ 18–28px**; cobble **≈16px**. Forbidden: raw 0.4+ on 200px moss sheets as yard scatter.

## Remaining follow-ups (not blocking)

- Village square: museum portal / civic AABB spacing (separate pass)
- Forest entrance: cabin-adjacent trees still need AABB polish after blocked_mask
- Station: north trees vs roof; cobble ballast optional decorate
- Market sack off west shop wall

## 禁止偷懒

1. 禁止只改一个场景的石头路径却继续在海岸/梯田用苔藓大石  
2. 禁止把箱子/长椅/宝箱留在河湖中心“好看”  
3. 禁止 props 穿进房子 AABB（必须尊重 `blocked_mask`）  
4. 禁止声称石头已重做却没有新 biome 目录 + `RockCatalog`  
5. 禁止只写审计文档不改 assembler  
6. 禁止放大 `rock_02` 到 0.7 当矿洞门（须 ≤0.35 或专用入口图）  
7. 禁止室内下沉物规则与户外水域规则混用而不文档化  

## Hand-test

瀑布/湖/湖屋/灯塔/梯田/民居：确认岸边有石、水心无箱、房顶无杂物、石头风格随场景变化。
