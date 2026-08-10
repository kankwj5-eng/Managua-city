extends Camera3D

@export var player_path: NodePath = "/root/Main/Player"
@export var height: float = 30.0

var player: Node3D = null

func _ready():
	projection = Camera3D.PROJECTION_ORTHOGONAL
	size = 35.0 # View width in meters
	rotation_degrees = Vector3(-90, 0, 0)

	_find_player()

func _find_player():
	if has_node(player_path):
		player = get_node(player_path) as Node3D
	else:
		# Fallback: search tree for a node named "Player"
		var root = get_tree().root
		player = _search_for_player_node(root)

func _search_for_player_node(node: Node) -> Node3D:
	if node.name == "Player" and node is Node3D:
		return node
	for child in node.get_children():
		var found = _search_for_player_node(child)
		if found:
			return found
	return null

func _physics_process(_delta):
	if not player or not is_instance_valid(player):
		_find_player()
		return

	# Follow player horizontally from above
	global_position = Vector3(player.global_position.x, height, player.global_position.z)
