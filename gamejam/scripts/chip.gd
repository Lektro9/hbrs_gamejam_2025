extends Node2D

@export var target_y : float
var stats: ChipStats

func _init() -> void:
	var st = stats.clone

func _physics_process(delta: float) -> void:
	if position.y < target_y:
		position.y += $RigidBody2D.gravity_scale * 400 * delta
		if position.y > target_y:
			position.y = target_y
