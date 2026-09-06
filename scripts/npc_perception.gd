extends Node3D

@export var detection_radius := 18.0
@export var think_interval := 0.35
var _clock := 0.0
var _player: Node3D

func _ready() -> void:
    _player = get_tree().get_first_node_in_group("player") as Node3D
    if _player == null:
        _player = get_tree().root.find_child("NPC", true, false) as Node3D

func _process(delta: float) -> void:
    _clock -= delta
    if _clock > 0.0:
        return
    _clock = think_interval
    if _player == null or not is_instance_valid(_player):
        return
    var owner_node := get_parent() as Node3D
    if owner_node == null:
        return
    var close := owner_node.global_position.distance_to(_player.global_position) <= detection_radius
    var controller := owner_node.get_node_or_null("NPCController") as NPCController
    if controller and not controller.is_main_character:
        controller.set_state("idle" if close else "walk")
