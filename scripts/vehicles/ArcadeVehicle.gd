class_name ArcadeVehicle
extends RigidBody3D

signal driver_changed(driver: PlayerController)

@export_category("Conducción")
@export var engine_force := 28.0
@export var reverse_force := 16.0
@export var max_forward_speed := 24.0
@export var max_reverse_speed := 8.0
@export var steering_power := 1.7
@export var lateral_grip := 5.0
@export var brake_strength := 7.0
@export var exit_offset := Vector3(2.0, 0.2, 0.0)

var driver: PlayerController
var throttle := 0.0
var steering := 0.0
var model: Node3D
const SEDAN_MODEL := preload("res://assets/models/third_party/kenney_car_kit/sedan.glb")

func _ready() -> void:
	add_to_group("vehicles")
	mass = 1100.0
	linear_damp = 0.18
	angular_damp = 3.0
	lock_rotation = false
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	contact_monitor = true
	max_contacts_reported = 8
	_create_visual_model()

func _physics_process(delta: float) -> void:
	if driver:
		_read_driver_input()
		_apply_arcade_drive(delta)
		if Input.is_action_just_pressed("exit_vehicle"):
			release_driver()
	else:
		throttle = 0.0
		steering = 0.0

func _read_driver_input() -> void:
	throttle = Input.get_axis("brake", "accelerate")
	steering = Input.get_axis("steer_left", "steer_right")

func _apply_arcade_drive(delta: float) -> void:
	var forward := -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	var forward_speed := linear_velocity.dot(forward)
	var lateral_speed := linear_velocity.dot(right)
	var allowed_speed := max_forward_speed if throttle >= 0.0 else max_reverse_speed
	var force := engine_force if throttle >= 0.0 else reverse_force
	if absf(forward_speed) < allowed_speed or signf(throttle) != signf(forward_speed):
		apply_central_force(forward * throttle * force * mass * delta)
	if absf(throttle) < 0.05:
		linear_velocity = linear_velocity.move_toward(Vector3.ZERO, brake_strength * delta)
	linear_velocity -= right * lateral_speed * min(lateral_grip * delta, 0.85)
	var steering_factor := clamp(absf(forward_speed) / 5.0, 0.25, 1.0)
	angular_velocity.y = lerp(angular_velocity.y, -steering * steering_power * steering_factor, min(7.0 * delta, 1.0))

func request_driver(player: PlayerController) -> void:
	if driver:
		GameState.show_toast("Ese carro ya está ocupado.")
		return
	driver = player
	driver.enter_vehicle(self)
	driver_changed.emit(driver)

func release_driver() -> void:
	if not driver:
		return
	var leaving_driver := driver
	driver = null
	var exit_position := global_position + global_transform.basis * exit_offset
	exit_position.y += 0.7
	leaving_driver.leave_vehicle(exit_position)
	driver_changed.emit(null)

func get_speed_kmh() -> int:
	return roundi(linear_velocity.length() * 3.6)

func _create_visual_model() -> void:
	model = SEDAN_MODEL.instantiate() as Node3D
	model.name = "SedanModel"
	model.scale = Vector3(0.95, 0.95, 0.95)
	model.rotation_degrees.y = 180.0
	add_child(model)
