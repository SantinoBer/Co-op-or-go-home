extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music(AudioManager.MENU_MUSIC)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	SceneManager.change_scene("res://scenes/prototype_2/proto_level_1.tscn")

func _on_settings_pressed() -> void:
	$Settings.show()
	$Panel.hide()
	$VBoxContainer.hide()
	$Label.hide()

func _on_settings_back_pressed() -> void:
	$Settings.hide()
	$Panel.show()
	$VBoxContainer.show()
	$Label.show()

func _on_exit_pressed() -> void:
	get_tree().quit()
