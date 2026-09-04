extends Node3D

## Ajusta la cámara inicial sin cerrar el juego.
func _ready() -> void:
    var camera := $Camera3D as Camera3D
    camera.position = Vector3(360.0, 170.0, 360.0)
    camera.look_at(Vector3(-54.0, -260.0, -180.0), Vector3.UP)
