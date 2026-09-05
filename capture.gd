extends "res://scripts/world_upgrades.gd"

## Ajusta la cámara inicial y ejecuta las mejoras visuales sin cerrar el juego.
func _ready() -> void:
    super._ready()
    var camera := $Camera3D as Camera3D
    camera.position = Vector3(360.0, 170.0, 360.0)
    camera.look_at(Vector3(-54.0, -260.0, -180.0), Vector3.UP)
