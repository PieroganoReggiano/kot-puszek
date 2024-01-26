extends Node3D

# ---- arguments ----
@export var sprite_frames:SpriteFrames
@export var is_player:bool = false
@export var allow_jumping = false

# How fast the player moves in meters per second.
@export var speed:float = 14
@export var acceleration:float = 3
@export var deceleration:float = 3
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

# ---- ----

# ---- variables ----
var animation_states:Dictionary
var target_velocity = Vector3.ZERO

var move_direction = Vector3.ZERO

var move_left:bool = false
var move_right:bool = false
var move_up:bool = false
var move_down:bool = false
# ---- ----

# ---- objects ----
@onready var sprite = get_node("Body/sprite_center/Sprite")
@onready var sprite_center = get_node("Body/sprite_center")
@onready var collision_shape = get_node("Body/CollisionShape3D")
@onready var body = get_node("Body")
# ---- ----

var sprite_size




# Called when the node enters the scene tree for the first time.
func _ready():
	animation_states = {}
	sprite.sprite_frames = sprite_frames
	sprite_size = sprite.sprite_frames.get_frame_texture("Idle", 0).get_size()
	play_animation("Idle")
	
func play_animation(name):
	# store previous animation position
	animation_states[sprite.animation] = sprite.frame
	# play new anim
	sprite.play(name)
	# set frame if already stored
	if(name in animation_states):
		sprite.frame = animation_states[name]


func process_player_input():
	move_left = Input.is_action_pressed("move_left")
	move_right = Input.is_action_pressed("move_right")
	move_up = Input.is_action_pressed("move_up")
	move_down = Input.is_action_pressed("move_down")
	

func process_movement(delta):
	# We create a local variable to store the input direction.
	
	# We check for each move input and update the direction accordingly.
	if move_right:
		move_direction.x += acceleration * delta
	else:
		if(move_direction.x > 0): move_direction.x = maxf(move_direction.x - deceleration * delta, 0)
		
	if move_left:
		move_direction.x -= acceleration * delta
	else:
		if(move_direction.x < 0): move_direction.x = minf(move_direction.x + deceleration * delta, 0)
		
	if move_down:
		move_direction.z += acceleration * delta
	else:
		if(move_direction.z > 0): move_direction.z = maxf(move_direction.z - deceleration * delta, 0)
		
	if move_up:
		move_direction.z -= acceleration * delta
	else:
		if(move_direction.z < 0): move_direction.z = minf(move_direction.z + deceleration * delta, 0)
	
	# speed clamping
	if(move_direction.x > 1): move_direction.x = 1;
	if(move_direction.x < -1): move_direction.x = -1;
	if(move_direction.z > 1): move_direction.z = 1;
	if(move_direction.z < -1): move_direction.z = -1;
	
	if body.is_on_wall():
		move_direction.x = 0
		move_direction.z = 0
	
	var direction = move_direction
		
	#if move_direction != Vector3.ZERO:
	#	direction = direction.normalized()
	#	# Setting the basis property will affect the rotation of the node.
	#	#$Pivot.basis = Basis.looking_at(direction)
	
	var old_target_velocity = Vector3(target_velocity)
	target_velocity = move_direction
	
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if allow_jumping:
		if not body.is_on_floor(): # If in the air, fall towards the floor. Literally gravity
			target_velocity.y = target_velocity.y - (fall_acceleration * delta)
			

	

	if(target_velocity == Vector3.ZERO and old_target_velocity != Vector3.ZERO):
		play_animation("Idle")
	if(target_velocity != Vector3.ZERO and old_target_velocity == Vector3.ZERO):
		play_animation("Run")
	if target_velocity.x >= 0:
		sprite.flip_h = false
	if target_velocity.x < 0:
		sprite.flip_h = true
		
	# Moving the Character
	body.velocity = target_velocity
	$Body.move_and_slide()


func _physics_process(delta):
	process_movement(delta)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var camera = get_viewport().get_camera_3d()
	var point = camera.global_transform.origin
	sprite.look_at(Vector3(point.x, point.y, point.z), Vector3.UP)
	#sprite_center.rotation.y = 33
	
	collision_shape.shape.height = sprite_size.x * sprite.pixel_size
	collision_shape.shape.radius = sprite_size.y * sprite.pixel_size / 2.0

	if is_player:
		process_player_input()

