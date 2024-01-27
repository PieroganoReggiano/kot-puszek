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

@export var collision_width_override:float = 0
@export var collision_height_override:float = 0
@export var collision_height_offsety:float = 0
# ---- ----

# ---- non user-configurable parameters ----
var jump_acceleration_time:float = 0.016667 * 8.0


# ---- variables ----
var jump_time_elapsed:float = 99999

var animation_states:Dictionary
var animation_playing:String = "idle"
var animation_modifier:String = ""

var target_velocity = Vector3.ZERO

var move_direction = Vector3.ZERO

var move_left:bool = false
var move_right:bool = false
var move_up:bool = false
var move_down:bool = false
var move_jump:bool = false
# ---- ----

# ---- objects ----
@onready var body = self
@onready var sprite = body.get_node("sprite_center/Sprite")
@onready var sprite_center = body.get_node("sprite_center")
@onready var collision_shape = body.get_node("Collision")
@onready var parent = body.get_parent()
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
	if collision_width_override == 0:
		collision_shape.shape.radius = sprite_size.x * sprite.pixel_size / 2.0
	else:
		collision_shape.shape.radius = collision_width_override * sprite.pixel_size / 2.0
	if collision_height_override == 0:
		collision_shape.shape.height = sprite_size.y * sprite.pixel_size
	else:
		collision_shape.shape.height = collision_height_override * sprite.pixel_size
	if collision_height_offsety != 0:
		collision_shape.position.y = collision_height_offsety * sprite.pixel_size #-collision_shape.shape.height # -sprite_size.y * sprite.pixel_size # Vector pointing along the Y axis = 
	
	force_animation("idle")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func update_animation():
	play_animation(sprite.animation)
	
func force_animation(name):	
	animation_states[sprite.animation] = sprite.frame
	animation_playing = name
	sprite.play(name + animation_modifier)
	if(sprite.animation in animation_states):
		sprite.frame = animation_states[sprite.animation]

func play_animation(name):
	# dont update animation if we want to play the same again
	if name + animation_modifier == sprite.animation:
		return
	# store previous animation position
	animation_states[sprite.animation] = sprite.frame
	# play new anim
	if sprite.sprite_frames.has_animation(name):
		animation_playing = name
		sprite.play(name + animation_modifier)
		# set frame if already stored
		if(sprite.animation in animation_states):
			sprite.frame = animation_states[sprite.animation]
	

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
	
	var direction = move_direction
		
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
			

	

	#if(target_velocity == Vector3.ZERO and old_target_velocity != Vector3.ZERO):
	if(target_velocity == Vector3.ZERO):
		play_animation("idle")
	#if(target_velocity != Vector3.ZERO and old_target_velocity == Vector3.ZERO):
		#play_animation("move_side")
	else:
		var target_velocity_noy = Vector3(target_velocity.x, 0, target_velocity.z)
		var angle = (target_velocity_noy.signed_angle_to(Vector3(1,0,0),Vector3(0,1,0)) + PI) / 2
	
		var anim_dir = snapped(angle / PI * (8 - 0.25), 1) + 1
		if anim_dir == 9 or anim_dir == 8 or anim_dir == 1 or anim_dir == 2: play_animation("move_side")
		if anim_dir == 3: play_animation("move_up")
		if anim_dir == 4 or anim_dir == 5 or anim_dir == 6: play_animation("move_side")
		if anim_dir == 7: play_animation("move_down")
		
	if target_velocity.x >= 0:
		sprite.flip_h = true
	if target_velocity.x < 0:
		sprite.flip_h = false

	# Moving the Character
	body.velocity = target_velocity
	var collision_occured = body.move_and_slide()
	
	# Interactive collision detection
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
	
	
	#print(collision_shape.transform)

