class_name TweenCustom extends Node

@export var property_name: String
@export var isAnimatingFunction: bool = false
@export var methodName: String
@export var initial_value: float = 0.0
@export var final_value: float
@export var duration: float = 1.0
@export var transition_type: Tween.TransitionType = Tween.TRANS_LINEAR
@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var auto_start: bool = true
@export var shouldLooping: bool = true
@export var shouldAnimateToInitial = true

var tween: Tween
var target;

func _ready():
	if auto_start:
		start_tween()

func start_tween():
	target = get_parent()
	if not is_instance_valid(target):
		return
	if isAnimatingFunction:
		start_tween_method()
		return
		
	tween = target.create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(transition_type)
	if shouldLooping:
		tween.set_loops()
		
	tween.tween_property(
		get_parent(),
		property_name,
		final_value,
		duration,
	).from(initial_value)
	if shouldAnimateToInitial:
		tween.tween_property(
			get_parent(),
			property_name,
			initial_value,
			duration,
		).from(final_value)

func start_tween_method():
	if not target.has_method(methodName):
		push_error("Name of method is invalid")
		return
	tween = target.create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(transition_type)
	tween.tween_method(target[methodName], initial_value, final_value, duration)
	if shouldAnimateToInitial:
		tween.tween_method(target[methodName], final_value, initial_value , duration)
