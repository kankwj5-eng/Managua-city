extends Node3D

const ROAD_COLOR := Color(0.12, 0.14, 0.16, 1.0)
const SIDEWALK_COLOR := Color(0.62, 0.55, 0.42, 1.0)
const SAND_COLOR := Color(0.86, 0.69, 0.40, 1.0)
const BUILDING_COLORS := [
	Color(0.86, 0.32, 0.18, 1.0),
	Color(0.94, 0.63, 0.18, 1.0),
	Color(0.20, 0.48, 0.66, 1.0),
	Color(0.82, 0.82, 0.68, 1.0),
	Color(0.45, 0.66, 0.40, 1.0),
	Color(0.76, 0.35, 0.35, 1.0)
]

func _ready() -> void:
	_build_ground()
	_build_roads()
	_build_blocks()
	_build_market()
	_build_lakefront()
	_build_tiscapa_viewpoint()
	_build_landmarks()

func _build_ground() -> void:
	_add_static_box("Terreno Managua", Vector3(0, -0.35, 0), Vector3(190, 0.7, 150), Color(0.28, 0.48, 0.25, 1.0))
	_add_static_box("Playa Xolotlán", Vector3(24, -0.015, -58), Vector3(150, 0.06, 16), SAND_COLOR, false)
	var water := _add_static_box("Lago Xolotlán", Vector3(24, -0.08, -76), Vector3(190, 0.08, 28), Color(0.06, 0.38, 0.58, 0.86), false)
	var water_mesh := water.get_node("Mesh") as MeshInstance3D
	if water_mesh and water_mesh.material_override:
		water_mesh.material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		water_mesh.material_override.roughness = 0.2
		water_mesh.material_override.metallic = 0.1

func _build_roads() -> void:
	_add_static_box("Avenida Bolívar a Chávez", Vector3(0, 0.02, 0), Vector3(142, 0.05, 12), ROAD_COLOR, false)
	_add_static_box("Carretera Norte", Vector3(0, 0.024, 24), Vector3(142, 0.055, 9), ROAD_COLOR, false)
	_add_static_box("Calle del Mercado", Vector3(-33, 0.026, 9), Vector3(9, 0.06, 86), ROAD_COLOR, false)
	_add_static_box("Camino al Malecón", Vector3(33, 0.028, -28), Vector3(12, 0.06, 58), ROAD_COLOR, false)
	_add_static_box("Paseo del Lago", Vector3(28, 0.03, -49), Vector3(112, 0.06, 9), ROAD_COLOR, false)
	for x in range(-64, 65, 12):
		_add_static_box("Linea_Av_%d" % x, Vector3(x, 0.058, 0), Vector3(4.4, 0.014, 0.22), Color(1.0, 0.78, 0.2, 1.0), false)
	for x in range(-60, 61, 20):
		_add_static_box("Banqueta_A_%d" % x, Vector3(x, 0.07, 7.2), Vector3(14, 0.09, 2.0), SIDEWALK_COLOR, false)
		_add_static_box("Banqueta_B_%d" % x, Vector3(x, 0.07, -7.2), Vector3(14, 0.09, 2.0), SIDEWALK_COLOR, false)

func _build_blocks() -> void:
	var positions := [
		Vector3(-54, 0, 23), Vector3(-43, 0, 35), Vector3(-54, 0, 47),
		Vector3(-7, 0, 25), Vector3(8, 0, 34), Vector3(22, 0, 25),
		Vector3(50, 0, 22), Vector3(61, 0, 35), Vector3(52, 0, 47),
		Vector3(-6, 0, -24), Vector3(-21, 0, -34), Vector3(-48, 0, -24),
		Vector3(52, 0, -27), Vector3(66, 0, -30)
	]
	for index in range(positions.size()):
		var width := 8.0 + float(index % 3) * 2.0
		var depth := 7.0 + float((index + 1) % 3) * 2.0
		var height := 4.0 + float(index % 4) * 1.8
		_add_building("Casa_Managua_%02d" % index, positions[index], Vector3(width, height, depth), BUILDING_COLORS[index % BUILDING_COLORS.size()])
	for x in range(-58, 59, 16):
		_add_tree(Vector3(x, 0, 9.0), 1.0)
		_add_tree(Vector3(x + 5, 0, -10.0), 0.8)
	for z in range(-35, 46, 16):
		_add_lamp(Vector3(-10.0, 0, z))
		_add_lamp(Vector3(13.0, 0, z))

func _build_market() -> void:
	_add_static_box("Mercado Oriental", Vector3(-43, 2.1, 8), Vector3(18, 4.2, 14), Color(0.80, 0.24, 0.13, 1.0))
	_add_static_box("Mercado Oriental Techo", Vector3(-43, 4.45, 8), Vector3(19, 0.35, 15), Color(0.08, 0.28, 0.46, 1.0), false)
	for x in [-50.0, -43.0, -36.0]:
		_add_static_box("Puesto_%d" % int(x), Vector3(x, 1.0, -1.0), Vector3(5.0, 2.0, 3.0), Color(0.95, 0.66, 0.18, 1.0))
		_add_sign(Vector3(x, 2.45, -1.0), "PULPERÍA", Color(1.0, 0.93, 0.65, 1.0))
	_add_sign(Vector3(-43, 5.0, 8), "MERCADO ORIENTAL", Color(1.0, 0.90, 0.35, 1.0))

func _build_lakefront() -> void:
	_add_static_box("Puerto Salvador Allende", Vector3(28, 0.45, -49), Vector3(68, 0.9, 8), Color(0.44, 0.24, 0.11, 1.0), true)
	_add_static_box("Muelle principal", Vector3(28, 0.5, -63), Vector3(34, 1.0, 5), Color(0.48, 0.29, 0.12, 1.0), true)
	_add_static_box("Paseo Xolotlán", Vector3(70, 0.35, -53), Vector3(42, 0.7, 12), Color(0.82, 0.72, 0.52, 1.0), false)
	for x in range(-4, 83, 11):
		_add_palm(Vector3(x, 0, -54), 1.0 + float((x + 4) % 3) * 0.12)
	_add_sign(Vector3(28, 2.7, -49), "PUERTO SALVADOR ALLENDE", Color(0.98, 0.86, 0.28, 1.0))
	_add_sign(Vector3(63, 2.5, -53), "LAGO XOLOTLÁN", Color(0.62, 0.94, 1.0, 1.0))

func _build_tiscapa_viewpoint() -> void:
	_add_static_box("Loma de Tiscapa", Vector3(61, 2.4, 4), Vector3(22, 4.8, 18), Color(0.31, 0.46, 0.28, 1.0), true)
	_add_static_box("Laguna de Tiscapa", Vector3(61, 4.86, 4), Vector3(13, 0.1, 9), Color(0.07, 0.34, 0.47, 1.0), false)
	_add_sign(Vector3(61, 7.2, 4), "LOMA DE TISCAPA", Color(0.96, 0.85, 0.36, 1.0))

func _build_landmarks() -> void:
	_add_sign(Vector3(-4, 4.0, 0), "AVENIDA BOLÍVAR A CHÁVEZ", Color(1.0, 0.94, 0.74, 1.0))
	_add_static_box("Barrio Altagracia", Vector3(-8, 0.6, 47), Vector3(20, 1.2, 8), Color(0.58, 0.20, 0.17, 1.0), false)
	_add_sign(Vector3(-8, 2.0, 47), "BARRIO ALTAGRACIA", Color(1.0, 0.76, 0.48, 1.0))
	_add_static_box("Cancha del Barrio", Vector3(-7, 0.08, 37), Vector3(14, 0.06, 8), Color(0.12, 0.42, 0.26, 1.0), false)
	_add_marker("MissionPickup", Vector3(-43, 0.35, -1.0), Color(0.95, 0.55, 0.12, 1.0), "mission_pickup")
	_add_marker("MissionDelivery", Vector3(28, 0.35, -63.0), Color(0.52, 0.30, 0.96, 1.0), "mission_delivery")

func _add_static_box(label: String, position_value: Vector3, size: Vector3, color: Color, collisions := true) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = label
	body.position = position_value
	add_child(body)
	var mesh := MeshInstance3D.new()
	mesh.name = "Mesh"
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
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
	roof.material_override = _material(Color(0.08, 0.10, 0.14, 1.0), 0.86)
	body.add_child(roof)
	_add_sign(ground_position + Vector3(0, size.y + 0.35, 0), "BARRIO", Color(0.95, 0.86, 0.54, 1.0))

func _add_tree(position_value: Vector3, scale_value: float) -> void:
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.14 * scale_value
	trunk_mesh.bottom_radius = 0.22 * scale_value
	trunk_mesh.height = 2.8 * scale_value
	trunk.mesh = trunk_mesh
	trunk.position = position_value + Vector3(0, 1.4 * scale_value, 0)
	trunk.material_override = _material(Color(0.25, 0.13, 0.06, 1.0), 0.95)
	add_child(trunk)
	var crown := MeshInstance3D.new()
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = 1.35 * scale_value
	crown_mesh.height = 2.1 * scale_value
	crown.mesh = crown_mesh
	crown.position = position_value + Vector3(0, 3.0 * scale_value, 0)
	crown.material_override = _material(Color(0.10, 0.42, 0.18, 1.0), 0.96)
	add_child(crown)

func _add_palm(position_value: Vector3, scale_value: float) -> void:
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.10 * scale_value
	trunk_mesh.bottom_radius = 0.18 * scale_value
	trunk_mesh.height = 4.2 * scale_value
	trunk.mesh = trunk_mesh
	trunk.position = position_value + Vector3(0, 2.1 * scale_value, 0)
	trunk.material_override = _material(Color(0.34, 0.18, 0.07, 1.0), 0.9)
	add_child(trunk)
	var leaves := MeshInstance3D.new()
	var leaves_mesh := SphereMesh.new()
	leaves_mesh.radius = 1.25 * scale_value
	leaves_mesh.height = 0.42 * scale_value
	leaves.mesh = leaves_mesh
	leaves.position = position_value + Vector3(0, 4.2 * scale_value, 0)
	leaves.material_override = _material(Color(0.10, 0.48, 0.18, 1.0), 0.92)
	add_child(leaves)

func _add_lamp(position_value: Vector3) -> void:
	var pole := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.055
	mesh.bottom_radius = 0.09
	mesh.height = 3.6
	pole.mesh = mesh
	pole.position = position_value + Vector3(0, 1.8, 0)
	pole.material_override = _material(Color(0.10, 0.12, 0.16, 1.0), 0.92)
	add_child(pole)
	var bulb := MeshInstance3D.new()
	var bulb_mesh := SphereMesh.new()
	bulb_mesh.radius = 0.14
	bulb_mesh.height = 0.28
	bulb.mesh = bulb_mesh
	bulb.position = position_value + Vector3(0, 3.72, 0)
	var bulb_material := _material(Color(1.0, 0.68, 0.18, 1.0), 0.35)
	bulb_material.emission_enabled = true
	bulb_material.emission = Color(1.0, 0.36, 0.04, 1.0)
	bulb_material.emission_energy_multiplier = 2.0
	bulb.material_override = bulb_material
	add_child(bulb)

func _add_sign(position_value: Vector3, text_value: String, color: Color) -> void:
	var label := Label3D.new()
	label.text = text_value
	label.position = position_value
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 28
	label.outline_size = 8
	label.modulate = color
	label.no_depth_test = true
	add_child(label)

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
	mesh.height = 1.35
	mesh_instance.mesh = mesh
	mesh_instance.position.y = 0.68
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.5
	mesh_instance.material_override = material
	marker.add_child(mesh_instance)

func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material
