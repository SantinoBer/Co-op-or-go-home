extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

const MENU_MUSIC = preload("res://audio/music/Go_Home_(Demo_1).wav")
const LEVEL_1_MUSIC = preload("res://audio/music/Go_Home_(Final_Demo).wav")

@export var menu_loop_delay: float = 2.0

var current_music: AudioStream = null
var looping := false


func _ready() -> void:
	music_player.finished.connect(_on_music_finished)


func play_music(music: AudioStream) -> void:
	current_music = music

	if music == MENU_MUSIC:
		music_player.volume_db = -20.0
		looping = true

	elif music == LEVEL_1_MUSIC:
		music_player.volume_db = -5.0
		looping = true

	music_player.stream = music
	music_player.play()


func stop_music() -> void:
	looping = false
	music_player.stop()


func restart_music() -> void:
	music_player.stop()
	music_player.play(0.0)


func _on_music_finished() -> void:
	if not looping:
		return

	if current_music == MENU_MUSIC:
		await get_tree().create_timer(menu_loop_delay).timeout

		if current_music == MENU_MUSIC and looping:
			music_player.play(0.0)

	elif current_music == LEVEL_1_MUSIC:
		music_player.play(17.0)
