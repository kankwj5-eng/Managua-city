extends Node3D

@export var sensitivity := 0.009
@export var min_pitch := deg_to_rad(-42.0)
@export var max_pitch := deg_to_rad(16.0)
@export var follow_speed := 12.0
@export var rotation_speed := 14.0
@export var default_distance := 5.2
@export var vehicle_distance := 7.2

var yaw := 0.0
var pitch := deg_to_rad(-12.0)
var target_yaw := 0.0
var target_pitch := deg_to_rad(-12.0)
var target: Node3D
var vehicle_mode := false
@onready var spring_arm: SpringArm3D = $SpringArm3D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	target = get_parent() as Node3D
	rotation = Vector3(pitch, yaw, 0.0)
	GameState.player_vehicle_changed.connect(_on_player_vehicle_changed)

func _process(delta: float) -> void:
	if not target:
		return
	global_position = global_position.lerp(target.global_position, clamp(follow_speed * delta, 0.0, 1.0))
	yaw = lerp_angle(yaw, target_yaw, clamp(rotation_speed * delta, 0.0, 1.0))
	pitch = lerp(pitch, target_pitch, clamp(rotation_speed * delta, 0.0, 1.0))
	rotation = Vector3(pitch, yaw, 0.0)

func _unhandled_input(event: InputEvent) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_rotate_from_delta(event.relative)
	elif event is InputEventScreenDrag:
		var is_look_area := event.position.x > viewport_size.x * 0.42 and event.position.y < viewport_size.y * 0.76
		if is_look_area:
			_rotate_from_delta(event.relative)

func _rotate_from_delta(delta: Vector2) -> void:
	target_yaw -= delta.x * sensitivity
	target_pitch = clamp(target_pitch - delta.y * sensitivity, min_pitch, max_pitch)

func set_target(new_target: Node3D, use_vehicle_distance := false) -> void:
	target = new_target
	vehicle_mode = use_vehicle_distance
	spring_arm.spring_length = vehicle_distance if vehicle_mode else default_distance

func _on_player_vehicle_changed(active: bool) -> void:
	if active and GameState.active_vehicle:
		set_target(GameState.active_vehicle, true)
	elif GameState.player:
		set_target(GameState.player, false)
