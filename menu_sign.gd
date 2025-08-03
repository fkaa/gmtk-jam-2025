extends Node3D
class_name MenuSign

@onready var start_sign = $start
@onready var help_sign  = $help

func lower_signs():
	var t = get_tree().create_tween()
	t.tween_property(self, "position", Vector3(0, 8.5, 0), 1.5)
	await t.finished
	unfurl_signs()
	
func furl_signs():
	var t = get_tree().create_tween()
	t.tween_property(start_sign, "rotation", Vector3(PI/2, 0, 0), 0.5)
	t.tween_property(help_sign, "rotation", Vector3(PI/2, 0, 0), 0.5)
	await t.finished
	
func raise_signs():
	await furl_signs()
	var t = get_tree().create_tween()
	await t.tween_property(self, "position", Vector3(0, 40, 0), 1)

func unfurl_signs():
	var t = get_tree().create_tween()
	t.tween_property(start_sign, "rotation", Vector3(0, 0, 0), 0.5)
	t.tween_property(help_sign, "rotation", Vector3(0, 0, 0), 0.5)
	await t.finished
