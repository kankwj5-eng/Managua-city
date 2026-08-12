extends Node

signal objective_changed(title: String, detail: String)
signal toast_requested(message: String, duration: float)
signal money_changed(value: int)
signal player_vehicle_changed(active: bool)
signal mission_completed(mission_id: String)

var money: int = 0
var active_vehicle: Node3D
var player: Node3D
var current_mission_id := ""
var current_objective := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configure_input_actions()

func _configure_input_actions() -> void:
	_register_key_action("move_forward", KEY_W)
	_register_key_action("move_back", KEY_S)
	_register_key_action("move_left", KEY_A)
	_register_key_action("move_right", KEY_D)
	_register_key_action("jump", KEY_SPACE)
	_register_key_action("interact", KEY_E)
	_register_key_action("accelerate", KEY_W)
	_register_key_action("brake", KEY_S)
	_register_key_action("steer_left", KEY_A)
	_register_key_action("steer_right", KEY_D)
	_register_key_action("exit_vehicle", KEY_F)

func _register_key_action(action: StringName, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_add_event(action, event)

func set_objective(title: String, detail: String) -> void:
	current_objective = title
	objective_changed.emit(title, detail)

func show_toast(message: String, duration := 2.6) -> void:
	toast_requested.emit(message, duration)

func add_money(amount: int) -> void:
	money = max(0, money + amount)
	money_changed.emit(money)

func set_vehicle(vehicle: Node3D) -> void:
	active_vehicle = vehicle
	player_vehicle_changed.emit(active_vehicle != null)

func finish_mission(mission_id: String) -> void:
	current_mission_id = mission_id
	mission_completed.emit(mission_id)
