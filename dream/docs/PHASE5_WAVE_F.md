# Phase 5 Wave F — Civic tour · Transit/dive · NPC rings · World systems

**Status:** IN PROGRESS (seeded) 2026-09-11  
**User lock:** Ship C40–C45, C34–C36+C23, C53–C54, C55+C58–C62 as **four parallel region teams**. Do not polish Wave A–E unless broken portals.  
**Locks:** [`PHASE5.md`](./PHASE5.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md), [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md), [`ENV_H.md`](./ENV_H.md) (season pattern), [`NPC_ANIM.md`](./NPC_ANIM.md)  
**Skills:** `interior-territory-craft`, `painting-asset-craft`, `interior-visual-qa`, `realistic-scene-craft` (outdoor hosts — Lead only)

## Parallel region teams (mutual exclusion)

| Team | Owns | Packages | Done when |
| --- | --- | --- | --- |
| **CivicTour** | profiles `c40_*`…`c45_*` + docs `MUSEUM_C40`…`TAVERN_UP_C45` + own props | C40–C45 | each library min + desk QA |
| **TransitDive** | `c34_*` `c35_*` `c36_*` `c23_*` + docs + props | C34–C36, C23 | each library min + desk QA |
| **NpcRing** | `scripts/npc/**` rings + `docs/NPC_RINGS_C53C54.md` (may thin-hook C02/outdoor actors) | C53–C54 | ≥3 work + ≥3 life loops |
| **WorldSys** | `scripts/env/seasonal_decor.gd`, `scripts/world/**`, docs `SEASON_C55` + `WORLD_C58_C62` | C55, C58–C62 | season layer + interact/break/gate/chest/secret mins |

**Shared (Lead only):** `scene_router.gd`, `gen_interior_scenes.py`, outdoor portal appends, stub profiles/shells, this MD, `PHASE5.md`, C04 tavern stair seed.

### Portal hosts (Lead-seeded)

| Interior / system | Host | Control |
| --- | --- | --- |
| C40 museum | `village_square` ~(220,280) | 进入博物馆 |
| C41 aquarium | `lake` ~(420,480) | 进入水族馆 |
| C42 hotspring | `hill_farm` ~(640,360) | 进入温泉 |
| C43 bathhouse | `village_square` ~(1080,280) | 进入浴场 |
| C44 inn | `market_street` ~(200,400) | 进入旅馆 |
| C45 tavern up | C04 `extra_portals` | ↑二楼 |
| C34 fish dock | `lake` ~(280,620) | 进入渔码头 |
| C34 trade dock | `lighthouse` ~(360,700) | 进入商码头 |
| C35 boat docked | C34 fish dock `extra` | 登船 |
| C35 boat wreck | `lake` ~(900,640) | 半沉船 |
| C36 train car | `station` ~(900,360) | 进入车厢 |
| C23 underwater | `lake` ~(640,700) | ↓潜水 |
| C55 / C58–C62 | `village_square` TopBar / thin hooks | WorldSys mounts (Env-H style) |
| C53–C54 | square + market + C02 thin hooks | NpcRing mounts |

## SceneRouter interiors

```
C40_MUSEUM C41_AQUARIUM C42_HOTSPRING C43_BATHHOUSE C44_INN C45_TAVERN_UP
C34_DOCK_FISH C34_DOCK_TRADE C35_BOAT_DOCKED C35_BOAT_WRECK C36_TRAIN_CAR C23_UNDERWATER
```

## Library Done-when

| ID | Min |
| --- | --- |
| C40 | ≥1 展厅 + 捐赠钩子可读 |
| C41 | ≥1 水缸区（可绑钓鱼捐赠钩） |
| C42 | ≥1 泡池（更衣/蒸汽可读） |
| C43 | ≥1 浴池 + 更衣 |
| C44 | 大厅 + ≥1 客房 |
| C45 | ≥1 酒馆二楼房（客房/老板/密会可读） |
| C34 | ≥2 码头类型（渔/商）可进 |
| C35 | ≥2 船状态（停靠/半沉） |
| C36 | ≥1 车厢 |
| C23 | ≥1 潜水点（水草/沉木/箱） |
| C53 | ≥3 职业工作环 |
| C54 | ≥3 生活态 |
| C55 | 广场四季装饰层可切换（复用 A09） |
| C58 | ≥8 交互类型 |
| C59 | ≥4 可清物 |
| C60 | ≥3 进度门 |
| C61 | ≥5 隐藏箱点 |
| C62 | ≥1 完整密道链（跨 ≥2 室外） |

## 禁止偷懒（全队）

1. 禁止门只有 InfoPanel、无 `scene_path`  
2. 禁止室内无 `return_path` / 堵南门通廊  
3. 禁止整文件重写 `interior_profiles.gd`（只改本队 key）  
4. 禁止改其他车道 profile / assembler / scene_router（Lead 除外）  
5. 禁止抛光 Wave A–E；C04 仅保留 ↑二楼 portal  
6. 禁止 C55 新开整盘节日大地图（必须广场装饰层）  
7. 禁止 C53/C54 只写 MD 不接线 actor/route  
8. 禁止 C58–C62 只列清单无场景可点可走钩子  
9. 禁止棋盘格地板 / 整屋橙色洗色 / 家用台灯进渔商码头船舱  
10. 禁止未写包 MD + desk Visual QA（房间）或系统验收表就标 DONE  
11. 禁止中文路径强跑易损 Godot CLI（用户本机 QA）  
12. 禁止「放下就算」——房间须 Ensemble/Interact-ready  

## Integration checklist (Lead)

- [ ] All region packages enriched  
- [ ] Package/system MDs + desk QA  
- [ ] Portals + returns + TopBar hooks  
- [ ] Commit + push `origin/master`  
- [ ] User Godot QA note  
