extends CanvasLayer

@onready var health_bar = $Control/HealthBar
@onready var ammo_label = $Control/AmmoLabel
@onready var mission_title = $Control/MissionPanel/MissionTitle
@onready var mission_description = $Control/MissionPanel/MissionDescription
@onready var mission_progress = $Control/MissionPanel/MissionProgress
@onready var wanted_label = $Control/WantedLabel
@onready var toast_label = $Control/ToastLabel
@onready var pause_menu = $Control/PauseMenu
@onready var mobile_controls = $Control/MobileControls

func _ready():
	# Ensure Pause Menu and HUD process mode is always running even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect player stats signals
	PlayerStats.health_changed.connect(_on_health_changed)

	# Initialize HUD elements
	if health_bar:
		_on_health_changed(PlayerStats.current_health, PlayerStats.max_health)

	if ammo_label:
		ammo_label.text = "30 / 90" # Placeholder for shooting ammo as requested

	if pause_menu:
		pause_menu.hide()
	call_deferred("_connect_open_world_director")

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
		var fill_sb = health_bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
		if fill_sb:
			var ratio = 0.0
			if max_health > 0:
				ratio = clamp(current / max_health, 0.0, 1.0)
			# Interpolate color from Red (low health) to Green (high health)
			fill_sb.bg_color = Color(0.9, 0.2, 0.2, 0.9).lerp(Color(0.2, 0.8, 0.2, 0.9), ratio)
			health_bar.add_theme_stylebox_override("fill", fill_sb)

func _connect_open_world_director() -> void:
	var director = get_node_or_null("/root/Main/OpenWorldDirector")
	if not director:
		return
	director.mission_updated.connect(_on_mission_updated)
	director.wanted_changed.connect(_on_wanted_changed)
	director.clue_found.connect(_on_clue_found)
	if director.has_method("emit_current_state"):
		director.emit_current_state()

func _on_mission_updated(title: String, description: String, progress: String) -> void:
	if mission_title:
		mission_title.text = title
	if mission_description:
		mission_description.text = description
	if mission_progress:
		mission_progress.text = progress

func _on_wanted_changed(level: int) -> void:
	if wanted_label:
		var stars := ""
		for _index in range(level):
			stars += "*"
		wanted_label.text = "REDANE: " + stars

func _on_clue_found(message: String) -> void:
	if toast_label:
		toast_label.text = message
		toast_label.show()
		get_tree().create_timer(6.0).timeout.connect(func(): toast_label.hide())

func _on_resume_pressed():
	toggle_pause()

func _on_quit_pressed():
	get_tree().quit()
