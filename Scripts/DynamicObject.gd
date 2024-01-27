@tool
extends Node3D

# ---- arguments ----
@export var sprite_frames:SpriteFrames
@export var is_player:bool = false
@export var gravity_enabled = false
@export var gravity:float = 0.2

# How fast the player moves in meters per second.
@export var speed:float = 14
@export var jump_speed:float = 4
@export var acceleration:float = 3
@export var deceleration:float = 3
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
# ---- ----

# ---- non user-configurable parameters ----
var jump_acceleration_time:float = 0.016667 * 8.0


# ---- variables ----
var jump_time_elapsed:float = 99999

var animation_states:Dictionary
var target_velocity = Vector3.ZERO

var move_direction = Vector3.ZERO

var move_left:bool = false
var move_right:bool = false
var move_up:bool = false
var move_down:bool = false
var move_jump:bool = false
# ---- ----

# ---- objects ----
@onready var sprite = get_node("sprite_center/Sprite")
@onready var sprite_center = get_node("sprite_center")
@onready var collision_shape = get_node("Collision")
@onready var body = self
@onready var parent = get_parent()
# ---- ----

var sprite_size


var initialized:bool = false

func init():
	if(sprite_frames != null):
		initialized = true
	else:
		return
		
	animation_states = {}
	sprite.sprite_frames = sprite_frames
	sprite_size = sprite.sprite_frames.get_frame_texture("idle", 0).get_size()
	collision_shape.shape.height = sprite_size.y * sprite.pixel_size
	collision_shape.shape.radius = sprite_size.x * sprite.pixel_size
	collision_shape.position.y = 0 #-collision_shape.shape.height # -sprite_size.y * sprite.pixel_size # Vector pointing along the Y axis = 
	play_animation("idle")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func play_animation(name):
	# store previous animation position
	animation_states[sprite.animation] = sprite.frame
	# play new anim
	if sprite.sprite_frames.has_animation(name):
		sprite.play(name)
		# set frame if already stored
		if(name in animation_states):
			sprite.frame = animation_states[name]
	

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
	
	#if body.is_on_wall():
		#move_direction.x = 0
		#move_direction.z = 0
	
	var direction = move_direction
		
	#if move_direction != Vector3.ZERO:
	#	direction = direction.normalized()
	#	# Setting the basis property will affect the rotation of the node.
	#	#$Pivot.basis = Basis.looking_at(direction)
	
	var old_target_velocity = Vector3(target_velocity)
	target_velocity = move_direction
	
	if not body.is_on_floor():
		jump_time_elapsed += delta
	
	# init jump
	if move_jump and gravity_enabled:
		if body.is_on_floor():
			jump_time_elapsed = 0
		if jump_time_elapsed < jump_acceleration_time:
			jump_time_elapsed += delta
			move_direction.y += jump_speed * delta # * (jump_time_elapsed/jump_acceleration_time)

	if gravity_enabled:
		if body.is_on_floor() and jump_time_elapsed > jump_acceleration_time:
			move_direction.y = 0
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	
	#print(move_direction.y)
	
	# Vertical Velocity
	if gravity_enabled:
		if not body.is_on_floor(): # If in the air, fall towards the floor. Literally gravity
			move_direction.y = move_direction.y - (gravity * delta)
			

	

	if(target_velocity == Vector3.ZERO and old_target_velocity != Vector3.ZERO):
		play_animation("idle")
	if(target_velocity != Vector3.ZERO and old_target_velocity == Vector3.ZERO):
		play_animation("move_side")
	if target_velocity.x >= 0:
		sprite.flip_h = true
	if target_velocity.x < 0:
		sprite.flip_h = false

	# Moving the Character
	body.velocity = target_velocity
	var collision_occured = body.move_and_slide()
	
	# Interactive collision detection
	'''
	if parent.has_method("collision_callback"):
		var collision_results = body.move_and_collide(target_velocity,true)
		if collision_results:
			for i in range(collision_results.get_collision_count() - 1):
				var collider = collision_results.get_collider(i)
				parent.collision_callback(collider)
	'''
	#if collision_occured:
	#	for i in range(body.get_slide_collision_count() - 1):
	#		var collider = body.get_slide_collision(i)
	var collision_results = body.move_and_collide(target_velocity * delta * 2, true)
	if collision_results:
		var test = collision_results.get_collision_count()
		for i in range(collision_results.get_collision_count()):
			var collider = collision_results.get_collider(i)
			#var test = collider_parent.get_script().get_path()
			if (parent.has_method("collision_DynamicObject_callback") and
				collider != null and
				collider.get_script() != null and
				collider.get_script().get_path() == "res://Scripts/DynamicObject.gd"):
				# collided with DynamicObject, run method dedicated for our nice objects
				parent.collision_DynamicObject_callback(collider.get_parent()) # parent will be DynamicObject node
			elif(parent.has_method("collision_generic_callback")):
				# collided with something, run generic method
				parent.collision_generic_callback(collider)
						
						
	



func _physics_process(delta):
	if(!initialized):
		return
		
	process_movement(delta)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!initialized):
		return
		
	# Ostatecznie poszla alternatywna opcja: billboard
	#if not Engine.is_editor_hint():
	#	var camera = get_viewport().get_camera_3d()
	#	var point = camera.global_transform.origin
	#	sprite.look_at(Vector3(point.x, point.y, point.z), Vector3.UP)
	#sprite_center.rotation.y = 33
	
	
	print(collision_shape.transform)

