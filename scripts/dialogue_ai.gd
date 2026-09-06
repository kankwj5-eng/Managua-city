class_name DialogueAI
extends Node

## IA opcional: el juego funciona sin red usando respuestas locales.
@export var endpoint := ""
@export var timeout_seconds := 4.0
var local_lines := [
    "Bienvenido al barrio. La playa queda hacia el sur.",
    "El mercado está cerca; sigue la avenida principal.",
    "Ten cuidado al cruzar la avenida; aquí pasan muchos vehículos.",
    "¿Buscas trabajo? Pregunta en el centro de la ciudad."
]
var _http: HTTPRequest
var _pending_fallback := ""

func _ready() -> void:
    _http = HTTPRequest.new()
    _http.timeout = timeout_seconds
    add_child(_http)
    _http.request_completed.connect(_on_request_completed)

func get_dialogue(player_text: String, character_id: int = 0) -> String:
    return local_lines[(player_text.length() + character_id) % local_lines.size()]

func request_dialogue(player_text: String, character_id: int = 0) -> void:
    _pending_fallback = get_dialogue(player_text, character_id)
    if endpoint.is_empty() or _http.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
        return
    var payload := {"character_id": character_id, "message": player_text.substr(0, 240), "language": "es", "max_tokens": 80}
    _http.request(endpoint, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(payload))

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
        dialogue_ready.emit(_pending_fallback)
        return
    var parsed = JSON.parse_string(body.get_string_from_utf8())
    if parsed is Dictionary and parsed.has("reply") and str(parsed.reply).length() <= 360:
        dialogue_ready.emit(str(parsed.reply).strip_edges())
    else:
        dialogue_ready.emit(_pending_fallback)

signal dialogue_ready(reply: String)
