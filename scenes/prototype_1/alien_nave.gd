extends Area2D

@export_category("Movimiento")
@export var movement_speed: float = 380.0
@export var side_margin: float = 12.0

@export_category("Movimiento Vertical")
@export var vertical_amplitude: float = 8.0
@export var vertical_frequency: float = 2.0

@export_category("Entrada")
@export var enter_speed: float = 1000.0

@export_category("Disparo")
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0

var movement_time: float = 0.0
var entering: bool = true
var direction: float = 1.0
var camera: Camera2D

var screen_size := Vector2(320, 180)
var base_y: float = 0.0

@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	shoot_timer.wait_time = shoot_interval
	shoot_timer.one_shot = false

	if not shoot_timer.timeout.is_connected(shoot):
		shoot_timer.timeout.connect(shoot)

	shoot_timer.start()

func _process(delta: float) -> void:
	camera = get_viewport().get_camera_2d()

	if camera == null:
		return

	movement_time += delta

	var local_pos: Vector2 = global_position - camera.global_position

	if entering:
		local_pos = enter_screen(delta, local_pos)
	else:
		local_pos = move_inside_screen(delta, local_pos)

	global_position = camera.global_position + local_pos

func enter_screen(delta: float, local_pos: Vector2) -> Vector2:
	var target := Vector2(
		0.0,
		40.0 - screen_size.y / 2.0
	)

	local_pos = local_pos.move_toward(
		target,
		enter_speed * delta
	)

	if local_pos.distance_to(target) <= 1.0:
		local_pos = target
		entering = false
		base_y = local_pos.y

		print("Nave completamente dentro de la cámara")

	return local_pos

func move_inside_screen(delta: float, local_pos: Vector2) -> Vector2:
	var half_w: float = screen_size.x / 2.0
	var half_h: float = screen_size.y / 2.0

	var min_x: float = -half_w + side_margin
	var max_x: float = half_w - side_margin

	local_pos.x += movement_speed * direction * delta

	if local_pos.x >= max_x:
		local_pos.x = max_x
		direction = 0

	elif local_pos.x <= min_x:
		local_pos.x = min_x
		direction = 1.0

	local_pos.y = base_y + sin(
		movement_time * vertical_frequency
	) * vertical_amplitude

	local_pos.y = clamp(
		local_pos.y,
		-half_h + side_margin,
		half_h - side_margin
	)

	return local_pos

func shoot() -> void:
	if entering:
		return

	if bullet_scene == null:
		print("Nave: bullet_scene no está asignada")
		return

	var bullet = bullet_scene.instantiate()

	get_parent().add_child(bullet)

	bullet.global_position = global_position

	if bullet.has_method("setup"):
		bullet.setup(Vector2.DOWN, 0.0)

	if bullet.has_method("set_direction"):
		bullet.set_direction(Vector2.DOWN)

	print("Nave disparó hacia abajo")
