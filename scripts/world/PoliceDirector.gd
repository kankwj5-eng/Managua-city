extends Node3D

var alert_level := 0
var siren_clock := 0.0

func _ready() -> void:
	GameState.wanted_changed.connect(_on_wanted_changed)
	GameState.action_fired.connect(_on_action_fired)

func _process(delta: float) -> void:
	siren_clock += delta
	if GameState.wanted_level <= 0 or not GameState.player:
		return
	var player_position := GameState.player.global_position
	for officer in get_tree().get_nodes_in_group("police"):
		if not is_instance_valid(officer):
			continue
		var distance := officer.global_position.distance_to(player_position)
		if distance < 20.0:
			officer.look_at(Vector3(player_position.x, officer.global_position.y, player_position.z), Vector3.UP)
			if distance > 5.5:
				officer.global_position = officer.global_position.move_toward(player_position, delta * (0.7 + float(GameState.wanted_level) * 0.35))
		if int(siren_clock * 2.0) % 2 == 0:
			var plate := officer.get_node_or_null("Nameplate") as Label3D
			if plate:
				plate.modulate = Color(0.3, 0.7, 1.0, 1.0)
		else:
			var plate := officer.get_node_or_null("Nameplate") as Label3D
			if plate:
				plate.modulate = Color(1.0, 0.25, 0.2, 1.0)

func _on_wanted_changed(level: int) -> void:
	alert_level = level
	if level > 0:
		GameState.show_toast("Alerta policial: nivel %d. Corré o bajá la tensión." % level, 3.0)
		GameState.sound_requested.emit("siren")
	else:
		GameState.show_toast("La alerta se calmó.", 2.0)

func _on_action_fired(_origin: Vector3, _direction: Vector3) -> void:
	if GameState.wanted_level == 0:
		GameState.raise_wanted_level(1)
