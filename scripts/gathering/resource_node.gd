class_name ResourceNode
extends StaticBody2D

enum Kind { TREE, ROCK, PLANT }

@export var persistent_id: StringName
@export var kind: Kind = Kind.TREE
@export var required_tool: StringName = &"basic_axe"
@export var drop_item_id: StringName = &"wood"
@export var drop_quantity: int = 3
@export var hits_required: int = 3

var hits_remaining: int
var depleted := false

const DROP_SCENE := preload("res://scenes/items/world_drop.tscn")


func _ready() -> void:
	add_to_group("resource_nodes")
	hits_remaining = hits_required
	if bool(GameState.world_state.get("resource_%s" % persistent_id, false)):
		_set_depleted(false)
	queue_redraw()


func hit(tool_id: StringName) -> bool:
	if depleted:
		return false
	if required_tool != &"" and tool_id != required_tool:
		GameState.notify("Needs %s" % GameState.get_item(required_tool).display_name)
		return false
	hits_remaining -= 1
	_react()
	if hits_remaining <= 0:
		_spawn_drop()
		_set_depleted(true)
	else:
		GameState.notify("%d hit%s remaining" % [hits_remaining, "" if hits_remaining == 1 else "s"])
	return true


func _react() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(0.9, 1.08), 0.06)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)


func _spawn_drop() -> void:
	var drop: WorldDrop = DROP_SCENE.instantiate()
	get_tree().current_scene.add_child(drop)
	drop.global_position = global_position + Vector2(0, 8)
	drop.setup(drop_item_id, drop_quantity)
	GameState.notify("Gathered %s" % GameState.get_item(drop_item_id).display_name)


func _set_depleted(record: bool) -> void:
	depleted = true
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	if record:
		GameState.world_state["resource_%s" % persistent_id] = true


func _draw() -> void:
	if kind == Kind.TREE:
		draw_rect(Rect2(-4, -22, 8, 22), Color("#704538"))
		draw_rect(Rect2(-2, -22, 3, 20), Color("#bc7650"))
		draw_polygon(PackedVector2Array([Vector2(-16, -20), Vector2(-11, -35), Vector2(0, -43), Vector2(13, -35), Vector2(17, -18), Vector2(8, -10), Vector2(-10, -11)]), PackedColorArray([Color("#356342")]))
		draw_circle(Vector2(-4, -27), 8, Color("#52914f"))
		draw_circle(Vector2(7, -27), 7, Color("#70ad5c"))
	elif kind == Kind.ROCK:
		draw_polygon(PackedVector2Array([Vector2(-12, 0), Vector2(-10, -10), Vector2(-3, -16), Vector2(9, -12), Vector2(13, -2), Vector2(8, 4), Vector2(-7, 4)]), PackedColorArray([Color("#60716a")]))
		draw_polygon(PackedVector2Array([Vector2(-6, -9), Vector2(-2, -13), Vector2(6, -10), Vector2(2, -6)]), PackedColorArray([Color("#a7b29f")]))
	else:
		for x: int in [-7, -2, 3, 8]:
			draw_line(Vector2(x, 2), Vector2(x - 2, -11 - abs(x) / 3), Color("#3f7547"), 2.0)
		draw_circle(Vector2(1, -7), 3, Color("#91c968"))
