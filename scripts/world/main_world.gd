class_name MainWorld
extends Node2D

@onready var player: PlayerController = $PlaygroundBase/World/Player
@onready var stats: PlayerStats = $PlaygroundBase/World/Player/Stats


func _ready() -> void:
	player.position = GameState.player_position
	stats.died.connect(_on_player_died)
	_update_region(true)


func _process(_delta: float) -> void:
	GameState.player_position = player.position
	_update_region(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_day"):
		TimeManager.advance_day()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("save_game"):
		SaveManager.save_game()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("load_game"):
		SaveManager.load_game()
		get_viewport().set_input_as_handled()


func _update_region(force: bool) -> void:
	var region: StringName = &"forest" if player.position.x >= 620.0 else &"farm"
	if force or GameState.current_region != region:
		GameState.set_region(region)
		GameState.notify("Entered %s Region" % String(region).capitalize())


func _on_player_died() -> void:
	set_process(false)
	player.set_physics_process(false)
	GameState.add_gold(-int(ceil(GameState.gold * 0.1)))
	GameState.notify("Chun was defeated — returning home")
	$DefeatOverlay.show_defeat()
	await get_tree().create_timer(0.8).timeout
	player.position = Vector2(352, 270)
	stats.restore_all()
	player.set_physics_process(true)
	set_process(true)
