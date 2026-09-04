class_name DialogueAI
extends Node

## Interfaz preparada para IA remota; la APK usa fallback local si no hay red.
@export var endpoint := ""
var local_lines := [
    "Bienvenido al barrio. La playa queda hacia el sur.",
    "El hospital nuevo está cerca del mercado.",
    "Ten cuidado al cruzar la avenida; aquí pasan muchos vehículos.",
    "¿Buscas trabajo? Pregunta en el centro de la ciudad."
]

func get_dialogue(player_text: String, character_id: int = 0) -> String:
    if endpoint.is_empty():
        return local_lines[(player_text.length() + character_id) % local_lines.size()]
    # La integración remota se activa sólo con un backend seguro propio.
    return local_lines[character_id % local_lines.size()]
