extends Node2D

onready var game_over_canvas: CanvasLayer = $GameOverCanvas

onready var player: KinematicBody2D = $Player

onready var coins_total_label: Label = $MainCanvas/CoinsTotal # Label to show collected coins total

onready var game_timer: Timer = $GameTimer # Remaining game time

onready var coin_spawn_points: Node2D = $Level/CoinSpawnPoints

onready var coin_spawn_points_array = coin_spawn_points.get_children()

onready var coin_spawn_points_count = coin_spawn_points_array.size()

const NormalCoin = preload("res://scenes/NormalCoin.tscn")

const BombCoin = preload("res://scenes/BombCoin.tscn")

var generation_probability_of_bomb : int = 10

var coins_total : int = 0 # Total number of coins collected by Player

var min_distance_from_player : float = 200 # If there are other coins within a distance of this number, no coins are generated there.


func _ready():
	randomize()
	

func add_coin() -> void:
	# Add one to the number of coins collected by Player
	coins_total += 1
		
	# Update the display of collected coins total
	coins_total_label.text = "Coins: " + str(coins_total)


# When the remaining game time runs out
func _on_GameTimer_timeout():
	game_over()


func bomb_went_off() -> void:
	player.current_player_state = "death"
	game_timer.paused = true
	game_over()


func game_over() -> void:
	player.can_move = false # Disable Player's movement
	game_over_canvas.set_visible(true) # Show canvas layer for game over


func bomb_timer_timeout():
	coins_total += 1  # Add one to the coins total as a bonus
	coins_total_label.text = "Coins: " + str(coins_total) # Update the display of collected coins total


func _on_ResetButton_pressed():
	get_tree().reload_current_scene()


func _on_SpawnCoinTimer_timeout():
	if game_over_canvas.visible == false:
		spawn_coin()
	elif game_over_canvas.visible == true:
		pass

# Generating a new coin
func spawn_coin():
	# Draw one of coin generation points at random
	var coin_parent = coin_spawn_points_array[randi() % coin_spawn_points_count]	
	
	if coin_parent.get_child_count() > 0:	
		pass
	# Check to see if the coin generation point already has coins
	elif coin_parent.get_child_count() == 0:	
		# Check to see if Player is near that generation point
		if coin_parent.position.distance_to(player.position) < min_distance_from_player:
			# Generating nothing due to Player is too close.
			pass
		elif  coin_parent.position.distance_to(player.position) > min_distance_from_player:
			var coin_instance
			var coin_types = randi() % 100
			
			if coin_types >= generation_probability_of_bomb:
				# Generate a new  normal coin
				coin_instance = NormalCoin.instance()
			elif coin_types < generation_probability_of_bomb:
				# Generate a new bomb coin
				coin_instance = BombCoin.instance()
			coin_parent.add_child(coin_instance)
