extends Node3D

func _ready():
	# Dynamically generate trimesh collisions for all meshes in this level
	_generate_collisions(self)

func _generate_collisions(node: Node):
	if node is MeshInstance3D:
		# create_trimesh_collision creates a StaticBody3D with a CollisionShape3D
		# as a child of the MeshInstance3D automatically.
		node.create_trimesh_collision()

	for child in node.get_children():
		_generate_collisions(child)
