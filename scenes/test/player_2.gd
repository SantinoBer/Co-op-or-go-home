extends CharacterBody2D

@export var p2_bullet: PackedScene 

func _process(delta):
	var target_x = get_global_mouse_position().x
	global_position.x = lerp(global_position.x, target_x, 10.0 * delta)

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		
		shoot()

func shoot() -> void:
	if p2_bullet:
		# Instance the bullet into memory
		var bullet_instance = p2_bullet.instantiate()
		
		# Set the bullet's starting position to the player's current position
		bullet_instance.global_position = global_position
		
		# Add the bullet to the main tree (the level) so it moves independently
		get_tree().current_scene.add_child(bullet_instance)
