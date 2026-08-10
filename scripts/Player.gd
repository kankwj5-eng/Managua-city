extends CharacterBody3D

@export var SPEED = 5.0
@export var ACCELERATION = 15.0
@export var DECELERATION = 20.0
@export var JUMP_VELOCITY = 6.0
@export var ROTATION_SPEED = 10.0

# Gravity configurations for weightier jump
@export var RISE_GRAVITY_MULTIPLIER = 1.0
@export var FALL_GRAVITY_MULTIPLIER = 1.8

# Get the gravity from the project settings to be synced with RigidBody nodes.
var base_gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

@onready var camera_pivot = $"../CameraPivot"
@onready var visual_node = $personaje_relieve

# Reference to animation player/tree if they exist in the visual node
var animation_player: AnimationPlayer = null
var animation_tree: AnimationTree = null

func _ready():
	# Ensure correct collision layers/masks
	# Player can be on layer 1, and mask layer 1 (world)
	collision_layer = 1
	collision_mask = 1

	# Safely scan for AnimationPlayer or AnimationTree inside the visual_node
	if visual_node:
		_find_animations(visual_node)

func _find_animations(node: Node):
	if node is AnimationPlayer:
		animation_player = node
	elif node is AnimationTree:
		animation_tree = node
	for child in node.get_children():
		_find_animations(child)

func _physics_process(delta):
	# Update CameraPivot position to follow the player
	if camera_pivot:
		camera_pivot.global_position = global_position

	# Add variable gravity.
	# Add the gravity.
	if not is_on_floor():
		var current_gravity = base_gravity
		if velocity.y < 0:
			# Stronger gravity when falling
			current_gravity *= FALL_GRAVITY_MULTIPLIER
		else:
			# Gravity when rising
			current_gravity *= RISE_GRAVITY_MULTIPLIER
		velocity.y -= current_gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# We use basic WASD keys / Arrow keys mapping or generic ui_ actions.
	var input_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_dir.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_dir.x += 1.0

	# Standard input normalization
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()

	# Rotate movement vector relative to camera rotation
	var direction = Vector3.ZERO
	if camera_pivot:
		var camera_rot_y = camera_pivot.global_transform.basis.get_euler().y
		direction = (Transform3D().rotated(Vector3.UP, camera_rot_y) * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	else:
		direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	# Smooth horizontal velocity using move_toward() with ACCELERATION and DECELERATION
	if direction:
		var target_velocity_x = direction.x * SPEED
		var target_velocity_z = direction.z * SPEED
		velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, target_velocity_z, ACCELERATION * delta)

		# Smoothly rotate the character visual towards the movement direction using lerp_angle
		var target_rotation_y = atan2(-direction.x, -direction.z)
		if visual_node:
			# Smoothly interpolate character visual rotation using lerp_angle
			visual_node.rotation.y = lerp_angle(visual_node.rotation.y, target_rotation_y, ROTATION_SPEED * delta)
	else:
		# Decelerate when there's no input
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)

	move_and_slide()

	# Update animations if an AnimationPlayer or AnimationTree is present
	_update_animations()

# Safe update of animations depending on the state of movement
func _update_animations():
	# If there is an AnimationTree, we might set parameters. Let's provide standard state mapping for both
	# We'll support idle, caminar (walk), correr (run), saltar (jump)
	# Check horizontal speed
	var speed_h = Vector2(velocity.x, velocity.z).length()
	var state = "idle"

	if not is_on_floor():
		state = "saltar"
	elif speed_h > 0.1:
		if speed_h > (SPEED * 0.8):
			state = "correr"
		else:
			state = "caminar"
	else:
		state = "idle"

	# Safe play on AnimationPlayer if it exists and has the requested animation
	if animation_player:
		if animation_player.has_animation(state):
			if animation_player.current_animation != state:
				animation_player.play(state)
		elif state == "correr" and animation_player.has_animation("caminar"):
			# Fallback if correr doesn't exist but caminar does
			if animation_player.current_animation != "caminar":
				animation_player.play("caminar")
		elif state == "saltar" and animation_player.has_animation("idle"):
			# Fallback for jump
			if animation_player.current_animation != "idle":
				animation_player.play("idle")

	# Safe set on AnimationTree if it exists
	if animation_tree:
		# Standard setups for AnimationTree: either a state machine or blend space
		# We can set parameters like "parameters/playback" or state variables if they exist.
		var playback = animation_tree.get("parameters/playback")
		if playback and playback is AnimationNodeStateMachinePlayback:
			if playback.has_node(state):
				playback.travel(state)
			elif state == "correr" and playback.has_node("caminar"):
				playback.travel("caminar")
			elif state == "saltar" and playback.has_node("idle"):
				playback.travel("idle")
		else:
			# Set blend/state parameters if set up directly
			animation_tree.set("parameters/state", state)
			animation_tree.set("parameters/speed", speed_h)
			animation_tree.set("parameters/is_on_floor", is_on_floor())

# Also support basic touch dragging / mouse drag for look-around
func _unhandled_input(event):
	if event is InputEventScreenDrag or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		if camera_pivot:
			# Rotate camera pivot horizontally and vertically based on swipe/drag
			camera_pivot.rotation.y -= event.relative.x * 0.005
			camera_pivot.rotation.x -= event.relative.y * 0.005
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.2, 0.5) # Clamp pitch to avoid flipping
