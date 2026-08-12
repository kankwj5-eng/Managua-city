class_name PlayerController
extends CharacterBody3D

signal interaction_requested

@export_category("Movimiento")
@export var walk_speed := 5.2
@export var sprint_speed := 7.4
@export var acceleration := 18.0
@export var air_control := 5.0
@export var jump_velocity := 6.5
@export var interaction_distance := 4.0

var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float
var input_enabled := true
var current_vehicle: Node
@onready var visual: Node3D = $Visual
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var camera_pivot: Node3D = $CameraPivot

func _ready() -> void:
	GameState.player = self
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not input_enabled:
		return
	_apply_gravity(delta)
	_move_from_input(delta)
	if Input.is_action_just_pressed("interact"):
		_try_interact()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

func _move_from_input(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var basis := camera_pivot.global_transform.basis
	var forward := -basis.z
	var right := basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	var desired_direction := (right * input_vector.x + forward * input_vector.y).normalized()
	var target_speed := sprint_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed
	var target_velocity := desired_direction * target_speed
	var control := acceleration if is_on_floor() else air_control
	velocity.x = move_toward(velocity.x, target_velocity.x, control * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, control * delta)
	if desired_direction.length_squared() > 0.01:
		var target_rotation := atan2(-desired_direction.x, -desired_direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_rotation, min(12.0 * delta, 1.0))
	move_and_slide()

func _try_interact() -> void:
	interaction_requested.emit()
	var closest_vehicle: Node = null
	var closest_distance := interaction_distance
	for vehicle in get_tree().get_nodes_in_group("vehicles"):
		if not vehicle.has_method("request_driver"):
			continue
		var distance := global_position.distance_to(vehicle.global_position)
		if distance < closest_distance:
			closest_vehicle = vehicle
			closest_distance = distance
	if closest_vehicle:
		closest_vehicle.request_driver(self)
		return
	GameState.show_toast("No hay nada cerca para usar.")

func enter_vehicle(vehicle: Node) -> void:
	current_vehicle = vehicle
	input_enabled = false
	visible = false
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)
	GameState.set_vehicle(vehicle)
	GameState.show_toast("Subiste al carro. F para bajarte.")

func leave_vehicle(exit_position: Vector3) -> void:
	global_position = exit_position
	current_vehicle = null
	visible = true
	collision_shape.set_deferred("disabled", false)
	input_enabled = true
	set_physics_process(true)
	GameState.set_vehicle(null)
	GameState.show_toast("Bajaste del carro.")
