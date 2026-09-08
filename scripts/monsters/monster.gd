class_name Monster
extends CharacterBody2D

enum State { IDLE, WANDER, CHASE, ATTACK, RETURN }

@export var data: MonsterData
@export var aggro_range := 80.0
@export var leash_range := 150.0
@export var attack_range := 18.0

var health: int
var home: Vector2
var state := State.IDLE
var state_time := 1.0
var attack_cooldown := 0.0
var wander_direction := Vector2.ZERO
var player: PlayerController

const DROP_SCENE := preload("res://scenes/items/world_drop.tscn")


func _ready() -> void:
	add_to_group("monsters")
	health = data.max_health
	home = global_position
	player = get_tree().get_first_node_in_group("player")
	queue_redraw()


func _physics_process(delta: float) -> void:
	if player == null: return
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	state_time -= delta
	var player_distance := global_position.distance_to(player.global_position)
	var home_distance := global_position.distance_to(home)
	if home_distance > leash_range: state = State.RETURN
	elif player_distance <= attack_range: state = State.ATTACK
	elif player_distance <= aggro_range: state = State.CHASE
	elif state in [State.CHASE, State.ATTACK, State.RETURN]: state = State.IDLE; state_time = 1.0
	match state:
		State.CHASE: velocity = global_position.direction_to(player.global_position) * data.move_speed
		State.ATTACK:
			velocity = Vector2.ZERO
			if attack_cooldown <= 0.0:
				attack_cooldown = 1.1
				var hurtbox := player.get_node("Hurtbox") as Hurtbox
				hurtbox.receive_hit(data.attack_damage, global_position.direction_to(player.global_position) * 35.0)
		State.RETURN: velocity = global_position.direction_to(home) * data.move_speed
		State.IDLE:
			velocity = Vector2.ZERO
			if state_time <= 0.0:
				state = State.WANDER; state_time = 1.2; wander_direction = Vector2.from_angle(fmod(global_position.x + global_position.y, TAU)).normalized()
		State.WANDER:
			velocity = wander_direction * data.move_speed * 0.45
			if state_time <= 0.0: state = State.IDLE; state_time = 1.8
	move_and_slide()


func take_hit(damage: int, knockback: Vector2) -> void:
	health -= maxi(1, damage)
	global_position += knockback * 0.035
	modulate = Color(1.7, 1.7, 1.7)
	var tween := create_tween(); tween.tween_property(self, "modulate", Color.WHITE, 0.12)
	if health <= 0: _die()


func _die() -> void:
	GameState.player_stats.add_experience(data.xp_reward)
	var drop: WorldDrop = DROP_SCENE.instantiate()
	get_tree().current_scene.add_child(drop)
	drop.global_position = global_position
	drop.setup(data.loot_item_id, data.loot_quantity)
	GameState.notify("Defeated %s +%d XP" % [data.display_name, data.xp_reward])
	queue_free()


func _draw() -> void:
	if data == null: return
	if data.id == &"slime":
		draw_circle(Vector2(0, -3), 10, data.placeholder_color)
		draw_rect(Rect2(-10, -3, 20, 8), data.placeholder_color, true)
		draw_circle(Vector2(-3, -5), 1.3, Color("#17372b")); draw_circle(Vector2(4, -5), 1.3, Color("#17372b"))
	elif data.id == &"bat":
		draw_polygon(PackedVector2Array([Vector2(-16, 0), Vector2(-8, -8), Vector2(-3, -2), Vector2(0, -8), Vector2(3, -2), Vector2(9, -8), Vector2(16, 0), Vector2(7, 5), Vector2(0, 2), Vector2(-7, 5)]), PackedColorArray([data.placeholder_color]))
		draw_circle(Vector2.ZERO, 4, data.placeholder_color.lightened(0.2))
	else:
		draw_circle(Vector2(0, -5), 8, Color(data.placeholder_color, 0.85))
		draw_polygon(PackedVector2Array([Vector2(-8, -2), Vector2(0, -18), Vector2(8, -2), Vector2(5, 8), Vector2(-5, 8)]), PackedColorArray([Color(data.placeholder_color, 0.75)]))
		draw_circle(Vector2(0, -7), 2, Color("#e8ffd4"))
