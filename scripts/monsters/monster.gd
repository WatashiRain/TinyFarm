class_name Monster
extends CharacterBody2D

enum State { IDLE, WANDER, CHASE, ATTACK, RETURN }

@export var data: MonsterData
@export var aggro_range := 80.0
@export var leash_range := 150.0
@export var attack_range := 18.0

@onready var attack_controller: MonsterAttackController = $AttackController

var health: int
var home: Vector2
var state := State.IDLE
var state_time := 1.0
var attack_cooldown := 0.0
var wander_direction := Vector2.ZERO
var player: PlayerController
var stagger_time := 0.0

const DROP_SCENE := preload("res://scenes/items/world_drop.tscn")


func _ready() -> void:
	add_to_group("monsters")
	health = data.max_health
	home = global_position
	player = get_tree().get_first_node_in_group("player")
	queue_redraw()


func _physics_process(delta: float) -> void:
	if player == null: return
	if stagger_time > 0.0:
		stagger_time = maxf(0.0, stagger_time - delta)
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if attack_controller.busy:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	state_time -= delta
	var player_distance := global_position.distance_to(player.global_position)
	var home_distance := global_position.distance_to(home)
	if home_distance > leash_range: state = State.RETURN
	elif player_distance <= aggro_range and attack_controller.try_attack(player_distance): state = State.ATTACK
	elif player_distance <= aggro_range: state = State.CHASE
	elif state in [State.CHASE, State.ATTACK, State.RETURN]: state = State.IDLE; state_time = 1.0
	match state:
		State.CHASE:
			var to_player := global_position.direction_to(player.global_position)
			if data.preferred_distance > 0.0 and player_distance < data.preferred_distance - 12.0:
				velocity = -to_player * data.move_speed * 0.8
			elif data.preferred_distance > 0.0 and player_distance <= data.preferred_distance + 10.0:
				velocity = Vector2(-to_player.y, to_player.x) * data.move_speed * 0.35
			else:
				velocity = to_player * data.move_speed
		State.ATTACK: velocity = Vector2.ZERO
		State.RETURN: velocity = global_position.direction_to(home) * data.move_speed
		State.IDLE:
			velocity = Vector2.ZERO
			if state_time <= 0.0:
				state = State.WANDER; state_time = 1.2; wander_direction = Vector2.from_angle(fmod(global_position.x + global_position.y, TAU)).normalized()
		State.WANDER:
			velocity = wander_direction * data.move_speed * 0.45
			if state_time <= 0.0: state = State.IDLE; state_time = 1.8
	move_and_slide()


func stagger(duration: float) -> void:
	stagger_time = maxf(stagger_time, duration)
	attack_controller.busy = false
	attack_controller.telegraph.hide_attack()
	modulate = Color("#fff3a1")
	var tween := create_tween(); tween.tween_property(self, "modulate", Color.WHITE, duration)


func take_hit(damage: int, knockback: Vector2) -> void:
	health -= maxi(1, damage)
	global_position += knockback * 0.035
	modulate = Color(1.7, 1.7, 1.7)
	var tween := create_tween(); tween.tween_property(self, "modulate", Color.WHITE, 0.12)
	if health <= 0: _die()


func _die() -> void:
	GameState.player_stats.add_experience(data.xp_reward)
	GameState.monster_defeated.emit(data.id)
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
