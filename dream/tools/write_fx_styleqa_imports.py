#!/usr/bin/env python3
"""Write .import sidecars for fishing/fx PNGs used by StyleQA batch."""
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def write_import(png: Path, template_import: Path) -> None:
	params = template_import.read_text(encoding="utf-8").split("[params]")[1]
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
		+ params
	)
	(png.parent / f"{png.name}.import").write_text(content, encoding="utf-8", newline="\n")
	print("import", png.relative_to(ROOT))


def main() -> None:
	fx_tpl = ROOT / "assets/sprites/fx/leaf_fall_00.png.import"
	for name in (
		"fish_bubble_00",
		"fish_splash_00",
		"fish_ring_00",
		"window_light_shaft_00",
		"leaf_fall_00",
		"leaf_fall_01",
		"leaf_fall_02",
		"leaf_fall_03",
		"bird_peck_00",
		"bird_peck_01",
		"bird_peck_02",
		"bird_peck_03",
	):
		png = ROOT / "assets/sprites/fx" / f"{name}.png"
		if png.exists():
			write_import(png, fx_tpl)


if __name__ == "__main__":
	main()
