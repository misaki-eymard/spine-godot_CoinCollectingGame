extends Node2D

onready var coin: SpineSprite = $Coin

onready var main = get_tree().get_current_scene().get_node("/root/Main")

onready var bomb_hit_collision = $CoinArea/CollisionShape2D

onready var coin_area = $CoinArea

onready var get_bomb_timer = $GetBombTimer


func _ready():
	coin.get_animation_state().set_animation("caution", false, 0)
	coin.get_animation_state().add_animation("idle", 0, true, 0)


func _on_GetBombTimer_timeout():
	if main.game_over_canvas.visible == true:
		pass
	if main.game_over_canvas.visible == false:
		coin.get_animation_state().set_animation("get", false, 0)
		coin_area.queue_free()
		main.add_coin()


func _on_CoinArea_body_entered(body):
	if body.is_in_group("Player"):
		coin.get_animation_state().set_animation("bomb", false, 0)
		main.bomb_went_off()
		get_bomb_timer.set_paused(true) 
		coin_area.queue_free()


func _on_Coin_animation_completed(spine_sprite, animation_state, track_entry):
	if track_entry.get_animation().get_name() == "caution":
		bomb_hit_collision.set_disabled(false)
	if track_entry.get_animation().get_name() == "get":
		self.queue_free()
	if track_entry.get_animation().get_name() == "bomb":
		self.queue_free()
