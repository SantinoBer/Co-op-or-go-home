extends Node

# PRELOAD
var obs_1 = preload("res://scenes/prototype_2/obs_1.tscn")
var obs_2 = preload("res://scenes/prototype_2/obs_2.tscn")
var obs_3 = preload("res://scenes/prototype_2/obs_3.tscn")
var alien_suelo = preload("res://scenes/prototype_2/alien_suelo.tscn")
var nave_scene = preload("res://scenes/prototype_2/alien_nave.tscn")

var ground_obstacles := [obs_1, obs_2, obs_3]
var obstacles: Array = []

# CONFIGURACIÓN
@export_category("Velocidad")
@export var min_speed: float = 180.0
@export var max_speed: float = 360.0
@export var acceleration_duration: float = 30.0

@export_category("Victoria")
@export var max_speed_duration: float = 10.0


@export_category("Obstáculos")
@export var obstacle_min_spawn_distance: int = 300
@export var obstacle_max_spawn_distance: int = 500

@export_category("Alien")
@export var alien_min_spawn_distance: int = 800
@export var alien_max_spawn_distance: int = 1500

@export_category("Nave")
@export var ship_min_spawn_distance: int = 1200
@export var ship_max_spawn_distance: int = 2000

@export_category("Otros")
@export var screen_size := Vector2i(320, 180)

# POSICIONES
const PLAYER_1_START_POS := Vector2i(60, 145)
const PLAYER_2_START_POS := Vector2i(217, 32)
const CAM_START_POS := Vector2i(160, 90)

# VARIABLES
var speed: float = 0.0
var distance_travelled: float = 0.0

var ground_height: int
var last_obs = null
var next_spawn_distance: float = 0.0

var alien_instance = null
var next_alien_spawn_distance: float = 0.0

var nave_instance = null
var next_ship_spawn_distance: float = 0.0

var game_running := true
var max_health: int
var win_timer: float = 0.0
var acceleration_timer: float = 0.0
var max_speed_reached := false

func _ready() -> void:
	max_health = $CanvasLayer/HeartBar.get_child_count()
	ground_height = $Ground/StaticBody2D/CollisionShape2D.shape.size.y
	AudioManager.play_music(AudioManager.LEVEL_1_MUSIC)
	$GameOver.get_node("Panel/VBoxContainer/Restart").pressed.connect(new_game)

	new_game()

func new_game() -> void:
	acceleration_timer = 0.0
	win_timer = 0.0
	max_speed_reached = false
	speed = min_speed
	distance_travelled = 0.0

	
	AudioManager.play_music(AudioManager.LEVEL_1_MUSIC)

	$WinPanel.hide()
	
	$player_1.position = PLAYER_1_START_POS
	$player_1.velocity = Vector2.ZERO

	$player_2.position = PLAYER_2_START_POS
	$player_2.get_node("CharacterBody2D").velocity = Vector2.ZERO

	$Camera2D.position = CAM_START_POS

	game_running = true
	get_tree().paused = false

	max_health = $CanvasLayer/HeartBar.get_child_count()
	$CanvasLayer/HeartBar.update_health(max_health)

	$GameOver.hide()

	for obs in obstacles:
		if is_instance_valid(obs):
			obs.queue_free()

	obstacles.clear()

	if is_instance_valid(alien_instance):
		alien_instance.queue_free()
	alien_instance = null

	if is_instance_valid(nave_instance):
		nave_instance.queue_free()
	nave_instance = null

	next_spawn_distance = randi_range(
		obstacle_min_spawn_distance,
		obstacle_max_spawn_distance
	)

	next_alien_spawn_distance = randi_range(
		alien_min_spawn_distance,
		alien_max_spawn_distance
	)

	next_ship_spawn_distance = randi_range(
		ship_min_spawn_distance,
		ship_max_spawn_distance
	)

func generate_obs() -> void:
	var obs_type = ground_obstacles[
		randi() % ground_obstacles.size()
	]

	var obs = obs_type.instantiate()

	var sprite = obs.get_node("Sprite2D")
	var obs_height = sprite.texture.get_height()
	var obs_scale = sprite.scale

	var obs_x: int = screen_size.x + 100

	var obs_y = (
		screen_size.y
		- ground_height
		- (obs_height * obs_scale.y / 2.0)
		+ 5
	)

	add_obs(obs, obs_x, obs_y)

	next_spawn_distance = distance_travelled + randi_range(
		obstacle_min_spawn_distance,
		obstacle_max_spawn_distance
	)

func add_obs(obs, x, y) -> void:
	obs.position = Vector2i(x, y)

	obs.body_entered.connect(
		hit_obs.bind(obs)
	)

	last_obs = obs

	add_child(obs)
	obstacles.append(obs)

func hit_obs(body, obs) -> void:
	if body.name == "player_1":
		damage_player(1)

	if body.get_parent() != null:
		if body.get_parent().name == "player_2":
			if is_instance_valid(obs):
				var die_sfx = obs.get_node("AudioStreamPlayer")
				play_die_sfx(die_sfx)
				
				obs.queue_free()

			obstacles.erase(obs)

func play_die_sfx(die_sfx) -> void:
	die_sfx.reparent(get_parent())
	die_sfx.play()
	die_sfx.finished.connect(die_sfx.queue_free)

func damage_player(damage: int) -> void:
	if not game_running:
		return

	if max_health <= 0:
		return

	max_health -= damage
	max_health = max(max_health, 0)

	$CanvasLayer/HeartBar.update_health(max_health)

	if max_health <= 0:
		game_over()

func generate_alien() -> void:
	if is_instance_valid(alien_instance):
		return

	alien_instance = alien_suelo.instantiate()
	add_child(alien_instance)

	alien_instance.body_entered.connect(
		hit_alien.bind(alien_instance)
	)

	var alien_y = (
		screen_size.y
		- ground_height
		- 10
	)

	# Empieza fuera de pantalla a la izquierda
	alien_instance.position = Vector2(
		-40,
		alien_y
	)

func hit_alien(body, alien) -> void:
	if body.get_parent() != null:
		if body.get_parent().name == "player_2":
			if is_instance_valid(alien):
				alien.queue_free()

			alien_instance = null

			next_alien_spawn_distance = (
				distance_travelled
				+ randi_range(
					alien_min_spawn_distance,
					alien_max_spawn_distance
				)
			)

func generate_nave() -> void:
	if is_instance_valid(nave_instance):
		return

	nave_instance = nave_scene.instantiate()
	nave_instance.position = Vector2(
		-280,
		randi_range(30,70)
	)
	add_child(nave_instance)
	nave_instance.body_entered.connect(
		hit_nave.bind(nave_instance)
	)

func hit_nave(body, nave) -> void:
	if body.get_parent() == $player_2:
		if is_instance_valid(nave):
			nave.queue_free()

		nave_instance = null

		next_ship_spawn_distance = (
			distance_travelled
			+ randi_range(
				ship_min_spawn_distance,
				ship_max_spawn_distance
			)
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

		if obs.position.x < -100:
			obstacles.erase(obs)
			obs.queue_free()

func win_game() -> void:
	game_running = false
	get_tree().paused = true
	$WinPanel.show()

func _process(delta: float) -> void:
	if not game_running:
		return
	# ACELERACIÓN
	if not max_speed_reached:
		acceleration_timer += delta
		var progress: float = (
			acceleration_timer
			/ acceleration_duration
		)
		
		progress = clamp(progress, 0.0, 1.0)
		speed = lerp(
			min_speed,
			max_speed,
			progress
		)
		
		if progress >= 1.0:
			speed = max_speed
			max_speed_reached = true
			
	if max_speed_reached:
		win_timer += delta
		if win_timer >= max_speed_duration:
			win_game()
			return

	# DISTANCIA VIRTUAL
	distance_travelled += speed * delta

	# SPAWN OBSTÁCULOS
	if distance_travelled >= next_spawn_distance:
		generate_obs()

	# MOVER OBSTÁCULOS
	for obs in obstacles:
		if is_instance_valid(obs):
			obs.position.x -= speed * delta

	# ALIEN
	if not is_instance_valid(alien_instance):
		if distance_travelled >= next_alien_spawn_distance:
			generate_alien()

	# NAVE
	if not is_instance_valid(nave_instance):
		if distance_travelled >= next_ship_spawn_distance:
			generate_nave()
	# SUELO
	$Ground/Parallax2D.scroll_offset.x -= speed * delta
	# FONDO LEJANO
	$Bg_level_1/ParallaxLayer.motion_offset.x -= speed * 0.1 * delta
	# FONDO MEDIO
	$Bg_level_1/ParallaxLayer2.motion_offset.x -= speed * 0.3 * delta
	# FONDO CERCANO
	$Bg_level_1/ParallaxLayer3.motion_offset.x -= speed * 0.6 * delta
	# LIMPIEZA
	clean_old_obstacles()
