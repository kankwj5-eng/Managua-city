extends Node

enum MissionStage { MEET_CHELA, PICK_UP_BOX, DELIVER_BOX, COMPLETE }

const ACTION_RADIUS := 3.2

var stage := MissionStage.MEET_CHELA
var contact: Node3D
var pickup: Node3D
var delivery: Node3D
var cargo_visual: Node3D
var elapsed := 0.0
var last_hint := -10.0

func _ready() -> void:
	await get_tree().process_frame
	contact = get_tree().get_first_node_in_group("mission_contact") as Node3D
	pickup = get_tree().get_first_node_in_group("mission_pickup") as Node3D
	delivery = get_tree().get_first_node_in_group("mission_delivery") as Node3D
	_spawn_cargo()
	GameState.current_mission_id = "encargo_del_lago"
	GameState.set_objective("La última llamada", "Encontrá a La Chela en el Mercado Oriental.")
	GameState.show_toast("¡Diay, maje! Managua te necesita.", 4.0)

func _process(delta: float) -> void:
	elapsed += delta
	if GameState.dialogue_open:
		return
	_animate_markers()
	if stage == MissionStage.COMPLETE or not _has_actor():
		return
	if Input.is_action_just_pressed("interact"):
		_try_advance()
	elif elapsed - last_hint > 10.0:
		last_hint = elapsed
		_show_stage_hint()

func _has_actor() -> bool:
	return GameState.player != null

func _actor_position() -> Vector3:
	if GameState.active_vehicle:
		return GameState.active_vehicle.global_position
	return GameState.player.global_position

func _try_advance() -> void:
	var actor_position := _actor_position()
	match stage:
		MissionStage.MEET_CHELA:
			if contact and actor_position.distance_to(contact.global_position) <= ACTION_RADIUS:
				stage = MissionStage.PICK_UP_BOX
				GameState.set_objective("La última llamada", "Recogé el paquete en el mercado y llevalo al malecón.")
				GameState.show_dialogue("La Chela", ["¡Ideay, Lenner! Al fin aparecés.", "Tu hermana dejó una caja en el mercado. No preguntés mucho, maje.", "Llevála al Puerto Salvador Allende. Allí te van a dar la siguiente pista."])
			else:
				GameState.show_toast("La Chela está en el Mercado Oriental, por la calle de los puestos.")
		MissionStage.PICK_UP_BOX:
			if pickup and actor_position.distance_to(pickup.global_position) <= ACTION_RADIUS:
				stage = MissionStage.DELIVER_BOX
				if cargo_visual:
					cargo_visual.hide()
				pickup.visible = false
				GameState.set_objective("La última llamada", "Llevá el paquete al muelle del Puerto Salvador Allende.")
				GameState.show_dialogue("Lenner", ["La caja pesa. Aquí hay algo de la investigación de mi hermana.", "Mejor me voy por la avenida antes de que se arme el relajo."])
			else:
				GameState.show_toast("El paquete está dentro del Mercado Oriental, junto a la pulpería.")
		MissionStage.DELIVER_BOX:
			if delivery and actor_position.distance_to(delivery.global_position) <= ACTION_RADIUS + 1.0:
				stage = MissionStage.COMPLETE
				delivery.visible = false
				GameState.add_money(250)
				GameState.finish_mission("encargo_del_lago")
				GameState.clear_wanted_level()
				GameState.set_objective("La última llamada", "Pista encontrada. Explorá el muelle y preparate para la siguiente misión.")
				GameState.show_dialogue("Mecánico Tono", ["¡Tuani! Llegaste entero.", "La señal salió desde el lago. Tu hermana estuvo aquí hace poco.", "Guardá esa pista, chavalo. Esto apenas comienza."])
			else:
				GameState.show_toast("El muelle está al norte, junto al agua del Xolotlán.")

func _spawn_cargo() -> void:
	if not pickup:
		return
	cargo_visual = MeshInstance3D.new()
	cargo_visual.name = "EncargoBox"
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(0.72, 0.58, 0.72)
	cargo_visual.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.58, 0.28, 0.08, 1.0)
	material.roughness = 0.82
	cargo_visual.material_override = material
	cargo_visual.position = Vector3(0, 0.42, 0)
	pickup.add_child(cargo_visual)

func _animate_markers() -> void:
	for marker in [contact, pickup, delivery]:
		if marker and marker.visible:
			marker.rotation.y += 0.8 * get_process_delta_time()
			marker.position.y = lerp(marker.position.y, 0.35 + sin(elapsed * 2.2 + marker.position.x) * 0.07, 0.08)

func _show_stage_hint() -> void:
	match stage:
		MissionStage.MEET_CHELA:
			GameState.show_toast("Objetivo: encontrá a La Chela en el Mercado Oriental.", 2.4)
		MissionStage.PICK_UP_BOX:
			GameState.show_toast("Objetivo: buscá el paquete marcado.", 2.4)
		MissionStage.DELIVER_BOX:
			GameState.show_toast("Objetivo: cruzá la avenida hasta el Puerto Salvador Allende.", 2.4)
