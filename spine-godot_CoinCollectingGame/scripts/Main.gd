extends Node2D

onready var gameover_canvas: CanvasLayer = $CanvasGameOver

onready var player: Node2D = $Player

onready var player_kinematicBody2D: KinematicBody2D = $Player/PlayerKinematicBody2D

onready var time_label: Label = $CanvasMain/Control/TimeLabel # Label to show remaining game time

onready var coin_label: Label = $CanvasMain/Control/CoinsTotal # Label to show collected coins total

onready var game_timer: Timer = $GameTimer # Remaining game time

onready var coin_spawn_points: Node2D = $Level/CoinPositions

var Coin = preload("res://scenes/Coin.tscn")

var can_generate_coins : bool = true

var coins_total : int = 0 # Total number of coins collected by Player

var player_current_position : Vector2 # This is used to avoid coins being created in positions where it overlaps with Player

var min_distance_from_other_coins : float = 200 # If there are other coins within a distance of this number, no coins are generated there.


func _ready():
	# Get Player's current position. This is used to avoid coins being created in positions where it overlaps with Player
	get_player_current_position()
	
	# Generate the first coin
	spawn_coin()


func _process(delta):
	# Update the display of remaining time
	time_label.text = "Time: " + str(game_timer.time_left).pad_decimals(0)
	
	# Get Player's current position. This is used to avoid coins being created in positions where it overlaps with Player
	get_player_current_position()


# When the remaining game time runs out
func _on_GameTimer_timeout():
	# Stop generating coins
	can_generate_coins = false
	
	# Disable Player's movement
	player.can_move = false
	
	# Show canvas layer for game over
	gameover_canvas.set_visible(true)


func _on_CoinTimer_timeout():
	if can_generate_coins == true:
		spawn_coin()
	elif can_generate_coins == false:
		pass


# Generating a new coin
func spawn_coin():
	# Collect the reference points for the position of coin generation in an array
	var coin_spawn_points_array = coin_spawn_points.get_children()
	
	# Draw only one of a total of 14 coin generation points at randum
	var coin_parent = coin_spawn_points_array[randi() % 14]	
	
	# Check to see if the coin generation point already has coins
	if coin_parent.get_child_count() == 0:	
		# Check to see if Player is near that generation point
		if coin_parent.position.distance_to(player_current_position) < min_distance_from_other_coins:
			# Generating nothing due to Player is too close.
			pass
		elif  coin_parent.position.distance_to(player_current_position) > min_distance_from_other_coins:
			# Generating a new coin
			var coin_instance = Coin.instance()
			coin_parent.add_child(coin_instance)
	elif not coin_parent.get_child_count() == 0:
		pass


func get_player_current_position():
	player_current_position = player.position + player_kinematicBody2D.position


func _on_ResetButton_pressed():
	# Remove all coins that remain in the level
	get_tree().call_group("Coins", "queue_free")
	
	# Reset the number of coins collected to 0
	coins_total = 0
	
	# Reset the player's position
	player_kinematicBody2D.position = Vector2(0,0)
	
	# Enables the generation of new coins
	can_generate_coins = true
	
	# Enables Player's movement
	player.can_move = true
	
	# Hide canvas layer for game over
	gameover_canvas.set_visible(false)
	
	# Start the countdown for the remaining time of the game
	game_timer.start()
