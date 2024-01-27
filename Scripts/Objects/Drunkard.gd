@tool
extends Node3D

@export var gravity_enabled = false
@export var speed:float = 0.4
@export var acceleration:float = 2
@export var deceleration:float = 4
@export var jump_speed:float = 35
@export var gravity:float = 10
@export var navigation_path:PackedVector3Array

@onready var body = get_node("Body")


var anim_timer:Timer = Timer.new()
var navigation_agent: NavigationAgent3D = NavigationAgent3D.new()
var navigation_point_now:int = 0
var navigation_ready:bool = false

var beers_drank:int = 0

var alcohol_level:float = 0

# ---- non user-modifiable parameters
var alcohol_per_beer:float = 20

var movement_target_position: Vector3 = Vector3(-3.0,0.0,1.0)

func anim_drink():
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
	anim_timer.timeout.disconnect(anim_idle)
	body.play_animation("idle")
	
	
func drink_beer():
	alcohol_level += alcohol_per_beer
	beers_drank += 1
	anim_drink()
	
	
func navigation_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(navigation_path[navigation_point_now])
	#set_movement_target(movement_target_position)
	#set_movement_target(Vector3(0,0,0))
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
	if navigation_path != null and navigation_ready:
		if navigation_agent.is_navigation_finished():
			if navigation_point_now < navigation_path.size()-1:
				navigation_point_now += 1
				set_movement_target(navigation_path[navigation_point_now])
			else:
				return
		#get_point_position 
		var current_agent_position: Vector3 = body.global_transform.origin
		var next_path_position: Vector3 = navigation_agent.get_next_path_position()
		
		#next_path_position = get_parent().get_node("Player/Body").global_transform.origin
		print("navpath: " + str(navigation_agent.get_current_navigation_path()))
		print("navpathidx: " + str(navigation_agent.get_current_navigation_path_index()))
		print("C: " + str(current_agent_position))
		print("N: " + str(next_path_position))
		print("DIST: " + str(navigation_agent.distance_to_target()))
		print("ISREACH: " + str(navigation_agent.is_target_reachable()))
		print("REACHED: " + str(navigation_agent.is_target_reached()))
		
		#body.velocity = current_agent_position.direction_to(next_path_position) * speed
		
		var target_origin_plane = Vector3(next_path_position.x, 0, next_path_position.z)
		var object_origin_plane = Vector3(current_agent_position.x, 0, current_agent_position.z)
		var diff = target_origin_plane - object_origin_plane
		
		body.velocity = diff.normalized() * speed
		
		body.move_and_slide()

func _physics_process(delta):
	process_movement(delta)
	
func _process(delta):
	alcohol_level -= delta
	if(alcohol_level < 0): alcohol_level = 0

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
	
	body.collision_width_override = 16
	body.init()
	
	if navigation_path != null:
		body.add_child(navigation_agent)
		navigation_agent.path_desired_distance = 0.5
		navigation_agent.target_desired_distance = 0.5

		# Make sure to not await during _ready.
		call_deferred("navigation_setup")
	
	body.play_animation("idle")

func collision_DynamicObject_callback(object):
	# detect can
	#print(object.name)
	if(object.name.begins_with("Can")):
		drink_beer()
		object.queue_free()

	
