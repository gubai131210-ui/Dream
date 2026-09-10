# Painting references (Dream)

Companion to `SKILL.md`. Deep cites live in research notes.

## Spec tables

See skill body for size + frame matrices.  
Project lock: [`docs/SCALE.md`](../../../docs/SCALE.md).

## Draw-order (terrain)

Mirrored from `realistic-scene-craft/reference-pipeline.md` — when painting, that order is mandatory.

## Inpaint recipe (missing prop on a busy sheet)

1. Copy sheet → work file.  
2. Mask only the missing/broken island (keep 2–4 px dilate).  
3. Inpaint with surrounding style reference (same sheet crop as ControlNet/ref).  
4. rembg if you need a clean RGBA stamp.  
5. Scale to prop band; place with feet pivot.

## Camera change checklist

- [ ] New vanishing / wall visibility documented  
- [ ] Old sheets quarantined (do not mix in one scene)  
- [ ] Door facing rewritten in `AREA_FRAMEWORK` / layout if axis flips  
- [ ] Character dirs regenerated for new ground diamond  

## Sources

- [`docs/research/practitioners/sprite-painting-specs.md`](../../../docs/research/practitioners/sprite-painting-specs.md)  
- [`docs/research/practitioners/artists-tile-pipeline.md`](../../../docs/research/practitioners/artists-tile-pipeline.md)  
- [`docs/research/practitioners/agent-art-tooling.md`](../../../docs/research/practitioners/agent-art-tooling.md)  
- Aseprite CLI: https://www.aseprite.org/docs/cli/  
- Godot importing images: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html  
