extends Node2D

onready var player_kinematicBody2D: KinematicBody2D = $PlayerKinematicBody2D

onready var spineboy: SpineSprite = $PlayerKinematicBody2D/Spineboy

const UP_DIRECTION := Vector2.UP

export var speed : float = 700 # Movement speed
export var jump_strength : float = 1500 # Strength to rise above when jumping
export var gravity : float = 5000 # Gravity from jump to landing on the floor

var _velocity := Vector2.ZERO

export var velocity_threshold_min : float = 0 # Threshold for velocity to play the "jump_down" animation

var can_move : bool = true # Whether Player can move or not

# These are used to limit the Spineboy's range of movement
onready var screen_width = get_viewport_rect().size.x
# Player is standing in the center of the screen, so half the screen position is the limit.
onready var right_limit = screen_width/2
onready var left_limit = -(screen_width/2)

var current_player_state : String = "idle" # Current status of Player
var current_animation : String # Player's current animation


func _ready():
	# Start playing the idle animation
	spineboy.get_animation_state().set_animation("idle", true, 0)


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
		
		# Flip skeleton based on _velocity.x
		flip_skeleton()
		
		# Gravity is always added to _velocity.y every delta time
		_velocity.y += gravity * delta
		
		# Set the current state of Player
		set_player_state()
	
	# When the game is over and Player cannot be moved
	elif !can_move:
		# Set _velocity.x to 0 immediately
		_velocity.x = 0
		
		# As for _velocity.y, determine based on whether or not Player is on floor
		if player_kinematicBody2D.is_on_floor():
			# If Player is on the floor, turn the state to idle.
			current_player_state = "idle"
		elif not player_kinematicBody2D.is_on_floor():
			# If Player is not on the floor, interrupt the jump action and lower to the floor
			current_player_state = "jump_down"
			_velocity.y += gravity * delta
	
	_velocity = player_kinematicBody2D.move_and_slide(_velocity, UP_DIRECTION)
	
	# Limit the x-axis position so that Player does not move off the screen
	limit_player_position()
	
	# Set an animation that match the current state of Player
	set_skeleton_animation()


# Limit the x-axis position so that Player does not move off the screen
func limit_player_position():
	if player_kinematicBody2D.position.x > right_limit:
		player_kinematicBody2D.position.x = right_limit
	elif player_kinematicBody2D.position.x < left_limit:
		player_kinematicBody2D.position.x = left_limit


# Set the current state of Player
func set_player_state():
	# If Player is on floor the floor and velocity is zero, set "current_player_state" to "idle"
	if player_kinematicBody2D.is_on_floor() and is_zero_approx(_velocity.x):
		current_player_state = "idle"

	# If Player is on floor the floor but velocity is not zero, set "current_player_state" to "running"
	elif player_kinematicBody2D.is_on_floor() and not is_zero_approx(_velocity.x):
		current_player_state = "running"
	
	# If Player is on floor the floor and the "jump" button is pressed, set "current_player_state" to "jump_up"
	if player_kinematicBody2D.is_on_floor() and Input.is_action_just_pressed("jump"):
		current_player_state = "jump_up"
		_velocity.y = -jump_strength
	
	# If Player is not on floor but velocity.y is higher than "velocity_threshold_min", set "current_player_state" to "jump_down"
	if not player_kinematicBody2D.is_on_floor() and _velocity.y > velocity_threshold_min:
		current_player_state = "jump_down"	


# Flip the skeleton according to whether the direction of velocity is positive or negative
func flip_skeleton() -> void:
	if not is_zero_approx(_velocity.x):
		if _velocity.x > 0:
			spineboy.get_skeleton().set_scale_x(1)
		elif _velocity.x < -0:
			spineboy.get_skeleton().set_scale_x(-1)


# Set an animation that match the current state of Player
func set_skeleton_animation() -> void:
	# Get the current animation playing on track 0
	current_animation = spineboy.get_animation_state().get_current(0).get_animation().get_name()
	
	if current_player_state == "jump_up":
		if current_animation == "jump_up":
			pass
		elif current_animation != "jump_up":
			spineboy.get_animation_state().set_animation("jump_up", false, 0)
			
	elif current_player_state == "jump_down":
		if current_animation == "jump_down":
			pass
		elif current_animation != "jump_down":
			spineboy.get_animation_state().set_animation("jump_down", false, 0)		
		
	elif current_player_state == "running":
		if current_animation == "run":
			pass
		elif current_animation != "run":
			spineboy.get_animation_state().set_animation("run", true, 0)
		
	elif current_player_state == "idle":
		if current_animation == "idle":
			pass
		elif current_animation != "idle":
			spineboy.get_animation_state().set_animation("idle", true, 0)

