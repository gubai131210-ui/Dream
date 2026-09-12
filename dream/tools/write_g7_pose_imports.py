#!/usr/bin/env python3
"""Write .import sidecars for drawer / work poses / gate_log."""
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def write_import(png: Path, template: Path) -> None:
	params = template.read_text(encoding="utf-8").split("[params]")[1]
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
	interior_tpl = ROOT / "assets/sprites/interior/props/dresser_00.png.import"
	prop_tpl = ROOT / "assets/sprites/props/bench_0.png.import"
	for i in range(4):
		write_import(ROOT / f"assets/sprites/interior/props/drawer_open_{i:02d}.png", interior_tpl)
	write_import(ROOT / "assets/sprites/props/gate_log_00.png", prop_tpl)
	for job in ("sow", "smith", "stall", "cook"):
		for i in range(4):
			write_import(
				ROOT / f"assets/sprites/npc/work_poses/{job}/pose_{i:02d}.png",
				prop_tpl,
			)


if __name__ == "__main__":
	main()
