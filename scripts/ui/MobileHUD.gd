extends CanvasLayer

var held_actions: Dictionary = {}
var dialogue_lines: Array[String] = []
var dialogue_index := 0
@onready var objective_title: Label = %ObjectiveTitle
@onready var objective_detail: Label = %ObjectiveDetail
@onready var money_label: Label = %MoneyLabel
@onready var status_label: Label = %StatusLabel
@onready var toast_panel: PanelContainer = %ToastPanel
@onready var toast_label: Label = %ToastLabel
@onready var toast_timer: Timer = %ToastTimer
@onready var dialogue_panel: PanelContainer = %DialoguePanel
@onready var dialogue_speaker: Label = %DialogueSpeaker
@onready var dialogue_text: Label = %DialogueText
@onready var next_dialogue_button: Button = %NextDialogueButton

func _ready() -> void:
	_bind_action_button(%ForwardButton, "move_forward")
	_bind_action_button(%BackButton, "move_back")
	_bind_action_button(%LeftButton, "move_left")
	_bind_action_button(%RightButton, "move_right")
	_bind_action_button(%JumpButton, "jump")
	_bind_action_button(%InteractButton, "interact")
	_bind_action_button(%ExitButton, "exit_vehicle")
	_bind_tap_action(%ActionButton, "action")
	next_dialogue_button.pressed.connect(_advance_dialogue)
	GameState.objective_changed.connect(_set_objective)
	GameState.toast_requested.connect(show_toast)
	GameState.money_changed.connect(_set_money)
	GameState.player_vehicle_changed.connect(_set_vehicle_mode)
	GameState.dialogue_requested.connect(_open_dialogue)
	GameState.wanted_changed.connect(_set_wanted)
	_set_objective("La última llamada", "Encontrá a La Chela en el Mercado Oriental.")
	_set_money(GameState.money)
	_set_wanted(GameState.wanted_level)
	_set_vehicle_mode(false)
	toast_panel.hide()
	dialogue_panel.hide()

func _process(_delta: float) -> void:
	if GameState.active_vehicle and GameState.active_vehicle.has_method("get_speed_kmh"):
		status_label.text = "%03d km/h" % GameState.active_vehicle.get_speed_kmh()
	else:
		status_label.text = "A PIE"
	if GameState.dialogue_open and Input.is_action_just_pressed("interact"):
		_advance_dialogue()

func _bind_action_button(button: BaseButton, action: String) -> void:
	button.button_down.connect(func() -> void: _press_action(action))
	button.button_up.connect(func() -> void: _release_action(action))
	button.mouse_exited.connect(func() -> void: _release_action(action))

func _bind_tap_action(button: BaseButton, action: String) -> void:
	button.pressed.connect(func() -> void: _tap_action(action))

func _press_action(action: String) -> void:
	if held_actions.get(action, false):
		return
	held_actions[action] = true
	Input.action_press(action)

func _release_action(action: String) -> void:
	if not held_actions.get(action, false):
		return
	held_actions[action] = false
	Input.action_release(action)

func _tap_action(action: String) -> void:
	Input.action_press(action)
	await get_tree().create_timer(0.08).timeout
	Input.action_release(action)

func _set_objective(title: String, detail: String) -> void:
	objective_title.text = title
	objective_detail.text = detail

func _set_money(value: int) -> void:
	money_label.text = "C$ %d" % value

func _set_wanted(level: int) -> void:
	if level <= 0:
		status_label.modulate = Color(0.80, 0.92, 1.0, 1.0)
		return
	status_label.text = "ALERTA " + "★".repeat(level)
	status_label.modulate = Color(1.0, 0.30, 0.22, 1.0)

func _set_vehicle_mode(active: bool) -> void:
	%ExitButton.visible = active
	%JumpButton.visible = not active
	%ActionButton.visible = not active

func show_toast(message: String, duration := 2.6) -> void:
	toast_label.text = message
	toast_panel.show()
	toast_timer.start(duration)

func _on_toast_timer_timeout() -> void:
	toast_panel.hide()

func _open_dialogue(speaker: String, lines: Array[String]) -> void:
	dialogue_lines = lines
	dialogue_index = 0
	dialogue_speaker.text = speaker
	dialogue_panel.show()
	_update_dialogue_line()

func _update_dialogue_line() -> void:
	if dialogue_lines.is_empty():
		return
	dialogue_text.text = dialogue_lines[dialogue_index]
	next_dialogue_button.text = "CONTINUAR" if dialogue_index < dialogue_lines.size() - 1 else "CERRAR"

func _advance_dialogue() -> void:
	if dialogue_index < dialogue_lines.size() - 1:
		dialogue_index += 1
		_update_dialogue_line()
	else:
		dialogue_panel.hide()
		GameState.close_dialogue()
