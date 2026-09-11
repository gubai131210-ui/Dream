---
name: interior-territory-craft
description: >-
  Makes Dream interiors feel spatially real via enclosure boundaries and storage
  mass — stall rails, chicken pens, grain/hay stacks, cargo piles — on top of
  functional clusters. Use when interiors feel "scientifically weird", empty,
  or like props floating in a room; when editing barn/coop/farmer mudroom/
  merchant cargo; when adding rails/enclosures; or when the user mentions 围栏,
  畜栏, 鸡圈, 粮垛, 体量, 领地, INTERIOR_TERRITORY, or interior territory grammar.
---

# Interior territory craft (Dream)

Operate on **readable territory**, not prop count. Primary lock: `docs/INTERIOR_TERRITORY.md`. Clusters first: `docs/INTERIOR_COMPOSITION.md`. Room silhouettes: `docs/INTERIOR_ROOM_BRIEFS.md`.

## Leading words

- **cluster** — one activity blob (already required)
- **boundary** — rails / pen ring that makes a zone *owned*
- **mass** — vertical or repeated stacks that read as inventory volume
- **gap** — intentional opening in an enclosure aligned to door aisle
- **aisle** — clear circulation; never block south door with fences or stacks

## When this skill runs

```
Territory checklist:
- [ ] 1. Re-read INTERIOR_TERRITORY + room brief for this profile
- [ ] 2. Name the zone that must be legible (stall / pen / grain / cargo)
- [ ] 3. Add boundary (rails or enclosure+gaps) before adding more loose props
- [ ] 4. Add mass (grain_stack / hay_stack / crate offsets) where inventory should read tall
- [ ] 5. Keep ambient animals inside the enclosed zone
- [ ] 6. Keep south door → aisle clear (gaps / no stack in door tiles)
- [ ] 7. Update INTERIOR_TERRITORY / ROOM_BRIEFS if new grammar shipped
- [ ] 8. User Godot QA: zone readable at a glance without InfoPanel
```

**Done when:** a stranger can name the room type from silhouette (barn aisle+rails, coop pen, grain mass) without clicking.

## Hard rules

1. **区界 → 体量 → 数量.** Never scatter-fill to fake density.
2. Barn stalls need **aisle-facing rails**, not hay alone.
3. Coop needs a **pen enclosure** with south `gaps` + **4 corner sprites**; chickens spawn inside.
4. Storage needs **height or repetition**.
5. Doors enter **real scenes**; InfoPanel does not replace territory grammar.
6. **Scene-fit variants:** same function ≠ same product. Coop/barn use `lamp_farm_00`, never household `lamp_indoor_00`. Draw new variants when missing.
7. Fence H/V/corners = one board family; overwrite old `*_v` when style changes.
8. Always re-cover fence PNGs when changing style so Godot does not mix old V with new H.

## Schema (craft)

```text
rails: [{axis, tx|ty, a0, a1, step?:1, prop, scale?:1, ...}]
enclosures: [{
  rect:[x0,y0,x1,y1], prop_h, prop_v,
  corners:{nw,ne,sw,se}, gaps:[[tx,ty],...], scale?:1
}]
```

## 禁止偷懒

- 禁止语义暗示代替隔栏  
- 禁止无围栏鸡圈 / 小笔四周空地  
- 禁止正视侧视两套设计 / 旧 V 残留  
- 禁止无四角拐角硬拼 / 对角斜条糊弄转角  
- 禁止家用台灯进鸡舍谷仓  
- 禁止功能同类就跨场景复用同一 PNG  
- 禁止只写 MD 不改 profile/craft  

## Related skills

- `.cursor/skills/realistic-scene-craft/` — outdoor farm fences / build zones  
- `.cursor/skills/painting-asset-craft/` — new pixel props if procedural gen is insufficient  
