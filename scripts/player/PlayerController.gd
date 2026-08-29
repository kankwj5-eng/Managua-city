extends CharacterBody3D

signal interaction_requested

@export_category("Movimiento")
@export var walk_speed := 4.8
@export var sprint_speed := 7.0
@export var acceleration := 22.0
@export var air_control := 6.0
@export var jump_velocity := 6.2
@export var interaction_distance := 3.4
@export var action_cooldown := 0.55

var gravity := ProjectSettings.get_setting("physics/3d/default_gravity") as float
var input_enabled := true
var current_vehicle: Node
var action_timer := 0.0
var aim_flash_timer := 0.0
@onready var visual: Node3D = $Visual
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var weapon: Node3D = $Visual/Weapon

func _ready() -> void:
	GameState.player = self
	add_to_group("player")
	weapon.visible = false

func _physics_process(delta: float) -> void:
	if action_timer > 0.0:
		action_timer -= delta
	if aim_flash_timer > 0.0:
		aim_flash_timer -= delta
		if aim_flash_timer <= 0.0:
			weapon.visible = false
	if not input_enabled:
		return
	_apply_gravity(delta)
	_move_from_input(delta)
	if Input.is_action_just_pressed("interact"):
		_try_interact()
	if Input.is_action_just_pressed("action"):
		_fire_weapon()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
		GameState.sound_requested.emit("jump")

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
	var target_speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
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
	var actor_position := global_position
	var nearest_npc: Node3D
	var nearest_distance := interaction_distance
	for candidate in get_tree().get_nodes_in_group("interactive_npc"):
		if not is_instance_valid(candidate):
			continue
		var distance := actor_position.distance_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_npc = candidate
			nearest_distance = distance
	if nearest_npc and nearest_npc.has_method("interact"):
		nearest_npc.interact(self)
		return
	var closest_vehicle: Node
	nearest_distance = interaction_distance
	for vehicle in get_tree().get_nodes_in_group("vehicles"):
		if not vehicle.has_method("request_driver"):
			continue
		var distance := actor_position.distance_to(vehicle.global_position)
		if distance < nearest_distance:
			closest_vehicle = vehicle
			nearest_distance = distance
	if closest_vehicle:
		closest_vehicle.request_driver(self)
		return
	GameState.show_toast("No hay nada cerca para usar.")

func _fire_weapon() -> void:
	if action_timer > 0.0 or GameState.dialogue_open:
		return
	action_timer = action_cooldown
	weapon.visible = true
	aim_flash_timer = 0.12
	GameState.action_fired.emit(global_position + Vector3.UP * 1.1, -global_transform.basis.z)
	GameState.sound_requested.emit("shot")
	GameState.raise_wanted_level(1)
	GameState.show_toast("¡Pilas! Disparo de prueba. La policía ya está alerta.", 2.0)

func enter_vehicle(vehicle: Node) -> void:
	current_vehicle = vehicle
	input_enabled = false
	visible = false
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)
	GameState.set_vehicle(vehicle)
	GameState.show_toast("Subiste al carro. Tocá BAJAR para salir.")

func leave_vehicle(exit_position: Vector3) -> void:
	global_position = exit_position
	current_vehicle = null
	visible = true
	collision_shape.set_deferred("disabled", false)
	input_enabled = true
	set_physics_process(true)
	GameState.set_vehicle(null)
	GameState.show_toast("Bajaste del carro.")
