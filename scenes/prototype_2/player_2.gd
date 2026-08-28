extends CharacterBody2D

@export var speed_y: float = 800.0
@export var return_speed: float = 2.0

@onready var rope: Sprite2D = $"Sprite2D2"

var original_y: float
var rope_start_y: float


func _ready():
	original_y = global_position.y
	rope_start_y = rope.global_position.y - rope.texture.get_height()

	# Activamos Region
	rope.region_enabled = true


func _process(delta):
	# Movimiento horizontal
	var target_x = get_global_mouse_position().x
	velocity.x = (target_x - global_position.x) * 10.0

	# Movimiento vertical
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		velocity.y = speed_y
	else:
		velocity.y = 0.0
		global_position.y = lerp(
			global_position.y,
			original_y,
			return_speed * delta
		)

	move_and_slide()

	update_rope()

	# Colisiones
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.is_in_group("obstaculos"):
			collider.queue_free()


func update_rope():
	# Distancia entre el inicio de la soga y la garra
	var rope_length = global_position.y - rope_start_y

	rope_length = max(0.0, rope_length)

	# Hacer que la textura se repita verticalmente
	rope.region_rect.size.y = rope_length - rope.texture.get_height()

	# La soga queda centrada entre arriba y la garra
	rope.global_position.y = rope_start_y + rope_length / 2

	# La soga sigue horizontalmente a la garra
	rope.global_position.x = global_position.x
