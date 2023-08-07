extends CharacterBody2D

@onready var spine_sprite: SpineSprite = $SpineSprite

@onready var spine_sprite_anim_state = spine_sprite.get_animation_state()

# These are used to limit the Skeleton's range of movement
@onready var screen_width = get_viewport_rect().size.x
@onready var right_limit = screen_width
@onready var left_limit = 0

@export var speed : float = 700 # Movement speed
@export var jump_strength : float = 1700 # Strength to rise above when jumping
@export var gravity : float = 5100 # Gravity from jump to landing on the floor

@export var jump_down_threshold : float = 0 # Threshold for velocity to play the "jump_down" animation

const UP_DIRECTION := Vector2.UP

var _velocity := Vector2.ZERO

var can_move : bool = true # Whether Player can move or not

var current_player_state : String = "idle" # Current status of Player
var current_animation : String # Player's current animation

func _ready():
	spine_sprite_anim_state.set_animation("idle", true, 0)


func _physics_process(delta: float) -> void:
	# While the time is left and Player can move
	if can_move:
		# Check the input for horizontal direction
		var _horizontal_direction = (
			Input.get_action_strength("move_right")
			- Input.get_action_strength("move_left")
		)
		# Multiply horizontal direction and speed to determine _velocity.x
		_velocity.x = _horizontal_direction * speed
		
		# Set the current state of Player
		set_player_state()
	
	# When the game is over and Player cannot be moved
	elif not can_move:
		# Set _velocity.x to 0 immediately
		_velocity.x = 0
		
		if current_player_state == "death":
			pass
		elif not current_player_state == "death":
			if is_on_floor():
				current_player_state = "idle"
			elif not is_on_floor():
				current_player_state = "jump_down"
		
	# Gravity is always added to _velocity.y every delta time
	_velocity.y += gravity * delta
	
	set_velocity(_velocity)
	set_up_direction(UP_DIRECTION)
	move_and_slide()
	_velocity = velocity
	
	# Limit the x-axis position so that Player does not move off the screen
	limit_player_position()
	
	# Flip skeleton based on _velocity.x
	flip_skeleton()
	
	# Set an animation that match the current state of Player
	set_skeleton_animation()


# Limit the x-axis position so that Player does not move off the screen
func limit_player_position():
	if position.x > right_limit:
		position.x = right_limit
	elif position.x < left_limit:
		position.x = left_limit


func reset_player():
	position.x = screen_width/2
	position.y = 550
	can_move = true
	current_player_state = "idle"


# Set the current state of Player
func set_player_state() -> void:
	# If Player is on floor the floor and velocity is zero, set "current_player_state" to "idle"
	if is_on_floor() and is_zero_approx(_velocity.x):
		current_player_state = "idle"

	# If Player is on floor the floor but velocity is not zero, set "current_player_state" to "running"
	elif is_on_floor() and not is_zero_approx(_velocity.x):
		current_player_state = "run"
	
	# If Player is on floor the floor and the "jump" button is pressed, set "current_player_state" to "jump_up"
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		current_player_state = "jump_up"
		_velocity.y = -jump_strength
	
	# If Player is not on floor but velocity.y is higher than "jump_down_threshold", set "current_player_state" to "jump_down"
	if not is_on_floor() and _velocity.y > jump_down_threshold:
		current_player_state = "jump_down"	


# Flip the skeleton according to whether the direction of velocity is positive or negative
func flip_skeleton() -> void:
	if _velocity.x > 0:
		spine_sprite.get_skeleton().set_scale_x(1)
	elif _velocity.x < -0:
		spine_sprite.get_skeleton().set_scale_x(-1)


# Set an animation that match the current state of Player
func set_skeleton_animation() -> void:
	# Get the current animation playing on track 0
	current_animation = spine_sprite_anim_state.get_current(0).get_animation().get_name()
	
	if current_player_state == current_animation:
		pass
	elif current_player_state == "run" and current_animation != "run":
			spine_sprite_anim_state.set_animation("run", true, 0)
	elif current_player_state == "idle" and current_animation != "idle":
			spine_sprite_anim_state.set_animation("idle", true, 0)
	elif current_player_state == "jump_up" and current_animation != "jump_up":
			spine_sprite_anim_state.set_animation("jump_up", false, 0)
	elif current_player_state == "jump_down" and current_animation != "jump_down":
			spine_sprite_anim_state.set_animation("jump_down", false, 0)		
	elif current_player_state == "death" and current_animation != "death":
			spine_sprite_anim_state.set_animation("death", false, 0)

