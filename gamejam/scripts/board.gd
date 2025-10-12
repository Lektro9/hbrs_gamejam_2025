class_name GameBoardData
extends Node2D

signal board_updated
signal chip_dropped(chip: ChipInstance, column: int, cell: BoardCell)
signal ability_triggered(ability_name: String, cell: BoardCell, effects: Array)
signal effects_resolving(effects: Array)
signal cell_destroyed(pos: Vector2i, owner_before: int)
signal cell_recolored(pos: Vector2i, owner_before: int, owner_after: int)
signal cells_swapped(pos_a: Vector2i, pos_b: Vector2i)
signal chip_spawned(pos: Vector2i, owner_after: int)
signal timer_flagged(pos: Vector2i, countdown: int)
signal timers_ticked(ticks: Array) # [{pos: Vector2i, from: int, to: int}]
signal timer_exploded(center: Vector2i, destroyed_positions: Array) # [Vector2i]
signal effects_resolved(effects: Array)

var BOARD_WIDTH: int
var BOARD_HEIGHT: int
@export var CLUSTER_MIN_SIZE: int = 4

enum CellDirection {
	CELL_UP,
	CELL_UP_RIGHT,
	CELL_RIGHT,
	CELL_DOWN_RIGHT,
	CELL_DOWN,
	CELL_DOWN_LEFT,
	CELL_LEFT,
	CELL_UP_LEFT
}

var board_cells: Dictionary[Vector2i, BoardCell]

func _init(height, width):
	BOARD_WIDTH = width
	BOARD_HEIGHT = height
	
	board_cells = {}

	for x in BOARD_WIDTH:
		for y in BOARD_HEIGHT:
			# Set cell properties
			var cell = BoardCell.new(x, y)
			
			board_cells[Vector2i(x, y)] = cell
			
	for board_cell in board_cells:
		board_cells[board_cell].neighbours = get_board_cell_neighbours(board_cell).filter(func(bc: BoardCell): return bc != null)
	
	debug_print()

## Makes a chip "fall down" in the data layer
func _chip_gravity(cell: BoardCell) -> void:
	if cell.has_chip():
		var cell_below = get_board_cell_neighbour(cell.coords, CellDirection.CELL_DOWN)
		
		if cell_below == null:
			return
		
		if not cell_below.has_chip():
			cell_below.chip = cell.chip
			cell.chip = null
			_chip_gravity(cell_below)
			print(cell_below.coords)

## Updates the board status
## Makes all chips fall down
func update_board_state() -> void:
	# Chip gravity beginning at the bottom
	for y in BOARD_HEIGHT:
		for x in BOARD_WIDTH:
			_chip_gravity(get_board_cell_by_coords(x, y))
		
	get_clusters()
	
	debug_print()
	
	board_updated.emit()

## Get a single cell by Vector coords
func get_board_cell(coords: Vector2i) -> BoardCell:
	if board_cells.has(coords):
		return board_cells[coords]
		
	return null

## Get a single cell by integer coords
func get_board_cell_by_coords(x: int, y: int) -> BoardCell:
	return get_board_cell(Vector2i(x, y))

## Returns the neighbouring cell in a single direction (even diagonally)
func get_board_cell_neighbour(coords: Vector2i, direction: CellDirection) -> BoardCell:
	match direction:
		CellDirection.CELL_UP:
			return get_board_cell_by_coords(coords.x, coords.y + 1)
		CellDirection.CELL_UP_RIGHT:
			return get_board_cell_by_coords(coords.x + 1, coords.y + 1)
		CellDirection.CELL_RIGHT:
			return get_board_cell_by_coords(coords.x + 1, coords.y)
		CellDirection.CELL_DOWN_RIGHT:
			return get_board_cell_by_coords(coords.x + 1, coords.y - 1)
		CellDirection.CELL_DOWN:
			return get_board_cell_by_coords(coords.x, coords.y - 1)
		CellDirection.CELL_DOWN_LEFT:
			return get_board_cell_by_coords(coords.x - 1, coords.y - 1)
		CellDirection.CELL_LEFT:
			return get_board_cell_by_coords(coords.x - 1, coords.y)
		CellDirection.CELL_UP_LEFT:
			return get_board_cell_by_coords(coords.x - 1, coords.y + 1)
			
	return null

## Returns all neighbours of a single cell in a cross
func get_board_cell_neighbours_cross(coords: Vector2i) -> Array[BoardCell]:
	var cells: Array[BoardCell] = []
	
	cells.append(get_board_cell_neighbour(coords, CellDirection.CELL_UP))
	cells.append(get_board_cell_neighbour(coords, CellDirection.CELL_RIGHT))
	cells.append(get_board_cell_neighbour(coords, CellDirection.CELL_DOWN))
	cells.append(get_board_cell_neighbour(coords, CellDirection.CELL_LEFT))
	
	return cells.filter(func(c: BoardCell): c != null)

## Returns all neighbours of a single cell
func get_board_cell_neighbours(coords: Vector2i) -> Array[BoardCell]:
	var cells: Array[BoardCell] = []
	
	for direction in CellDirection.values():
		var nb = get_board_cell_neighbour(coords, direction)
		if nb != null:
			cells.append(nb)
	
	return cells

## Returns all cells below cell
func get_cells_below_board_cell(cell: BoardCell) -> Array[BoardCell]:
	var cells_below: Array[BoardCell] = []
	
	for y in range(cell.y - 1, -1, -1):
		cells_below.append(get_board_cell_by_coords(cell.x, y))
		
	return cells_below
	
## Returns all neighbours that are in a certain radius around cell
func get_board_cell_neighbours_in_radius(coords: Vector2i, radius: int = 1) -> Array[BoardCell]:
	var out: Array[BoardCell] = []
	var seen := {}
	
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			if dx == 0 && dy == 0:
				continue
				
			var p := Vector2i(coords.x + dx, coords.y + dy)
			var c := get_board_cell(p)
			
			if c != null && not seen.has(p):
				seen[p] = true
				out.append(c)
				
	return out


## Returns all cells in a certain column
func get_column(col_num: int) -> Array[BoardCell]:
	assert(col_num >= 0 and col_num < BOARD_WIDTH,
	"Position of column must be smaller than board width, which is %s" % BOARD_WIDTH)
	
	var col_cells: Array[BoardCell] = []
	
	for y in BOARD_HEIGHT:
		col_cells.append(get_board_cell_by_coords(col_num, y))
	
	return col_cells

## Returns all cells in a certain row
func get_row(row_num: int) -> Array[BoardCell]:
	assert(row_num >= 0 and row_num < BOARD_HEIGHT,
	"Position of row must be smaller than board height, which is %s" % BOARD_HEIGHT)
	
	var row_cells: Array[BoardCell] = []
	
	for x in BOARD_WIDTH:
		row_cells.append(get_board_cell_by_coords(x, row_num))
	
	return row_cells

## Returns all chips on the board
func all_chips_in_play() -> Array[BoardCell]:
	return board_cells.values().filter(func(c: BoardCell): return c.has_chip())

## Drops a chip onto the board
func drop_chip(chip: ChipInstance, col_num: int):
	var c = get_board_cell_by_coords(col_num, BOARD_HEIGHT - 1)
	
	if not c.has_chip():
		c.assign_chip(chip)
	
	update_board_state()
	
	# Determine the landed cell of this chip after gravity
	var landed: BoardCell = null
	for y in BOARD_HEIGHT:
		var cell := get_board_cell_by_coords(col_num, y)
		if cell.has_chip() and cell.chip == chip:
			landed = cell
			break
	
	if landed:
		chip_dropped.emit(chip, col_num, landed)
	if landed and chip.ChipResource and chip.ChipResource.ability != null:
		var ctx := Ability.AbilityContext.new()
		ctx.board = self
		ctx.cell = landed
		ctx.chip = chip.ChipResource
		ctx.rng = RandomNumberGenerator.new()
		ctx.active_player = chip.player_id

		var fx: Array[Effect] = chip.ChipResource.ability.compute_effects(ctx)
		
		ability_triggered.emit(chip.ChipResource.ability.get_class(), landed, fx)
		resolve_effects(fx)


## BFS cluster search
func get_cluster(start: BoardCell) -> Array[BoardCell]:
	var result: Array[BoardCell] = []
	if start == null or not start.has_chip():
		return result

	var chip_owner = start.chip.player_id
	if chip_owner == Chip.Ownership.NEUTRAL:
		return result # Neutrale zählen nicht für Spieler-Cluster

	var queue: Array[BoardCell] = [start]
	var visited := {}

	while not queue.is_empty():
		var cur: BoardCell = queue.pop_front()
		if visited.has(cur.coords):
			continue
		visited[cur.coords] = true
		result.append(cur)

		for nb in get_board_cell_neighbours(cur.coords):
			if nb.has_chip() and not visited.has(nb.coords) and nb.chip.player_id == chip_owner:
				queue.append(nb)

	var is_cluster := result.size() >= CLUSTER_MIN_SIZE
	for c in result:
		c.is_in_cluster = is_cluster
	return result


## Returns all clusters on the board
func get_clusters() -> Array[Array]:
	var clusters: Array[Array] = []
	var visited := {}

	for cell in all_chips_in_play():
		if visited.has(cell.coords):
			continue
		var cl = get_cluster(cell)
		for c in cl:
			visited[c.coords] = true
		if cl.size() >= CLUSTER_MIN_SIZE:
			clusters.append(cl)
	return clusters

## Total score, ignoring teams
func score_for_current_board() -> int:
	var total := 0
	for cl in get_clusters():
		total += cl.size()
	return total
	#

## Returns cluster with min_size divided by team 
func get_team_clusters() -> Dictionary:
	var clusters_by_team := {
		Chip.Ownership.PLAYER_ONE: [],
		Chip.Ownership.PLAYER_TWO: []
	}
	# Track visited per team to avoid duplicates
	var visited_by_team := {
		Chip.Ownership.PLAYER_ONE: {},
		Chip.Ownership.PLAYER_TWO: {}
	}

	for cell in all_chips_in_play():
		if cell == null or not cell.has_chip():
			continue
		var owner := cell.chip.player_id
		if owner != Chip.Ownership.PLAYER_ONE and owner != Chip.Ownership.PLAYER_TWO:
			continue # seed only from team-owned chips

		var team := owner
		if visited_by_team[team].has(cell.coords):
			continue

		# BFS with Mezzo wildcard connectivity
		var cluster: Array[BoardCell] = []
		var queue: Array[BoardCell] = [cell]
		var seen := {}

		while not queue.is_empty():
			var cur: BoardCell = queue.pop_front()
			if seen.has(cur.coords):
				continue
			seen[cur.coords] = true
			visited_by_team[team][cur.coords] = true
			cluster.append(cur)

			for nb in get_board_cell_neighbours(cur.coords):
				if nb != null and nb.has_chip() and not seen.has(nb.coords):
					var inst := nb.chip
					var is_team := inst.player_id == team
					var is_mezzo := inst.ChipResource != null and inst.ChipResource.special_type == Chip.Specials.MEZZO
					if is_team or is_mezzo:
						queue.append(nb)

		if cluster.size() >= CLUSTER_MIN_SIZE:
			clusters_by_team[team].append(cluster)

	return clusters_by_team


func get_team_scores() -> Dictionary[Chip.Ownership, int]:
	var clusters := get_team_clusters()
	var score1 := 0
	for cl in clusters[Chip.Ownership.PLAYER_ONE]:
		var bonus := 0
		for c in cl:
			if c != null and c.has_chip() and c.chip.ChipResource != null and c.chip.ChipResource.special_type == Chip.Specials.MEZZO:
				bonus = 2
				break
		score1 += cl.size() + bonus

	var score2 := 0
	for cl in clusters[Chip.Ownership.PLAYER_TWO]:
		var bonus2 := 0
		for c in cl:
			if c != null and c.has_chip() and c.chip.ChipResource != null and c.chip.ChipResource.special_type == Chip.Specials.MEZZO:
				bonus2 = 2
				break
		score2 += cl.size() + bonus2

	return {
		Chip.Ownership.PLAYER_ONE: score1,
		Chip.Ownership.PLAYER_TWO: score2
	}
	
# board_resolver.gd (oder Teil von GameBoardData)
func resolve_effects(effects: Array[Effect]) -> void:
	if effects.is_empty():
		return

	effects_resolving.emit(effects)

	var destroy := effects.filter(func(e): return e.kind == Effect.Kind.DESTROY_CELL)
	var recolor := effects.filter(func(e): return e.kind == Effect.Kind.RECOLOR_CELL)
	var swap := effects.filter(func(e): return e.kind == Effect.Kind.SWAP_CELLS)
	var spawn := effects.filter(func(e): return e.kind == Effect.Kind.SPAWN_CHIP)
	var timer := effects.filter(func(e): return e.kind == Effect.Kind.FLAG_TIMER)
	var custom := effects.filter(func(e): return e.kind == Effect.Kind.CUSTOM)
	var shift := effects.filter(func(e): return e.kind == Effect.Kind.SHIFT_COLUMNS)

	# Debug summary
	print("Effects: total=%s destroy=%s recolor=%s swap=%s spawn=%s timer=%s shift=%s custom=%s" % [
		effects.size(), destroy.size(), recolor.size(), swap.size(), spawn.size(), timer.size(), shift.size(), custom.size()
	])
	
	for e in destroy:
		var c := get_board_cell(e.pos_a)
		if c and c.has_chip():
			var owner_before := c.chip.player_id
			c.chip = null
			cell_destroyed.emit(e.pos_a, owner_before)

	for e in recolor:
		var c := get_board_cell(e.pos_a)
		if c and c.has_chip():
			var owner_before := c.chip.player_id
			var owner_after := int(e.payload.get("owner", c.chip.player_id))
			c.chip.player_id = owner_after
			cell_recolored.emit(e.pos_a, owner_before, owner_after)

	for e in swap:
		var a := get_board_cell(e.pos_a)
		var b := get_board_cell(e.pos_b)
		if a and b:
			var tmp = b.chip
			b.chip = a.chip
			a.chip = tmp
			cells_swapped.emit(e.pos_a, e.pos_b)

	for e in spawn:
		var c := get_board_cell(e.pos_a)
		if c and not c.has_chip():
			c.chip = e.payload.get("chip", null)
			if c.has_chip():
				chip_spawned.emit(e.pos_a, c.chip.player_id)

	for e in timer:
		var c := get_board_cell(e.pos_a)
		if c and c.has_chip():
			var cd := int(e.payload.get("countdown", c.chip.timer_countdown))
			c.chip.timer_countdown = cd
			timer_flagged.emit(e.pos_a, cd)

	# Apply column shifts (wrap-right)
	for e in shift:
		var delta := int(e.payload.get("delta", 1))
		# normalize shift to [0, BOARD_WIDTH)
		var sh := ((delta % BOARD_WIDTH) + BOARD_WIDTH) % BOARD_WIDTH
		if sh == 0:
			continue
		for y in BOARD_HEIGHT:
			var row := []
			for x in BOARD_WIDTH:
				row.append(get_board_cell_by_coords(x, y).chip)
			for x in BOARD_WIDTH:
				var src_x := (x - sh) % BOARD_WIDTH
				if src_x < 0:
					src_x += BOARD_WIDTH
				get_board_cell_by_coords(x, y).chip = row[src_x]

	# 3) Physik + Cluster (einmal pro “Welle”)
	update_board_state() # deine Gravity + clusters/emit
	effects_resolved.emit(effects)


func tick_timers_and_collect_effects() -> Array[Effect]:
	var out: Array[Effect] = []
	var ticks := []
	for cell in all_chips_in_play():
		var inst := cell.chip
		if inst != null and inst.timer_countdown != null and inst.timer_countdown >= 0:
			var from_val := inst.timer_countdown
			if inst.timer_countdown > 0:
				inst.timer_countdown -= 1
			# Collect tick info only if changed
			if inst.timer_countdown != from_val:
				ticks.append({
					"pos": cell.coords,
					"from": from_val,
					"to": inst.timer_countdown
				})
			if inst.timer_countdown == 0:
				var destroyed_positions: Array[Vector2i] = []
				for nb in get_board_cell_neighbours(cell.coords):
					if nb != null and nb.has_chip():
						var e := Effect.new()
						e.kind = Effect.Kind.DESTROY_CELL
						e.pos_a = nb.coords
						out.append(e)
						destroyed_positions.append(nb.coords)
				timer_exploded.emit(cell.coords, destroyed_positions)
				inst.timer_countdown = -1
	# Emit aggregated tick info
	if ticks.size() > 0:
		timers_ticked.emit(ticks)

	update_board_state()

	return out


func debug_print():
	var out := "\n"
	out += "╔" + "══".repeat(BOARD_WIDTH) + "╗\n"
	
	for y in range(BOARD_HEIGHT - 1, -1, -1):
		out += "║"
		for x in range(BOARD_WIDTH):
			var cell := get_board_cell_by_coords(x, y)
			if not cell.has_chip():
				out += "· "
			else:
				var c := cell.chip
				var char := ""
				var special_marker := ""
				var timer_marker := ""
				
				match c.player_id:
					Chip.Ownership.PLAYER_ONE:
						char = "1"
					Chip.Ownership.PLAYER_TWO:
						char = "2"
					_:
						char = "?"
				
				match c.ChipResource.special_type:
					Chip.Specials.NORMAL:
						special_marker = ""
					Chip.Specials.EXPLODE:
						special_marker = "E"
					Chip.Specials.PAINT:
						special_marker = "P"
					Chip.Specials.TIMER:
						special_marker = "T"
					Chip.Specials.KOMBUCHA:
						special_marker = "K"
					Chip.Specials.SHIFTER:
						special_marker = "S"
					Chip.Specials.MEZZO:
						special_marker = "M"
					_:
						special_marker = "*"
				
				if c.timer_countdown != null and c.timer_countdown >= 0:
					timer_marker = str(c.timer_countdown)
				
				var marker := special_marker + timer_marker
				
				if cell.is_in_cluster:
					out += "[" + char + marker + "]"
				else:
					out += " " + char + marker + " "
		out += "║\n"
	
	out += "╚" + "══".repeat(BOARD_WIDTH) + "╝\n"

	# Optionale Spaltennummern unten für Debug
	out += "  "
	for x in range(BOARD_WIDTH):
		out += str(x) + " "
	out += "\n"

	# Timer overview line
	var timers := []
	for bc in all_chips_in_play():
		var inst := bc.chip
		if inst != null and inst.timer_countdown != null and inst.timer_countdown >= 0:
			timers.append(str(bc.coords) + "=" + str(inst.timer_countdown))
	if timers.size() > 0:
		var timer_str := ""
		for i in range(timers.size()):
			timer_str += timers[i]
			if i < timers.size() - 1:
				timer_str += ", "
		out += "Timers: " + timer_str + "\n"

	print(out)
