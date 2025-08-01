extends Area3D
class_name PlateOnBelt

@onready var item_holder: Node3D = $ItemHolder

var items: Array[Node3D] = []

func take_item() -> Node3D:
	if len(items) > 0:
		return items.pop_back()
	else:
		return null
		


func add_item(item: Node3D, is_new : bool = false):
	items.append(item)
	
	if item.get_parent():
		item.reparent(item_holder)
	else:
		item_holder.add_child(item)
	
	if (is_new):
		await _animate_spawn_item(item)
	else:
		await _animate_take_item(item)
	
	item.top_level = false
	item.position = Vector3.ZERO
	item.position.y = len(items) * 0.25
	
func _animate_spawn_item(item: Node3D):
	item.position.y = 50
	var t = get_tree().create_tween()
	t.set_trans(t.TRANS_CIRC)
	t.tween_property(item, "position", Vector3(0, len(items) * 0.25, 0), 0.5)
	await t.finished

# Deletes the item afterward.. seems wrong for animation function ¯\_(ツ)_/¯
func _animate_remove_item(item: Node3D):
	var t = get_tree().create_tween()
	t.set_trans(t.TRANS_CIRC)
	t.tween_property(item, "position", Vector3(0, 50, 0), 0.5)
	await t.finished
	item.queue_free()

func _animate_take_item(item: Node3D):
	# "detach" the item's position from its parent, so we can animate it moving to us
	item.top_level = true
	
	# animate the item towards us
	var t = get_tree().create_tween()
	t.tween_property(item, "global_position", item_holder.global_position, 0.25)
	await t.finished
	
func clean_top_down():
	if (len(items) == 0): # nothing to clean
		return
		
	var top_dish = items.back() as Dish
	var top_idx = len(items)-1
		
	while (top_idx >= 0): # more to clean
		var next_dish = items[top_idx]
		if next_dish.dish_type == top_dish.dish_type:
			next_dish.clean()
			top_idx-=1
		else: # different dish type found, abort cleaning here
			return
			
func remove_clean_top_down():
	if (len(items) == 0): # nothing to remove
		return
	var top_dish = items.back() as Dish
	while ( not top_dish.is_dirty):
		var remove_dish = take_item()
		_animate_remove_item(remove_dish)
		if (len(items) == 0): # no more items left
			return
		top_dish = items.back()
	
