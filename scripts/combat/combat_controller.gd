class_name CombatController
extends Node2D

@onready var player: PlayerController = get_parent()
@onready var stats: PlayerStats = player.get_node("Stats")
@onready var hitbox: AttackHitbox = $AttackHitbox
var cooldown := 0.0


func _process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if GameState.selected_item_id() != &"basic_sword":
			GameState.notify("Select Basic Sword")
			return
		attack()


func attack(multiplier := 1.0, attack_range := 26.0, color := Color("#ffe089")) -> int:
	if cooldown > 0.0: return 0
	cooldown = 0.32
	var hits := hitbox.activate(_facing(), roundi(stats.attack * multiplier), attack_range, color)
	if hits > 0: player.get_node("Camera2D").shake(0.7, 0.1)
	return hits


func _facing() -> Vector2:
	return player.get_node("ToolController").facing_vector()
