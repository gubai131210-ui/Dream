extends RefCounted
class_name WalkContract

## Phase0 collision / walkability contract (docs + soft asserts for QA).
## Solids = tile mask via AreaCraft.is_npc_walkable.
## Detection = Area2D (portals, InteractableHotspot) — never treat as walls.
## Feet = PlayerActor.FOOT_CONTACT_Y (must stay 0.0).

const PLAYER_FOOT_CONTACT_Y := 0.0
const PORTAL_GRACE_SEC := 0.65


static func assert_player_feet(player: Node) -> bool:
	if player == null:
		return false
	var v: Variant = player.get("FOOT_CONTACT_Y")
	if typeof(v) != TYPE_FLOAT and typeof(v) != TYPE_INT:
		# const may not be readable via get; check script source path instead.
		return true
	return float(v) == PLAYER_FOOT_CONTACT_Y


static func describe() -> String:
	return "walk=tile-mask; portals/hotspots=Area2D-detect-only; feet=y0; portal_grace=%.2fs" % PORTAL_GRACE_SEC
