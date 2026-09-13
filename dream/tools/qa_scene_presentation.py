"""Regression checks for character contact stability and interior camera framing."""

from pathlib import Path

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
NPC_ROOT = ROOT / "assets" / "sprites" / "npc"


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def main() -> None:
    # Walk frames must be fixed-canvas assets. Runtime normalization is a safety
    # net, not a substitute for authoring stable source frames.
    frame_failures = []
    for character in ("farmer", "player", "merchant", "elder_woman", "blacksmith", "station_master"):
        expected_count = 8 if character in ("farmer", "player") else 4
        for direction in ("down", "left", "right", "up"):
            frames = sorted((NPC_ROOT / character).glob(f"walk_{direction}_*.png"))
            sizes = {Image.open(path).size for path in frames}
            if len(frames) != expected_count or len(sizes) != 1:
                frame_failures.append((character, direction, len(frames), sorted(sizes)))
                continue
            loaded = [Image.open(path).convert("RGBA") for path in frames]
            # A valid walk cycle must contain authored motion, not four idle
            # copies with a different filename. Compare actual pixels and keep
            # the threshold high enough to reject a one-pixel noise change.
            changes = []
            for index, current in enumerate(loaded):
                nxt = loaded[(index + 1) % len(loaded)]
                diff = ImageChops.difference(current, nxt)
                pixels = diff.load()
                changed = sum(
                    1
                    for y in range(diff.height)
                    for x in range(diff.width)
                    if pixels[x, y] != (0, 0, 0, 0)
                )
                changes.append(changed)
            if min(changes) < 120:
                frame_failures.append((character, direction, "low_motion", changes))
            # The visual content must touch the same contact line even when
            # the silhouette changes pose.
            bottoms = []
            centers = []
            for frame in loaded:
                used = frame.getchannel("A").getbbox()
                if used is None:
                    bottoms.append(-1)
                    centers.append(999)
                    continue
                bottoms.append(used[3])
                centers.append(abs((used[0] + used[2]) * 0.5 - frame.width * 0.5))
            if len(set(bottoms)) != 1 or max(centers) > 5.0:
                frame_failures.append((character, direction, "unstable_contact", bottoms, centers))
    if frame_failures:
        raise AssertionError(f"variable NPC frame canvases: {frame_failures}")

    patrol = read("scripts/actors/patrol_actor.gd")
    if "_anim.offset = Vector2(0, -28)" in patrol:
        raise AssertionError("PatrolActor still uses a hard-coded sprite offset")
    if "FOOT_CONTACT_Y" not in patrol or "NpcWalkFrames.foot_offset" not in patrol:
        raise AssertionError("PatrolActor has no explicit normalized foot anchor")
    frames_util = read("scripts/actors/npc_walk_frames.gd")
    if "canvas_h" not in frames_util or "foot_offset" not in frames_util:
        raise AssertionError("NpcWalkFrames missing normalized foot anchor")

    interior = read("scripts/interiors/interior_room_controller.gd")
    if "camera.position = Vector2(640, 480)" in interior:
        raise AssertionError("interior camera is still fixed to the viewport center")
    for needle in ("room_center", "fit_zoom", "camera.zoom"):
        if needle not in interior:
            raise AssertionError(f"interior camera fit missing {needle}")

    camera = read("scripts/core/camera_controller.gd")
    for needle in ("set_follow_target", "follow_enabled", "follow_smoothing"):
        if needle not in camera:
            raise AssertionError(f"camera follow missing {needle}")

    project = read("project.godot")
    if "PlayerBootstrap" not in project:
        raise AssertionError("PlayerBootstrap autoload missing from project.godot")

    player = read("scripts/actors/player_actor.gd")
    if "NpcWalkFrames.build" not in player or '"player"' not in player:
        raise AssertionError("PlayerActor missing NpcWalkFrames player pack wiring")

    print("GREEN scene-presentation QA (NPC canvases, player pack, camera follow, interior fit)")


if __name__ == "__main__":
    main()
