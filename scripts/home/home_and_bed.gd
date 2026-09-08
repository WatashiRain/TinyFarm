class_name HomeAndBed
extends StaticBody2D


func _ready() -> void:
	add_to_group("home_bed")
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"): return
	var player := get_tree().get_first_node_in_group("player") as PlayerController
	if player != null and player.global_position.distance_to(global_position + Vector2(0, 20)) < 38.0:
		sleep()


func sleep() -> void:
	TimeManager.advance_day()
	if GameState.player_stats != null: GameState.player_stats.restore_all()
	GameState.notify("Rested at home")


func _draw() -> void:
	draw_rect(Rect2(-28, -30, 56, 45), Color("#d8b071"), true)
	draw_polygon(PackedVector2Array([Vector2(-34, -29), Vector2(0, -51), Vector2(34, -29)]), PackedColorArray([Color("#8f4c45")]))
	draw_rect(Rect2(-8, -5, 16, 20), Color("#76503a"), true)
	draw_rect(Rect2(13, -17, 10, 10), Color("#8fd0ca"), true)
	draw_rect(Rect2(-22, 18, 30, 11), Color("#d9e0b4"), true)
	draw_rect(Rect2(-22, 24, 30, 5), Color("#73936a"), true)
	draw_string(ThemeDB.fallback_font, Vector2(-18, 40), "BED [F]", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#fff0b0"))
