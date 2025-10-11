class_name ChipStats
extends Resource

enum Ownership {NEUTRAL = 0, PLAYER_ONE, PLAYER_TWO}
enum Specials {NORMAL = 0, BONUS}

@export var ownership: Ownership = Ownership.NEUTRAL
@export var special_type: Specials = Specials.NORMAL
@export var chip_value: int = 1

func _init(is_special: bool, player_id: Ownership):
	if is_special:
		special_type = Specials.get(randi_range(1, Specials.BONUS))
	ownership = player_id
