class_name InventoryData
extends Resource

signal item_added(item_id: StringName, quantity: int)
signal item_removed(item_id: StringName, quantity: int)

@export var capacity: int = 24
var slots: Array[Dictionary] = []


func initialize(slot_count: int = 24) -> void:
	capacity = slot_count
	slots.resize(capacity)
	for index: int in range(capacity):
		if not slots[index].has("item_id") or not slots[index].has("quantity"):
			slots[index] = _empty_slot()
	emit_changed()


func add_item(item: ItemData, quantity: int) -> int:
	var remaining := maxi(0, quantity)
	for slot: Dictionary in slots:
		if slot["item_id"] == item.id and int(slot["quantity"]) < item.max_stack:
			var moved := mini(remaining, item.max_stack - int(slot["quantity"]))
			slot["quantity"] += moved
			remaining -= moved
			if remaining == 0:
				break
	while remaining > 0:
		var empty_index := _find_empty_slot()
		if empty_index < 0:
			break
		var moved := mini(remaining, item.max_stack)
		slots[empty_index] = {"item_id": item.id, "quantity": moved}
		remaining -= moved
	var accepted := quantity - remaining
	if accepted > 0:
		item_added.emit(item.id, accepted)
		emit_changed()
	return remaining


func remove_item(item_id: StringName, quantity: int) -> bool:
	if count_item(item_id) < quantity:
		return false
	var remaining := quantity
	for index: int in range(slots.size() - 1, -1, -1):
		if slots[index]["item_id"] != item_id:
			continue
		var removed := mini(remaining, int(slots[index]["quantity"]))
		slots[index]["quantity"] -= removed
		remaining -= removed
		if slots[index]["quantity"] <= 0:
			slots[index] = _empty_slot()
		if remaining == 0:
			break
	item_removed.emit(item_id, quantity)
	emit_changed()
	return true


func count_item(item_id: StringName) -> int:
	var total := 0
	for slot: Dictionary in slots:
		if slot["item_id"] == item_id:
			total += int(slot["quantity"])
	return total


func contains(item_id: StringName, quantity: int = 1) -> bool:
	return count_item(item_id) >= quantity


func move_slot(from_index: int, to_index: int) -> void:
	if not _valid_index(from_index) or not _valid_index(to_index) or from_index == to_index:
		return
	var source := slots[from_index]
	var target := slots[to_index]
	if source["item_id"] != &"" and source["item_id"] == target["item_id"]:
		var item: ItemData = GameState.get_item(source["item_id"])
		var moved := mini(int(source["quantity"]), item.max_stack - int(target["quantity"]))
		target["quantity"] += moved
		source["quantity"] -= moved
		if source["quantity"] <= 0:
			slots[from_index] = _empty_slot()
	else:
		slots[from_index] = target
		slots[to_index] = source
	emit_changed()


func swap_slots(first: int, second: int) -> void:
	move_slot(first, second)


func to_state() -> Array:
	var data: Array = []
	for slot: Dictionary in slots:
		data.append({"item_id": String(slot["item_id"]), "quantity": int(slot["quantity"])})
	return data


func apply_state(data: Array) -> void:
	initialize(capacity)
	for index: int in range(mini(data.size(), capacity)):
		var item_id := StringName(data[index].get("item_id", ""))
		slots[index] = {"item_id": item_id, "quantity": int(data[index].get("quantity", 0))}
	emit_changed()


func _find_empty_slot() -> int:
	for index: int in range(slots.size()):
		if slots[index]["item_id"] == &"":
			return index
	return -1


func _valid_index(index: int) -> bool:
	return index >= 0 and index < slots.size()


func _empty_slot() -> Dictionary:
	return {"item_id": &"", "quantity": 0}
