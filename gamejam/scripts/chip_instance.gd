extends Node2D
class_name ChipInstance

@export var ChipResource: Chip:
	set(value):
		ChipResource = value
		if sprite_2d and ChipResource:
			sprite_2d.texture = ChipResource.icon
		if letter and ChipResource and ChipResource.letter:
			letter.texture = ChipResource.letter
@export var player_id: Chip.Ownership
@export var color: Color
var _timer_countdown: int = -1
@export var timer_countdown: int = -1:
	set(value):
		_timer_countdown = value
		_update_timer_visual()
	get:
		return _timer_countdown

var already_animated := false
@onready var in_cluster_tween: TweenCustom = $Container/InClusterTween

@onready var container: Node2D = $Container
@onready var sprite_2d: Sprite2D = $Container/Sprite2D
@onready var letter: Sprite2D = %Letter
@onready var timer_label: Label = %TimerLabel

var fall_tween: Tween
var move_tween: Tween
var scale_tween: Tween
var color_tween: Tween

func _ready():
	if ChipResource:
		sprite_2d.texture = ChipResource.icon
		if ChipResource.letter:
			letter.texture = ChipResource.letter
	apply_player_color(color)
	container.position = Vector2.ZERO
	container.scale = Vector2.ONE
	_update_timer_visual()

func stop_in_cluster_tween():
	if in_cluster_tween and in_cluster_tween.tween:
		in_cluster_tween.tween.stop()
		$Container.position = Vector2.ZERO

func apply_player_color(target_color: Color) -> void:
	color = target_color
	if sprite_2d:
		sprite_2d.modulate = target_color
	if letter:
		letter.modulate = target_color.lerp(Color.WHITE, 0.35)

func start_falling(start_position: float) -> void:
	if already_animated:
		return
	fall_tween = _kill_tween(fall_tween)
	container.position.y = - start_position
	fall_tween = container.create_tween()
	fall_tween.set_trans(Tween.TRANS_EXPO)
	fall_tween.set_ease(Tween.EASE_IN)
	fall_tween.tween_property(container, "position:y", 6.0, 0.26)
	fall_tween.set_trans(Tween.TRANS_BACK)
	fall_tween.set_ease(Tween.EASE_OUT)
	fall_tween.tween_property(container, "position:y", -120.0, 0.1)
	fall_tween.tween_property(container, "position:y", 0.0, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fall_tween.finished.connect(_on_drop_landed)
	already_animated = true

func animate_to_position(target: Vector2, travel: Vector2, cell_size: Vector2) -> void:
	if position.distance_to(target) < 0.5:
		position = target
		return
	move_tween = _kill_tween(move_tween)
	var travel_length: float = travel.length()
	var duration: float = clamp(0.18 + travel_length / max(cell_size.length(), 0.001) * 0.06, 0.2, 0.48)
	var direction: Vector2 = Vector2.ZERO
	if travel_length > 0.0:
		direction = travel / travel_length
	var overshoot_amount: float = 0.0
	var is_horizontal: bool = abs(travel.x) >= abs(travel.y) * 0.6
	if travel_length > 0.5:
		overshoot_amount = min(travel_length * 0.18, cell_size.length() * 0.25)

	move_tween = create_tween()
	move_tween.set_trans(Tween.TRANS_SINE)
	move_tween.set_ease(Tween.EASE_OUT)

	if is_horizontal and overshoot_amount > 0.0:
		move_tween.tween_property(self, "position", target + direction * overshoot_amount, duration * 0.7)
		move_tween.tween_property(self, "position", target, max(duration * 0.3, 0.08)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		move_tween.tween_property(self, "position", target, duration)

	if abs(travel.x) > cell_size.x * 0.9 and abs(travel.y) < cell_size.y * 0.25:
		_play_squash_and_flash(duration * 0.6, 1.08)
	elif abs(travel.y) > cell_size.y * 0.9:
		_play_squash_and_flash(duration * 0.6, 1.05)

func play_recolor_flash(new_color: Color) -> void:
	color_tween = _kill_tween(color_tween)
	var highlight: Color = new_color.lerp(Color.WHITE, 0.35)
	color_tween = sprite_2d.create_tween()
	color_tween.set_trans(Tween.TRANS_SINE)
	color_tween.set_ease(Tween.EASE_OUT)
	color_tween.tween_property(sprite_2d, "modulate", highlight, 0.12)
	color_tween.tween_property(sprite_2d, "modulate", new_color, 0.18)
	if letter:
		var letter_highlight: Color = letter.modulate.lerp(Color.WHITE, 0.4)
		var letter_tween: Tween = letter.create_tween()
		letter_tween.set_trans(Tween.TRANS_SINE)
		letter_tween.set_ease(Tween.EASE_OUT)
		letter_tween.tween_property(letter, "modulate", letter_highlight, 0.12)
		letter_tween.tween_property(letter, "modulate", new_color.lerp(Color.WHITE, 0.35), 0.18)
	color_tween.finished.connect(func():
		apply_player_color(new_color)
	)

func _on_drop_landed() -> void:
	_play_squash_and_flash(0.08, 1.12)
	container.position = Vector2.ZERO

func _play_squash_and_flash(duration: float, strength: float) -> void:
	if sprite_2d == null or container == null:
		return
	var inv_strength: float = 1.0 / max(strength, 0.001)
	var squash_scale: Vector2 = Vector2(strength, inv_strength)
	scale_tween = _kill_tween(scale_tween)
	scale_tween = container.create_tween()
	scale_tween.set_trans(Tween.TRANS_BACK)
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(container, "scale", squash_scale, duration)
	scale_tween.tween_property(container, "scale", Vector2.ONE, duration * 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

	var base_color: Color = sprite_2d.modulate
	var flash_color: Color = base_color.lerp(Color.WHITE, 0.25)
	var flash_tween: Tween = sprite_2d.create_tween()
	flash_tween.set_trans(Tween.TRANS_SINE)
	flash_tween.set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(sprite_2d, "modulate", flash_color, duration * 0.6)
	flash_tween.tween_property(sprite_2d, "modulate", base_color, duration * 0.9)
	if letter:
		var letter_base: Color = letter.modulate
		var letter_flash: Color = letter_base.lerp(Color.WHITE, 0.35)
		var letter_flash_tween: Tween = letter.create_tween()
		letter_flash_tween.set_trans(Tween.TRANS_SINE)
		letter_flash_tween.set_ease(Tween.EASE_OUT)
		letter_flash_tween.tween_property(letter, "modulate", letter_flash, duration * 0.6)
		letter_flash_tween.tween_property(letter, "modulate", letter_base, duration * 0.9)

func _update_timer_visual() -> void:
	if timer_label == null:
		return
	if _timer_countdown >= 0:
		timer_label.text = str(_timer_countdown)
		timer_label.visible = true
	else:
		timer_label.visible = false

func _kill_tween(tween_ref: Tween) -> Tween:
	if tween_ref != null and tween_ref.is_running():
		tween_ref.kill()
	return null
