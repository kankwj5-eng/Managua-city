extends Node3D

@export var move_speed := 18.0
@export var camera_path: NodePath
var _velocity := Vector3.ZERO
var _angle := 0.0

func _process(delta: float) -> void:
    var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var touch := get_node_or_null("/root/ManaguaCity/TouchControls")
    if touch and touch.has_method("get_direction"):
        var touch_dir: Vector2 = touch.get_direction()
        if touch_dir.length() > 0.05:
            input_2d = touch_dir
    var direction := Vector3(input_2d.x, 0.0, input_2d.y)
    if direction.length() > 0.05:
        direction = direction.normalized()
        position += direction * move_speed * delta
        _angle = lerp_angle(_angle, atan2(direction.x, direction.z), delta * 8.0)
        rotation.y = _angle
    var camera := get_node_or_null("../Camera3D") as Camera3D
    if camera:
        var desired := position + Vector3(18.0, 12.0, 22.0)
        camera.position = camera.position.lerp(desired, delta * 4.0)
        camera.look_at(position + Vector3(0.0, 3.0, 0.0), Vector3.UP)
