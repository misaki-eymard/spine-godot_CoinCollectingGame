extends Area2D

onready var main = get_tree().get_current_scene().get_node("/root/Main")

onready var bomb = get_parent()


func _on_AreaToHitBomb_body_entered(body):
	# If Player entered the coin's Area2D
	if body.is_in_group("Player"):
		main.bomb_went_off()
		bomb.bomb_went_off()
		queue_free() # Eliminate collision so that this coin is not acquired twice.


func _on_GetBombTimer_timeout():
	#main.bomb_timer_timeout()
	bomb.bomb_timer_timeout()
	queue_free() # Eliminate collision so that this bomb coin no longer go off.
