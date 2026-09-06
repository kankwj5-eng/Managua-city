class_name NPCController
extends Node3D

## Control procedural para modelos sin esqueleto: reposo, caminar, correr y pelea.
@export_enum("idle", "walk", "run", "fight") var state := "idle"
@export var is_main_character := false
@export var character_id := 0
var _time := 0.0
var _base_position := Vector3.ZERO
var _base_scale := Vector3.ONE
var _skeleton: Skeleton3D

func _ready() -> void:
    var target := get_parent() if get_parent() is Node3D else self
    _base_position = target.position
    _base_scale = target.scale
    _skeleton = target.find_child("HumanoidRig", true, false) as Skeleton3D

func _process(delta: float) -> void:
    _time += delta
    var speed := 1.0
    var stride := 0.025
    match state:
        "walk":
            speed = 3.0
            stride = 0.07
        "run":
            speed = 7.0
            stride = 0.12
        "fight":
            speed = 8.0
            stride = 0.04
    var wave := sin(_time * speed)
    var target := get_parent() if get_parent() is Node3D else self
    target.position = _base_position + Vector3(0.0, abs(wave) * stride, 0.0)
    target.rotation.y = sin(_time * speed * 0.5) * (0.035 if state != "fight" else 0.12)
    if state == "fight":
        target.rotation.x = sin(_time * speed) * 0.035
    else:
        target.rotation.x = 0.0
    _animate_skeleton(wave, state)
    var pulse: float = 1.0 + (abs(wave) * 0.015 if is_main_character else 0.0)
    target.scale = _base_scale * pulse

func set_state(next_state: String) -> void:
    if next_state in ["idle", "walk", "run", "fight"]:
        state = next_state

func _animate_skeleton(wave: float, current_state: String) -> void:
    if _skeleton == null:
        return
    var swing := wave * (0.55 if current_state == "run" else 0.32)
    if current_state == "fight":
        swing = sin(_time * 8.0) * 0.75
    for side in ["L", "R"]:
        var sign := -1.0 if side == "L" else 1.0
        var thigh := _skeleton.find_bone("thigh." + side)
        var shin := _skeleton.find_bone("shin." + side)
        var upper_arm := _skeleton.find_bone("upper_arm." + side)
        if thigh >= 0:
            _skeleton.set_bone_pose_rotation(thigh, Quaternion(Vector3.RIGHT, swing * sign))
        if shin >= 0:
            _skeleton.set_bone_pose_rotation(shin, Quaternion(Vector3.RIGHT, max(0.0, -swing * sign) * 0.45))
        if upper_arm >= 0:
            _skeleton.set_bone_pose_rotation(upper_arm, Quaternion(Vector3.RIGHT, -swing * sign * 0.8))
