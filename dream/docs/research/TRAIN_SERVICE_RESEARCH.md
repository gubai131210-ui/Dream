# Train service research — Dream A11 / C36 (2026-09-13)

## Primary inspirations

### Stardew Valley — Railroad train
- Source: [Stardew Wiki — Railroad](https://stardewvalleywiki.com/Railroad)
- Train is mostly an **atmospheric / opportunistic event**, not a daily commute tool.
- Appears randomly in a day window; whistle + toast warn the player to **run and catch it**.
- Cars vary (passenger / freight / themed); scarcity of “useful” trains creates chase tension.
- **Steal:** rare services feel special; missable arrival; empty tracks after it leaves.

### Animal Crossing (GC / New Leaf) — Station train
- Source: [Nookipedia — Train](https://nookipedia.com/wiki/Train)
- Train is the **actual travel verb** between towns; station is the hub.
- Passing trains on a coarse schedule add life even when you are not boarding.
- **Steal:** board at station → travel → arrive elsewhere; timetable as social ritual.

### Dream constraints
- No full wallet economy yet → ticket scarcity via **seat quota + favor + weather/night gates**, not gold grind.
- Existing: outdoor tracks (`station_assembler`), C11 waiting/ticket interior, C36 coach interior (static).
- Gap: **no locomotive sprite, no dwell/depart loop, no window ride, no destination hop.**

## Dream design (ubiquitous language)

| Term | Meaning |
| --- | --- |
| Service | One named run (村线 / 湖岸线 / 夜行慢车) with destination + rules |
| Approach | Train enters from off-map along the track band |
| Dwell | Train stopped at platform; doors open; boarding allowed |
| Depart | Train accelerates off-map; platform left with steam wisps |
| Ticket | Soft entitlement to board a specific Service while seats remain |
| Window Ride | C36 parallax scenery while en-route before destination load |

## Service table (v1)

| Id | Name | Dest | When | Seats/day | Notes |
| --- | --- | --- | --- | --- | --- |
| `local_hill` | 村线慢车 | 坡田 | Day | 3 | Most frequent; teaching service |
| `lake_coast` | 湖岸线 | 湖区 | Day + Clear | 2 | Skips in rain/fog |
| `night_express` | 夜行慢车 | 灯塔 | Night only | 1 | Scarce; “站长只剩一张” |

## Stop / go rules
1. **Stop (Dwell)** when service is scheduled and TrainService reaches APPROACHING→DOCKED.
2. **Stay docked** for dwell seconds unless player forces early depart (conductor) or dwell ends.
3. **Depart** when dwell ends OR all seats sold and boarding closed.
4. **Empty after leave:** loco gone; leftover steam FX + timetable text “已发车 · 下一班 …”.
5. **Board:** outdoor/C36 portal only during DOCKED + holding matching ticket (peek without ticket shows locked doors flavor).
6. **Arrive:** after window-ride duration, `SceneRouter` to destination outdoor map.

## Asset pack
- `train_loco_00`, `train_coach_00`, `train_steam_00`, `train_water_tower_00`
- `train_ticket_00`, `train_window_scenery_00` (scroll strip)
- Blend with A11 raw station art (black loco + warm coach windows).
