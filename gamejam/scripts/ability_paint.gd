class_name AbilityPaint
extends Ability

func compute_effects(ctx: AbilityContext) -> Array[Effect]:
	var effects: Array[Effect] = []
	for nb in ctx.board.get_board_cell_neighbours(ctx.cell.coords):
		if nb != null and nb.has_chip():
			var e := Effect.new()
			e.kind = Effect.Kind.RECOLOR_CELL
			e.pos_a = nb.coords
			e.payload = {"owner": ctx.active_player}
			effects.append(e)
	return effects