extends Node2D

onready var particle = $CPUParticles2D

onready var coin_get_collision = $AreaToGetCoin

onready var main = get_tree().get_current_scene().get_node("/root/Main")

var coin_get : bool = false


func _process(delta):
	# If the coin has already been acquired and 
	# particle emission has been completed, eliminate this coin instance.
	# You cannot check this only by the emitting state, 
	# since particle emission has not started at first.
	if coin_get:
		if particle.emitting:
			pass
		elif not particle.emitting:
			self.queue_free()
	elif not coin_get:
		pass


func _on_Area2D_body_entered(body):
	# If Player entered the coin's Area2D
	if body.is_in_group("Player"):
		# This coin has been acquired so the coin_get is set to true
		coin_get = true
		
		# Start emitting particles
		particle.set_emitting(true)
		
		# Add one to the number of coins collected by Player
		main.coins_total += 1
		
		# Update the display of collected coins total
		main.coin_label.text = "Coins: " + str(main.coins_total)
		
		# Eliminate collision so that this coin is not acquired twice.
		# Don't eliminate the coin instance itself at this time because the particle has not finished emitting.
		coin_get_collision.queue_free()
