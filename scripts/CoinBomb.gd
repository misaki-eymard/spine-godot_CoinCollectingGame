extends Node2D

onready var coin: SpineSprite = $Coin

onready var main = get_tree().get_current_scene().get_node("/root/Main")

onready var bomb_hit_collision = $AreaToHitBomb/CollisionForPlayer

onready var area_to_hit_bomb = $AreaToHitBomb

onready var get_bomb_timer = $GetBombTimer


func _ready():
	coin.get_animation_state().set_animation("caution", false, 0)
	coin.get_animation_state().add_animation("idle_bomb", 0, true, 0)


func _on_BombCoin_animation_completed(spine_sprite, animation_state, track_entry):
	if track_entry.get_animation().get_name() == "caution":
		bomb_hit_collision.set_disabled(false)
	if track_entry.get_animation().get_name() == "get_bomb":
		self.queue_free()
	if track_entry.get_animation().get_name() == "bomb":
		self.queue_free()


func _on_AreaToHitBomb_body_entered(body):
	if body.is_in_group("Player"):
		coin.get_animation_state().set_animation("bomb", false, 0)
		main.bomb_went_off()
		get_bomb_timer.set_paused(true) 
		area_to_hit_bomb.queue_free()


func _on_GetBombTimer_timeout():
	if main.game_over_canvas.visible == true:
		pass
	if main.game_over_canvas.visible == false:
		coin.get_animation_state().set_animation("get_bomb", false, 0)
		area_to_hit_bomb.queue_free()
		main.add_coin()
