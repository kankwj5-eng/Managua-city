extends Node3D

const POLICE_DIRECTOR_SCRIPT = preload("res://scripts/world/PoliceDirector.gd")

func _ready() -> void:
	var audio_director := AudioDirector.new()
	audio_director.name = "AudioDirector"
	add_child(audio_director)
	var mission := MissionController.new()
	mission.name = "MissionController"
	add_child(mission)
	var police := Node3D.new()
	police.name = "PoliceDirector"
	police.set_script(POLICE_DIRECTOR_SCRIPT)
	add_child(police)
	GameState.show_toast("Ciudad del Lago — Managua despierta", 3.0)
