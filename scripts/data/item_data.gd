class_name ItemData
extends Resource

enum Category {
	MATERIAL,
	TOOL,
	SEED,
	CROP,
	FOOD,
	MONSTER_DROP,
	WEAPON,
	CONSUMABLE,
	BUILDING_MATERIAL,
}

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var category: Category = Category.MATERIAL
@export var max_stack: int = 99
@export var sell_value: int = 1
@export var placeholder_color: Color = Color.WHITE
