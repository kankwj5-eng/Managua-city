extends SpringArm3D

@export var target: Node3D
@export var sensitivity: float = 0.005
@export var smooth_speed: float = 5.0
@export var min_pitch: float = -1.2
@export var max_pitch: float = 0.5

var rot_x: float = 0.0
var rot_y: float = 0.0

func _ready():
	# Reducir spring_length de 5.0 a un valor entre 2.5 y 3.0
	spring_length = 2.8

	if not target:
		target = get_node_or_null("/root/Main/Player")
		if not target:
			target = get_node_or_null("../../Player")

	# Explicitly exclude player from collision checks
	if target:
		add_excluded_object(target.get_rid())

	# Ensure correct collision mask (detect environment/map, but exclude player layer)
	# Default collision_mask is 1. If player is on layer 1, RID exclusion ensures the player is ignored.
	collision_mask = 1

	# Set process physics priority to 0 (which runs after the player's -10)
	process_physics_priority = 0

	# Initialize rotations based on current parent rotation
	var parent = get_parent()
	if parent:
		rot_x = parent.rotation.x
		rot_y = parent.rotation.y

func _physics_process(delta):
	if target:
		var parent = get_parent()
		if parent:
			# Agregar suavizado (lerp) al seguimiento de la cámara sobre el personaje,
			# usando delta para que no se sienta brusca
			parent.global_position = parent.global_position.lerp(target.global_position, clamp(smooth_speed * delta, 0.0, 1.0))

			# Apply horizontal/vertical rotations smoothly or directly
			parent.rotation.x = rot_x
			parent.rotation.y = rot_y

func _unhandled_input(event):
	if event is InputEventScreenDrag or (event is InputEventMouseMotion and (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)):
		# Permitir rotación libre de cámara con el input de mouse/touch,
		# con límites verticales (no dejar que gire 360° en el eje X)
		rot_y -= event.relative.x * sensitivity
		rot_x -= event.relative.y * sensitivity
		rot_x = clamp(rot_x, min_pitch, max_pitch)
