extends Node3D

const CITIZEN_SCRIPT = preload("res://scripts/world/Citizen.gd")

const NPC_DATA := [
	{"name": "La Chela", "role": "Contacto del mercado", "position": Vector3(-28, 0.0, 4.5), "color": Color(0.84, 0.20, 0.16), "accent": Color(1.0, 0.80, 0.22), "dialogue": ["¡Ideay, Lenner! Vení rápido, maje.", "Tu hermana dejó una pista cerca del malecón.", "Andá por el encargo y no te metás en clavos." ]},
	{"name": "Don Chano", "role": "Vendedor del mercado", "position": Vector3(-37, 0.0, 8.0), "color": Color(0.95, 0.56, 0.12), "accent": Color(0.12, 0.32, 0.66), "dialogue": ["Pasá adelante, chavalo. Aquí se consigue de todo.", "Vi una camioneta rara rumbo al lago, ¡qué bárbaros!" ]},
	{"name": "Mecánico Tono", "role": "Mecánico del puerto", "position": Vector3(19, 0.0, -48.0), "color": Color(0.12, 0.38, 0.72), "accent": Color(0.95, 0.74, 0.18), "dialogue": ["Ese motor todavía aguanta, pero no lo forcés.", "Si querés llegar a la costa, agarrá la avenida y dale suave." ]},
	{"name": "Doña Maritza", "role": "Vecina de Altagracia", "position": Vector3(-9, 0.0, 7.2), "color": Color(0.72, 0.16, 0.42), "accent": Color(0.98, 0.78, 0.32), "dialogue": ["Aquí en el barrio todos nos conocemos, corazón.", "La radio dijo que hay retenes cerca del mercado." ]},
	{"name": "Pescador del Xolotlán", "role": "Guía del muelle", "position": Vector3(34, 0.0, -52.0), "color": Color(0.12, 0.54, 0.42), "accent": Color(0.94, 0.86, 0.64), "dialogue": ["El Xolotlán está bravo hoy, pero el muelle aguanta.", "Mirá hacia el Momotombo: por ahí vieron luces anoche." ]},
	{"name": "Oficial Rivas", "role": "Policía de patrulla", "position": Vector3(10, 0.0, 8.5), "color": Color(0.04, 0.18, 0.42), "accent": Color(0.18, 0.78, 1.0), "police": true, "dialogue": ["Buenas, ciudadano. Mantenga la calma y no haga relajo.", "Si ve algo sospechoso, avise a la patrulla." ]},
	{"name": "Oficial Gutiérrez", "role": "Policía del malecón", "position": Vector3(42, 0.0, -43.0), "color": Color(0.05, 0.22, 0.48), "accent": Color(0.96, 0.88, 0.24), "police": true, "dialogue": ["Este sector está bajo vigilancia, jefe.", "No se acerque al muelle cerrado sin autorización." ]}
]

var actors: Array[Node3D] = []
var elapsed := 0.0

func _ready() -> void:
	for data in NPC_DATA:
		_spawn_npc(data)

func _process(delta: float) -> void:
	elapsed += delta
	for index in actors.size():
		var actor := actors[index]
		if not is_instance_valid(actor):
			continue
		var base_y := float(actor.get_meta("base_y", 0.0))
		actor.position.y = base_y + sin(elapsed * 1.15 + float(index) * 0.7) * 0.012

func _spawn_npc(data: Dictionary) -> void:
	var actor := Node3D.new()
	actor.name = "NPC_" + String(data["name"]).replace(" ", "_")
	actor.set_script(CITIZEN_SCRIPT)
	actor.set("npc_name", data["name"])
	actor.set("role", data["role"])
	actor.set("dialogue", data["dialogue"])
	actor.set("police", bool(data.get("police", false)))
	actor.position = data["position"]
	actor.set("home_position", actor.position)
	actor.set_meta("base_y", actor.position.y)
	actor.add_to_group("npc")
	actor.add_to_group("interactive_npc")
	if bool(actor.get("police")):
		actor.add_to_group("police")
	if String(actor.get("npc_name")) == "La Chela":
		actor.add_to_group("mission_contact")
	add_child(actor)
	_build_character(actor, data["color"], data["accent"], bool(actor.get("police")))
	_add_nameplate(actor, data["name"], data["role"], data["accent"])
	_add_interaction_area(actor)
	actors.append(actor)

func _build_character(actor: Node3D, shirt_color: Color, accent: Color, is_police: bool) -> void:
	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.33
	body_mesh.height = 0.85
	body_mesh.radial_segments = 12
	body.mesh = body_mesh
	body.position = Vector3(0, 1.05, 0)
	body.material_override = _material(shirt_color, 0.78)
	actor.add_child(body)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.255
	head_mesh.height = 0.51
	head_mesh.radial_segments = 14
	head.mesh = head_mesh
	head.position = Vector3(0, 1.72, 0)
	head.material_override = _material(Color(0.56, 0.28, 0.14), 0.85)
	actor.add_child(head)

	var hair := MeshInstance3D.new()
	var hair_mesh := SphereMesh.new()
	hair_mesh.radius = 0.27
	hair_mesh.height = 0.22
	hair_mesh.radial_segments = 12
	hair.mesh = hair_mesh
	hair.scale = Vector3(1.0, 0.55, 1.0)
	hair.position = Vector3(0, 1.93, 0)
	hair.material_override = _material(Color(0.025, 0.018, 0.012), 0.94)
	actor.add_child(hair)

	for side in [-1.0, 1.0]:
		var leg := MeshInstance3D.new()
		var leg_mesh := BoxMesh.new()
		leg_mesh.size = Vector3(0.21, 0.62, 0.24)
		leg.mesh = leg_mesh
		leg.position = Vector3(0.16 * side, 0.48, 0)
		leg.material_override = _material(Color(0.07, 0.09, 0.14), 0.9)
		actor.add_child(leg)

	var belt := MeshInstance3D.new()
	var belt_mesh := BoxMesh.new()
	belt_mesh.size = Vector3(0.54, 0.11, 0.46)
	belt.mesh = belt_mesh
	belt.position = Vector3(0, 0.83, 0)
	belt.material_override = _material(accent, 0.72)
	actor.add_child(belt)

	if is_police:
		var cap := MeshInstance3D.new()
		var cap_mesh := CylinderMesh.new()
		cap_mesh.top_radius = 0.26
		cap_mesh.bottom_radius = 0.31
		cap_mesh.height = 0.12
		cap.mesh = cap_mesh
		cap.position = Vector3(0, 2.02, 0)
		cap.material_override = _material(Color(0.02, 0.08, 0.2), 0.72)
		actor.add_child(cap)

func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material

func _add_nameplate(actor: Node3D, npc_name: String, role: String, accent: Color) -> void:
	var label := Label3D.new()
	label.name = "Nameplate"
	label.text = npc_name + "\n" + role
	label.position = Vector3(0, 2.35, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 28
	label.outline_size = 7
	label.modulate = accent
	label.no_depth_test = true
	actor.add_child(label)

func _add_interaction_area(actor: Node3D) -> void:
	var area := Area3D.new()
	area.name = "InteractionArea"
	area.collision_layer = 0
	area.collision_mask = 0
	var shape_node := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 1.4
	shape_node.shape = shape
	area.add_child(shape_node)
	actor.add_child(area)
