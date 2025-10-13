extends CanvasLayer
@onready var player_1_score: RichTextLabel = %Player1Score
@onready var player_2_score: RichTextLabel = %Player2Score
@onready var score_board: HBoxContainer = %ScoreBoard
@onready var score_input: LineEdit = %ScoreInput
@onready var grid_x_input: LineEdit = %GridXInput
@onready var grid_y_input: LineEdit = %GridYInput
@onready var next_chip: Label = %NextChip
@onready var next_chip_container: VBoxContainer = %NextChipContainer
@onready var area_2d: Area2D = %Area2D
@onready var hover_panel: Panel = %HoverPanel
@onready var chip_desc: RichTextLabel = %ChipDesc
@onready var chip_choices_title: Label = %ChipChoicesTitle
@onready var chip_offers_input: LineEdit = %ChipOffersInput
@onready var choice_preview_root: Node2D = %ChoicePreviewRoot

var chip_choices: Array[ChipInstance] = []
var selected_chip_index: int = -1
var choice_preview_metadata: Array[Dictionary] = []
const PREVIEW_HORIZONTAL_SPACING := 90.0
const PREVIEW_SCALE_SELECTED := Vector2(0.82, 0.82)
const PREVIEW_SCALE_IDLE := Vector2(0.68, 0.68)
const PREVIEW_DIM_COLOR := Color(0.7, 0.7, 0.7, 1.0)

func _ready() -> void:
	GameManager.update_player_score.connect(update_score_labels)
	GameManager.game_over.connect(set_up_game_over)
	GameManager.show_score_board.connect(func(should_show): %ScoreBoard.visible = should_show)
	GameManager.show_main_menu.connect(func(should_show): %MainMenu.visible = should_show)
	GameManager.show_chip_value.connect(show_chip_label)
	GameManager.update_curr_chip.connect(update_chip_label)
	GameManager.update_chip_choices.connect(update_chip_choices)
	chip_choices_title.visible = false
	
func update_chip_choices(chips):
	chip_choices.clear()
	chip_choices.append_array(chips)
	selected_chip_index = -1
	_rebuild_choice_previews()
	var has_choices := not chip_choices.is_empty()
	chip_choices_title.visible = has_choices
	choice_preview_root.visible = has_choices
	if has_choices:
		_set_selected_chip_index(0, false)
	else:
		_highlight_selected_preview()

func _set_selected_chip_index(index: int, notify_manager: bool) -> void:
	if chip_choices.is_empty():
		selected_chip_index = -1
		_highlight_selected_preview()
		return
	var clamped: int = clamp(index, 0, chip_choices.size() - 1)
	selected_chip_index = clamped
	_highlight_selected_preview()
	if notify_manager:
		GameManager.choose_chip(selected_chip_index)

func _clear_choice_previews() -> void:
	for meta in choice_preview_metadata:
		if meta.has("area") and meta["area"]:
			var area := meta["area"] as Area2D
			if area:
				area.queue_free()
	choice_preview_metadata.clear()
	choice_preview_root.visible = false

func _rebuild_choice_previews() -> void:
	_clear_choice_previews()
	if chip_choices.is_empty():
		return
	var start_x := - (PREVIEW_HORIZONTAL_SPACING * (chip_choices.size() - 1) * 0.5)
	for index in chip_choices.size():
		var choice := chip_choices[index]
		var preview_area := Area2D.new()
		preview_area.position = Vector2(start_x + PREVIEW_HORIZONTAL_SPACING * index, 0)
		preview_area.z_index = 10
		preview_area.input_pickable = true
		choice_preview_root.add_child(preview_area)
		var collision := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 72.0
		collision.shape = circle
		preview_area.add_child(collision)
		var chip_node: ChipInstance = null
		if choice != null:
			chip_node = choice.duplicate()
			chip_node.position = Vector2.ZERO
			chip_node.scale = PREVIEW_SCALE_IDLE
			if chip_node.has_method("apply_player_color"):
				chip_node.apply_player_color(choice.color)
			preview_area.add_child(chip_node)
		preview_area.connect("input_event", Callable(self, "_on_preview_input").bind(index))
		var entry := {
			"area": preview_area,
			"chip_node": chip_node
		}
		choice_preview_metadata.append(entry)
	choice_preview_root.visible = true

func _highlight_selected_preview() -> void:
	if choice_preview_metadata.is_empty():
		return
	for idx in choice_preview_metadata.size():
		var meta: Dictionary = choice_preview_metadata[idx]
		if not meta.has("chip_node"):
			continue
		var chip_node: ChipInstance = meta.chip_node
		if chip_node == null:
			continue
		var is_selected := idx == selected_chip_index
		chip_node.scale = PREVIEW_SCALE_SELECTED if is_selected else PREVIEW_SCALE_IDLE
		chip_node.modulate = Color.WHITE if is_selected else PREVIEW_DIM_COLOR

func _on_preview_input(viewport, event: InputEvent, _shape_idx: int, preview_index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_set_selected_chip_index(preview_index, true)


func update_score_labels(scores):
	var p1_score = scores.get(Chip.Ownership.PLAYER_ONE)
	var p2_score = scores.get(Chip.Ownership.PLAYER_TWO)
	player_1_score.set_final_value(p1_score)
	player_2_score.set_final_value(p2_score)

func set_up_game_over(player_id: int, shouldShow: bool):
	if shouldShow:
		%GameOver.show()
	else:
		%GameOver.hide()
	%ResultText.text = "[wave amp=50.0 freq=5.0 connected=1]Player " + str(player_id) + " has won![/wave]"

func start_game():
	GameManager.score_needed = int(score_input.text)
	GameManager.BOARD_WIDTH = int(grid_x_input.text)
	GameManager.BOARD_HEIGHT = int(grid_y_input.text)
	var offers := int(chip_offers_input.text)
	if offers <= 0:
		offers = 1
	GameManager.chips_per_turn = offers
	GameManager.start_game()

func restart_game():
	GameManager.state_chart.send_event("restart_game")

func _on_score_sub_pressed() -> void:
	score_input.text = str(int(score_input.text) - 1)

func _on_score_add_pressed() -> void:
	score_input.text = str(int(score_input.text) + 1)

func update_chip_label(chip: ChipInstance) -> void:
	for child in %SpawnMarker.get_children():
		child.queue_free()
	if chip == null:
		chip_desc.text = ""
		_highlight_selected_preview()
		return
	var duplicate := chip.duplicate()
	duplicate.position = Vector2.ZERO
	duplicate.scale = Vector2.ONE
	%SpawnMarker.add_child(duplicate)
	if duplicate.ChipResource != null:
		chip_desc.text = duplicate.ChipResource.description
	else:
		chip_desc.text = ""
	var idx := chip_choices.find(chip)
	if idx != -1:
		_set_selected_chip_index(idx, false)
	else:
		_highlight_selected_preview()
	
func show_chip_label(show):
	next_chip.visible = show
	%SpawnMarker.visible = show
	%Area2D.visible = show
	chip_choices_title.visible = show and not chip_choices.is_empty()
	choice_preview_root.visible = show and not chip_choices.is_empty()
	if not show:
		hover_panel.visible = false

func _on_area_2d_mouse_entered() -> void:
	hover_panel.visible = true

func _on_area_2d_mouse_exited() -> void:
	hover_panel.visible = false
