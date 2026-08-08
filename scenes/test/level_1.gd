extends Node

const PLAYER_1_START_POS := Vector2i(150, 50) 
const PLAYER_2_START_POS := Vector2i(190, 30) 
const CAM_START_POS := Vector2i(160, 90) 

var speed : float
const START_SPEED : float = 1.0
const MAX_SPEED : int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

func new_game():
	$player_1.position = PLAYER_1_START_POS
	$player_1.velocity = Vector2i(0,0)
	$player_2.position = PLAYER_2_START_POS
	$player_2.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Gd_level_1.position = Vector2i(0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed = START_SPEED
	
	$player_1.position.x += speed
	$player_2.position.x += speed
	$Camera2D.position.x += speed
