class_name Ability
extends Resource

class AbilityContext:
	var board: GameBoardData
	var cell: BoardCell
	var chip: Chip
	var rng: RandomNumberGenerator
	var active_player: int
	
func compute_effects(ctx: AbilityContext) -> Array[Effect]:
	return []
