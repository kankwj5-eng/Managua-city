extends Control

var _direction := Vector2.ZERO
@onready var up := $Up
@onready var down := $Down
@onready var left := $Left
@onready var right := $Right

func _process(_delta: float) -> void:
    _direction = Vector2(
        float(right.button_pressed) - float(left.button_pressed),
        float(down.button_pressed) - float(up.button_pressed)
    )

func get_direction() -> Vector2:
    return _direction.normalized() if _direction.length() > 1.0 else _direction
