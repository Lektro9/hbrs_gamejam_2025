class_name AbilityKombucha
extends Ability

func compute_effects(ctx: AbilityContext) -> Array[Effect]:
	var effects: Array[Effect] = []
	if ctx == null or ctx.board == null or ctx.cell == null:
		return effects
	var below := ctx.board.get_cells_below_board_cell(ctx.cell)
	for bc in below.slice(0, 1):
		if bc != null and bc.has_chip():
			var e := Effect.new()
			e.kind = Effect.Kind.DESTROY_CELL
			e.pos_a = bc.coords
			effects.append(e)
	return effects
