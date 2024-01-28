@tool
extends Node3D

var gravity_enabled = true
var speed:float = 4
var acceleration:float = 2
var deceleration:float = 4
var jump_speed:float = 35
var gravity:float = 10
@export var navigation_path:PackedVector3Array # defines moving path as vector3 points
@export var navigation_prefix:String # defines moving path as list of objects that are in root/<navigation_prefix>/(0...n)
@export var max_health:float
@export var start_moving:bool = false

@onready var body = get_node("Body")


var sound_player : AudioStreamPlayer3D;

var krok_integral = 0.0

var points:float = 0

var anim_timer:Timer = Timer.new()
var navigation_agent: NavigationAgent3D = NavigationAgent3D.new()
var navigation_point_now:int = 0
var navigation_ready:bool = false
var navigation_use_path:bool = true

var beers_drank:int = 0

var alcohol_level:float = 0
var dead:bool = false

# ---- non user-modifiable parameters
var alcohol_per_beer:float = 20
var drinking_beer_now:bool = false

func anim_drink():
	drinking_beer_now = true
	anim_timer.timeout.disconnect(anim_idle)
	anim_timer.timeout.disconnect(anim_laugh)
	body.play_animation("drink")
	anim_timer.one_shot = true
	anim_timer.timeout.connect(anim_laugh)
	anim_timer.set_wait_time(2)
	anim_timer.start()
func anim_laugh():
	body.play_animation("laugh")
	anim_timer.one_shot = true
	anim_timer.timeout.disconnect(anim_laugh)
	anim_timer.timeout.connect(anim_idle)
	anim_timer.set_wait_time(2)
	anim_timer.start()
func anim_idle():
	drinking_beer_now = false
	anim_timer.timeout.disconnect(anim_idle)
	body.play_animation("idle")
	
func navigation_prefix_point_exists(idx):
	return get_parent().has_node(navigation_prefix + "/" + str(idx))
func navigation_prefix_get_point(idx):
	var obj = get_parent().get_node(navigation_prefix + "/" + str(idx))
	var current_obj_position: Vector3 = obj.global_transform.origin
	return current_obj_position
	
	
func drink_beer():
	alcohol_level += alcohol_per_beer
	beers_drank += 1
	anim_drink()
	
func death(attacker):
	body.force_stun = true
	body.max_health = 0
	body.play_animation("death")
	navigation_ready = false
	dead = true
	if(has_node("../../..")):
		var rootnode = get_node("../../..")
		if rootnode.has_method("przegranko"):
			rootnode.przegranko()
	
func navigation_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	if navigation_use_path:
		set_movement_target(navigation_path[navigation_point_now])
	else:
		set_movement_target(navigation_prefix_get_point(navigation_point_now))

	navigation_ready = true
	
func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)
	navigation_agent.target_position = movement_target
	
func process_movementOLD(delta):
	if navigation_path != null and navigation_ready:
		if navigation_agent.is_navigation_finished():
			return

		var current_agent_position: Vector3 = body.global_transform.origin
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()

		body.velocity = current_agent_position.direction_to(next_path_position) * speed
		body.move_and_slide()
	
func process_movement(delta):
	var body = get_node("Body")
	if navigation_path != null and navigation_ready and start_moving:
		if navigation_agent.is_navigation_finished():
			if navigation_use_path and navigation_point_now < navigation_path.size()-1:
				navigation_point_now += 1
				set_movement_target(navigation_path[navigation_point_now])
			elif (not navigation_use_path) and navigation_prefix_point_exists(navigation_point_now + 1):
				navigation_point_now += 1
				set_movement_target(navigation_prefix_get_point(navigation_point_now))
			else:
				return
		#get_point_position 
		var current_agent_position: Vector3 = body.global_transform.origin
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		
		#next_path_position = get_parent().get_node("Player/Body").global_transform.origin
		#print("navpath: " + str(navigation_agent.get_current_navigation_path()))
		#print("navpathidx: " + str(navigation_agent.get_current_navigation_path_index()))
		#print("C: " + str(current_agent_position))
		#print("N: " + str(next_path_position))
		#print("DIST: " + str(navigation_agent.distance_to_target()))
		#print("ISREACH: " + str(navigation_agent.is_target_reachable()))
		#print("REACHED: " + str(navigation_agent.is_target_reached()))
		
		#body.velocity = current_agent_position.direction_to(next_path_position) * speed
		
		var target_origin_plane = Vector3(next_path_position.x, 0, next_path_position.z)
		var object_origin_plane = Vector3(current_agent_position.x, 0, current_agent_position.z)
		var diff = target_origin_plane - object_origin_plane
		
		body.velocity = diff.normalized() * speed
		
		var target_velocity = body.velocity
		if not drinking_beer_now:
			body.move_and_slide()
		
		body.animation_use_move = false
		
		if(not drinking_beer_now):
			if(target_velocity == Vector3.ZERO):
				# only reset animation to idle if we were playing generic moving animation
				if not dead:
					body.play_animation("idle")
			else:
				var target_velocity_noy = Vector3(target_velocity.x, 0, target_velocity.z)
				var angle = (target_velocity_noy.signed_angle_to(Vector3(1,0,0),Vector3(0,1,0)) + PI) / 2
			
				var anim_dir = snapped(angle / PI * (8 - 0.25), 1) + 1
				if anim_dir == 9: anim_dir = 1
				
				if anim_dir == 8 or anim_dir == 1 or anim_dir == 2: body.play_animation("move_side")
				if anim_dir == 3: body.play_animation("move_up")
				if anim_dir == 4 or anim_dir == 5 or anim_dir == 6: body.play_animation("move_side")
				if anim_dir == 7: body.play_animation("move_down")
			
		if target_velocity.x > 0:
			body.sprite.flip_h = true
		if target_velocity.x < 0:
			body.sprite.flip_h = false

func _physics_process(delta):
	process_movement(delta)
	
func _process(delta):
	if(body.health > 0):
		points += (50 - abs(50 - alcohol_level)) * delta * 1
	alcohol_level -= delta
	if(alcohol_level < 0): alcohol_level = 0
	
	
	if body.velocity.length() > 0.01:
		var threshold = 2.5
		krok_integral += (body.velocity * delta).length()
		if krok_integral > threshold:
			krok_integral -= threshold
			if not sound_player.playing:
				sound_player.stream = load("res://krok.wav")
				sound_player.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(anim_timer)
	
	body.sprite_frames = load("res://Images/Bum/Frames.tres")
	body.gravity_enabled = gravity_enabled
	body.gravity = gravity
	body.speed = speed
	body.jump_speed = jump_speed
	body.acceleration = acceleration
	body.deceleration = deceleration
	
	body.attack_class = 1
	body.max_health = max_health
	body.stunnable = true
	
	body.collision_width_override = 16
	body.collision_height_offsety = 0
	body.init()
	
	if (navigation_path != null and navigation_path.size() > 0) or navigation_prefix != "":
		if navigation_prefix != "":
			navigation_use_path = false # use object navigation
			
		body.add_child(navigation_agent)
		navigation_agent.path_desired_distance = 1.5
		navigation_agent.target_desired_distance = 1.5

		# Make sure to not await during _ready.
		call_deferred("navigation_setup")
	
	body.play_animation("idle")
	
	
	sound_player = AudioStreamPlayer3D.new()
	body.add_child(sound_player)

func collision_DynamicObject_callback(object):
	# detect can
	#print(object.name)
	if(object.name.begins_with("Can") and not dead):
		drink_beer()
		object.queue_free()

	
