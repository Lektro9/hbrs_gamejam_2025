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
		print(board_cells[board_cell])
		for cell_neighbour in board_cells[board_cell].neighbours:
			print("\t -> %s" % cell_neighbour)

## Makes a chip "fall down" in the data layer
func _chip_gravity(cell: BoardCell) -> void:
	if cell.has_chip():
		var cell_below = get_board_cell_neighbour(cell.coords, CellDirection.CELL_DOWN)
		
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
	
	for direction in CellDirection:
		cells.append(get_board_cell_neighbour(coords, CellDirection[direction]))
	
	return cells

## Returns all cells below cell
func get_cells_below_board_cell(cell: BoardCell) -> Array[BoardCell]:
	var cells_below: Array[BoardCell] = []
	
	for c in range(cell.y, 0, -1):
		cells_below.append(c)
		
	return cells_below
	
# TODO
## Returns all neighbours that are in a certain radius around cell
func get_board_cell_neighbours_in_radius(coords: Vector2i, radius: int = 1) -> Array[BoardCell]:
	var cells: Dictionary[Vector2i, BoardCell] = {}
	var cells_array: Array[BoardCell]
	
	var neighbours = get_board_cell_neighbours(coords)
	
	for neighbour in neighbours:
		cells[neighbour.coords] = neighbour
	
	for cell in cells:
		cells_array.append(cells[cell])
		
	return cells_array

## Returns all cells in a certain column
func get_column(col_num: int) -> Array[BoardCell]:
	assert(col_num < BOARD_WIDTH, 
	"Position of column must be smaller than board width, which is %s" % BOARD_WIDTH)
	
	var col_cells: Array[BoardCell] = []
	
	for i in BOARD_HEIGHT:
		col_cells.append(get_board_cell_by_coords(col_num, i))
	
	return col_cells

## Returns all cells in a certain row
func get_row(row_num: int) -> Array[BoardCell]:
	assert(row_num < BOARD_HEIGHT, 
	"Position of row must be smaller than board height, which is %s" % BOARD_HEIGHT)
	
	var row_cells: Array[BoardCell] = []
	
	for i in BOARD_HEIGHT:
		row_cells.append(get_board_cell_by_coords(i, row_num))
	
	return row_cells

## Returns all chips on the board
func all_chips_in_play() -> Array[BoardCell]:
	return board_cells.values().filter(func(c: BoardCell): return c.has_chip())

## Drops a chip onto the board
func drop_chip(chip: ChipStats, col_num: int):
	var cell = get_board_cell_by_coords(col_num, BOARD_HEIGHT - 1)
	
	if (not cell.has_chip()):
		cell.assign_chip(chip)
		_chip_gravity(cell)

## BFS cluster search
func get_cluster(cell: BoardCell) -> Array[BoardCell]:
	var cluster: Array[BoardCell] = []
	var current_cell: BoardCell = cell
	var root: BoardCell = cell
	
	if not current_cell.has_chip():
		return cluster
		
	root.is_explored = true
	cluster.push_front(root)
	
	while not cluster.is_empty():
		current_cell = cluster.pop_front()
		
		if current_cell.has_chip() and not current_cell.is_in_cluster:
			for 	neighbour: BoardCell in get_board_cell_neighbours(current_cell.coords).filter(func(c: BoardCell): return c.has_chip()):
				if not neighbour.is_explored:
					neighbour.is_explored = true
					cluster.push_front(neighbour)
	
	for c in cluster:
		if cluster.size() > CLUSTER_MIN_SIZE:
			c.is_in_cluster = true
		else:
			c.is_in_cluster = false
		
		c.is_explored = false
	
	return cluster

## Returns all clusters on the board
func get_clusters():
	var cells_with_chips = all_chips_in_play()
	var clusters: Dictionary[int, Array]
	
	for i in range(0, cells_with_chips.size(), 1):
		var cell = cells_with_chips[i]
		
		if not cell.is_in_cluster:
			clusters[i] = get_cluster(cell)
