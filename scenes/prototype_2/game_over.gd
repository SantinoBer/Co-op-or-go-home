extends CanvasLayer

func _ready() -> void:
	AudioManager.play_music(AudioManager.MENU_MUSIC)

func _on_exit_pressed() -> void:
	get_tree().paused = false
	SceneManager.change_scene("res://scenes/main_menu.tscn")

func _on_restart_pressed() -> void:
	pass

func _on_settings_pressed() -> void:
	$Settings.show()
	$Panel.hide()

func _on_settings_back_pressed() -> void:
	$Settings.hide()
	$Panel.show()
