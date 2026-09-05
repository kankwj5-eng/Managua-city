extends Node3D

@export var walk_speed := 6.0
@export var run_speed := 11.0
@export var acceleration := 24.0
@export var braking := 30.0
@export var turn_speed := 10.0
var _velocity := Vector3.ZERO
var _angle := 0.0
var _step_time := 0.0

func _process(delta: float) -> void:
    var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var touch := get_node_or_null("/root/ManaguaCity/TouchControls")
    var sprinting := Input.is_action_pressed("sprint")
    if touch and touch.has_method("get_direction"):
        var touch_dir: Vector2 = touch.get_direction()
        if touch_dir.length() > 0.05:
            input_2d = touch_dir
        sprinting = sprinting or touch.is_sprinting()

    var camera := get_node_or_null("../Camera3D") as Camera3D
    var direction := Vector3(input_2d.x, 0.0, input_2d.y)
    if camera:
        var forward := -camera.global_transform.basis.z
        var right := camera.global_transform.basis.x
        forward.y = 0.0
        right.y = 0.0
        direction = (right.normalized() * input_2d.x) + (forward.normalized() * -input_2d.y)
    direction.y = 0.0
    if direction.length() > 1.0:
        direction = direction.normalized()

    var target_speed := run_speed if sprinting else walk_speed
    var target_velocity := direction * target_speed
    var blend := acceleration if direction.length() > 0.05 else braking
    _velocity = _velocity.move_toward(target_velocity, blend * delta)
    position += _velocity * delta

    if _velocity.length() > 0.15:
        _angle = lerp_angle(_angle, atan2(_velocity.x, _velocity.z), turn_speed * delta)
        rotation.y = _angle
        _step_time += delta * (10.0 if sprinting else 7.0)
        position.y = 0.2 + abs(sin(_step_time)) * (0.035 if sprinting else 0.018)
    else:
        position.y = 0.2
