class_name GameBoardData
extends Node2D

signal board_updated

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

	for i in BOARD_WIDTH:
		for j in BOARD_HEIGHT:	
			# Set cell properties
			var cell = BoardCell.new(i, j)
			
			board_cells[Vector2i(i, j)] = cell
			
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

## Updates the board status
## Makes all chips fall down
func update() -> void:
	# Chip gravity beginning at the bottom
	for cell in get_row(0):
		_chip_gravity(cell)
		
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
	
# TODO
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
	
	for x in BOARD_HEIGHT:
		row_cells.append(get_board_cell_by_coords(x, row_num))
	
	return row_cells

## Returns all chips on the board
func all_chips_in_play() -> Array[BoardCell]:
	return board_cells.values().filter(func(c: BoardCell): return c.has_chip())

## Drops a chip onto the board
func drop_chip(chip: Chip, col_num: int):
	for y in range(BOARD_HEIGHT - 1, -1, -1):
		var c = get_board_cell_by_coords(col_num, y)
		
		if not c.has_chip():
			c.assign_chip(chip)
			break
			
	update()


## BFS cluster search
func get_cluster(start: BoardCell) -> Array[BoardCell]:
	var result: Array[BoardCell] = []
	if start == null or not start.has_chip():
		return result

	var owner = start.chip.player_id
	if owner == Chip.Ownership.NEUTRAL:
		return result  # Neutrale zählen nicht für Spieler-Cluster

	var queue: Array[BoardCell] = [start]
	var visited := {}

	while not queue.is_empty():
		var cur: BoardCell = queue.pop_front()
		if visited.has(cur.coords):
			continue
		visited[cur.coords] = true
		result.append(cur)

		for nb in get_board_cell_neighbours(cur.coords):
			if nb.has_chip() and not visited.has(nb.coords) and nb.chip.player_id == owner:
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
	
	var visited := {}

	for cell in all_chips_in_play():
		if visited.has(cell.coords):
			continue
		
		var cluster := get_cluster(cell)
		
		for c in cluster:
			visited[c.coords] = true
		
		if cluster.size() >= CLUSTER_MIN_SIZE and cell.chip != null:
			match cell.chip.player_id:
				Chip.Ownership.PLAYER_ONE:
					clusters_by_team[Chip.Ownership.PLAYER_ONE].append(cluster)
				Chip.Ownership.PLAYER_TWO:
					clusters_by_team[Chip.Ownership.PLAYER_TWO].append(cluster)
				_:
					pass
	
	return clusters_by_team


func get_team_scores() -> Dictionary[Chip.Ownership, int]:
	var clusters := get_team_clusters()
	var score1 := 0
	
	for cl in clusters[Chip.Ownership.PLAYER_ONE]:
		score1 += cl.size()
		
	var score2 := 0
	
	for cluster in clusters[Chip.Ownership.PLAYER_TWO]:
		score2 += cluster.size()
		
	return {
		Chip.Ownership.PLAYER_ONE: score1,
		Chip.Ownership.PLAYER_TWO: score2
	}

func debug_print():
	var out := ""
	for y in BOARD_HEIGHT: # oben nach unten
		for x in range(BOARD_WIDTH):
			var cell := get_board_cell_by_coords(x, y)
			if not cell.has_chip():
				out += ". "
			else:
				match cell.chip.player_id:
					Chip.Ownership.PLAYER_ONE:
						out += "1 "
					Chip.Ownership.PLAYER_TWO:
						out += "2 "
					_:
						out += "N "
		out += "\n"
	print(out)
