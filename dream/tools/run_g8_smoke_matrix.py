#!/usr/bin/env python3
"""Headless smoke matrix for G8 evidence — writes markdown report."""
from __future__ import annotations

import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "docs" / "GOAL_G8_SMOKE_EVIDENCE.md"
INTERACT_REPORT = ROOT / "docs" / "GOAL_G8_INTERACT_ACTIVATE_EVIDENCE.md"
INTERIOR_FX_REPORT = ROOT / "docs" / "GOAL_G8_INTERIOR_OPEN_FX_EVIDENCE.md"
PORTAL_REPORT = ROOT / "docs" / "GOAL_G8_PORTAL_CUE_EVIDENCE.md"

AREA_SCENES = sorted(
	f"res://scenes/areas/{p.name}/{p.name}.tscn"
	for p in (ROOT / "scenes/areas").iterdir()
	if p.is_dir() and (p / f"{p.name}.tscn").exists()
)
INTERIOR_SCENES = sorted(
	f"res://scenes/interiors/{p.name}/{p.name}.tscn"
	for p in (ROOT / "scenes/interiors").iterdir()
	if p.is_dir() and (p / f"{p.name}.tscn").exists()
)
HUB_SCENES = sorted(
	f"res://scenes/hub/{p.stem}.tscn"
	for p in (ROOT / "scenes/hub").glob("*.tscn")
)
# Full outdoor shell + all interiors + hubs.
SCENES = AREA_SCENES + INTERIOR_SCENES + HUB_SCENES


def find_godot() -> str:
	# Prefer running process path (Windows).
	try:
		ps = subprocess.run(
			[
				"powershell",
				"-NoProfile",
				"-Command",
				"Get-Process | Where-Object { $_.ProcessName -match 'Godot' } | Select-Object -First 1 -ExpandProperty Path",
			],
			capture_output=True,
			text=True,
			check=False,
		)
		path = (ps.stdout or "").strip()
		if path and Path(path).exists():
			return path
	except OSError:
		pass
	env = Path(os.environ.get("GODOT", "") or os.environ.get("GODOT_PATH", ""))
	if env and env.exists():
		return str(env)
	raise SystemExit("Godot process not found — open the editor once, then re-run.")


def smoke(godot: str, scene: str) -> tuple[int, int]:
	log = Path(f"{Path.home()}/AppData/Local/Temp/dream_smoke_{scene.split('/')[-1]}.log")
	err = log.with_suffix(".err")
	proc = subprocess.run(
		[godot, "--path", str(ROOT), "--headless", "--quit-after", "2", scene],
		capture_output=True,
		timeout=90,
		check=False,
	)
	out = (proc.stdout or b"").decode("utf-8", errors="replace") + "\n" + (proc.stderr or b"").decode(
		"utf-8", errors="replace"
	)
	log.write_text(out, encoding="utf-8", errors="replace")
	err.write_text((proc.stderr or b"").decode("utf-8", errors="replace"), encoding="utf-8", errors="replace")
	errors = sum(1 for line in out.splitlines() if "ERROR:" in line)
	scripts = sum(
		1
		for line in out.splitlines()
		if "SCRIPT ERROR" in line or "Parse Error" in line
	)
	return errors, scripts


def _run_script_smoke(godot: str, script: str, tag: str, report: Path) -> bool:
	proc = subprocess.run(
		[godot, "--path", str(ROOT), "--headless", "-s", script],
		capture_output=True,
		timeout=120,
		check=False,
	)
	out = (proc.stdout or b"").decode("utf-8", errors="replace") + "\n" + (proc.stderr or b"").decode(
		"utf-8", errors="replace"
	)
	(Path.home() / "AppData/Local/Temp" / f"dream_{tag}.log").write_text(out, encoding="utf-8", errors="replace")
	pass_token = f"{tag}: PASS"
	ok = pass_token in out and proc.returncode == 0
	lines = [
		f"# Goal evidence — {tag}",
		"",
		f"**Runner:** `{script}`",
		f"**Result:** {'PASS' if ok else 'FAIL'} (exit={proc.returncode})",
		"",
		"## Log excerpt",
		"",
		"```",
	]
	for line in out.splitlines():
		if tag in line or "SCRIPT ERROR" in line or "ERROR:" in line:
			lines.append(line)
	lines.extend(["```", "", "User Godot QA still required for visual fidelity.", ""])
	report.write_text("\n".join(lines), encoding="utf-8")
	print("wrote", report.relative_to(ROOT), "PASS" if ok else "FAIL")
	return ok


def smoke_interact_activate(godot: str) -> tuple[bool, str]:
	ok = _run_script_smoke(
		godot,
		"res://tools/g8_interact_activate_smoke.gd",
		"G8_INTERACT_SMOKE",
		INTERACT_REPORT,
	)
	return ok, ""


def smoke_interior_open_fx(godot: str) -> bool:
	return _run_script_smoke(
		godot,
		"res://tools/g8_interior_open_fx_smoke.gd",
		"G8_INTERIOR_FX",
		INTERIOR_FX_REPORT,
	)


def smoke_portal_cues(godot: str) -> bool:
	return _run_script_smoke(
		godot,
		"res://tools/g8_portal_cue_smoke.gd",
		"G8_PORTAL_CUE",
		PORTAL_REPORT,
	)


def smoke_worldsys_activate(godot: str) -> bool:
	return _run_script_smoke(
		godot,
		"res://tools/g8_worldsys_activate_smoke.gd",
		"G8_WORLDSYS",
		ROOT / "docs" / "GOAL_G8_WORLDSYS_ACTIVATE_EVIDENCE.md",
	)


def smoke_anim_fx(godot: str) -> bool:
	return _run_script_smoke(
		godot,
		"res://tools/g8_anim_fx_smoke.gd",
		"G8_ANIM_FX",
		ROOT / "docs" / "GOAL_G8_ANIM_FX_EVIDENCE.md",
	)


def smoke_bath_portal(godot: str) -> bool:
	return _run_script_smoke(
		godot,
		"res://tools/g8_bath_portal_smoke.gd",
		"G8_BATH_PORTAL",
		ROOT / "docs" / "GOAL_G8_BATH_PORTAL_EVIDENCE.md",
	)


def smoke_c62_secret(godot: str) -> bool:
	return _run_script_smoke(
		godot,
		"res://tools/g8_c62_secret_smoke.gd",
		"G8_C62",
		ROOT / "docs" / "GOAL_G8_C62_SECRET_EVIDENCE.md",
	)


def smoke_interact_target(godot: str) -> bool:
	return _run_script_smoke(
		godot,
		"res://tools/g8_interact_target_smoke.gd",
		"G8_TARGET",
		ROOT / "docs" / "GOAL_G8_INTERACT_TARGET_EVIDENCE.md",
	)


def main() -> int:
	godot = find_godot()
	print(
		f"scenes={len(SCENES)} (areas={len(AREA_SCENES)} interiors={len(INTERIOR_SCENES)} hubs={len(HUB_SCENES)})"
	)
	rows: list[tuple[str, int, int, str]] = []
	for scene in SCENES:
		sid = scene.rsplit("/", 1)[-1].replace(".tscn", "")
		try:
			e, s = smoke(godot, scene)
			status = "PASS" if e == 0 and s == 0 else "FAIL"
		except Exception as exc:  # noqa: BLE001
			e, s, status = -1, -1, f"FAIL ({exc})"
		rows.append((sid, e, s, status))
		print(f"{sid}: ERRORS={e} SCRIPT={s} {status}")
		time.sleep(0.12)

	passed = sum(1 for *_, st in rows if st == "PASS")
	interact_ok, _ = smoke_interact_activate(godot)
	interior_ok = smoke_interior_open_fx(godot)
	portal_ok = smoke_portal_cues(godot)
	worldsys_ok = smoke_worldsys_activate(godot)
	anim_ok = smoke_anim_fx(godot)
	bath_ok = smoke_bath_portal(godot)
	c62_ok = smoke_c62_secret(godot)
	target_ok = smoke_interact_target(godot)
	lines = [
		"# Goal G8 smoke evidence",
		"",
		f"**Date:** auto-generated by `tools/run_g8_smoke_matrix.py`",
		f"**Result:** {passed}/{len(rows)} scenes PASS (ERROR=0, SCRIPT=0)",
		f"**Interact activate:** {'PASS' if interact_ok else 'FAIL'} — `GOAL_G8_INTERACT_ACTIVATE_EVIDENCE.md`",
		f"**Interior open FX:** {'PASS' if interior_ok else 'FAIL'} — `GOAL_G8_INTERIOR_OPEN_FX_EVIDENCE.md`",
		f"**Portal cues:** {'PASS' if portal_ok else 'FAIL'} — `GOAL_G8_PORTAL_CUE_EVIDENCE.md`",
		f"**Worldsys activate:** {'PASS' if worldsys_ok else 'FAIL'} — `GOAL_G8_WORLDSYS_ACTIVATE_EVIDENCE.md`",
		f"**Anim FX (pose+leaf):** {'PASS' if anim_ok else 'FAIL'} — `GOAL_G8_ANIM_FX_EVIDENCE.md`",
		f"**Bath portal enter:** {'PASS' if bath_ok else 'FAIL'} — `GOAL_G8_BATH_PORTAL_EVIDENCE.md`",
		f"**C62 secret chain:** {'PASS' if c62_ok else 'FAIL'} — `GOAL_G8_C62_SECRET_EVIDENCE.md`",
		f"**Interact target sync:** {'PASS' if target_ok else 'FAIL'} — `GOAL_G8_INTERACT_TARGET_EVIDENCE.md`",
		"",
		"| Scene | ERRORS | SCRIPT | Status |",
		"| --- | ---: | ---: | --- |",
	]
	for sid, e, s, st in rows:
		lines.append(f"| `{sid}` | {e} | {s} | {st} |")
	lines.extend(
		[
			"",
			"## Notes",
			"",
			"- Headless `--quit-after 2` load smoke (not full playthrough).",
			"- Interact-activate fires C58 `activated` on square kit.",
			"- Worldsys-activate covers C58+C59+C60 (15 activations).",
			"- Anim-FX asserts WorkPoseAnim ≥4 frames + shake_tree leaf_fall FX.",
			"- Bath portal smoke asserts facade_bath cues + SceneRouter enter C43.",
			"- C62 secret smoke walks forest→cave→waterfall→lake with Sprite2D façades.",
			"- Interact-target smoke asserts hover/click share one executable hotspot.",
			"- Interior open-FX activates C01 open_fx hotspots.",
			"- Portal cue smoke asserts DoorFacade / doorstep sprites on square portals.",
			"- User local Godot QA still required for click/animation fidelity.",
			"- tomyud1 MCP screenshot path optional when server is up.",
			"",
		]
	)
	REPORT.write_text("\n".join(lines), encoding="utf-8")
	print("wrote", REPORT.relative_to(ROOT))
	ok = (
		passed == len(rows)
		and interact_ok
		and interior_ok
		and portal_ok
		and worldsys_ok
		and anim_ok
		and bath_ok
		and c62_ok
		and target_ok
	)
	return 0 if ok else 1


if __name__ == "__main__":
	sys.exit(main())
