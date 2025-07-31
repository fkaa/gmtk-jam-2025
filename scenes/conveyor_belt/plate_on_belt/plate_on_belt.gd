extends Area3D
class_name PlateOnBelt

@onready var item_holder: Node3D = $ItemHolder

var items: Array[Node3D] = []

func take_item() -> Node3D:
	if len(items) > 0:
		return items.pop_back()
	else:
		return null

func add_item(item: Node3D):
	items.append(item)
	
	if item.get_parent():
		item.reparent(item_holder)
	else:
		item_holder.add_child(item)
	
	await _animate_take_item(item)
	
	item.top_level = false
	item.position = Vector3.ZERO
	item.position.y = len(items) * 0.25

func _animate_take_item(item: Node3D):
	# "detach" the item's position from its parent, so we can animate it moving to us
	item.top_level = true
	
	# animate the item towards us
	var t = get_tree().create_tween()
	t.tween_property(item, "global_position", item_holder.global_position, 0.25)
	await t.finished
