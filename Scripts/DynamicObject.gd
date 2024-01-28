@tool
extends Node3D

# ---- arguments ----
@export var sprite_frames:SpriteFrames
@export var is_player:bool = false
@export var gravity_enabled = false
@export var gravity:float = 30

@export var max_health:float = 0
@export var stunnable:bool = false
@export var attack_strength:float = 1.0
@export var attack_class:int = 0 # if zero then non attackable
# How fast the player moves in meters per second.
@export var speed:float = 14
@export var jump_speed:float = 120
@export var acceleration:float = 3
@export var deceleration:float = 3

@export var ignore_blocking_collision:bool = false
@export var collision_width_override:float = 0
@export var collision_height_override:float = 0
@export var collision_height_offsety:float = 0
# ---- ----

# ---- non user-configurable parameters ----
var jump_acceleration_time:float = 0.016667 * 8.0
var attack_range = 40.0
var interaction_range = 10.0
var attack_cooldown:float = 1

# ---- variables ----
var jump_time_elapsed:float = 99999

var animation_states:Dictionary
var animation_playing:String = "idle"
var animation_modifier:String = ""
var animation_use_move:bool = true

var target_velocity = Vector3.ZERO

var move_direction = Vector3.ZERO

var move_left:bool = false
var move_right:bool = false
var move_up:bool = false
var move_down:bool = false
var move_jump:bool = false

# ---- attack logic ----
var move_attack:bool = false
var attack_timer:float = 9999

var stun_timer:float = 9999
var stun_time:float = 0.8

var invincibility_timer:float = 9999
var invincibility_time:float = 2
# ---- ----

# ---- object state ----
var health:float = 0
var force_stun:bool = false

# ---- objects ----
@onready var body = self
@onready var sprite = body.get_node("sprite_center/Sprite")
@onready var sprite_center = body.get_node("sprite_center")
@onready var collision_shape = body.get_node("Collision")
@onready var interaction_shape = body.get_node("interaction_area")
@onready var attack_shape = body.get_node("attack_area")
@onready var parent = body.get_parent()
# ---- ----

var sprite_size


var initialized:bool = false

func init():
	if(sprite_frames != null):
		initialized = true
	else:
		return
	
	health = max_health 	
		
	animation_states = {}
	sprite.sprite_frames = sprite_frames
	sprite_size = sprite.sprite_frames.get_frame_texture("idle", 0).get_size()
	if collision_width_override == 0:
		collision_shape.shape.radius = sprite_size.x * sprite.pixel_size / 2.0
		interaction_shape.get_node("iCollision").shape.radius = (sprite_size.x + interaction_range) * sprite.pixel_size / 2.0
		attack_shape.get_node("aCollision").shape.radius = (sprite_size.x + attack_range) * sprite.pixel_size / 2.0 
	else:
		collision_shape.shape.radius = collision_width_override * sprite.pixel_size / 2.0
		interaction_shape.get_node("iCollision").shape.radius = (collision_width_override + interaction_range) * sprite.pixel_size / 2.0
		attack_shape.get_node("aCollision").shape.radius = (collision_width_override + attack_range) * sprite.pixel_size / 2.0
	if collision_height_override == 0:
		collision_shape.shape.height = sprite_size.y * sprite.pixel_size
		interaction_shape.get_node("iCollision").shape.height = (sprite_size.y + interaction_range) * sprite.pixel_size
		attack_shape.get_node("aCollision").shape.height = (sprite_size.y + attack_range) * sprite.pixel_size
	else:
		collision_shape.shape.height = collision_height_override * sprite.pixel_size
		interaction_shape.get_node("iCollision").shape.height = (collision_height_override + interaction_range) * sprite.pixel_size
		attack_shape.get_node("aCollision").shape.height = (collision_height_override + attack_range) * sprite.pixel_size
	if collision_height_offsety != 0:
		collision_shape.position.y = collision_height_offsety * sprite.pixel_size #-collision_shape.shape.height # -sprite_size.y * sprite.pixel_size # Vector pointing along the Y axis = 
		interaction_shape.position.y = collision_height_offsety * sprite.pixel_size
		attack_shape.position.y = collision_height_offsety * sprite.pixel_size
		
	#interaction_shape.process_mode = Node.PROCESS_MODE_DISABLED
	#attack_shape.process_mode = Node.PROCESS_MODE_DISABLED
	
	if ignore_blocking_collision:
		collision_shape.disabled = true
	
	#interaction_shape.get_node("Collision").shape.height += 99
	get_node("sprite_center/Sprite").connect("animation_finished", _on_sprite_animation_finished)
		
	force_animation("idle")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# if attack has ended force idle animation
func _on_sprite_animation_finished():
	if(body.animation_playing == "move_attack"):
		body.animation_use_move = true
	if(body.animation_playing == "stun"):
		body.animation_use_move = true
	
func is_stunned():
	return force_stun or stun_timer < stun_time
	
func is_invincible():
	return invincibility_timer < invincibility_time
	
func stun_status_update(delta):
	if(stun_timer < stun_time):
		stun_timer += delta
		
func invincible_status_update(delta):
	if(invincibility_timer < invincibility_time):
		invincibility_timer += delta
		
func stun():
	body.animation_use_move = false
	body.play_animation("stun", 0)
	stun_timer = 0
	
func make_invincible():
	invincibility_timer = 0

func attack():
	if attack_timer > attack_cooldown and not is_stunned():
		force_attack()
		
func force_attack():
	body.animation_use_move = false
	body.play_animation("move_attack", 0)
	attack_timer = 0
	var attackable_objects = attack_shape.get_overlapping_bodies()
	for object in attackable_objects:
		if(object != body and
			object.has_method("take_damage") and
			object.attack_class != body.attack_class and
			body.attack_class > 0 and
			object.attack_class > 0):
			print(body.get_parent().name + " attacks " + object.get_parent().name + " @ " + str(attack_strength) + " hp!")
			object.take_damage(self.get_parent(), attack_strength)
			
		
func take_damage(attacker, damage):
	if not is_invincible() and health > 0:
		if(max_health > 0):
			health -= damage
			print(body.get_parent().name + " gets attacked by " + attacker.name + " @ " + str(damage) + " hp! New hp: " + str(health))
			if stunnable: stun()
			make_invincible()
			if(get_parent().has_method("take_damage")):
				get_parent().take_damage(attacker, damage) # propagate attack to main object, if function defined
			if health <= 0:
				if(get_parent().has_method("death")):
					get_parent().death(attacker) # if parent defined death function, use it
				else:
					get_parent().queue_free() # if not, just remove object
		else:
			if stunnable:
				stun()
	elif not is_invincible() and max_health == 0:
		if stunnable:
			stun()
			make_invincible()
	
func update_animation():
	play_animation(sprite.animation)
	
func force_animation(name, frame=null):	
	animation_states[sprite.animation] = sprite.frame
	animation_playing = name
	sprite.play(name + animation_modifier)
	if(sprite.animation in animation_states and frame == null):
		sprite.frame = animation_states[sprite.animation]
	elif frame != null:
		sprite.frame = frame
			
func play_animation(name, frame=null, custom_modifier=null):
	var anim_modifier = animation_modifier if custom_modifier == null else custom_modifier
	# dont update animation if we want to play the same again
	if name + anim_modifier == sprite.animation:
		return
	# store previous animation position
	animation_states[sprite.animation] = sprite.frame
	# play new anim
	if sprite.sprite_frames.has_animation(name + anim_modifier):
		animation_playing = name
		sprite.play(name + anim_modifier)
		if parent.name == "Drunkard": print(parent.name + " anim: " + name + anim_modifier)
		# set frame if already stored
		if(sprite.animation in animation_states and frame == null):
			sprite.frame = animation_states[sprite.animation]
		elif frame != null:
			sprite.frame = frame
	elif custom_modifier != "": # if frame with modifier not found, try default animation, without modifier
		play_animation(name, frame, "")
	


func process_movement(delta):
	var obj = get_parent()
	#if obj.name in ["Player", "Drunkard"]:
	#	print(obj.name + ": L2" + str(get_node("../Body").global_transform.origin))
	#	print(obj.name + ": G" + str(body.global_transform.origin))
	#	print(obj.name + ": L" + str(obj.global_transform.origin))
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
	
	# init jump - jump on getting stuned (by taking damage, not by forcing state) or when jump command is received
	if (move_jump or is_stunned()) and not force_stun and gravity_enabled:
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
	
	if is_stunned():
		target_velocity.x = 0
		target_velocity.z = 0
	
	#print(move_direction.y)
	
	# Vertical Velocity
	if gravity_enabled:
		if not body.is_on_floor(): # If in the air, fall towards the floor. Literally gravity
			move_direction.y = move_direction.y - (gravity * delta)
			

	
	if(animation_use_move):
		if(target_velocity == Vector3.ZERO and body.is_on_floor()):
			# only reset animation to idle if we were playing generic moving animation
			if(animation_playing in ["move_up", "move_down", "move_side", "move_attack"]):
				play_animation("idle")
		else:
			var target_velocity_noy = Vector3(target_velocity.x, 0, target_velocity.z)
			var angle = (target_velocity_noy.signed_angle_to(Vector3(1,0,0),Vector3(0,1,0)) + PI) / 2
		
			var anim_dir = snapped(angle / PI * (8 - 0.25), 1) + 1
			if anim_dir == 9: anim_dir = 1
			
			if anim_dir == 8 or anim_dir == 1 or anim_dir == 2: play_animation("move_side")
			if anim_dir == 3: play_animation("move_up")
			if anim_dir == 4 or anim_dir == 5 or anim_dir == 6: play_animation("move_side")
			if anim_dir == 7: play_animation("move_down")
		
	if target_velocity.x > 0:
		sprite.flip_h = true
	if target_velocity.x < 0:
		sprite.flip_h = false

	# Moving the Character
	body.velocity = target_velocity
	var collision_occured = body.move_and_slide()
	
	'''
	# Interactive collision detection - based on physics bodies and simulated movement
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
	'''	
	# Interactive collision detection - based on area test
	var objects_to_interact = interaction_shape.get_overlapping_bodies()
	for object in objects_to_interact:
		if(object != body):
			var collider = object
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
	
	if move_attack:
		attack()
					#print("attacking: " + object.get_parent().name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!initialized):
		return
	
	if attack_timer < attack_cooldown:
		attack_timer += delta
	
	stun_status_update(delta)
	invincible_status_update(delta)
	
	# Ostatecznie poszla alternatywna opcja: billboard
	#if not Engine.is_editor_hint():
	#	var camera = get_viewport().get_camera_3d()
	#	var point = camera.global_transform.origin
	#	sprite.look_at(Vector3(point.x, point.y, point.z), Vector3.UP)
	#sprite_center.rotation.y = 33
	
	
	#print(collision_shape.transform)
