extends Node3D

var npc_name := "Vecino"
var role := "Habitante"
var dialogue: Array[String] = []
var police := false
var home_position := Vector3.ZERO
var patrol_phase := 0.0

func interact(_player: Node) -> void:
	if dialogue.is_empty():
		GameState.show_toast("Buenas, maje. Aquí todo tranquilo.")
		return
	GameState.show_dialogue(npc_name, dialogue)

func _process(delta: float) -> void:
	patrol_phase += delta
	if police:
		return
	rotation.y = sin(patrol_phase * 0.25 + home_position.x) * 0.08
