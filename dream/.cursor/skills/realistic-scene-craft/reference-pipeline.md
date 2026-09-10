# Asset pipeline — 先画什么再画什么

## Spec lock (before pixels)

- `BASE_TILE = 32` (`docs/SCALE.md`)
- Character ~48–64 px; cottages 3–5 tiles tall
- One light direction; one door **facing** for the building set
- Nearest import; no mip on tile atlases

## Paint stack (per sprite / tile)

1. Silhouette  
2. Value  
3. Color / local hue  
4. Detail / edge pixels  

## Terrain atlas order

1. **Filler** wrap tile (`L==R`, `T==B`) — grass / dirt / sand / stone centers  
2. Edge strips  
3. Outer corners  
4. Inner corners (do not skip)  
5. Biome blends (dry↔damp, grass↔dirt)  
6. Water fill variants  
7. Foam / shore accents  
8. Probability variants of the same peering  

Rebuild Dream grass: `python dream/tools/make_seamless_terrain.py`

## Buildings

- Modules: wall base (collision) → door → roof (Y-sort / front)  
- All doors share facing; layout places lots so doors face plaza/paths  
- Leave door apron clear of trees  

## Props / trees

- Pivot at **feet**  
- Footprint validation against water/path masks  
- Bank willows: flip_h variety OK; do not invent north-facing without art  

## After tiling checklist

- [ ] No vignette pad borders on fill tiles  
- [ ] Atlas padding / extrude if filtered  
- [ ] Screenshot at integer zoom — no hairline grid  
- [ ] Water FX only on water mask  

## Sources

- `docs/research/practitioners/artists-tile-pipeline.md`
- ConcernedApe: first tile was dirt — https://mentalnerd.com/blog/getting-started-pixel-art-interview/
