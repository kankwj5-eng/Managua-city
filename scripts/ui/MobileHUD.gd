class_name MobileHUD
extends CanvasLayer

var held_actions: Dictionary = {}
@onready var objective_title: Label = %ObjectiveTitle
@onready var objective_detail: Label = %ObjectiveDetail
@onready var money_label: Label = %MoneyLabel
@onready var speed_label: Label = %SpeedLabel
@onready var toast_panel: PanelContainer = %ToastPanel
@onready var toast_label: Label = %ToastLabel
@onready var toast_timer: Timer = %ToastTimer

func _ready() -> void:
	_bind_action_button(%ForwardButton, "accelerate")
	_bind_action_button(%BackButton, "brake")
	_bind_action_button(%LeftButton, "steer_left")
	_bind_action_button(%RightButton, "steer_right")
	_bind_action_button(%JumpButton, "jump")
	_bind_action_button(%InteractButton, "interact")
	_bind_action_button(%ExitButton, "exit_vehicle")
	GameState.objective_changed.connect(_set_objective)
	GameState.toast_requested.connect(show_toast)
	GameState.money_changed.connect(_set_money)
	GameState.player_vehicle_changed.connect(_set_vehicle_mode)
	_set_objective("Bienvenido a Puerto del Sur", "Explora el barrio y buscá el encargo en el mercado.")
	_set_money(GameState.money)
	toast_panel.hide()

func _process(_delta: float) -> void:
	if GameState.active_vehicle and GameState.active_vehicle.has_method("get_speed_kmh"):
		speed_label.text = "%03d km/h" % GameState.active_vehicle.get_speed_kmh()
	else:
		speed_label.text = "A PIE"

func _bind_action_button(button: BaseButton, action: String) -> void:
	button.button_down.connect(func() -> void: _press_action(action))
	button.button_up.connect(func() -> void: _release_action(action))
	button.mouse_exited.connect(func() -> void: _release_action(action))

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

func _set_objective(title: String, detail: String) -> void:
	objective_title.text = title
	objective_detail.text = detail

func _set_money(value: int) -> void:
	money_label.text = "C$ %d" % value

func _set_vehicle_mode(active: bool) -> void:
	%ExitButton.visible = active
	%JumpButton.visible = not active

func show_toast(message: String, duration := 2.6) -> void:
	toast_label.text = message
	toast_panel.show()
	toast_timer.start(duration)

func _on_toast_timer_timeout() -> void:
	toast_panel.hide()
