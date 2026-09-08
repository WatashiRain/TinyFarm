class_name WorldDrop
extends Area2D

@export var item_id: StringName = &"wood"
@export var quantity: int = 1

var _time := 0.0
var _base_visual_y := 0.0


func _ready() -> void:
	add_to_group("world_drops")
	body_entered.connect(_on_body_entered)
	_base_visual_y = $Visual.position.y
	scale = Vector2(0.4, 0.4)
	var pop := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(self, "scale", Vector2.ONE, 0.22)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	$Visual.position.y = _base_visual_y + roundf(sin(_time * 3.0))


func setup(new_item_id: StringName, new_quantity: int) -> void:
	item_id = new_item_id
	quantity = new_quantity
	queue_redraw()


func _draw() -> void:
	var item: ItemData = GameState.get_item(item_id)
	var color := item.placeholder_color if item != null else Color.WHITE
	draw_polygon(PackedVector2Array([Vector2(0, -6), Vector2(6, 0), Vector2(0, 5), Vector2(-6, 0)]), PackedColorArray([color]))
	draw_polyline(PackedVector2Array([Vector2(0, -6), Vector2(6, 0), Vector2(0, 5), Vector2(-6, 0), Vector2(0, -6)]), Color("#1f3935"), 1.0)


func _on_body_entered(body: Node2D) -> void:
	if body is not PlayerController:
		return
	var item: ItemData = GameState.get_item(item_id)
	var remaining := GameState.inventory.add_item(item, quantity)
	var accepted := quantity - remaining
	if accepted <= 0:
		GameState.notify("Inventory full")
		return
	quantity = remaining
	GameState.notify("Picked up %s ×%d" % [item.display_name, accepted])
	if quantity == 0:
		queue_free()
