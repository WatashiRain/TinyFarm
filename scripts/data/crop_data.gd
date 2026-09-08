class_name CropData
extends Resource

@export var id: StringName
@export var display_name: String
@export var seed_item_id: StringName
@export var harvest_item_id: StringName
@export var growth_stages: int = 4
@export var days_per_stage: int = 1
@export var regrows := false
@export var stage_colors: PackedColorArray
