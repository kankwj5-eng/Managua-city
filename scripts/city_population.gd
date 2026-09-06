extends Node

## Población ligera por barrios usando instancias reutilizables de los tres modelos.
@export_range(0, 3) var selected_character := 0
@export var copies_per_neighborhood := 4
@export var neighborhoods := ["Centro", "Playa", "Mercado"]
var character_scenes := [
    preload("res://assets/npc/rigged/npc_rigged.glb"),
    preload("res://assets/npc/rigged/npc_02_rigged.glb"),
    preload("res://assets/npc/rigged/npc_03_rigged.glb")
]
var characters: Array[Node3D] = []

func _ready() -> void:
    _spawn_neighborhoods()

func _spawn_neighborhoods() -> void:
    for barrio_index in neighborhoods.size():
        var barrio := Node3D.new()
        barrio.name = "Barrio_" + str(neighborhoods[barrio_index])
        add_child(barrio)
        var center := Vector3(float(barrio_index * 70 - 70), 0.2, 45.0)
        for copy_index in copies_per_neighborhood:
            var character_index := (barrio_index + copy_index) % 3
            var actor := character_scenes[character_index].instantiate() as Node3D
            actor.name = "NPC_%s_%02d" % [neighborhoods[barrio_index], copy_index + 1]
            actor.scale = Vector3.ONE * 1.80
            actor.position = center + Vector3(float((copy_index % 2) * 12 - 6), 0.0, float((copy_index / 2) * 12 - 6))
            barrio.add_child(actor)
            _configure_actor(actor, character_index, false)
            characters.append(actor)

func _configure_actor(actor: Node3D, character_index: int, main_character: bool) -> void:
    var controller := NPCController.new()
    controller.character_id = character_index
    controller.is_main_character = main_character
    controller.state = "walk"
    actor.add_child(controller)

func select_character(character_index: int) -> void:
    if character_index < 0 or character_index >= character_scenes.size():
        return
    selected_character = character_index
    for actor in characters:
        var controller := actor.get_node_or_null("NPCController") as NPCController
        if controller:
            controller.is_main_character = false
    var selected := character_scenes[character_index].instantiate() as Node3D
    selected.name = "PersonajePrincipal"
    selected.scale = Vector3.ONE * 1.80
    selected.position = Vector3(0, 0.2, 0)
    add_child(selected)
    _configure_actor(selected, character_index, true)
    characters.append(selected)
