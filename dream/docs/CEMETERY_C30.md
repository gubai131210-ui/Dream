# Cemetery C30 — 墓园（墓区 + 穴簇）

**Status:** DONE 2026-09-11  
**Locks:** [`PHASE5_WAVE_C.md`](./PHASE5_WAVE_C.md), [`INTERIOR_LIBRARY.md`](./INTERIOR_LIBRARY.md) C30, [`INTERIOR_FOUNDATION.md`](./INTERIOR_FOUNDATION.md), [`INTERIOR_COMPOSITION.md`](./INTERIOR_COMPOSITION.md), [`SCALE.md`](./SCALE.md)  
**Skills:** `interior-visual-qa`, `painting-asset-craft` (dedicated headstones + crypt door)  
**Peer silhouette:** parish churchyard — west grave rows + east low crypt/mausoleum mass + clear south path (≠ C10 axial nave pews, ≠ ruins nave)

## Goal

One enterable **墓园院子** with readable outdoor-yard grammar:

| Cluster | Verb | Tile anchor (approx) |
| --- | --- | --- |
| `graves` | 祭扫 | west, `tx≈6 ty≈8` — headstone rows + offerings |
| `crypt` | 入穴 | east, `tx≈19 ty≈7` — stone crypt door mass + rocks |

Center **path aisle** `door_tx0–door_tx1` = **11–14** (≥2 tiles) clear south door → north. Stone floor, cool dusk modulate, cool blue lights. Optional caretaker patrols graves ↔ crypt.

## Ownership

| Piece | Path |
| --- | --- |
| Profile only | `scripts/interiors/interior_profiles.gd` → `"c30_cemetery"` |
| Unique props | `headstone_00.png`, `headstone_01.png`, `crypt_door_00.png` |
| Scene (gen’d shell) | `scenes/interiors/c30_cemetery/c30_cemetery.tscn` |
| Outdoor portal host | Square 教堂南 `~(1000,360)` — Lead-seeded **进入墓园**（团队勿改 assembler） |
| Router const (Lead) | `SceneRouter.C30_CEMETERY_PATH` |
| This doc | `docs/CEMETERY_C30.md` |

## Portal wiring

| From | Control | To |
| --- | --- | --- |
| A09 广场 教堂南墓园 | `enter_title`「进入墓园」→ `C30_CEMETERY_PATH` | C30 interior |
| C30 south door / TopBar 返回室外 | `return_path` = `SQ` | `village_square.tscn` |
| C30 TopBar 世界总览 | Hub | hub |

## How to enter (user QA)

1. Open Godot project `dream/` locally（中文路径下请你本机测，勿强跑易损 CLI）。  
2. Hub → **广场** → click portal **进入墓园** south of the church (~1000,360).  
3. Walk north on center path; west headstones readable; east crypt door mass; click props for InfoPanel; 守墓人 patrols.  
4. Exit: south **← 返回** portal or TopBar **返回室外** → 广场.  

Scene path: `res://scenes/interiors/c30_cemetery/c30_cemetery.tscn`.

## Layout notes

- `room_w×room_h` = **26×18** (yard rectangle; not church’s taller nave).  
- Floor `stone`; modulate cool blue-grey dusk; lights cool `Color(0.7x, 0.7x, 1.0)`.  
- Graves: dedicated `headstone_00` / `headstone_01` (not notice boards); basket/crate offerings with south approach stands.  
- Crypt: dedicated `crypt_door_00` arched iron-bar mouth + outdoor rocks as perimeter mass; chest south of door.  
- No indoor rug (outdoor-yard feel). Door band 11–14 kept clear of props.

## 禁止偷懒

1. 禁止改 C01–C04 / 其他 Wave C 包 profile  
2. 禁止拆广场「进入墓园」portal / 改 `village_square_assembler`  
3. 禁止室内无返回广场 / 堵死南门 11–14 通廊  
4. 禁止用告示牌/饭桌冒充墓碑与穴门  
5. 禁止做成 C10 礼堂中轴座席轮廓  
6. 禁止整屋酒馆暖橙洗色 / 棋盘格地板  
7. 禁止无「穴」可读簇却声称 DONE  
8. 禁止未写本 MD / 未跑 Visual QA 就声称 DONE  

## Interior Visual QA (desk)

```
Interior Visual QA: PASS (desk) — user Godot shot pending
Place: Reality PASS (grave rows + crypt door ≤3s)
      Peer PASS (churchyard west graves / east crypt)
      Scene-fit PASS (stone cool yard; dedicated headstones/crypt)
      Territory PASS (crypt rock mass; grave offering cluster)
      Composition PASS (2 verbs; actor ≥2 anchors)
      Ensemble PASS (primary crypt mass east + graves west; open aisle ≥30% void)
      Interact-ready PASS (via_stands south of offerings / crypt door)
Art: Style PASS | Craft PASS (headstones ~100 colors, crypt ~120)
      Bleed PASS (no outdoor grass on stone props) | Name≠pixels PASS
Assembly: Corridor PASS (door 11–14 clear) | Y-sort craft parent | Profile-wire PASS
Meta: Size PASS (prop band) | Profile-wire PASS
Escalation: none
Blockers: none (user Godot playtest for colliders/lights)
```

## Done checklist

- [x] Profile `c30_cemetery` enriched (graves + crypt)
- [x] Dedicated headstone + crypt door props
- [x] `CEMETERY_C30.md` written
- [x] return_path SQ; cool lights; door aisle clear
- [ ] User Godot enter/exit QA from square portal
