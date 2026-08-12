extends Node

const DAY_AMBIENCE = preload("res://assets/audio/managua_day.wav")
const MARKET_AMBIENCE = preload("res://assets/audio/market_day.wav")
const LAKE_AMBIENCE = preload("res://assets/audio/xolotlan_waves.wav")
const DIALOGUE_TICK = preload("res://assets/audio/dialogue_tick.wav")
const JUMP_SFX = preload("res://assets/audio/jump.wav")
const SHOT_SFX = preload("res://assets/audio/shot.wav")
const SIREN_SFX = preload("res://assets/audio/siren.wav")
const BUTTON_SFX = preload("res://assets/audio/button.wav")

var ambience_player: AudioStreamPlayer
var market_player: AudioStreamPlayer
var lake_player: AudioStreamPlayer
var engine_player: AudioStreamPlayer
var engine_playback: AudioStreamGeneratorPlayback
var engine_phase := 0.0

func _ready() -> void:
	ambience_player = _create_loop_player(DAY_AMBIENCE, -16.0)
	market_player = _create_loop_player(MARKET_AMBIENCE, -24.0)
	lake_player = _create_loop_player(LAKE_AMBIENCE, -21.0)
	engine_player = _create_engine_player()
	engine_playback = engine_player.get_stream_playback() as AudioStreamGeneratorPlayback
	GameState.sound_requested.connect(_on_sound_requested)

func _process(_delta: float) -> void:
	_fill_engine()
	_update_zone_mix()

func _create_loop_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	add_child(player)
	player.play()
	return player

func _create_engine_player() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050.0
	stream.buffer_length = 0.18
	player.stream = stream
	player.volume_db = -21.0
	add_child(player)
	player.play()
	return player

func _fill_engine() -> void:
	if not engine_playback:
		return
	var frames := engine_playback.get_frames_available()
	var speed := 0.0
	if GameState.active_vehicle and GameState.active_vehicle.has_method("get_speed_kmh"):
		speed = float(GameState.active_vehicle.get_speed_kmh())
	for _frame in frames:
		engine_phase += 1.0 / 22050.0
		var frequency := 45.0 + speed * 3.1
		var amplitude := 0.0 if not GameState.active_vehicle else 0.024 + min(speed / 180.0, 0.10)
		var tone := sin(engine_phase * TAU * frequency) * amplitude
		var harmonic := sin(engine_phase * TAU * frequency * 2.03) * amplitude * 0.30
		engine_playback.push_frame(Vector2(tone + harmonic, tone + harmonic))

func _update_zone_mix() -> void:
	if not GameState.player:
		return
	var position := GameState.player.global_position
	var market_weight := clamp(1.0 - position.distance_to(Vector3(-43, 0, 8)) / 28.0, 0.0, 1.0)
	var lake_weight := clamp(1.0 - position.distance_to(Vector3(28, 0, -55)) / 34.0, 0.0, 1.0)
	market_player.volume_db = lerp(-34.0, -19.0, market_weight)
	lake_player.volume_db = lerp(-34.0, -18.0, lake_weight)

func _on_sound_requested(kind: String) -> void:
	match kind:
		"jump":
			_play_one_shot(JUMP_SFX, -4.0)
		"shot":
			_play_one_shot(SHOT_SFX, -1.0)
		"siren":
			_play_one_shot(SIREN_SFX, -5.0)
		"dialogue":
			_play_one_shot(DIALOGUE_TICK, -9.0)
		"button":
			_play_one_shot(BUTTON_SFX, -10.0)

func _play_one_shot(stream: AudioStream, volume_db: float) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
