extends Node

# ============================================================
# PRELOAD OBSTÁCULOS
# ============================================================

var obs_1 = preload("res://scenes/prototype_1/obs_1.tscn")
var obs_2 = preload("res://scenes/prototype_1/obs_2.tscn")
var obs_3 = preload("res://scenes/prototype_1/obs_3.tscn")
var alien_suelo = preload("res://scenes/prototype_1/alien_suelo.tscn")

var ground_obstacles := [obs_1, obs_2, obs_3]
var obstacles: Array = []


# ============================================================
# VARIABLES DEL JUEGO
# ============================================================

const PLAYER_1_START_POS := Vector2i(60, 145)
const PLAYER_2_START_POS := Vector2i(217, 32)
const CAM_START_POS := Vector2i(160, 90)

const START_SPEED: float = 3.0
const MAX_SPEED: int = 10
const SCREEN_SIZE := Vector2i(320, 180)

# Distancia después de la cual puede aparecer el alien
const ALIEN_FIRST_SPAWN_DISTANCE := 1000
const ALIEN_RESPAWN_DISTANCE := 1000

var speed: float
var ground_height: int
var last_obs
var next_spawn_distance: float = 0.0

var alien_instance = null
var next_alien_spawn_distance: float = 0.0

var game_running := true
var max_health: int

func _ready() -> void:
	max_health = $CanvasLayer/HeartBar.get_child_count()

	ground_height = $Gd_level_1.get_node("CollisionShape2D").shape.size.y

	$GameOver.get_node("VBoxContainer/Restart").pressed.connect(new_game)

	new_game()
	
func new_game() -> void:
	# Resetear jugadores
	$player_1.position = PLAYER_1_START_POS
	$player_1.velocity = Vector2i(0, 0)

	$player_2.position = PLAYER_2_START_POS
	$player_2.get_node("CharacterBody2D").velocity = Vector2i(0, 0)

	# Resetear cámara y suelo
	$Camera2D.position = CAM_START_POS
	$Gd_level_1.position = Vector2i(0, 0)

	# Resetear estado
	game_running = true
	get_tree().paused = false

	max_health = 3
	$CanvasLayer/HeartBar.update_health(max_health)

	$GameOver.hide()


	# Eliminar obstáculos anteriores
	for obs in obstacles:
		if is_instance_valid(obs):
			obs.queue_free()

	obstacles.clear()

	# Eliminar alien anterior
	if is_instance_valid(alien_instance):
		alien_instance.queue_free()

	alien_instance = null

	# Primer obstáculo
	next_spawn_distance = $player_1.position.x + randi_range(300, 600)

	# Primer alien
	next_alien_spawn_distance = (
		$player_1.position.x + ALIEN_FIRST_SPAWN_DISTANCE
	)

func generate_obs() -> void:

	var obs_type = ground_obstacles[randi() % ground_obstacles.size()]
	var obs = obs_type.instantiate()

	# Obtener sprite
	var sprite = obs.get_node("Sprite2D")

	var obs_height = sprite.texture.get_height()
	var obs_scale = sprite.scale

	# Posición X
	var obs_x: int = ($Camera2D.position.x + (SCREEN_SIZE.x / 2) + 100)

	# Posición Y
	var obs_y = (
		SCREEN_SIZE.y
		- ground_height
		- (obs_height * obs_scale.y / 2)
		+ 5
	)

	add_obs(obs, obs_x, obs_y)

	# Próximo obstáculo
	next_spawn_distance = (
		obs_x + randi_range(200, 500)
	)

func add_obs(obs, x, y) -> void:
	obs.position = Vector2i(x, y)
	# Pasamos el obstáculo que produjo la colisión
	obs.body_entered.connect(hit_obs.bind(obs))
	
	last_obs = obs
	add_child(obs)
	obstacles.append(obs)

func hit_obs(body, obs) -> void:
	# Player 1
	if body.name == "player_1":
		if max_health > 0:
			max_health -= 1
			$CanvasLayer/HeartBar.update_health(max_health)
		
		if max_health == 0:
			game_over()
	
	# Player 2
	if body.get_parent() != null:
		if body.get_parent().name == "player_2":
			if is_instance_valid(obs):
				obs.queue_free()
			# Lo sacamos de la lista
			obstacles.erase(obs)

func generate_alien() -> void:
	# Si ya existe un alien, no generar otro
	if is_instance_valid(alien_instance):
		return
	alien_instance = alien_suelo.instantiate()
	add_child(alien_instance)
	
	# Conectar colisión
	alien_instance.body_entered.connect(hit_alien.bind(alien_instance))
	update_alien_position()

func update_alien_position() -> void:
	if not is_instance_valid(alien_instance):
		return
	# Borde izquierdo de la cámara
	var camera_left = ($Camera2D.position.x - (SCREEN_SIZE.x / 2))

	# Mantenerlo a la izquierda
	alien_instance.position.x = camera_left + 20

	# Sobre el suelo
	alien_instance.position.y = (
		SCREEN_SIZE.y
		- ground_height
		- 10
	)

func hit_alien(body, alien) -> void:

	# El body es el CharacterBody2D de player_2
	if body.get_parent() != null:
		if body.get_parent().name == "player_2":
			print("PLAYER 2 TOCÓ AL ALIEN")
			if is_instance_valid(alien):
				alien.queue_free()

			# IMPORTANTE:
			# Ya no existe ningún alien
			alien_instance = null

			# No lo generamos inmediatamente.
			# Esperará cierta distancia.
			next_alien_spawn_distance = (
				$player_1.position.x
				+ ALIEN_RESPAWN_DISTANCE
			)

func game_over() -> void:
	game_running = false
	get_tree().paused = true
	$GameOver.show()

func clean_old_obstacles() -> void:
	for obs in obstacles.duplicate():
		if not is_instance_valid(obs):
			obstacles.erase(obs)
			continue

		if obs.position.x < (
			$Camera2D.position.x
			- (SCREEN_SIZE.x / 2)
			- 100
		):

			obstacles.erase(obs)
			obs.queue_free()

func _process(delta: float) -> void:
	if not game_running:
		return
		
	speed = START_SPEED

	# Generar obstáculos
	if (
		$player_1.position.x >= next_spawn_distance
		or obstacles.is_empty()
	):
		
		generate_obs()

	# Mover jugadores
	$player_1.position.x += speed
	$player_2.position.x += speed

	# Mover cámara
	$Camera2D.position.x += speed

	# Alien
	if is_instance_valid(alien_instance):
		# El alien ya existe:
		# mantenerlo a la izquierda
		update_alien_position()
	else:
		# No existe.
		# Comprobar si ya llegó el momento de generarlo.
		if $player_1.position.x >= next_alien_spawn_distance:
			generate_alien()

	# Mover suelo
	var ground_is_out_of_camera: bool = (
		$Camera2D.position.x
		- $Gd_level_1.position.x
		> SCREEN_SIZE.x * 1.5
	)
	if ground_is_out_of_camera:
		$Gd_level_1.position.x += SCREEN_SIZE.x

	# Eliminar obstáculos viejos
	clean_old_obstacles()
