extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

const MENU_MUSIC = preload("res://audio/music/Go Home (Demo 1).wav")
const LEVEL_1_MUSIC = preload("res://audio/music/Go Home (Segunda Versión).wav")

func play_music(music: AudioStream) -> void:
	music_player.stream = music
	
	if music == MENU_MUSIC:
		music_player.volume_db = -20.0
	elif music == LEVEL_1_MUSIC:
		music_player.volume_db = -5.0

	music_player.stream = music
	music_player.play()


func stop_music() -> void:
	music_player.stop()

func restart_music() -> void:
	music_player.stop()
	music_player.play()
