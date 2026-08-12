extends Node3D

func _ready() -> void:
	var weather := CinematicWeather.new()
	weather.name = "CinematicWeather"
	add_child(weather)
	var audio_director := AudioDirector.new()
	audio_director.name = "AudioDirector"
	add_child(audio_director)
	var mission := MissionController.new()
	mission.name = "MissionController"
	add_child(mission)
	GameState.show_toast("Ciudad del Lago — Vertical Slice", 3.0)
