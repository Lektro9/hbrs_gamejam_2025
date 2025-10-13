extends Node2D

signal game_over(winner: int, show_win_screen: bool, is_draw: bool)
signal update_player_score(scores)
signal show_score_board(should_show: bool)
signal show_main_menu(should_show: bool)
signal show_chip_value(should_show: bool)
signal show_next_chip_ui(should_show: bool)
signal init_visual_board
signal scroll_background(is_going_down: bool)
signal update_curr_chip(chip: ChipInstance)
signal update_chip_choices(chips: Array[ChipInstance])
signal clean_up_visuals

@onready var draw_label: Label = $DebugUi/DrawLabel
@onready var state_chart: StateChart = $StateChart
#@onready var debug_menu: CanvasLayer = %DebugMenu
#@onready var state_chart_debugger: MarginContainer = $DebugUi/StateChartDebugger
const CHIP_INSTANCE := preload("uid://dcmnbaonn5a5p")
const DEFAULT_CHIP := preload("uid://by11wc80p4n7w")
const EXPLODING_CHIP := preload("uid://bw88ik32ujbr7")
const KOMBUCHA_CHIP := preload("uid://c57ucj5aav206")
const MEZZO_CHIP := preload("uid://d2mhdm3mamng5")
const PAINTING_CHIP := preload("uid://bv32ffxumgi8j")
const SHIFTER_CHIP := preload("uid://rpu2nuj5vjk5")
const TIMER_CHIP := preload("uid://ckwb352522uuj")
const MAX_NORMAL_CHIPS_PER_OFFER := 1

var player_1: Player
var player_2: Player
var game_board: GameBoardData
var does_player_one_play = true # true for player 1, false for player 2
var chosen_column: int
var score_needed: int = 20
var chips_per_turn: int = 3
var BOARD_HEIGHT: int = 6
var BOARD_WIDTH: int = 7
var current_round_offer_templates: Array[Chip] = []

#func _ready() -> void:
	#if not OS.is_debug_build():
	#debug_menu.hide()
	
func get_player() -> Player:
	if does_player_one_play:
		return player_1
	else:
		return player_2

func switch_player():
	does_player_one_play = !does_player_one_play

func start_game():
	state_chart.send_event("start_game")

func drop_chip(col: int):
	chosen_column = col
	state_chart.send_event("dropping_chip")

func choose_chip(choice_index: int) -> void:
	var current_player := get_player()
	if current_player == null:
		return
	if choice_index < 0 or choice_index >= current_player.chip_choices.size():
		return
	current_player.selected_choice_index = choice_index
	var selected_chip: ChipInstance = current_player.chip_choices[choice_index]
	if selected_chip == null:
		return
	current_player.current_chip = selected_chip
	update_curr_chip.emit(selected_chip)

func restart_game():
	state_chart.set_expression_property("is_game_won", false)
	state_chart.send_event("restart_game")

func _player_id_to_ownership(player_id: Player.PlayerId) -> Chip.Ownership:
	match player_id:
		Player.PlayerId.PLAYER_ONE:
			return Chip.Ownership.PLAYER_ONE
		Player.PlayerId.PLAYER_TWO:
			return Chip.Ownership.PLAYER_TWO
		_:
			return Chip.Ownership.NEUTRAL

func _pick_special_chip(rng: RandomNumberGenerator) -> Chip:
	var roll := rng.randi_range(1, 100)
	if roll <= 17:
		return EXPLODING_CHIP.duplicate(true)
	elif roll <= 34:
		return PAINTING_CHIP.duplicate(true)
	elif roll <= 51:
		return TIMER_CHIP.duplicate(true)
	elif roll <= 68:
		return KOMBUCHA_CHIP.duplicate(true)
	elif roll <= 85:
		return SHIFTER_CHIP.duplicate(true)
	else:
		return MEZZO_CHIP.duplicate(true)

func _generate_chip_resource(rng: RandomNumberGenerator, require_special: bool = false) -> Chip:
	var wants_special := require_special or rng.randi_range(1, 100) <= 34
	if wants_special:
		return _pick_special_chip(rng)
	return DEFAULT_CHIP.duplicate(true)

func _instantiate_chip_from_template(player: Player, template: Chip) -> ChipInstance:
	var chip_instance: ChipInstance = CHIP_INSTANCE.instantiate()
	chip_instance.ChipResource = template.duplicate(true)
	chip_instance.player_id = _player_id_to_ownership(player.player_id)
	chip_instance.color = player.color
	return chip_instance

func _generate_round_offer_templates(rng: RandomNumberGenerator, offer_count: int) -> Array[Chip]:
	var templates: Array[Chip] = []
	var normals_remaining := MAX_NORMAL_CHIPS_PER_OFFER
	var used_special_types: Dictionary = {}
	var reroll_guard := 0
	var fallback_specials: Array[Dictionary] = [
		{"type": Chip.Specials.EXPLODE, "resource": EXPLODING_CHIP},
		{"type": Chip.Specials.PAINT, "resource": PAINTING_CHIP},
		{"type": Chip.Specials.TIMER, "resource": TIMER_CHIP},
		{"type": Chip.Specials.KOMBUCHA, "resource": KOMBUCHA_CHIP},
		{"type": Chip.Specials.SHIFTER, "resource": SHIFTER_CHIP},
		{"type": Chip.Specials.MEZZO, "resource": MEZZO_CHIP}
	]
	while templates.size() < offer_count and reroll_guard < 100:
		reroll_guard += 1
		var require_special := normals_remaining <= 0
		var chip_res := _generate_chip_resource(rng, require_special)
		if chip_res == null:
			continue
		if chip_res.special_type == Chip.Specials.NORMAL:
			if normals_remaining <= 0:
				continue
			normals_remaining -= 1
			templates.append(chip_res)
		else:
			if used_special_types.has(chip_res.special_type):
				continue
			used_special_types[chip_res.special_type] = true
			templates.append(chip_res)
	if templates.size() < offer_count:
		# deterministic fallback to ensure uniqueness
		rng.shuffle_array(fallback_specials)
		for candidate_dict in fallback_specials:
			if templates.size() >= offer_count:
				break
			var special_type: int = candidate_dict["type"]
			if used_special_types.has(special_type):
				continue
			var resource: Chip = candidate_dict["resource"]
			if resource == null:
				continue
			templates.append(resource.duplicate(true))
			used_special_types[special_type] = true
	if templates.size() < offer_count and normals_remaining > 0:
		templates.append(DEFAULT_CHIP.duplicate(true))
	return templates

func _instantiate_offer_instances(player: Player, templates: Array[Chip]) -> Array[ChipInstance]:
	var instances: Array[ChipInstance] = []
	for template in templates:
		instances.append(_instantiate_chip_from_template(player, template))
	return instances

func _create_chip_instance_for_player(player: Player, rng: RandomNumberGenerator) -> ChipInstance:
	return _instantiate_chip_from_template(player, _generate_chip_resource(rng))

func _discard_unplayed_choices(player: Player, except_chip: ChipInstance = null) -> void:
	if player == null:
		return
	for choice in player.chip_choices:
		if choice == null or choice == except_chip:
			continue
		choice.queue_free()
	player.chip_choices.clear()
	player.selected_choice_index = -1

func set_is_game_won_expression(is_game_won: bool):
	state_chart.set_expression_property("is_game_won", is_game_won)

func _on_init_state_entered() -> void:
	# Initialising players
	player_1 = Player.new(1, Color(0.72, 0.162, 0.185, 1.0))
	player_2 = Player.new(2, Color(0.158, 0.353, 0.849, 1.0))
	set_is_game_won_expression(false)
	show_main_menu.emit(true)
	show_score_board.emit(false)
	show_chip_value.emit(false)
	update_chip_choices.emit([])
	current_round_offer_templates.clear()
	game_over.emit(get_player().player_id, false, false)
	does_player_one_play = true

func _on_init_state_exited() -> void:
	game_board = GameBoardData.new(BOARD_HEIGHT, BOARD_WIDTH)
	var scores := game_board.get_team_scores()
	update_player_score.emit(scores)
	init_visual_board.emit()
	scroll_background.emit(true)

func _on_drop_chip_state_entered() -> void:
	var current_player := get_player()
	if current_player == null:
		return
	var played_chip := current_player.current_chip
	if played_chip == null:
		push_warning("Attempted to drop a chip without selecting one.")
		return
	game_board.drop_chip(played_chip, chosen_column)
	var scores := game_board.get_team_scores()
	player_1.score = scores.get(player_1.player_id)
	player_2.score = scores.get(player_2.player_id)
	update_player_score.emit(scores)
	print("Player 1 has: " + str(player_1.score))
	print("Player 2 has: " + str(player_2.score))
	_discard_unplayed_choices(current_player, played_chip)
	current_player.current_chip = null
	update_chip_choices.emit([])
	update_curr_chip.emit(null)

func _on_check_win_state_entered() -> void:
	if game_board.all_chips_in_play().size() >= BOARD_HEIGHT * BOARD_WIDTH:
		state_chart.send_event("draw_game")
	if player_1.score >= score_needed && player_2.score >= score_needed:
		state_chart.send_event("draw_game")
	if player_1.score >= score_needed:
		set_is_game_won_expression(true)
	if player_2.score >= score_needed:
		set_is_game_won_expression(true)
	if game_board.is_board_full():
		state_chart.send_event("draw_game")

func _on_switch_player_state_entered() -> void:
	switch_player()
	# A full round completes when control returns to Player 1
	if does_player_one_play:
		current_round_offer_templates.clear()
		var tx: Array[Effect] = game_board.tick_timers_and_collect_effects()
		if not tx.is_empty():
			game_board.resolve_effects(tx)
			# refresh scores after timer explosions
			var scores := game_board.get_team_scores()
			player_1.score = scores.get(player_1.player_id)
			player_2.score = scores.get(player_2.player_id)
			update_player_score.emit(scores)

func _on_player_turn_state_entered() -> void:
	show_chip_value.emit(true)
	show_score_board.emit(true)
	show_next_chip_ui.emit(true)
	show_main_menu.emit(false)
	var current_player := get_player()
	if current_player == null:
		return
	_discard_unplayed_choices(current_player)
	current_player.current_chip = null
	current_player.selected_choice_index = -1
	var offer_count: int = max(1, chips_per_turn)
	var should_regenerate := does_player_one_play or current_round_offer_templates.is_empty() or current_round_offer_templates.size() != offer_count
	if should_regenerate:
		var generation_rng := RandomNumberGenerator.new()
		generation_rng.randomize()
		current_round_offer_templates = _generate_round_offer_templates(generation_rng, offer_count)
	var choices: Array[ChipInstance] = _instantiate_offer_instances(current_player, current_round_offer_templates)
	current_player.chip_choices = choices
	update_chip_choices.emit(choices)
	if choices.is_empty():
		update_curr_chip.emit(null)
	else:
		choose_chip(0)


func _on_win_state_entered() -> void:
	game_over.emit(get_player().player_id, true, false)

func _on_draw_state_entered() -> void:
	game_over.emit(get_player().player_id, true, true)

func _on_draw_state_exited() -> void:
	draw_label.visible = false


func _on_restart_prompt_state_exited() -> void:
	scroll_background.emit(false)
	clean_up_visuals.emit()
	show_next_chip_ui.emit(false)
