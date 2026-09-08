class_name TinyFarmNPC
extends StaticBody2D

@export var npc_name := "Mira"
@export var role: StringName = &"mira"
@export var placeholder_color := Color("#d98672")


func _ready() -> void:
	add_to_group("npcs")
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"): return
	var player := get_tree().get_first_node_in_group("player") as PlayerController
	if player == null or player.global_position.distance_to(global_position) > 32.0: return
	var dialogue := get_tree().get_first_node_in_group("dialogue_ui") as DialogueUI
	if role == &"mira":
		dialogue.open(npc_name, ["Welcome to the farm, Chun.", "Could you gather 10 Wood for our repairs?"], _mira_finished)
	else:
		dialogue.open(npc_name, ["Good tools begin with good materials.", "Bring me your crops and supplies whenever you want to trade."], _ren_finished)


func _mira_finished() -> void:
	var quests := get_tree().get_first_node_in_group("quest_system") as QuestSystem
	quests.start_quest(&"gather_wood")
	quests.start_quest(&"defeat_slimes")


func _ren_finished() -> void:
	var quests := get_tree().get_first_node_in_group("quest_system") as QuestSystem
	quests.start_quest(&"craft_workbench")
	(get_tree().get_first_node_in_group("shop_ui") as ShopUI).open()


func _draw() -> void:
	draw_rect(Rect2(-5, -18, 10, 14), placeholder_color, true)
	draw_circle(Vector2(0, -23), 6, placeholder_color.lightened(0.18))
	draw_rect(Rect2(-6, -3, 4, 8), Color("#4a3b42"), true)
	draw_rect(Rect2(2, -3, 4, 8), Color("#4a3b42"), true)
	draw_circle(Vector2(-2, -24), 1, Color("#243833")); draw_circle(Vector2(2, -24), 1, Color("#243833"))
	draw_string(ThemeDB.fallback_font, Vector2(-12, -31), npc_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("#fff0b0"))
