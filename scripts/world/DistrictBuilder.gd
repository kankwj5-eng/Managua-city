class_name DistrictBuilder
extends Node3D

const ROAD_COLOR := Color(0.028, 0.040, 0.060, 1.0)
const SIDEWALK_COLOR := Color(0.17, 0.20, 0.24, 1.0)
const BUILDING_COLORS := [
	Color(0.15, 0.22, 0.29, 1.0),
	Color(0.24, 0.18, 0.25, 1.0),
	Color(0.28, 0.23, 0.17, 1.0),
	Color(0.13, 0.29, 0.28, 1.0)
]

func _ready() -> void:
	_build_ground()
	_build_roads()
	_build_blocks()
	_build_landmarks()

func _build_ground() -> void:
	_add_static_box("Ground", Vector3(0, -0.28, 0), Vector3(170, 0.56, 170), Color(0.09, 0.11, 0.12, 1.0))
	_add_static_box("Lake", Vector3(0, -0.06, -72), Vector3(170, 0.08, 26), Color(0.025, 0.13, 0.19, 1.0), false, 0.12)

func _build_roads() -> void:
	_add_static_box("Avenida Central", Vector3(0, 0.018, 0), Vector3(118, 0.04, 13.0), ROAD_COLOR, false)
	_add_static_box("Calle Mercado", Vector3(-19, 0.022, 0), Vector3(12.0, 0.045, 110), ROAD_COLOR, false)
	_add_static_box("Malecón", Vector3(28, 0.022, -45), Vector3(80, 0.045, 10), ROAD_COLOR, false)
	for x in range(-48, 49, 12):
		_add_static_box("Line_%d" % x, Vector3(x, 0.048, 0), Vector3(4.5, 0.012, 0.24), Color(0.95, 0.70, 0.24, 1.0), false, 0.8)

func _build_blocks() -> void:
	var positions := [
		Vector3(-48, 0, 22), Vector3(-39, 0, 31), Vector3(-50, 0, 42),
		Vector3(6, 0, 24), Vector3(19, 0, 31), Vector3(31, 0, 21),
		Vector3(45, 0, -19), Vector3(56, 0, -28), Vector3(21, 0, -26),
		Vector3(-3, 0, -27), Vector3(-37, 0, -25), Vector3(-50, 0, -34)
	]
	for index in positions.size():
		var width := 8.0 + float(index % 3) * 2.0
		var depth := 8.0 + float((index + 1) % 3) * 2.2
		var height := 6.0 + float(index % 4) * 3.5
		_add_building("Edificio_%02d" % index, positions[index], Vector3(width, height, depth), BUILDING_COLORS[index % BUILDING_COLORS.size()])
	for x in range(-54, 55, 12):
		_add_lamp(Vector3(x, 0, 7.0))
		_add_lamp(Vector3(x, 0, -7.0))
	for z in range(-36, 43, 14):
		_add_lamp(Vector3(-13.0, 0, z))
		_add_lamp(Vector3(-25.0, 0, z))

func _build_landmarks() -> void:
	_add_static_box("Mercado Azul", Vector3(-38, 2.0, 3.0), Vector3(15.0, 4.0, 10.0), Color(0.03, 0.25, 0.37, 1.0))
	_add_static_box("Muelle", Vector3(25, 0.35, -53), Vector3(55, 0.7, 7.5), Color(0.20, 0.12, 0.06, 1.0))
	_add_static_box("Bodega", Vector3(28, 2.5, -39), Vector3(12, 5, 10), Color(0.22, 0.13, 0.08, 1.0))
	_add_marker("MissionContact", Vector3(-28, 0.6, 4.5), Color(0.08, 0.85, 0.92, 1.0), "mission_contact")
	_add_marker("MissionPickup", Vector3(-42, 0.35, -2.0), Color(0.95, 0.55, 0.12, 1.0), "mission_pickup")
	_add_marker("MissionDelivery", Vector3(27, 0.35, -48.0), Color(0.52, 0.30, 0.96, 1.0), "mission_delivery")

func _add_static_box(label: String, position_value: Vector3, size: Vector3, color: Color, collisions := true, emission := 0.0) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = position_value
	add_child(body)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	if emission > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission
	mesh.material_override = material
	body.add_child(mesh)
	if collisions:
		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape
		body.add_child(shape)
	return body

func _add_building(label: String, ground_position: Vector3, size: Vector3, color: Color) -> void:
	var body := _add_static_box(label, ground_position + Vector3(0, size.y * 0.5, 0), size, color, true)
	var roof := MeshInstance3D.new()
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(size.x + 0.32, 0.24, size.z + 0.32)
	roof.mesh = roof_mesh
	roof.position = Vector3(0, size.y * 0.5 + 0.14, 0)
	var roof_material := StandardMaterial3D.new()
	roof_material.albedo_color = Color(0.04, 0.06, 0.09, 1.0)
	roof.material_override = roof_material
	body.add_child(roof)

func _add_lamp(position_value: Vector3) -> void:
	var pole := MeshInstance3D.new()
	pole.name = "Farol"
	pole.position = position_value + Vector3(0, 2.2, 0)
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.07
	mesh.bottom_radius = 0.11
	mesh.height = 4.4
	pole.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.08, 0.1, 0.13, 1.0)
	pole.material_override = material
	add_child(pole)
	var bulb := MeshInstance3D.new()
	bulb.position = position_value + Vector3(0, 4.18, 0)
	var bulb_mesh := SphereMesh.new()
	bulb_mesh.radius = 0.18
	bulb_mesh.height = 0.36
	bulb.mesh = bulb_mesh
	var bulb_material := StandardMaterial3D.new()
	bulb_material.albedo_color = Color(1.0, 0.48, 0.16, 1.0)
	bulb_material.emission_enabled = true
	bulb_material.emission = Color(1.0, 0.26, 0.04, 1.0)
	bulb_material.emission_energy_multiplier = 2.5
	bulb.material_override = bulb_material
	add_child(bulb)

func _add_marker(label: String, position_value: Vector3, color: Color, group_name: String) -> void:
	var marker := Node3D.new()
	marker.name = label
	marker.position = position_value
	marker.add_to_group(group_name)
	add_child(marker)
	var mesh_instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.42
	mesh.bottom_radius = 0.42
	mesh.height = 1.8
	mesh_instance.mesh = mesh
	mesh_instance.position.y = 0.9
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.4
	mesh_instance.material_override = material
	marker.add_child(mesh_instance)
