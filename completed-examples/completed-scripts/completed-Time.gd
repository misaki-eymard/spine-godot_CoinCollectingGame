extends Label

@onready var game_timer = $"../../GameTimer"

func _process(_delta):
	text = "Time: " + str(game_timer.time_left).pad_decimals(0)
