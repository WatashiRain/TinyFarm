class_name CraftingUI
extends CanvasLayer

signal item_crafted(item_id: StringName, quantity: int)

@onready var panel: PanelContainer = $Panel
@onready var list: VBoxContainer = $Panel/Margin/List
var recipes: Array[RecipeData] = []

const RECIPE_PATHS := [
	"res://resources/recipes/wood_plank.tres", "res://resources/recipes/stone_block.tres",
	"res://resources/recipes/basic_chest.tres", "res://resources/recipes/workbench.tres",
	"res://resources/recipes/fence.tres",
]


func _ready() -> void:
	for path: String in RECIPE_PATHS:
		recipes.append(load(path))
	GameState.inventory.changed.connect(_refresh)
	_build()
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("craft_menu"):
		panel.visible = not panel.visible
		get_viewport().set_input_as_handled()


func craft(recipe: RecipeData) -> bool:
	if not recipe.can_craft(GameState.inventory):
		GameState.notify("Missing crafting materials")
		return false
	var output: ItemData = GameState.get_item(recipe.output_item_id)
	if GameState.inventory.add_item(output, recipe.output_quantity) > 0:
		GameState.notify("Inventory full")
		return false
	for ingredient: String in recipe.ingredients:
		GameState.inventory.remove_item(StringName(ingredient), int(recipe.ingredients[ingredient]))
	GameState.notify("Crafted %s" % output.display_name)
	item_crafted.emit(output.id, recipe.output_quantity)
	GameState.item_crafted.emit(output.id, recipe.output_quantity)
	return true


func _build() -> void:
	for recipe: RecipeData in recipes:
		var button := Button.new()
		button.custom_minimum_size = Vector2(180, 27)
		button.add_theme_font_size_override("font_size", 8)
		button.pressed.connect(craft.bind(recipe))
		list.add_child(button)


func _refresh() -> void:
	for index: int in range(recipes.size()):
		var recipe := recipes[index]
		var costs: Array[String] = []
		for ingredient: String in recipe.ingredients:
			costs.append("%s %d/%d" % [GameState.get_item(StringName(ingredient)).display_name, GameState.inventory.count_item(StringName(ingredient)), int(recipe.ingredients[ingredient])])
		var button: Button = list.get_child(index + 1)
		button.text = "%s\n%s" % [recipe.display_name, ", ".join(costs)]
		button.disabled = not recipe.can_craft(GameState.inventory)
