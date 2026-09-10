class_name Scale
extends Object

## Canonical numbers — keep in sync with docs/SCALE.md

const BASE_TILE: int = 32
const HALF_TILE: int = 16
const CHARACTER_HEIGHT_MIN: int = 48
const CHARACTER_HEIGHT_MAX: int = 64
const CHARACTER_HEIGHT_TARGET: int = 56
const COTTAGE_HEIGHT_TILES_MIN: int = 3
const COTTAGE_HEIGHT_TILES_MAX: int = 5
const TOWN_HALL_HEIGHT_TILES_MIN: int = 5
const TOWN_HALL_HEIGHT_TILES_MAX: int = 8
const INTERACT_RADIUS_TILES: float = 1.25


static func tiles_to_px(tiles: float) -> float:
	return tiles * float(BASE_TILE)


static func px_to_tiles(px: float) -> float:
	return px / float(BASE_TILE)
