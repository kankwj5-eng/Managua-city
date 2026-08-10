extends Control

@export var max_length: float = 60.0
@onready var handle = $Handle

var dragging: bool = false
var joystick_center: Vector2 = Vector2.ZERO

func _ready():
	# Ensure correct mouse/touch consumption
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Initialize joystick position
	call_deferred("reset_joystick")

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			joystick_center = size / 2.0
			_update_joystick(event.position)
		else:
			dragging = false
			reset_joystick()
		get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag and dragging:
		_update_joystick(event.position)
		get_viewport().set_input_as_handled()

func _update_joystick(touch_pos: Vector2):
	var offset = touch_pos - joystick_center
	if offset.length() > max_length:
		offset = offset.normalized() * max_length

	if handle:
		handle.position = joystick_center + offset - (handle.size / 2.0)

	# Calculate normalized output vector
	var output = offset / max_length
	PlayerStats.touch_input_vector = output

func reset_joystick():
	dragging = false
	if handle:
		handle.position = (size / 2.0) - (handle.size / 2.0)
	PlayerStats.touch_input_vector = Vector2.ZERO
