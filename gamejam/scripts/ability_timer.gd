class_name AbilityTimer
extends Ability

func compute_effects(ctx: AbilityContext) -> Array[Effect]:
	var effects: Array[Effect] = []
	var e := Effect.new()
	e.kind = Effect.Kind.FLAG_TIMER
	e.pos_a = ctx.cell.coords
	e.payload = {"countdown": 2}
	effects.append(e)
	return effects