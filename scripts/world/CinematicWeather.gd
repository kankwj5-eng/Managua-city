class_name CinematicWeather
extends Node3D

var rain: GPUParticles3D

func _ready() -> void:
	rain = GPUParticles3D.new()
	rain.name = "LightRain"
	rain.amount = 950
	rain.lifetime = 0.82
	rain.visibility_aabb = AABB(Vector3(-28, -2, -28), Vector3(56, 22, 56))
	rain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	rain.process_material = _rain_process_material()
	rain.draw_pass_1 = _rain_mesh()
	add_child(rain)

func _process(_delta: float) -> void:
	if GameState.player:
		global_position = GameState.player.global_position.snapped(Vector3(4.0, 1.0, 4.0)) + Vector3(0, 10, 0)

func _rain_process_material() -> ParticleProcessMaterial:
	var material := ParticleProcessMaterial.new()
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(28, 0.25, 28)
	material.direction = Vector3(0, -1, 0)
	material.spread = 7.0
	material.gravity = Vector3(0, -18, 0)
	material.initial_velocity_min = 9.0
	material.initial_velocity_max = 12.5
	material.scale_min = 0.65
	material.scale_max = 1.2
	return material

func _rain_mesh() -> QuadMesh:
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.018, 0.62)
	mesh.orientation = PlaneMesh.FACE_Z
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.42, 0.72, 1.0, 0.36)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	mesh.material = material
	return mesh
