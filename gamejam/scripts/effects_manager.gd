extends Node2D
class_name EffectsManager

var _board: GameBoardData = null
@onready var screen_shake: PhantomCameraNoiseEmitter2D = %ScreenShake
@onready var sfx_stream: AudioStreamPlayer2D = %AudioStreamSFX
@onready var visual_board: VisualBoard = %VisualBoard
var SFX_CHIP_DROP: AudioStream = preload("res://audio/chip_drop.mp3")
var SFX_RECOLOR: AudioStream = preload("res://audio/paint_splash.wav")
var SFX_DESTROY_VARIANTS: Array = [
	preload("res://audio/small_explosion.wav")
]
var SFX_TIMER_EXPLODE: AudioStream = preload("res://audio/medium_explosion.wav")

var SFX_GAME_OVER: AudioStream = preload("res://audio/yay.mp3")

var VFX_PARTICLE_EXPLOSION = preload("res://effects/particle_explosion.tscn")

func _ready():
	if Engine.is_editor_hint():
		return
	if not GameManager.init_visual_board.is_connected(_on_init_visual_board):
		GameManager.init_visual_board.connect(_on_init_visual_board)
	# If a board already exists already, hook immediately
	if GameManager.game_board != null:
		_hook_to_board(GameManager.game_board)
	
	if not GameManager.game_over.is_connected(sfx_on_game_over):
		GameManager.game_over.connect(sfx_on_game_over)

func _on_init_visual_board():
	_hook_to_board(GameManager.game_board)

func _safe_disconnect_all():
	if _board == null:
		return
	if _board.chip_dropped.is_connected(_on_chip_dropped):
		_board.chip_dropped.disconnect(_on_chip_dropped)
	if _board.cell_recolored.is_connected(_on_cell_recolored):
		_board.cell_recolored.disconnect(_on_cell_recolored)
	if _board.cell_destroyed.is_connected(_on_cell_destroyed):
		_board.cell_destroyed.disconnect(_on_cell_destroyed)
	if _board.timer_exploded.is_connected(_on_timer_exploded):
		_board.timer_exploded.disconnect(_on_timer_exploded)

func _hook_to_board(board: GameBoardData):
	if board == null:
		return
	if _board != null and _board != board:
		_safe_disconnect_all()
	_board = board
	if not _board.chip_dropped.is_connected(_on_chip_dropped):
		_board.chip_dropped.connect(_on_chip_dropped)
	if not _board.cell_recolored.is_connected(_on_cell_recolored):
		_board.cell_recolored.connect(_on_cell_recolored)
	if not _board.cell_destroyed.is_connected(_on_cell_destroyed):
		_board.cell_destroyed.connect(_on_cell_destroyed)
	if not _board.timer_exploded.is_connected(_on_timer_exploded):
		_board.timer_exploded.connect(_on_timer_exploded)

# Event handlers
func _on_chip_dropped(chip: ChipInstance, column: int, cell: BoardCell) -> void:
	shake_small()
	sfx_on_chip_dropped(chip, column, cell.coords)

func _on_cell_recolored(pos: Vector2i, owner_before: int, owner_after: int) -> void:
	shake_small()
	sfx_on_cell_recolored(pos, owner_before, owner_after)

func _on_cell_destroyed(pos: Vector2i, owner_before: int) -> void:
	shake_medium()
	sfx_on_cell_destroyed(pos, owner_before)
	vfx_on_cell_destroyed(pos, owner_before)

func _on_timer_exploded(center: Vector2i, destroyed_positions: Array) -> void:
	shake_strong()
	#sfx_on_timer_exploded(center, destroyed_positions)

# Shake presets
func shake_small() -> void:
	if screen_shake == null:
		return

	screen_shake.noise.amplitude = 10
	screen_shake.noise.frequency = 1

	screen_shake.growth_time = 0.02
	screen_shake.duration = 0.08
	screen_shake.decay_time = 0.12
	screen_shake.emit()

func shake_medium() -> void:
	if screen_shake == null:
		return

	screen_shake.noise.amplitude = 50
	screen_shake.noise.frequency = 3

	screen_shake.growth_time = 0.04
	screen_shake.duration = 0.5
	screen_shake.decay_time = 0.2
	screen_shake.emit()

func shake_strong() -> void:
	if screen_shake == null:
		return

	screen_shake.noise.amplitude = 75
	screen_shake.noise.frequency = 4

	screen_shake.growth_time = 0.06
	screen_shake.duration = 0.75
	screen_shake.decay_time = 0.32
	screen_shake.emit()


# SFX
func sfx_on_chip_dropped(_chip: ChipInstance, _column: int, _coords: Vector2i) -> void:
	if sfx_stream == null:
		return
	sfx_stream.stream = SFX_CHIP_DROP
	sfx_stream.play()

func sfx_on_cell_recolored(_pos: Vector2i, _owner_before: int, _owner_after: int) -> void:
	if sfx_stream == null:
		return
	sfx_stream.stream = SFX_RECOLOR
	sfx_stream.play()

func sfx_on_cell_destroyed(_pos: Vector2i, _owner_before: int) -> void:
	if sfx_stream == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var idx := rng.randi_range(0, SFX_DESTROY_VARIANTS.size() - 1)
	sfx_stream.stream = SFX_DESTROY_VARIANTS[idx]
	sfx_stream.play()

func sfx_on_game_over(_winner: int, _show_win_screen: bool):
	if sfx_stream == null:
		return
	sfx_stream.stream = SFX_GAME_OVER
	sfx_stream.play()


# VFX
func vfx_on_cell_destroyed(_pos: Vector2i, _owner_before: int):
	var pos := visual_board.get_cell_world_position(_pos.x, _pos.y)

	var particle_explosion: GPUParticles2D = VFX_PARTICLE_EXPLOSION.instantiate()

	particle_explosion.global_position = pos

	add_child(particle_explosion)

#func sfx_on_timer_exploded(_center: Vector2i, _destroyed_positions: Array) -> void:
	#if sfx_stream == null:
		#return
	#sfx_stream.stream = SFX_TIMER_EXPLODE
	#sfx_stream.play()
