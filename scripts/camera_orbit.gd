extends Camera3D

@export var target_path: NodePath = NodePath("../NPC")
@export var distance := 9.0
@export var height := 4.2
@export var look_sensitivity := 0.012
@export var follow_speed := 7.0
@export var min_pitch := -55.0
@export var max_pitch := 35.0
var yaw := 0.0
var pitch := deg_to_rad(-12.0)
var dragging := false

func _ready() -> void:
    current = true

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        dragging = event.pressed
    elif event is InputEventMouseMotion and dragging:
        yaw -= event.relative.x * look_sensitivity
        pitch = clamp(pitch - event.relative.y * look_sensitivity, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
    elif event is InputEventScreenDrag:
        yaw -= event.relative.x * look_sensitivity
        pitch = clamp(pitch - event.relative.y * look_sensitivity, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func _process(delta: float) -> void:
    var target := get_node_or_null(target_path) as Node3D
    if target == null:
        return
    var focus := target.global_position + Vector3.UP * height
    var orbit := Vector3(
        cos(pitch) * sin(yaw) * distance,
        sin(pitch) * distance,
        cos(pitch) * cos(yaw) * distance
    )
    global_position = global_position.lerp(focus + orbit, delta * follow_speed)
    look_at(focus, Vector3.UP)
