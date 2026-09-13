# Train Service — A11 outdoor train + C36 ride + scarce tickets

**Status:** CODE 2026-09-13  
**Locks:** [`TRAIN_C36.md`](./TRAIN_C36.md), [`STATION_C11.md`](./STATION_C11.md), [`research/TRAIN_SERVICE_RESEARCH.md`](./research/TRAIN_SERVICE_RESEARCH.md)  
**Skills:** domain-modeling (glossary in research), painting assets (loco/coach), station assembler runtime

## Goal

Make the station **feel like a real railway**: steam train arrives/departs, tickets are scarce, boarding unlocks a window ride, then the player lands on a destination map.

## Player loop

1. Hub → 车站 → 看行车牌 / 站台售票窗  
2. Wait for **汽笛进站**（约数十秒冷却；班次受日夜/天气门控）  
3. 停靠时买票（余座有限）或向站长求人情票  
4. 持票点 **进入车厢** → C36  
5. 约 3 秒后发车 → 窗外景色滚动 → 抵达坡田/湖区/灯塔  

## Files

| Piece | Path |
| --- | --- |
| Autoload | `scripts/world/train_service.gd` |
| Outdoor runtime | `scripts/areas/station_train_runtime.gd` |
| Window ride | `scripts/interiors/train_car_window_ride.gd` |
| Assets | `assets/sprites/props/train_loco_00.png`, `train_coach_00.png`, … |
| Import tool | `tools/import_train_assets.py` |
| QA | `tools/qa_train_service.py` |

## Services

| Id | Title | Dest | Gate | Seats/day |
| --- | --- | --- | --- | --- |
| local_hill | 村线慢车 | 坡田 | Day | 3 |
| lake_coast | 湖岸线 | 湖区 | Day + Clear | 2 |
| night_express | 夜行慢车 | 灯塔 | Night | 1 |

## 禁止偷懒

1. 禁止只放静止火车贴图却声称“有火车系统”  
2. 禁止无限车票 / 无余座逻辑  
3. 禁止无窗外景色就跳场景  
4. 禁止车次不受日夜/天气影响（湖岸晴开、夜行仅夜）  
5. 禁止汽车/巴士素材冒充蒸汽火车  
6. 禁止堵死站台轨道既有 sleeper/rail  
7. 禁止未写研究笔记就拍脑袋发车规则  
8. 禁止声称用户已测过（中文路径下请用户本地 Godot 测）  

## Acceptance checklist

- [x] Loco + coach sprites imported  
- [x] TrainService autoload with dwell/depart/en-route  
- [x] Outdoor approach/dock/depart animation + post-leave steam  
- [x] Ticket scarcity + board gate  
- [x] C36 window scroll + destination hop  
- [ ] User Godot: 车站等车 → 买票 → 上车 → 窗外 → 新地图  
