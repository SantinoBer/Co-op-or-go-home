extends Control

@onready var master_slider: HSlider = $Panel/HBoxContainer/VBoxContainer2/Master
@onready var music_slider: HSlider = $Panel/HBoxContainer/VBoxContainer2/Music
@onready var sfx_slider: HSlider = $Panel/HBoxContainer/VBoxContainer2/Sfx

signal back_pressed

func _ready() -> void:
	master_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(
			AudioServer.get_bus_index("Master")
		)
	)

	music_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(
			AudioServer.get_bus_index("Music")
		)
	)

	sfx_slider.value = db_to_linear(
		AudioServer.get_bus_volume_db(
			AudioServer.get_bus_index("SFX")
		)
	)

func _on_master_value_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))

func _on_music_value_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))

func _on_sfx_value_changed(value: float) -> void:
	var bus := AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))

func _on_back_pressed() -> void:
	back_pressed.emit()
