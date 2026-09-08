class_name ShopUI
extends CanvasLayer

@onready var panel: PanelContainer = $Panel
@onready var gold_label: Label = $Panel/Margin/List/Gold


func _ready() -> void:
	add_to_group("shop_ui")
	GameState.gold_changed.connect(_refresh)
	GameState.inventory.changed.connect(_refresh)
	$Panel/Margin/List/BuySeed.pressed.connect(buy_turnip_seed)
	$Panel/Margin/List/SellTurnip.pressed.connect(sell.bind(&"turnip"))
	$Panel/Margin/List/SellWood.pressed.connect(sell.bind(&"wood"))
	$Panel/Margin/List/SellStone.pressed.connect(sell.bind(&"stone"))
	$Panel/Margin/List/Close.pressed.connect(func() -> void: panel.visible = false)
	_refresh()


func open() -> void:
	panel.visible = true
	_refresh()


func buy_turnip_seed() -> bool:
	if not GameState.spend_gold(5):
		GameState.notify("Not enough Gold")
		return false
	if GameState.inventory.add_item(GameState.get_item(&"turnip_seed"), 1) > 0:
		GameState.add_gold(5)
		return false
	GameState.notify("Bought Turnip Seed")
	return true


func sell(item_id: StringName) -> bool:
	if not GameState.inventory.remove_item(item_id, 1):
		GameState.notify("Nothing to sell")
		return false
	var value := GameState.get_item(item_id).sell_value
	GameState.add_gold(value)
	GameState.notify("Sold %s +%d Gold" % [GameState.get_item(item_id).display_name, value])
	return true


func _refresh(_current_gold: int = -1) -> void:
	if gold_label == null: return
	gold_label.text = "GOLD  %d" % GameState.gold
	$Panel/Margin/List/SellTurnip.text = "Sell Turnip (%d)" % GameState.inventory.count_item(&"turnip")
	$Panel/Margin/List/SellWood.text = "Sell Wood (%d)" % GameState.inventory.count_item(&"wood")
	$Panel/Margin/List/SellStone.text = "Sell Stone (%d)" % GameState.inventory.count_item(&"stone")
