extends Node3D

## Población ligera del vertical slice.
## Los modelos proceden de Universal Base Characters de Quaternius (CC0).

const MALE_NPC: PackedScene = preload("res://assets/models/npcs/quaternius/Superhero_Male_FullBody.gltf")
const FEMALE_NPC: PackedScene = preload("res://assets/models/npcs/quaternius/Superhero_Female_FullBody.gltf")

const NPC_DATA := [
	{"name": "La Chela", "role": "Contacto", "position": Vector3(-28, 0.02, 4.5), "scene": "female", "color": Color(0.24, 0.82, 0.92, 1.0)},
	{"name": "Vendedor del Mercado", "role": "Mercado Azul", "position": Vector3(-37, 0.02, 8.0), "scene": "male", "color": Color(1.0, 0.67, 0.24, 1.0)},
	{"name": "Mecánico del Puerto", "role": "Muelle", "position": Vector3(19, 0.02, -48.0), "scene": "male", "color": Color(0.55, 0.42, 0.96, 1.0)},
	{"name": "Viajera del Lago", "role": "Pista", "position": Vector3(33, 0.02, -42.0), "scene": "female", "color": Color(0.94, 0.35, 0.42, 1.0)},
	{"name": "Vecino de la Avenida", "role": "Puerto del Sur", "position": Vector3(-9, 0.02, 7.2), "scene": "male", "color": Color(0.96, 0.86, 0.32, 1.0)}
]

var actors: Array[Node3D] = []
var elapsed := 0.0

func _ready() -> void:
	await get_tree().process_frame
	for data in NPC_DATA:
		_spawn_npc(data)
	# El contacto de misión vive ahora en el personaje, no en un cilindro flotante.
	var old_marker := get_tree().get_first_node_in_group("mission_contact")
	if old_marker:
		old_marker.visible = false

func _process(delta: float) -> void:
	elapsed += delta
	for index in actors.size():
		var actor := actors[index]
		if not is_instance_valid(actor):
			continue
		var base_y := float(actor.get_meta("base_y", 0.02))
		actor.position.y = base_y + sin(elapsed * 1.35 + float(index) * 0.8) * 0.018
		if actor.has_meta("look_offset"):
			actor.rotation.y = lerp_angle(actor.rotation.y, float(actor.get_meta("look_offset")), delta * 0.45)

func _spawn_npc(data: Dictionary) -> void:
	var model_scene: PackedScene = FEMALE_NPC if data.scene == "female" else MALE_NPC
	var actor := model_scene.instantiate() as Node3D
	if not actor:
		return
	actor.name = "NPC_" + String(data.name).replace(" ", "_")
	actor.position = data.position
	actor.scale = Vector3(1.0, 1.0, 1.0)
	actor.set_meta("base_y", data.position.y)
	actor.set_meta("look_offset", 0.0 if data.scene == "female" else PI)
	actor.add_to_group("npc")
	add_child(actor)
	actors.append(actor)
	_add_nameplate(actor, String(data.name), String(data.role), data.color)
	_add_interaction_area(actor)

func _add_nameplate(actor: Node3D, npc_name: String, role: String, accent: Color) -> void:
	var label := Label3D.new()
	label.name = "Nameplate"
	label.text = npc_name + "\n" + role
	label.position = Vector3(0, 2.35, 0)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 30
	label.outline_size = 8
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
	shape.radius = 1.35
	shape_node.shape = shape
	area.add_child(shape_node)
	actor.add_child(area)
