extends Node3D

signal mission_updated(title: String, description: String, progress: String)
signal wanted_changed(level: int)
signal clue_found(message: String)

const INTERACT_DISTANCE := 3.0

var story_steps := [
	{
		"title": "Última llamada",
		"description": "Busca la antena marcada en Managua. La hermana de Lenner dejó una señal antes de desaparecer.",
		"target": Vector3(18, 0.5, -10),
		"clue": "Señal recuperada: 'Redane movió el laboratorio hacia el viejo distrito. No confíes en patrullas sin insignia.'"
	},
	{
		"title": "Rastro de Redane",
		"description": "Cruza la ciudad abierta y encuentra los documentos que vinculan a Redane con el origen del caos.",
		"target": Vector3(-26, 0.5, 20),
		"clue": "Documento encontrado: Redane ocultó a la científica porque conoce la fuente del apagón nacional."
	},
	{
		"title": "La verdad escondida",
		"description": "Llega al refugio señalado y prepárate para rescatar a tu hermana en la siguiente misión.",
		"target": Vector3(35, 0.5, 30),
		"clue": "Coordenadas confirmadas: el refugio está activo. La verdadera aventura apenas comienza."
	}
]

var side_activities := [
	{"name": "Botiquín de emergencia", "position": Vector3(8, 1.0, 18), "type": "health"},
	{"name": "Caja de munición", "position": Vector3(-12, 1.0, -18), "type": "ammo"},
	{"name": "Informe civil", "position": Vector3(28, 1.0, 5), "type": "intel"}
]

var current_step := 0
var wanted_level := 0
var wanted_decay_timer := 0.0
var player: Node3D
var mission_marker: Area3D
var enemies: Array[CharacterBody3D] = []

func _ready() -> void:
	player = get_node_or_null("../Player")
	_build_open_world_content()
	_set_current_mission(0)

func _process(delta: float) -> void:
	if not player:
		return
	if Input.is_action_just_pressed("interact"):
		_try_interact()
	_update_world_pressure(delta)

func notify_shot_fired(origin: Vector3) -> void:
	wanted_decay_timer = 12.0
	wanted_level = clamp(wanted_level + 1, 0, 5)
	wanted_changed.emit(wanted_level)
	if wanted_level == 1:
		AudioManager.play_alert()
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.global_position.distance_to(origin) < 45.0:
			enemy.call("alert_to", player)
		elif is_instance_valid(enemy) and enemy.has_method("investigate"):
			enemy.call("investigate", origin)

func _build_open_world_content() -> void:
	_spawn_mission_marker()
	for activity in side_activities:
		_spawn_pickup(activity)
	for pos in [Vector3(12, 1, 10), Vector3(-18, 1, 14), Vector3(30, 1, -22), Vector3(-30, 1, -12)]:
		_spawn_enemy(pos)
	_spawn_safehouse(Vector3(0, 0.1, 0))
	_spawn_city_life()

func _spawn_mission_marker() -> void:
	mission_marker = Area3D.new()
	mission_marker.name = "MissionMarker"
	mission_marker.collision_layer = 0
	mission_marker.collision_mask = 1
	add_child(mission_marker)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.4
	shape.shape = sphere
	mission_marker.add_child(shape)
	mission_marker.body_entered.connect(_on_mission_marker_body_entered)
	mission_marker.add_child(_make_beacon_mesh(Color(0.1, 0.65, 1.0, 0.55)))

func _set_current_mission(index: int) -> void:
	current_step = clamp(index, 0, story_steps.size() - 1)
	var step = story_steps[current_step]
	mission_marker.global_position = step["target"]
	emit_current_state()

func emit_current_state() -> void:
	if current_step >= story_steps.size():
		mission_updated.emit("Mundo abierto liberado", "Explora Managua, reúne recursos y sobrevive a Redane hasta la próxima historia.", "Historia inicial completa")
		return
	var step = story_steps[current_step]
	mission_updated.emit(step["title"], step["description"], "%d/%d pistas" % [current_step, story_steps.size()])
	wanted_changed.emit(wanted_level)

func _on_mission_marker_body_entered(body: Node3D) -> void:
	if body != player:
		return
	var step = story_steps[current_step]
	clue_found.emit(step["clue"])
	AudioManager.play_mission_update()
	if current_step < story_steps.size() - 1:
		_set_current_mission(current_step + 1)
	else:
		mission_updated.emit("Mundo abierto liberado", "Explora Managua, reúne recursos y sobrevive a Redane hasta la próxima historia.", "Historia inicial completa")
		mission_marker.queue_free()
		mission_marker = null

func _spawn_pickup(activity: Dictionary) -> void:
	var pickup := Area3D.new()
	pickup.name = activity["name"]
	pickup.set_meta("pickup_type", activity["type"])
	pickup.global_position = activity["position"]
	pickup.collision_layer = 0
	pickup.collision_mask = 1
	add_child(pickup)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.2
	shape.shape = sphere
	pickup.add_child(shape)
	pickup.add_child(_make_beacon_mesh(Color(1.0, 0.8, 0.15, 0.65)))
	pickup.body_entered.connect(_on_pickup_body_entered.bind(pickup))

func _on_pickup_body_entered(body: Node3D, pickup: Area3D) -> void:
	if body != player:
		return
	match String(pickup.get_meta("pickup_type")):
		"health":
			PlayerStats.heal(35)
			clue_found.emit("Botiquín obtenido: Lenner recuperó salud para seguir buscando a su hermana.")
			AudioManager.play_pickup()
		"ammo":
			if player.has_method("add_ammo"):
				player.call("add_ammo", 30)
			clue_found.emit("Munición obtenida: Redane está cerca, conserva tus balas.")
			AudioManager.play_pickup()
		_:
			clue_found.emit("Informe civil: testigos vieron convoyes de Redane moviéndose por Managua.")
			AudioManager.play_pickup()
	pickup.queue_free()

func _spawn_enemy(pos: Vector3) -> void:
	var enemy := preload("res://scripts/RedaneEnemy.gd").new()
	enemy.global_position = pos
	add_child(enemy)
	enemies.append(enemy)

func _spawn_safehouse(pos: Vector3) -> void:
	var safehouse := MeshInstance3D.new()
	safehouse.name = "SafehouseBeacon"
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 1.4
	cylinder.bottom_radius = 1.4
	cylinder.height = 0.25
	safehouse.mesh = cylinder
	safehouse.global_position = pos
	safehouse.material_override = _make_material(Color(0.0, 0.8, 0.35, 0.55))
	add_child(safehouse)

func _make_beacon_mesh(color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.45
	cylinder.bottom_radius = 0.45
	cylinder.height = 3.0
	mesh.mesh = cylinder
	mesh.position.y = 1.5
	mesh.material_override = _make_material(color)
	return mesh

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _try_interact() -> void:
	if is_instance_valid(mission_marker) and player.global_position.distance_to(mission_marker.global_position) <= INTERACT_DISTANCE:
		_on_mission_marker_body_entered(player)

func _update_world_pressure(delta: float) -> void:
	if wanted_level <= 0 or not player:
		return
	wanted_decay_timer -= delta
	if wanted_decay_timer <= 0.0:
		wanted_level = max(wanted_level - 1, 0)
		wanted_decay_timer = 10.0
		wanted_changed.emit(wanted_level)
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.global_position.distance_to(player.global_position) < 55.0:
			enemy.call("alert_to", player)

func _spawn_city_life() -> void:
	for prop in [
		{"name": "Farol", "position": Vector3(10, 0.2, -6), "color": Color(1.0, 0.74, 0.35, 1.0)},
		{"name": "Farol", "position": Vector3(-16, 0.2, 11), "color": Color(1.0, 0.74, 0.35, 1.0)},
		{"name": "CartelRedane", "position": Vector3(24, 0.2, 10), "color": Color(0.8, 0.05, 0.05, 1.0)},
		{"name": "Barricada", "position": Vector3(-6, 0.2, -24), "color": Color(0.22, 0.22, 0.24, 1.0)}
	]:
		_spawn_urban_prop(prop)
	for npc_pos in [Vector3(6, 1, 8), Vector3(-10, 1, 6), Vector3(16, 1, 18)]:
		_spawn_civilian(npc_pos)

func _spawn_urban_prop(data: Dictionary) -> void:
	var prop := MeshInstance3D.new()
	prop.name = data["name"]
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.6, 2.4, 0.6) if data["name"] != "Barricada" else Vector3(3.0, 0.8, 0.5)
	prop.mesh = mesh
	prop.global_position = data["position"]
	prop.material_override = _make_lit_material(data["color"])
	add_child(prop)
	if data["name"] == "Farol":
		var light := OmniLight3D.new()
		light.name = "StreetLight"
		light.light_color = Color(1.0, 0.74, 0.42)
		light.light_energy = 0.75
		light.omni_range = 8.0
		light.position.y = 2.4
		prop.add_child(light)

func _spawn_civilian(pos: Vector3) -> void:
	var body := CharacterBody3D.new()
	body.name = "Civilian"
	body.global_position = pos
	body.collision_layer = 4
	body.collision_mask = 1
	var visual := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.28
	mesh.height = 1.55
	visual.mesh = mesh
	visual.position.y = 0.78
	visual.material_override = _make_lit_material(Color(0.15, 0.45, 0.9, 1.0))
	body.add_child(visual)
	add_child(body)

func _make_lit_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.65
	material.metallic = 0.05
	return material
