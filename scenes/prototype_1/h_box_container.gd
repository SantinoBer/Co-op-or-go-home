extends HBoxContainer

enum modes {EMPTY}

var heart_full = preload("res://assets/test/Assets Godot Runner/fullheart.png")
var heart_empty = preload("res://assets/test/Assets Godot Runner/emptyheart.png")

@export var mode : modes

func update_health(value):
	match mode:
		modes.EMPTY:
			update_empty(value)
			
func update_empty(value):
	for i in get_child_count():
		if value > i:
			get_child(i).texture = heart_full
		else:
			get_child(i).texture = heart_empty
