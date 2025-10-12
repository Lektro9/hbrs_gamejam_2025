class_name Chip
extends Resource

@export var icon: Texture2D
enum Ownership {NEUTRAL = 0, PLAYER_ONE, PLAYER_TWO}
enum Specials {NORMAL = 0, EXPLODE, PAINT, MAGNET, LINK, TIMER, KOMBUCHA, SHIFTER, MEZZO}

@export var special_type: Specials = Specials.NORMAL
@export var chip_value: int = 1

@export var ability = null
