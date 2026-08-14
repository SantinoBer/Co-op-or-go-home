extends Node

# Preload obstacles
var obs_1 = preload("res://scenes/prototype_1/obs_1.tscn")
var obs_2 = preload("res://scenes/prototype_1/obs_2.tscn")
var obs_3 = preload("res://scenes/prototype_1/obs_3.tscn")
var alien_suelo = preload("res://scenes/prototype_1/alien_suelo.tscn")

var ground_obstacles := [obs_1,obs_2,obs_3,alien_suelo]
var obstacles : Array

# Game variagles
const PLAYER_1_START_POS := Vector2i(40,145)
const PLAYER_2_START_POS := Vector2i(217,32)
const CAM_START_POS := Vector2i(160,90)

var speed : float
const START_SPEED : float = 3.0
const MAX_SPEED : int = 10
const SCREEN_SIZE := Vector2i(320,180)
var ground_height : int
var last_obs
var next_spawn_distance : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ground_height = $Gd_level_1.get_node("CollisionShape2D").shape.size.y
	new_game()
	

func new_game():
	$player_1.position = PLAYER_1_START_POS
	$player_1.velocity = Vector2i(0,0)
	$player_2.position = PLAYER_2_START_POS
	$player_2.get_node("CharacterBody2D").velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Gd_level_1.position = Vector2i(0,0)
	
	# Limpiar obstáculos si reinicias la partida
	for obs in obstacles:
		if is_instance_valid(obs):
			obs.queue_free()
	obstacles.clear()
	# Definir cuándo aparecerá el primer obstáculo de la partida
	next_spawn_distance = $player_1.position.x + randi_range(300, 600)

func generate_obs():
	var obs_type = ground_obstacles[randi() % ground_obstacles.size()]
	var obs = obs_type.instantiate()
	
	# Calcular la altura del sprite de forma segura
	var sprite = obs.get_node("Sprite2D")
	var obs_height = sprite.texture.get_height()
	var obs_scale = sprite.scale
	
	# Spawnearlo un poco por delante de la cámara actual del jugador
	var obs_x : int = $Camera2D.position.x + (SCREEN_SIZE.x / 2) + 100
	var obs_y = SCREEN_SIZE.y - ground_height - (obs_height * obs_scale.y / 2) + 5
	
	add_obs(obs, obs_x, obs_y)
	
	# Calcular la posición X exacta donde deberá spawnear el SIGUIENTE obstáculo
	next_spawn_distance = obs_x + randi_range(200, 500)

func add_obs(obs,x,y):
	obs.position = Vector2i(x, y)
	last_obs = obs
	add_child(obs)
	obstacles.append(obs)
	
func clean_old_obstacles():
	for obs in obstacles:
		if is_instance_valid(obs) and obs.position.x < $Camera2D.position.x - (SCREEN_SIZE.x / 2) - 100:
			obstacles.erase(obs)
			obs.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed = START_SPEED
	if $player_1.position.x >= next_spawn_distance or obstacles.is_empty():
		generate_obs()
	$player_1.position.x += speed
	$player_2.position.x += speed 
	$Camera2D.position.x += speed
	
	var ground_is_out_of_camera : bool = $Camera2D.position.x - $Gd_level_1.position.x > SCREEN_SIZE.x * 1.5
	if ground_is_out_of_camera:
		$Gd_level_1.position.x += SCREEN_SIZE.x
		
	clean_old_obstacles()
