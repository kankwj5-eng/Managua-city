extends CharacterBody3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var ROTATION_SPEED = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

@onready var camera_pivot = $"../CameraPivot"
@onready var visual_node = $personaje_relieve

func _ready():
	# Ensure correct collision layers/masks
	# Player can be on layer 1, and mask layer 1 (world)
	collision_layer = 1
	collision_mask = 1

func _physics_process(delta):
	# Update CameraPivot position to follow the player
	if camera_pivot:
		camera_pivot.global_position = global_position

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

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

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Smoothly rotate the character visual towards the movement direction
		var target_rotation_y = atan2(-direction.x, -direction.z)
		if visual_node:
			# Smoothly interpolate character visual rotation
			visual_node.rotation.y = rotate_toward(visual_node.rotation.y, target_rotation_y, ROTATION_SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

# Also support basic touch dragging / mouse drag for look-around
func _unhandled_input(event):
	if event is InputEventScreenDrag or (event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		if camera_pivot:
			# Rotate camera pivot horizontally and vertically based on swipe/drag
			camera_pivot.rotation.y -= event.relative.x * 0.005
			camera_pivot.rotation.x -= event.relative.y * 0.005
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -1.2, 0.5) # Clamp pitch to avoid flipping
