extends Node3D

@export var debug_mode: bool = false:
	set(val):
		debug_mode = val
		_update_collision_visibility()

# Keep track of generated StaticBody3D collision nodes to toggle visibility/materials
var _collision_bodies: Array[StaticBody3D] = []
var _debug_materials: Dictionary = {}

func _ready():
	# Dynamically generate trimesh collisions for all meshes in this level
	_generate_collisions(self)
	_update_collision_visibility()

func _input(event):
	# Press F3 key to toggle debug collision shapes visualization at runtime
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_F3:
			debug_mode = not debug_mode
			print("Collision Debug Mode toggled: ", debug_mode)

func _generate_collisions(node: Node):
	if node is MeshInstance3D:
		# create_trimesh_collision creates a StaticBody3D with a CollisionShape3D
		# as a child of the MeshInstance3D automatically.
		node.create_trimesh_collision()

		# Find the created static body to keep track for debug representation
		for child in node.get_children():
			if child is StaticBody3D:
				_collision_bodies.append(child)
				# Ensure correct collision layer for player interaction
				child.collision_layer = 1
				child.collision_mask = 1

	for child in node.get_children():
		_generate_collisions(child)

func _update_collision_visibility():
	# Toggle built-in debug collision shapes if running inside Godot debug session
	# In addition, we will dynamically construct visible meshes representing the collision boundaries
	# so that the player can see them clearly during the gameplay.
	for body in _collision_bodies:
		for child in body.get_children():
			if child is CollisionShape3D:
				# Show/Hide built-in visualizer if we can, or draw debug outlines
				var debug_mesh_name = "DebugVisualMesh"
				var existing_debug_mesh = body.get_node_or_null(debug_mesh_name)

				if debug_mode:
					if not existing_debug_mesh:
						# Generate a mesh to represent the collision visually
						var shape = child.shape
						var mesh_instance = MeshInstance3D.new()
						mesh_instance.name = debug_mesh_name

						# Create a visual representation matching the collision shape
						var debug_mesh = shape.get_debug_mesh()
						if debug_mesh:
							mesh_instance.mesh = debug_mesh

							# Create a semi-transparent material for the debug view
							var mat = StandardMaterial3D.new()
							mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
							mat.albedo_color = Color(0.1, 0.8, 0.1, 0.4) # Semi-transparent green
							mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
							mesh_instance.material_override = mat

							body.add_child(mesh_instance)
							mesh_instance.global_transform = child.global_transform
					else:
						existing_debug_mesh.visible = true
				else:
					if existing_debug_mesh:
						existing_debug_mesh.visible = false
