extends Node3D

## Mejoras ligeras y escalables para la ciudad móvil.
const NPC_SCALE := 1.80
const HOSPITAL_POSITION := Vector3(55.0, 0.0, 34.0)

func _ready() -> void:
    _normalize_npc_scale()
    _add_vegetation_accents()

func _normalize_npc_scale() -> void:
    for node in get_tree().get_nodes_in_group("characters"):
        node.scale = Vector3.ONE * NPC_SCALE

func _build_hospital() -> void:
    var hospital := Node3D.new()
    hospital.name = "HospitalCentral"
    hospital.position = HOSPITAL_POSITION
    add_child(hospital)
    var wall_material := StandardMaterial3D.new()
    wall_material.albedo_color = Color("#e8edf2")
    var accent_material := StandardMaterial3D.new()
    accent_material.albedo_color = Color("#55a9b8")
    var roof_material := StandardMaterial3D.new()
    roof_material.albedo_color = Color("#b8c7cf")
    _box(hospital, "Building", Vector3(20, 8, 14), Vector3(0, 4, 0), wall_material)
    _box(hospital, "Roof", Vector3(22, 0.7, 16), Vector3(0, 8.35, 0), roof_material)
    _box(hospital, "Entrance", Vector3(8, 3.5, 0.5), Vector3(0, 3.5, 7.1), accent_material)
    _box(hospital, "CrossVertical", Vector3(1.8, 5.0, 0.35), Vector3(0, 5.1, 7.45), ColorMaterial(Color.WHITE))
    _box(hospital, "CrossHorizontal", Vector3(5.0, 1.8, 0.35), Vector3(0, 5.1, 7.45), ColorMaterial(Color.WHITE))
    _box(hospital, "Parking", Vector3(28, 0.1, 20), Vector3(0, 0.05, 12), ColorMaterial(Color("#45515a")))

func _add_vegetation_accents() -> void:
    var vegetation := Node3D.new()
    vegetation.name = "VegetationAccents"
    add_child(vegetation)
    var trunk := ColorMaterial(Color("#6b4028"))
    var leaves := ColorMaterial(Color("#2d8a57"))
    for i in 12:
        var x := float((i % 6) * 11 - 28)
        var z := float((i / 6) * 12 - 12)
        _cylinder(vegetation, "PalmTrunk_%02d" % i, 0.22, 4.0, Vector3(x, 2.0, z), trunk)
        _sphere(vegetation, "PalmLeaves_%02d" % i, 1.6, Vector3(x, 4.5, z), leaves)

func _box(parent: Node3D, node_name: String, size: Vector3, pos: Vector3, material: Material) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    var instance := MeshInstance3D.new()
    instance.name = node_name
    instance.mesh = mesh
    instance.material_override = material
    instance.position = pos
    parent.add_child(instance)

func _cylinder(parent: Node3D, node_name: String, radius: float, height: float, pos: Vector3, material: Material) -> void:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius * 1.2
    mesh.height = height
    var instance := MeshInstance3D.new()
    instance.name = node_name
    instance.mesh = mesh
    instance.material_override = material
    instance.position = pos
    parent.add_child(instance)

func _sphere(parent: Node3D, node_name: String, radius: float, pos: Vector3, material: Material) -> void:
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 1.5
    var instance := MeshInstance3D.new()
    instance.name = node_name
    instance.mesh = mesh
    instance.material_override = material
    instance.position = pos
    parent.add_child(instance)

func ColorMaterial(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    return material
