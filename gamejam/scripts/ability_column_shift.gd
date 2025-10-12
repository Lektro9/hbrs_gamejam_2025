class_name AbilityColumnShift
extends Ability

func compute_effects(ctx: AbilityContext) -> Array[Effect]:
	var effects: Array[Effect] = []
	var e := Effect.new()
	e.kind = Effect.Kind.SHIFT_COLUMNS
	e.payload = {"delta": 1} # shift right by 1 with wrap
	effects.append(e)
	return effects
