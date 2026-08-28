extends CharacterBody2D


const SPEED = 150.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Start running
	$RunCol.disabled = false
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var duck := Input.is_action_pressed("move_down")
	if duck:
		$AnimatedSprite2D.play("ducking")
		$RunCol.disabled = true
	# If its not doing anything else
	$AnimatedSprite2D.play("running")

	move_and_slide()
