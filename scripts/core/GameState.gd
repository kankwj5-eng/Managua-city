extends Node

signal objective_changed(title: String, detail: String)
signal toast_requested(message: String, duration: float)
signal dialogue_requested(speaker: String, lines: Array[String])
signal dialogue_closed
signal money_changed(value: int)
signal player_vehicle_changed(active: bool)
signal mission_completed(mission_id: String)
signal action_fired(origin: Vector3, direction: Vector3)
signal wanted_changed(level: int)
signal sound_requested(kind: String)

var money: int = 0
var active_vehicle: Node3D
var player: Node3D
var current_mission_id := ""
var current_objective := ""
var wanted_level := 0
var dialogue_open := false

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
	_register_key_action("action", KEY_Q)
	_register_key_action("sprint", KEY_SHIFT)
	_register_key_action("accelerate", KEY_W)
	_register_key_action("brake", KEY_S)
	_register_key_action("steer_left", KEY_A)
	_register_key_action("steer_right", KEY_D)
	_register_key_action("exit_vehicle", KEY_F)

func _register_key_action(action: StringName, key: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == key:
			return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = key
	InputMap.action_add_event(action, key_event)

func set_objective(title: String, detail: String) -> void:
	current_objective = title
	objective_changed.emit(title, detail)

func show_toast(message: String, duration := 2.6) -> void:
	toast_requested.emit(message, duration)

func show_dialogue(speaker: String, lines: Array[String]) -> void:
	if lines.is_empty():
		return
	dialogue_open = true
	dialogue_requested.emit(speaker, lines)
	sound_requested.emit("dialogue")

func close_dialogue() -> void:
	if not dialogue_open:
		return
	dialogue_open = false
	dialogue_closed.emit()

func add_money(amount: int) -> void:
	money = max(0, money + amount)
	money_changed.emit(money)

func set_vehicle(vehicle: Node3D) -> void:
	active_vehicle = vehicle
	player_vehicle_changed.emit(active_vehicle != null)

func finish_mission(mission_id: String) -> void:
	current_mission_id = mission_id
	mission_completed.emit(mission_id)

func raise_wanted_level(amount := 1) -> void:
	wanted_level = clamp(wanted_level + amount, 0, 3)
	wanted_changed.emit(wanted_level)

func clear_wanted_level() -> void:
	wanted_level = 0
	wanted_changed.emit(wanted_level)
