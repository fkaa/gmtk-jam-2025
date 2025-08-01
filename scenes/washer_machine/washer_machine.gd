extends PlateOnBelt
class_name WashingMachine
const BASE_WASH_TIME    = 3
const COMBO_TIME_SCALAR = 0.75

var is_cleaning        : bool
var active_combo_count : int
var current_wash_time  : float

var dish_deposit       : PlateOnBelt

@onready var cleaning_timer = $CleaningTimer

func _process(delta_time) -> void:
	# Not cleaning, but items are in the queue
	if (not is_cleaning and items.size() > 0):
		# start cleaning
		is_cleaning = true
		current_wash_time = BASE_WASH_TIME
		cleaning_timer.set_wait_time(current_wash_time)
		cleaning_timer.start()
	elif ( is_cleaning and cleaning_timer.time_left == 0): # Finished cleaning last item
		var last_dish = clean_bottom_dish()
		if (items.size() > 0): # more to clean?
			var next_dish = items[0]
			if (last_dish.dish_type == next_dish.dish_type): # comboing?
				active_combo_count += 1
				current_wash_time *= COMBO_TIME_SCALAR
			# start timer for next dish
			cleaning_timer.set_wait_time(current_wash_time)
			cleaning_timer.start()
		else: # nothing to clean
			is_cleaning = false

func _ready()-> void:
	# it dont work..
	dish_deposit = get_parent().get_child(1)
	pass

func clean_bottom_dish() -> Dish:
	var clean_dish : Dish
	clean_dish = items[0]
	items.remove_at(0)
	clean_dish.clean()	
	dish_deposit.add_item(clean_dish, false, true)
	return clean_dish
