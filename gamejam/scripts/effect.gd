class_name Effect
extends Resource

enum Kind {DESTROY_CELL, RECOLOR_CELL, SPAWN_CHIP, SWAP_CELLS, OPEN_HOLE, FLAG_TIMER, SHIFT_COLUMNS, CUSTOM}

@export var kind: Kind
@export var pos_a: Vector2i = Vector2i(-1, -1)
@export var pos_b: Vector2i = Vector2i(-1, -1)
@export var payload: Dictionary = {} # Zusatzinfos (z. B. neue Farbe)
