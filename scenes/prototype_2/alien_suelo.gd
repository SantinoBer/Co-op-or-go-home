extends Area2D

@export_category("Entrada")
@export var enter_speed: float = 150.0
@export var enter_x: float = 30.0

@export_category("Disparo")
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0

var entering: bool = true

@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	shoot_timer.wait_time = shoot_interval
	shoot_timer.one_shot = false

	if not shoot_timer.timeout.is_connected(shoot):
		shoot_timer.timeout.connect(shoot)

func _process(delta: float) -> void:
	if entering:
		position.x += enter_speed * delta
		if position.x >= enter_x:
			position.x = enter_x
			entering = false
			shoot_timer.start()

func shoot() -> void:
	if entering:
		return
	if bullet_scene == null:
		print("Alien: bullet_scene no está asignada")
		return
		
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	
	if bullet.has_method("set_direction"):
		bullet.set_direction(Vector2.RIGHT)
