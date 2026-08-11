extends Node

const DEFAULT_VOLUME_DB := -12.0
const UI_VOLUME_DB := -10.0
const TONE_RATE := 44100

var _sfx_player: AudioStreamPlayer
var _ui_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio_buses()
	_sfx_player = _create_player("SFXPlayer", DEFAULT_VOLUME_DB)
	_ui_player = _create_player("UIPlayer", UI_VOLUME_DB)
	_ambient_player = _create_player("AmbientPlayer", -22.0)
	play_ambient_city_bed()

func play_shoot() -> void:
	_play_tone(_sfx_player, 150.0, 0.08, 0.55)

func play_reload() -> void:
	_play_tone(_sfx_player, 520.0, 0.11, 0.25)

func play_empty_weapon() -> void:
	_play_tone(_sfx_player, 230.0, 0.07, 0.18)

func play_pickup() -> void:
	_play_tone(_ui_player, 760.0, 0.13, 0.22)

func play_mission_update() -> void:
	_play_tone(_ui_player, 440.0, 0.18, 0.2)

func play_alert() -> void:
	_play_tone(_sfx_player, 95.0, 0.28, 0.35)

func play_ambient_city_bed() -> void:
	# Placeholder ambience until real Managua street ambience is imported.
	_play_tone(_ambient_player, 54.0, 1.2, 0.035)

func _create_player(player_name: String, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.volume_db = volume_db
	if player_name.begins_with("SFX"):
		player.bus = "SFX"
	elif player_name.begins_with("UI"):
		player.bus = "UI"
	else:
		player.bus = "Ambient"
	add_child(player)
	return player

func _ensure_audio_buses() -> void:
	for bus_name in ["Music", "SFX", "UI", "Ambient"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, bus_name)

func _play_tone(player: AudioStreamPlayer, frequency: float, duration: float, amplitude: float) -> void:
	if not player:
		return
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = TONE_RATE
	generator.buffer_length = max(duration + 0.05, 0.1)
	player.stream = generator
	player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if not playback:
		return
	var frames := int(TONE_RATE * duration)
	for frame_index in range(frames):
		var t := float(frame_index) / float(TONE_RATE)
		var fade := 1.0 - (float(frame_index) / max(float(frames), 1.0))
		var sample := sin(TAU * frequency * t) * amplitude * fade
		playback.push_frame(Vector2(sample, sample))
