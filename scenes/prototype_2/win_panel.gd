extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_exit_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_scene("res://scenes/main_menu.tscn")


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
