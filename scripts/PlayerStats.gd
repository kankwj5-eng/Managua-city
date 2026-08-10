extends Node

signal health_changed(current: float, max_health: float)
signal player_died

@export var max_health: float = 100.0:
	set(value):
		max_health = value
		if current_health > max_health:
			current_health = max_health
		health_changed.emit(current_health, max_health)

@export var current_health: float = 100.0:
	set(value):
		current_health = clamp(value, 0.0, max_health)
		health_changed.emit(current_health, max_health)

# Global Touch Input Vector from Virtual Joystick for Mobile
var touch_input_vector: Vector2 = Vector2.ZERO

func _ready():
	current_health = max_health

func take_damage(amount: float) -> void:
	if current_health <= 0:
		return
	current_health -= amount
	if current_health <= 0:
		player_died.emit()
		print("Player has died!")
		# Call deferred to avoid scene transition state conflicts during physics/collision steps
		call_deferred("_handle_death")

func heal(amount: float) -> void:
	if current_health <= 0:
		return # Can't heal if dead
	current_health += amount

func reset_stats() -> void:
	current_health = max_health

func _handle_death() -> void:
	reset_stats()
	var tree = get_tree()
	if tree:
		tree.reload_current_scene()
