#!/usr/bin/env python3
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
files = (
	list((ROOT / "assets/sprites/fx").glob("leaf_fall_*.png"))
	+ list((ROOT / "assets/sprites/fx").glob("bird_peck_*.png"))
	+ list((ROOT / "assets/sprites/props").glob("well_rope_*.png"))
	+ list((ROOT / "assets/sprites/props").glob("crate_lid_*.png"))
)
template_params = (ROOT / "assets/sprites/props/bench_0.png.import").read_text(encoding="utf-8").split("[params]")[1]
for png in files:
	rel = "res://" + png.relative_to(ROOT).as_posix()
	h = hashlib.md5(rel.encode()).hexdigest()
	uid = "uid://" + hashlib.md5(png.name.encode()).hexdigest()[:13]
	ctex = f"res://.godot/imported/{png.name}-{h}.ctex"
	content = (
		"[remap]\n\n"
		'importer="texture"\n'
		'type="CompressedTexture2D"\n'
		f'uid="{uid}"\n'
		f'path="{ctex}"\n'
		"metadata={\n"
		'"vram_texture": false\n'
		"}\n\n"
		"[deps]\n\n"
		f'source_file="{rel}"\n'
		f'dest_files=["{ctex}"]\n\n'
		"[params]\n"
		+ template_params
	)
	(png.parent / f"{png.name}.import").write_text(content, encoding="utf-8", newline="\n")
	print("import", png.name)
print("count", len(files))
