extends Area2D

@export_category("Movimiento")
@export var speed: float = 60.0
@export var left_limit: float = 20.0
@export var right_limit: float = 300.0

@export_category("Movimiento vertical")
@export var vertical_amplitude: float = 6.0
@export var vertical_speed: float = 2.0

@export_category("Disparo")
@export var bullet_scene: PackedScene

var direction: float = 1.0
var start_y: float
var time: float = 0.0

@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	start_y = global_position.y
	shoot_timer.start()

func _process(delta: float) -> void:
	time += delta
	# MOVIMIENTO HORIZONTAL
	global_position.x += speed * direction * delta
	# LLEGÓ AL BORDE DERECHO
	if global_position.x >= right_limit:
		global_position.x = right_limit
		direction = -1.0
	# LLEGÓ AL BORDE IZQUIERDO
	elif global_position.x <= left_limit:
		global_position.x = left_limit
		direction = 1.0
	# MOVIMIENTO VERTICAL SUAVE
	global_position.y = (
		start_y
		+ sin(time * vertical_speed) * vertical_amplitude
	)


func _on_shoot_timer_timeout() -> void:
	if bullet_scene == null:
		print("ERROR: no se asignó alien_bullet.tscn")
		return

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.rotation = PI / 2
	
	if bullet.has_method("set_direction"):
		bullet.set_direction(Vector2.DOWN)

	print("NAVE DISPARÓ")
