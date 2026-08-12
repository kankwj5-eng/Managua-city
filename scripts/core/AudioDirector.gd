class_name AudioDirector
extends Node

var ambience_player: AudioStreamPlayer
var engine_player: AudioStreamPlayer
var ambience_playback: AudioStreamGeneratorPlayback
var engine_playback: AudioStreamGeneratorPlayback
var ambience_phase := 0.0
var engine_phase := 0.0
var random := RandomNumberGenerator.new()

func _ready() -> void:
	random.seed = 349219
	ambience_player = _create_generator_player(22050.0, -25.0)
	engine_player = _create_generator_player(22050.0, -17.0)
	ambience_playback = ambience_player.get_stream_playback() as AudioStreamGeneratorPlayback
	engine_playback = engine_player.get_stream_playback() as AudioStreamGeneratorPlayback

func _process(_delta: float) -> void:
	_fill_ambience()
	_fill_engine()

func _create_generator_player(rate: float, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = rate
	stream.buffer_length = 0.18
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.play()
	return player

func _fill_ambience() -> void:
	if not ambience_playback:
		return
	var frames := ambience_playback.get_frames_available()
	for frame in frames:
		ambience_phase += 1.0 / 22050.0
		var rain := random.randf_range(-1.0, 1.0) * 0.055
		var distant_hum := sin(ambience_phase * TAU * 55.0) * 0.014
		var pulse := max(0.0, sin(ambience_phase * TAU * 0.38)) * 0.006
		var sample := rain + distant_hum + pulse
		ambience_playback.push_frame(Vector2(sample, sample))

func _fill_engine() -> void:
	if not engine_playback:
		return
	var frames := engine_playback.get_frames_available()
	var speed := 0.0
	if GameState.active_vehicle and GameState.active_vehicle.has_method("get_speed_kmh"):
		speed = float(GameState.active_vehicle.get_speed_kmh())
	for frame in frames:
		engine_phase += 1.0 / 22050.0
		var frequency := 45.0 + speed * 3.1
		var amplitude := 0.0 if not GameState.active_vehicle else 0.035 + min(speed / 180.0, 0.14)
		var tone := sin(engine_phase * TAU * frequency) * amplitude
		var harmonic := sin(engine_phase * TAU * frequency * 2.03) * amplitude * 0.30
		engine_playback.push_frame(Vector2(tone + harmonic, tone + harmonic))
