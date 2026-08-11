extends CharacterBody3D

enum State { PATROL, INVESTIGATE, CHASE, ATTACK, SEARCH }

@export var patrol_radius: float = 8.0
@export var speed: float = 2.5
@export var chase_speed: float = 4.0
@export var attack_range: float = 1.8
@export var sight_range: float = 28.0
@export var lose_range: float = 42.0
@export var damage_per_second: float = 12.0
@export var health: float = 45.0
@export var gravity_multiplier: float = 1.5

var home_position := Vector3.ZERO
var target: Node3D
var investigation_point := Vector3.ZERO
var patrol_angle := 0.0
var state: State = State.PATROL
var search_timer := 0.0
var navigation_agent: NavigationAgent3D
var gravity := ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

func _ready() -> void:
	name = "RedanePatrol"
	home_position = global_position
	investigation_point = home_position
	collision_layer = 2
	collision_mask = 1
	_add_collision_and_visuals()
	_add_navigation_agent()

func _physics_process(delta: float) -> void:
	_apply_state(delta)
	_apply_gravity(delta)
	move_and_slide()

func alert_to(new_target: Node3D) -> void:
	target = new_target
	state = State.CHASE

func investigate(point: Vector3) -> void:
	investigation_point = point
	state = State.INVESTIGATE
	search_timer = 4.0

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		queue_free()

func _apply_state(delta: float) -> void:
	match state:
		State.PATROL:
			_patrol(delta)
			_try_spot_player()
		State.INVESTIGATE:
			_move_to(investigation_point, speed)
			if global_position.distance_to(investigation_point) < 1.2:
				state = State.SEARCH
		State.CHASE:
			_chase(delta)
		State.ATTACK:
			_attack(delta)
		State.SEARCH:
			_search(delta)

func _patrol(delta: float) -> void:
	patrol_angle += delta * 0.45
	var destination := home_position + Vector3(cos(patrol_angle), 0, sin(patrol_angle)) * patrol_radius
	_move_to(destination, speed)

func _chase(_delta: float) -> void:
	if not target or not is_instance_valid(target):
		state = State.SEARCH
		return
	var distance := global_position.distance_to(target.global_position)
	if distance <= attack_range:
		state = State.ATTACK
	elif distance > lose_range:
		investigation_point = target.global_position
		state = State.SEARCH
		search_timer = 5.0
	else:
		_move_to(target.global_position, chase_speed)

func _attack(delta: float) -> void:
	if not target or not is_instance_valid(target):
		state = State.SEARCH
		return
	var distance := global_position.distance_to(target.global_position)
	if distance > attack_range * 1.35:
		state = State.CHASE
		return
	velocity.x = move_toward(velocity.x, 0.0, chase_speed * delta * 4.0)
	velocity.z = move_toward(velocity.z, 0.0, chase_speed * delta * 4.0)
	PlayerStats.take_damage(damage_per_second * delta)

func _search(delta: float) -> void:
	search_timer -= delta
	_move_to(investigation_point, speed)
	_try_spot_player()
	if search_timer <= 0.0:
		target = null
		state = State.PATROL

func _try_spot_player() -> void:
	var player := get_node_or_null("/root/Main/Player")
	if player and global_position.distance_to(player.global_position) <= sight_range:
		alert_to(player)

func _move_to(destination: Vector3, move_speed: float) -> void:
	var next_position := destination
	if navigation_agent:
		navigation_agent.target_position = destination
		if not navigation_agent.is_navigation_finished():
			next_position = navigation_agent.get_next_path_position()
	var direction := next_position - global_position
	direction.y = 0
	if direction.length() > 0.2:
		var normalized := direction.normalized()
		velocity.x = normalized.x * move_speed
		velocity.z = normalized.z * move_speed
		rotation.y = lerp_angle(rotation.y, atan2(-normalized.x, -normalized.z), 0.12)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta
	else:
		velocity.y = -0.1

func _add_navigation_agent() -> void:
	navigation_agent = NavigationAgent3D.new()
	navigation_agent.name = "NavigationAgent3D"
	navigation_agent.path_desired_distance = 0.6
	navigation_agent.target_desired_distance = 1.0
	add_child(navigation_agent)

func _add_collision_and_visuals() -> void:
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	shape.position.y = 0.85
	shape.shape = capsule
	add_child(shape)
	var visual := MeshInstance3D.new()
	visual.name = "RedaneSilhouette"
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.35
	mesh.height = 1.7
	visual.mesh = mesh
	visual.position.y = 0.85
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.8, 0.05, 0.05, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.45, 0.02, 0.02)
	visual.material_override = material
	add_child(visual)
