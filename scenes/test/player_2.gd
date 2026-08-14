extends CharacterBody2D

@export var speed_y: float = 400.0       # Velocidad de caída al hacer clic
@export var return_speed: float = 8.0    # Suavidad del regreso (más alto = más rápido)

# Variable para recordar la altura inicial del personaje
var original_y: float

func _ready():
	# Guardamos la posición Y con la que arranca el personaje en la escena
	original_y = global_position.y

func _process(delta):
	# 1. Movimiento horizontal con el mouse
	var target_x = get_global_mouse_position().x
	velocity.x = (target_x - global_position.x) * 10.0 

	# 2. Control del movimiento vertical (Eje Y)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Si clickeas, cae hacia abajo con velocidad constante
		velocity.y = speed_y
	else:
		# Si NO clickeas, calculamos el regreso suave a la posición original
		velocity.y = 0.0 # Apagamos la velocidad física para que no interfiera el slide
		global_position.y = lerp(global_position.y, original_y, return_speed * delta)

	# 3. Aplicar movimiento y físicas
	move_and_slide()

	# 4. Detección y eliminación de obstáculos al chocar
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Elimina el objeto si pertenece al grupo "obstaculos"
		if collider.is_in_group("obstaculos"):
			collider.queue_free()
