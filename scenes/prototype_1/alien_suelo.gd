extends Area2D


# ============================================================
# CONFIGURACIÓN
# ============================================================

@export_category("Disparo")

@export var bullet_scene: PackedScene

@export var shoot_interval: float = 1.5

@export var bullet_speed: float = 300.0


# ============================================================
# VARIABLES
# ============================================================

var level_speed: float = 0.0


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.one_shot = false

	$ShootTimer.timeout.connect(shoot)

	$ShootTimer.start()


# ============================================================
# RECIBIR VELOCIDAD DEL NIVEL
# ============================================================

func setup_level_speed(p_level_speed: float) -> void:

	level_speed = p_level_speed


# ============================================================
# DISPARAR
# ============================================================

func shoot() -> void:

	if bullet_scene == null:
		return


	# Crear bala
	var bullet = bullet_scene.instantiate()

	get_parent().add_child(bullet)


	# Aparece en la posición del alien
	bullet.global_position = global_position


	# La bala ya apunta hacia la derecha,
	# por lo que no necesitamos rotarla.
	bullet.rotation = 0.0


	# Dirección hacia la derecha
	bullet.setup(
		Vector2.RIGHT,
		level_speed
	)


	# Velocidad propia de la bala
	bullet.bullet_speed = bullet_speed
