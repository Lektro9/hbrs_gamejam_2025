class_name Chip
extends Resource

@export var icon: Texture2D
enum Ownership {NEUTRAL = 0, PLAYER_ONE, PLAYER_TWO}
enum Specials {NORMAL = 0, BONUS}

@export var player_id: Ownership = Ownership.NEUTRAL
@export var special_type: Specials = Specials.NORMAL
@export var chip_value: int = 1
