extends CharacterBody2D

@export var speed_y: float = 800.0
@export var return_speed: float = 2.0

## Porcentaje (0.0 a 1.0) que la garra tiene que haber recuperado hacia su
## posición original mientras sube, antes de poder volver a bajar con otro click.
@export_range(0.0, 1.0, 0.01) var min_recovery_to_redrop: float = 0.3

@onready var rope: Sprite2D = $"Sprite2D2"
@onready var sfx_player: AudioStreamPlayer = get_node("../AudioStreamPlayer")

enum State {IDLE, DROPPING, RISING}

var state: State = State.IDLE

var original_y: float
var rope_start_y: float
var lowest_y: float
var was_mouse_pressed: bool = false

func _ready() -> void:
	original_y = global_position.y
	lowest_y = original_y
	rope_start_y = rope.global_position.y - rope.texture.get_height()
	# Activamos Region
	rope.region_enabled = true

func _process(delta: float) -> void:
	# Movimiento horizontal (siempre sigue al mouse, sin importar el estado)
	var target_x := get_global_mouse_position().x
	velocity.x = (target_x - global_position.x) * 10.0
	_handle_click()
	_handle_vertical_movement(delta)
	move_and_slide()
	_check_obstacle_collisions()
	update_rope()


func _handle_click() -> void:
	var mouse_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var just_pressed := mouse_pressed and not was_mouse_pressed
	was_mouse_pressed = mouse_pressed

	if not just_pressed:
		return

	var can_drop := (
		state == State.IDLE
		or (state == State.RISING and _recovered_fraction() >= min_recovery_to_redrop)
	)

	if can_drop:
		_start_drop()


func _start_drop() -> void:
	state = State.DROPPING
	lowest_y = global_position.y
	sfx_player.play()


func _handle_vertical_movement(delta: float) -> void:
	match state:
		State.DROPPING:
			# Baja rápido hasta golpear con algo (move_and_slide la frena sola).
			velocity.y = speed_y
			lowest_y = max(lowest_y, global_position.y)

		State.RISING, State.IDLE:
			# Sube lento (o se mantiene arriba) de vuelta a su posición original.
			velocity.y = 0.0
			global_position.y = lerp(
				global_position.y,
				original_y,
				return_speed * delta
			)

			if state == State.RISING and _is_close_to(global_position.y, original_y):
				global_position.y = original_y
				state = State.IDLE


func _recovered_fraction() -> float:
	var total_drop := lowest_y - original_y

	if total_drop <= 0.0:
		return 1.0

	var recovered := lowest_y - global_position.y
	return clamp(recovered / total_drop, 0.0, 1.0)


func _is_close_to(a: float, b: float, tolerance: float = 0.5) -> bool:
	return abs(a - b) < tolerance


func _check_obstacle_collisions() -> void:
	var hit_something := false

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider.is_in_group("obstaculos"):
			collider.queue_free()
			
		hit_something = true
		
	if hit_something and state == State.DROPPING:
		state = State.RISING

func update_rope() -> void:
	# Distancia entre el inicio de la soga y la garra
	var rope_length := global_position.y - rope_start_y
	rope_length = max(0.0, rope_length)
	# Hacer que la textura se repita verticalmente
	rope.region_rect.size.y = rope_length - rope.texture.get_height()
	# La soga queda centrada entre arriba y la garra
	rope.global_position.y = rope_start_y + rope_length / 2
	# La soga sigue horizontalmente a la garra
	rope.global_position.x = global_position.x
