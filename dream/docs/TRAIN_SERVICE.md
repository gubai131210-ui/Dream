# Train Service — A11 outdoor train + C36 ride + scarce tickets

**Status:** CODE 2026-09-13  
**Locks:** [`TRAIN_C36.md`](./TRAIN_C36.md), [`STATION_C11.md`](./STATION_C11.md), [`research/TRAIN_SERVICE_RESEARCH.md`](./research/TRAIN_SERVICE_RESEARCH.md)  
**Skills:** domain-modeling (glossary in research), painting assets (loco/coach), station assembler runtime

## Goal

Make the station **feel like a real railway**: steam train arrives/departs, tickets are scarce, boarding enters the coach, then the player lands on a destination map.

## Player loop

1. Hub → 车站 → 看行车牌 / 站台售票窗  
2. Wait for **汽笛进站**（约数十秒冷却；班次受日夜/天气门控）  
3. 停靠时买票（余座有限）或向站长求人情票  
4. 持票点 **进入车厢** → C36（客座旅客 / 中廊）  
5. 约 3 秒后发车 → 抵达坡田/湖区/灯塔  

## Files

| Piece | Path |
| --- | --- |
| Autoload | `scripts/world/train_service.gd` |
| Outdoor runtime | `scripts/areas/station_train_runtime.gd` |
| Assets | `train_consist_00`、`track_band_seamless_00`、C36 coach family props |
| Outdoor track | `station_assembler._spawn_track_proxy` — 无缝带重叠铺满 |
| C36 coach | `interior_profiles` `c36_train_car` — 暖窗 / 旅客座排 / 中廊（**无**窗外 HUD 景色） |
| Import tool | `tools/import_train_a11_v2.py` / `tools/import_train_coach_family_v3.py` |
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
3. 禁止无窗外景色就跳场景 → **已改：C36 不再做窗外 HUD；发车后仍可切目的地**  
4. 禁止车次不受日夜/天气影响（湖岸晴开、夜行仅夜）  
5. 禁止汽车/巴士素材冒充蒸汽火车  
6. 禁止堵死站台轨道既有 sleeper/rail；禁止轨道只铺一半/中间断开  
7. 禁止未写研究笔记就拍脑袋发车规则  
8. 禁止声称用户已测过（中文路径下请用户本地 Godot 测）  
9. 禁止无视 A11 参考：黑锅炉+红轮+暖窗客车；禁止 C36 用普通室内家具冒充车厢；禁止空车厢无旅客剪影  

## Acceptance checklist

- [x] A11-style consist + continuous seamless track band  
- [x] C36 coach props（窗墙/双人座/行李架/过道毯/贯通道）  
- [x] TrainService autoload with dwell/depart/en-route  
- [x] Outdoor approach/dock/depart animation + post-leave steam  
- [x] Ticket scarcity + board gate  
- [x] C36 window scroll + destination hop  
- [ ] User Godot: 车站看贯通轨道与新火车 → 买票 → 上车看车厢内装 → 窗外 → 新地图  
