class_name ThirdPersonCamera
extends Node3D

@export var sensitivity := 0.010
@export var min_pitch := deg_to_rad(-52.0)
@export var max_pitch := deg_to_rad(18.0)
@export var follow_speed := 9.0
@export var default_distance := 5.4
@export var vehicle_distance := 7.2

var yaw := 0.0
var pitch := deg_to_rad(-14.0)
var target: Node3D
var vehicle_mode := false
@onready var spring_arm: SpringArm3D = $SpringArm3D

func _ready() -> void:
	target = get_parent() as Node3D
	_apply_rotation()
	GameState.player_vehicle_changed.connect(_on_player_vehicle_changed)

func _process(delta: float) -> void:
	if not target:
		return
	global_position = global_position.lerp(target.global_position, clamp(follow_speed * delta, 0.0, 1.0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_rotate_from_delta(event.relative)
	elif event is InputEventScreenDrag and event.position.x > get_viewport().get_visible_rect().size.x * 0.44:
		_rotate_from_delta(event.relative)

func _rotate_from_delta(delta: Vector2) -> void:
	yaw -= delta.x * sensitivity
	pitch = clamp(pitch - delta.y * sensitivity, min_pitch, max_pitch)
	_apply_rotation()

func _apply_rotation() -> void:
	rotation = Vector3(pitch, yaw, 0.0)

func set_target(new_target: Node3D, use_vehicle_distance := false) -> void:
	target = new_target
	vehicle_mode = use_vehicle_distance
	spring_arm.spring_length = vehicle_distance if vehicle_mode else default_distance

func _on_player_vehicle_changed(active: bool) -> void:
	if active and GameState.active_vehicle:
		set_target(GameState.active_vehicle, true)
	elif GameState.player:
		set_target(GameState.player, false)
