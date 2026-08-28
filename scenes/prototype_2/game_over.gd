extends CanvasLayer

func _ready() -> void:
	AudioManager.play_music(AudioManager.MENU_MUSIC)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_restart_pressed() -> void:
	pass

func _on_settings_pressed() -> void:
	$Settings.show()
	$Panel.hide()

func _on_settings_back_pressed() -> void:
	$Settings.hide()
	$Panel.show()
