# Spiritfarer — scene CRAFT research

**Focus:** realism-of-layout (how rooms/buildings face walkways, water edges, movement), not genre tropes.  
**Studio:** Thunder Lotus Games (Unity).  
**Use for Dream:** boat/island-like hubs, walkway-facing buildings, hand-authored water edges, NPC path targets, art pipeline separation.

---

## Techniques

### Boat as a living platform city (not a flat lot)

- The ship is a **square-grid construction space**: buildings occupy cells, can **stack vertically**, and expand when the player buys capacity upgrades (Albert’s Shipyard). Layout is temporary — salvage returns materials; homes can be moved freely ([Wikipedia:Spiritfarer](https://en.wikipedia.org/wiki/Spiritfarer); [TheGamer layout tips](https://www.thegamer.com/spiritfarer-best-boat-layouts-tips/)).
- **Circulation is the architecture.** Roofs, gutters, ladders, beams, and terraces are the walkways. Players treat flat roofs as continuous runways for event platforming (comets / jellyfish / lightning), and leave intentional gaps as through-paths rather than Tetris-filling every hole ([DualShockers ship layouts](https://www.dualshockers.com/spiritfarer-best-ship-layouts/); [TheGamer](https://www.thegamer.com/spiritfarer-best-boat-layouts-tips/)).
- **Editor physics are intentionally fake for placement, real for feel:** no structural integrity / gravity constraints; ladders/beams auto-anchor to deck; obstructed ladders adapt. That frees eccentric silhouettes while still reading as a coherent vessel ([TheGamer](https://www.thegamer.com/spiritfarer-best-boat-layouts-tips/)).
- **Functional zoning that mirrors real harbors / campus layouts:**
  - High-frequency rooms (kitchen, gardens/fields) near Stella’s cabin / amidships — short daily loops.
  - Production cluster (foundry, sawmill, loom) as a work district.
  - Guest rooms clustered as a residential strip; empty homes move to “attic” after farewell.
  - Tall stacks prefer port / away from the starboard navigation cabin so sightlines stay clear ([Switchblade ship guide](https://www.switchbladegaming.com/cozy-games/spiritfarer-ship-guide/); [DualShockers](https://www.dualshockers.com/spiritfarer-best-ship-layouts/)).
- **Buildings have quirky footprints** (e.g. Bruce & Mickey’s mansion). Symmetry is discouraged; awkward shapes create negative space that *becomes* corridor ([TheGamer](https://www.thegamer.com/spiritfarer-best-boat-layouts-tips/)).

### Islands: pier threshold → climbable architecture

- Arrival is almost always a **small pier / dinghy dock**, then a short horizontal approach into buildings that double as platforms (roofs, gutters, ledges). Tutorial islands teach jump → roof → gutter grab before dialogue ([Neoseeker First Steps](https://www.neoseeker.com/spiritfarer/walkthrough/First_Steps)).
- Islands are **hand-authored side-scroll strips**, not procedural continents. Facades face the playable walk line the way a waterfront street faces the quay: readable silhouettes, climbable eaves, interactive doors on the walkable plane.
- World geography is **memory-mapped place design**: Guérin describes islands as Stella’s mind — early spiritual / lived places (Northern France, Japan), mid map more urban (Montreal-like), late map darker forest/ocean tied to illness memory (GameSpot interview summarized in [Wikipedia Development](https://en.wikipedia.org/wiki/Spiritfarer)). Layout mood shifts with journey, not with random biomes.

### Water edges & open sea

- **Nature reads “real memory,” magic reads supernatural.** Animators state water, fog, rain, wind, sunrise/sunset should feel dreamy-nostalgic and based on remembered real places; the boat/spirits can be fantastical ([Toon Boom × Thunder Lotus](https://www.toonboom.com/thunder-lotus-games-on-animating-the-afterlife-in-spiritfarer)).
- **Vastness problem (side-scroller, camera zoomed on characters):** they do *not* solve it with a pull-back camera. They solve it with **lighting ambiances, time-of-day, per-place mood, and weather events** so the sea still feels large while the playable strip stays intimate ([Toon Boom](https://www.toonboom.com/thunder-lotus-games-on-animating-the-afterlife-in-spiritfarer)).
- **Landmark water composition:** the Everdoor went through many iterations and landed as a **half-circle bridge reflecting on water** — symbolic, calm, neither scary nor whimsical; Art Director Jo Gauthier referenced historical mystical bridges ([Game Developer / Guerin](https://www.gamedeveloper.com/design/inside-the-thoughtful-design-of-thunder-lotus-i-spiritfarer-i-)). Water edge here is a **composed mirror plane**, not a generic shoreline tile strip.
- Player-facing craft implication: water edges should look **authored** (cove, pier cut, bridge reflection, foam break) even if under the hood a shader animates the surface.

### Character & spirit movement

- Stella ≈ **100 animations**; ~25 for core platforming + transitions; rest mini-games / dialogue / moments. Spirits share a base set (walk, eat, sleep, hug, interact) but get **individual motion personality** ([Toon Boom](https://www.toonboom.com/thunder-lotus-games-on-animating-the-afterlife-in-spiritfarer)).
- 2D sprite animation has **no 3D-style procedural blend** — they author transition clips where clip changes would jar ([Toon Boom](https://www.toonboom.com/thunder-lotus-games-on-animating-the-afterlife-in-spiritfarer)).
- Ship traversal abilities (double jump, hat glide, dash, air vents, ziplines) make **vertical districts** viable; sparse ability props (one long zipline + one vent) beat filling the grid with mobility gadgets ([TheGamer](https://www.thegamer.com/spiritfarer-best-boat-layouts-tips/)).
- **NPC path craft (first-party):** Thunder Lotus reply — *“Generally we tried to avoid putting npc targets near actionable items.”* Misaligned stacked ladders (orchard over field/garden) caused spirits stuck in door loops and failed vertical jumps; edit toggle reset AI ([Steam bug thread, Dev ClockworkXI](https://steamcommunity.com/app/972660/discussions/8/3112530528196022178/)). Island pathfinding can also fail (Daffodil / pine trees) — design for fallbacks, not perfect graph coverage.

---

## Math / procedural

| System | What is procedural / systemic | What stays hand-authored |
|--------|-------------------------------|---------------------------|
| Ship hull capacity | Upgrade expands available grid | Silhouette of boat, cabin, wheel placement |
| Building placement | Player grid + rotation + stack | Per-building footprint art, door/ladder attach |
| Structural support | Auto ladders/beams/terraces (no integrity sim) | Visual deck / rail continuity |
| Day–night / weather | Engine lighting ambiances + meteo events | Painted BG plates per island mood |
| Water surface | Engine/shader motion (implied by tech-art lighting work; no public Spiritfarer shader dump) | Shore cutouts, pier docks, Everdoor reflection compose |
| Islands | None as primary generator | Full side-scroll layouts, props, climb routes |
| NPC schedules | Target points + pathfinding on built topology | Target placement away from interactables; ladder alignment |

**Anti-procedural lesson for Dream:** do not generate “random cozy docks.” Generate (or paint) **pier → walk line → door plane**, then let systemic pathfinding ride that topology. Ship stacking proves vertical graphs need **aligned connectors** or agents break.

**Useful abstract rules (layout math, not Spiritfarer code):**

1. **Door–walkway facing:** interactive façade normal ≈ walkable axis (quay / plaza / deck corridor).
2. **Negative space budget:** leave 15–30% of buildable cells empty as corridors / jump wells (player community practice; matches TheGamer “don’t plug every hole”).
3. **Frequency × distance:** place high-visit nodes near spawn / cabin; low-visit on periphery or upper stacks.
4. **Roof continuity:** adjacent flat tops form a second walkable graph for chase/event locomotion.
5. **Water edge length:** prefer irregular pier notches and cove radii over long straight canals (aligns with Dream `LAYOUT.md` meander rule; Spiritfarer islands visually favor docks and cut banks).

---

## Asset pipeline

Primary pipeline confirmed by Thunder Lotus staff interviews:

1. **Characters / spirits:** Toon Boom Harmony — mix of **frame-by-frame + cut-out**; export frames → pack into large spritesheets (custom exporter evolved from older TK2D workflow); also export **z-depth layer order** and **attach-point motion** into Unity ([Toon Boom](https://www.toonboom.com/thunder-lotus-games-on-animating-the-afterlife-in-spiritfarer)).
2. **Backgrounds / ship / scenery:** Adobe Photoshop plates ([Game Developer](https://www.gamedeveloper.com/design/inside-the-thoughtful-design-of-thunder-lotus-i-spiritfarer-i-)).
3. **Engine:** Unity. First dedicated technical artist **David Bergamin** owned **dynamic lighting ambiances** in-engine — critical for water vastness and place mood without losing the hand-drawn look ([Toon Boom](https://www.toonboom.com/thunder-lotus-games-on-animating-the-afterlife-in-spiritfarer); [Thunder Lotus hire note](https://thunderlotusgames.com/blog/say-hello-david-newest-recruit/)).
4. **Art direction:** Jo Gauthier — simple, soothing, melancholic-nostalgic balance ([Toon Boom](https://www.toonboom.com/thunder-lotus-games-on-animating-the-afterlife-in-spiritfarer)).
5. **Trailer / marketing animation:** Knights of the Light Table also used Harmony (separate from in-game pipeline) ([Toon Boom trailer interview](https://www.toonboom.com/spiritfarer-animated-trailer)).

**Secondary write-ups** (e.g. foro3d pipeline articles) claim ~12 fps character cadence, watercolor-sim Photoshop brushes, and character shaders that ignore ambient so sprites stay “cel-correct” under global BG gradients. Treat those as **unverified secondary** unless/until a first-party talk confirms them; the Toon Boom + Guerin interviews alone already justify: **separate character vs environment pipelines + engine lighting over painted plates**.

**Dream-relevant split:**

| Layer | Authoring | Runtime |
|-------|-----------|---------|
| Ground / water mask / docks | Hand layout / mask (meander, pier) | Tile/shader motion only on surface |
| Buildings | Door-facing sheets + footprints | Placement rules, not random rotate |
| Characters | High-expressivity clips + transitions | Path targets off interactables |
| Mood | Painted or graded plates | Day cycle / weather overlays |

---

## Agent rules

Use when generating or reviewing Dream boat/island/village scenes inspired by this research.

### Do

1. **Face doors / entries toward the primary walkway** (plaza, quay, deck corridor). South-facing art → place lots so doors read toward the path (see project `LAYOUT.md`).
2. **Author water edges:** pier notches, cove bends, bridge reflections; animate surface separately from the silhouette.
3. **Treat roofs and decks as second-story paths** when vertical play exists; align ladders/stairs so agents can climb.
4. **Zone by visit frequency:** kitchen/garden-class nodes near hub; storage/rare craft farther; residential clusters together.
5. **Leave intentional negative space** as corridors; do not pack every cell.
6. **Place NPC idle/path targets beside interactables**, never on door tiles / bellows / watering spots.
7. **Keep character art pipeline independent of environment lighting plates** when possible (tint/grade BG; preserve readable sprite colors).
8. **Solve “big water” with mood/lighting/weather**, not only camera zoom.

### Do not (anti-lazy)

- Do not paint **ruler-straight canals** as “ocean/river.”
- Do not rotate buildings for fill without matching **door → path** orientation.
- Do not stack vertical rooms with **misaligned connectors** and expect NPC pathfinding to heal it.
- Do not put spirit/NPC stand points on **actionable hotspots**.
- Do not fill every grid hole for “neatness”; holes are walkways.
- Do not rely on procedural island noise as a substitute for a **pier → climb → door** composition.
- Do not make water “feel large” only by tiling a flat blue quad with no edge craft.
- Do not skip authored **transition anims** if movement state changes are harsh (2D clip reality).

---

## Sources

### Primary / first-party

1. [Thunder Lotus Games on animating the afterlife in Spiritfarer](https://www.toonboom.com/thunder-lotus-games-on-animating-the-afterlife-in-spiritfarer) — Simon Nakauchi Pelletier & Alexandre Boyer; Harmony→Unity, nature vs supernatural, lighting/water vastness, anim counts, transitions.
2. [Inside the thoughtful design of Thunder Lotus' Spiritfarer](https://www.gamedeveloper.com/design/inside-the-thoughtful-design-of-thunder-lotus-i-spiritfarer-i-) — Nicolas Guérin; Unity + Photoshop + Toon Boom; Everdoor half-circle bridge on water (Jo Gauthier).
3. [Steam: Characters in front of actionable objects](https://steamcommunity.com/app/972660/discussions/8/3112530528196022178/) — Dev ClockworkXI on NPC targets vs interactables; player reports on ladder misalignment / stuck AI.
4. [Say hello to David Bergamin](https://thunderlotusgames.com/blog/say-hello-david-newest-recruit/) — Thunder Lotus technical artist hire.
5. [Spiritfarer (Wikipedia)](https://en.wikipedia.org/wiki/Spiritfarer) — square-grid ship stacking; development notes citing GameSpot (train→ship, geography-as-memory, farming scope cut).

### Strong secondary (player / guide craft observation)

6. [Spiritfarer Best Boat Layouts Tips — TheGamer](https://www.thegamer.com/spiritfarer-best-boat-layouts-tips/) — editor rules, gaps-as-paths, zoning, mobility props.
7. [Spiritfarer: 7 Best Ship Layout Ideas — DualShockers](https://www.dualshockers.com/spiritfarer-best-ship-layouts/) — roof runways for events; functional clusters.
8. [Spiritfarer Ship Building Guide — Switchblade](https://www.switchbladegaming.com/cozy-games/spiritfarer-ship-guide/) — grid placement, nav cabin clearance, kitchen/garden zoning.
9. [First Steps walkthrough — Neoseeker](https://www.neoseeker.com/spiritfarer/walkthrough/First_Steps) — pier → roof → gutter platforming island pattern.

### Related (pipeline adjacent, not ship layout)

10. [Knights of the Light Table / Spiritfarer trailer](https://www.toonboom.com/spiritfarer-animated-trailer) — Harmony marketing animation workflow.

### Confidence notes

- **High:** dual pipelines (Harmony / Photoshop / Unity), lighting for water scale, Everdoor water composition, grid ship + stack, NPC targets off interactables.
- **Medium:** community layout zoning heuristics (efficient but emergent from systems, not a published Thunder Lotus level-design bible).
- **Low / unverified:** exact water shader math, claimed 12 fps cadence, character shaders that fully ignore ambient (secondary blogs only).

---

*Research captured for Dream scene CRAFT. Cross-ref: `dream/docs/LAYOUT.md`, `dream/docs/SEAMLESS.md`.*
