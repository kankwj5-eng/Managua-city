extends CanvasLayer

@onready var health_bar = $Control/HealthBar
@onready var ammo_label = $Control/AmmoLabel
@onready var pause_menu = $Control/PauseMenu
@onready var mobile_controls = $Control/MobileControls

func _ready():
	# Ensure Pause Menu and HUD process mode is always running even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect player stats signals
	PlayerStats.health_changed.connect(_on_health_changed)

	# Initialize HUD elements
	if health_bar:
		health_bar.max_value = PlayerStats.max_health
		health_bar.value = PlayerStats.current_health

	if ammo_label:
		ammo_label.text = "30 / 90" # Placeholder for shooting ammo as requested

	if pause_menu:
		pause_menu.hide()

	# Handle mobile controls visibility based on platform
	if mobile_controls:
		if OS.get_name() == "Android" or OS.has_feature("mobile"):
			mobile_controls.show()
		else:
			mobile_controls.hide()

func _input(event):
	# Handle Pause Menu toggle on Escape key
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause():
	if not pause_menu:
		return

	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused

	# If paused, show the mouse cursor for UI interactions if mouse captured
	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		# Let the game handle mouse capture if it needs to
		pass

func _on_health_changed(current: float, max_health: float):
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current

func _on_resume_pressed():
	toggle_pause()

func _on_quit_pressed():
	get_tree().quit()
