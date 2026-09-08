class_name RecipeData
extends Resource

@export var id: StringName
@export var display_name: String
@export var output_item_id: StringName
@export var output_quantity: int = 1
@export var ingredients: Dictionary = {}


func can_craft(inventory: InventoryData) -> bool:
	for item_id: String in ingredients:
		if not inventory.contains(StringName(item_id), int(ingredients[item_id])):
			return false
	return true
