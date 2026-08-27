extends Area2D

@export_category("Bala")
@export var bullet_speed: float = 300.0
@export var damage: int = 1

var direction := Vector2.RIGHT
var level_speed: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func setup(p_direction: Vector2, p_level_speed: float) -> void:
	direction = p_direction.normalized()
	level_speed = p_level_speed

func setup_level_speed(new_speed: float) -> void:
	level_speed = new_speed

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()

func _process(delta: float) -> void:
	var velocity := direction * bullet_speed

	# El nivel se mueve hacia la derecha.
	# La bala conserva ese movimiento.
	velocity.x += level_speed

	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player_1":
		print("PLAYER 1 RECIBIÓ DAÑO DE UNA BALA")

		var level := get_parent()

		if level.has_method("damage_player"):
			level.damage_player(damage)

		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
