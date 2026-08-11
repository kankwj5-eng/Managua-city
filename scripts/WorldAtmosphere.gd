extends WorldEnvironment

@export var sky_top_color := Color(0.08, 0.18, 0.34, 1.0)
@export var sky_horizon_color := Color(0.95, 0.58, 0.28, 1.0)
@export var ambient_energy := 0.9
@export var fog_enabled := true

func _ready() -> void:
	var env := Environment.new()
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = sky_top_color
	sky_material.sky_horizon_color = sky_horizon_color
	sky_material.ground_bottom_color = Color(0.05, 0.045, 0.04, 1.0)
	sky_material.ground_horizon_color = Color(0.32, 0.24, 0.18, 1.0)
	sky.sky_material = sky_material
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = ambient_energy
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.25
	env.glow_strength = 0.55
	env.fog_enabled = fog_enabled
	env.fog_light_color = Color(0.95, 0.7, 0.48, 1.0)
	env.fog_density = 0.018
	environment = env
