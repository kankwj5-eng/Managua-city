extends Control

@export var action_name: String = ""

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event):
	if action_name == "":
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			Input.action_press(action_name)
			modulate = Color(0.7, 0.7, 0.7, 1.0)
		else:
			Input.action_release(action_name)
			modulate = Color(1.0, 1.0, 1.0, 1.0)
		get_viewport().set_input_as_handled()
