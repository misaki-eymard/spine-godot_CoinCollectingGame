extends Node2D

onready var coin = $Coin

onready var coin_get_collision = $CoinArea/CollisionShape2D

onready var main = get_tree().get_current_scene().get_node("/root/Main")


func _on_Coin_animation_completed(_spine_sprite, _animation_state, track_entry):
	if track_entry.get_animation().get_name() == "get":
		self.queue_free()


func _on_CoinArea_body_entered(body):
	if body.is_in_group("Player"):
		coin.get_animation_state().set_animation("get", false, 0)
		main.add_coin()
		coin_get_collision.queue_free()
