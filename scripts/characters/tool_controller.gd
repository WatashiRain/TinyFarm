class_name ToolController
extends Node2D

@export var show_target := true

@onready var player: PlayerController = get_parent()
@onready var stats: PlayerStats = player.get_node("Stats")
@onready var camera: CameraShake2D = player.get_node("Camera2D")


func _process(_delta: float) -> void:
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_tool"):
		_use_selected_tool()
	elif event.is_action_pressed("interact"):
		_try_gather_plant()


func target_position() -> Vector2:
	return player.global_position + facing_vector() * 18.0


func target_cell() -> Vector2i:
	return Vector2i(floori(target_position().x / 16.0), floori(target_position().y / 16.0))


func facing_vector() -> Vector2:
	match player.last_facing:
		PlayerController.Facing.LEFT:
			return Vector2.LEFT
		PlayerController.Facing.RIGHT:
			return Vector2.RIGHT
		PlayerController.Facing.UP:
			return Vector2.UP
	return Vector2.DOWN


func _use_selected_tool() -> void:
	var selected := GameState.selected_item_id()
	if selected == &"":
		GameState.notify("Select a tool on the hotbar")
		return
	if _use_farming(selected):
		stats.consume_energy(1)
		camera.shake(0.45, 0.08)
		return
	if not stats.consume_energy(2):
		GameState.notify("Too tired")
		return
	if _hit_resource(selected):
		camera.shake(0.8, 0.1)
	else:
		GameState.notify("Used %s" % GameState.get_item(selected).display_name)


func _try_gather_plant() -> void:
	if _harvest_crop():
		camera.shake(0.4, 0.08)
	elif _hit_resource(&""):
		camera.shake(0.5, 0.08)


func _use_farming(item_id: StringName) -> bool:
	for grid: FarmingGrid in get_tree().get_nodes_in_group("farming_grid"):
		if grid.use_item(item_id, target_position()):
			return true
	return false


func _harvest_crop() -> bool:
	for grid: FarmingGrid in get_tree().get_nodes_in_group("farming_grid"):
		if grid.harvest(target_position()):
			return true
	return false


func _hit_resource(tool_id: StringName) -> bool:
	var closest: ResourceNode
	var closest_distance := 24.0
	for node: ResourceNode in get_tree().get_nodes_in_group("resource_nodes"):
		var distance := node.global_position.distance_to(target_position())
		if distance < closest_distance and (node.required_tool == tool_id or node.required_tool == &""):
			closest = node
			closest_distance = distance
	return closest != null and closest.hit(tool_id)


func _draw() -> void:
	if not show_target:
		return
	var local_target := facing_vector() * 16.0
	draw_rect(Rect2(local_target - Vector2(8, 8), Vector2(16, 16)), Color(1, 0.94, 0.69, 0.1), true)
	draw_rect(Rect2(local_target - Vector2(8, 8), Vector2(16, 16)), Color(1, 0.94, 0.69, 0.45), false, 1.0)
