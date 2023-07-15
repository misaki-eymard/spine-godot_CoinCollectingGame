extends KinematicBody2D

onready var spine_sprite: SpineSprite = $SpineSprite

export var speed : float = 700 # Movement speed

var _velocity := Vector2.ZERO

const UP_DIRECTION := Vector2.UP

var current_player_state : String = "idle"
var current_animation : String


func _physics_process(delta: float) -> void:
	var _horizontal_direction = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)
	_velocity.x = _horizontal_direction * speed
	_velocity = move_and_slide(_velocity, UP_DIRECTION)
	
	flip_skeleton()
	set_player_state()
	set_skeleton_animation()

	
func flip_skeleton() -> void:
	if _velocity.x > 0:
		spine_sprite.get_skeleton().set_scale_x(1)
	elif _velocity.x < -0:
		spine_sprite.get_skeleton().set_scale_x(-1)

func set_player_state() -> void:
	if is_zero_approx(_velocity.x):
		current_player_state = "idle"

	elif not is_zero_approx(_velocity.x):
		current_player_state = "run"

func set_skeleton_animation() -> void:
	current_animation = spine_sprite.get_animation_state().get_current(0).get_animation().get_name()
	if current_player_state == current_animation:
		pass
	elif current_player_state == "run" and current_animation != "run":
		spine_sprite.get_animation_state().set_animation("run", true, 0)
	elif current_player_state == "idle" and current_animation != "idle":
		spine_sprite.get_animation_state().set_animation("idle", true, 0)
		
		
