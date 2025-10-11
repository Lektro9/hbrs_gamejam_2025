# Holds the properties of cells in the game board
class_name BoardCell
extends Node2D

# x coord
var x: int
# y coord
var y: int
# Holds all neighbours
var neighbours: Array[BoardCell] = []

var chip: ChipStats = null

var is_in_cluster: bool = false
var is_explored: bool = false

var coords: Vector2i:
	get:
		return Vector2i(x, y)
	set(value):
		x = value.x
		y = value.y

func _init(x_coord: int, y_coord: int) -> void:
	self.x = x_coord
	self.y = y_coord

func equals(other_cell: BoardCell) -> bool:
	return self.coords == other_cell.coords

func _to_string() -> String:
	return "(%s,%s)" % [x, y]

func has_chip() -> bool:
	return chip != null

func assign_chip(c = ChipStats) -> void:
	self.chip = c
