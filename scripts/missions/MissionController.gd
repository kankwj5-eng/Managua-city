class_name MissionController
extends Node

enum MissionStage { MEET_CHELA, PICK_UP_BOX, DELIVER_BOX, COMPLETE }

const BOX_MODEL := preload("res://assets/models/third_party/kenney_car_kit/box.glb")
const ACTION_RADIUS := 3.0

var stage := MissionStage.MEET_CHELA
var contact: Node3D
var pickup: Node3D
var delivery: Node3D
var cargo_visual: Node3D
var elapsed := 0.0

func _ready() -> void:
	await get_tree().process_frame
	contact = get_tree().get_first_node_in_group("mission_contact") as Node3D
	pickup = get_tree().get_first_node_in_group("mission_pickup") as Node3D
	delivery = get_tree().get_first_node_in_group("mission_delivery") as Node3D
	_spawn_cargo()
	GameState.current_mission_id = "encargo_del_lago"
	GameState.set_objective("Encargo del Lago", "Buscá a La Chela, junto al mercado azul.")
	GameState.show_toast("Diay, maje: Puerto del Sur está despierto.", 4.0)

func _process(delta: float) -> void:
	elapsed += delta
	_animate_markers()
	if stage == MissionStage.COMPLETE or not _has_actor():
		return
	if Input.is_action_just_pressed("interact"):
		_try_advance()

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
				contact.visible = false
				GameState.set_objective("Encargo del Lago", "Recogé la caja marcada dentro del mercado.")
				GameState.show_toast("La Chela: 'Llevá esa caja al malecón, pero con cuidado, pues.'", 4.5)
			else:
				GameState.show_toast("La Chela está junto al mercado azul.")
		MissionStage.PICK_UP_BOX:
			if pickup and actor_position.distance_to(pickup.global_position) <= ACTION_RADIUS:
				stage = MissionStage.DELIVER_BOX
				if cargo_visual:
					cargo_visual.hide()
				pickup.visible = false
				GameState.set_objective("Encargo del Lago", "Llevá el encargo al malecón. El punto violeta te guía.")
				GameState.show_toast("Caja asegurada. Dale suave en las curvas, maje.", 3.8)
			else:
				GameState.show_toast("La caja está marcada dentro del mercado.")
		MissionStage.DELIVER_BOX:
			if delivery and actor_position.distance_to(delivery.global_position) <= ACTION_RADIUS + 1.0:
				stage = MissionStage.COMPLETE
				delivery.visible = false
				GameState.add_money(250)
				GameState.finish_mission("encargo_del_lago")
				GameState.set_objective("Encargo del Lago", "Misión completada. Explorá Puerto del Sur.")
				GameState.show_toast("¡Tuani! Entrega hecha. Recibiste C$ 250.", 4.5)
			else:
				GameState.show_toast("El malecón queda hacia las luces del lago.")

func _spawn_cargo() -> void:
	if not pickup:
		return
	cargo_visual = BOX_MODEL.instantiate() as Node3D
	cargo_visual.name = "EncargoBox"
	cargo_visual.position = Vector3(0, 0.36, 0)
	cargo_visual.scale = Vector3(0.72, 0.72, 0.72)
	pickup.add_child(cargo_visual)

func _animate_markers() -> void:
	for marker in [contact, pickup, delivery]:
		if marker and marker.visible:
			marker.rotation.y += 0.8 * get_process_delta_time()
			marker.position.y = lerp(marker.position.y, 0.48 + sin(elapsed * 2.2 + marker.position.x) * 0.08, 0.08)
