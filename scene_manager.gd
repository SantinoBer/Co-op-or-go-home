extends Node

var scene_history: Array[String] = []


func change_scene(path: String) -> void:
	var current: String = get_tree().current_scene.scene_file_path
	
	if current != "":
		scene_history.append(current)
	
	get_tree().change_scene_to_file(path)

func go_back() -> void:
	if scene_history.is_empty():
		return
	print(scene_history)
	
	var previous_scene: String = str(scene_history.pop_back())
	get_tree().change_scene_to_file(previous_scene)
