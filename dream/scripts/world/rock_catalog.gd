class_name RockCatalog
extends RefCounted

## Biome rock families for outdoor assemblers.
## Prefer `res://assets/sprites/props/rocks/{family}/rock_XX.png`;
## fall back to legacy `props/rock_0X.png` (forest_moss pack) when missing.

const TARGET_H_SHORE := 22.0
const TARGET_H_TERRACE := 24.0
const TARGET_H_COBBLE := 16.0

const FAMILY_FOREST_MOSS := "forest_moss"
const FAMILY_COASTAL := "coastal"
const FAMILY_TERRACE := "terrace"
const FAMILY_COBBLE := "cobble"
const FAMILY_RIVER_BANK := "river_bank"

const _LEGACY_DIR := "res://assets/sprites/props"
const _FAMILY_DIR := "res://assets/sprites/props/rocks"


static func path(family: String, index: int) -> String:
	var xx := "%02d" % index
	var folder := family
	# On-disk folder aliases (generator uses short biome names).
	match family:
		FAMILY_RIVER_BANK:
			folder = "river"
		FAMILY_FOREST_MOSS:
			# No dedicated folder — always legacy moss pack.
			var legacy_fm := "%s/rock_%s.png" % [_LEGACY_DIR, xx]
			if ResourceLoader.exists(legacy_fm):
				return legacy_fm
			return legacy_fm
	var preferred := "%s/%s/rock_%s.png" % [_FAMILY_DIR, folder, xx]
	if ResourceLoader.exists(preferred):
		return preferred
	# Legacy pack lives as rock_00..rock_05 under props/ (forest_moss identity).
	var legacy := "%s/rock_%s.png" % [_LEGACY_DIR, xx]
	if ResourceLoader.exists(legacy):
		return legacy
	return preferred


static func load_tex(family: String, index: int) -> Texture2D:
	var p := path(family, index)
	if not ResourceLoader.exists(p):
		return null
	return load(p) as Texture2D


static func scale_for_target_h(tex: Texture2D, target_h: float) -> float:
	if tex == null or tex.get_height() <= 0:
		return 0.3
	return float(target_h) / float(tex.get_height())


static func families() -> PackedStringArray:
	return PackedStringArray([
		FAMILY_FOREST_MOSS,
		FAMILY_COASTAL,
		FAMILY_TERRACE,
		FAMILY_COBBLE,
		FAMILY_RIVER_BANK,
	])
