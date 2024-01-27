@tool
extends Node3D

@export var speed:float = 0.4
@export var acceleration:float = 2
@export var deceleration:float = 4
@export var jump_speed:float = 35
@export var gravity:float = 10
@export var target:Node3D

@onready var body = self.get_node("Body")

var logic_timer:Timer = Timer.new()
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		add_child(logic_timer)
		logic_timer.timeout.connect(process_state_machine)
		logic_timer.set_wait_time(2)
		logic_timer.start()
		
	body.sprite_frames = load("res://Images/Zombie/Frames.tres")
	body.gravity_enabled = true
	body.gravity = gravity
	body.speed = speed
	body.jump_speed = jump_speed
	body.acceleration = acceleration
	body.deceleration = deceleration
	
	body.collision_width_override = 16
	
	body.init()
	
func _physics_process(delta):
	if target != null:
		var target_origin = target.get_node("Body").global_transform.origin
		#print("ZOMBIE TARGET: " + str(target_origin))
		var object_origin = body.global_transform.origin
		var target_origin_plane = Vector3(target_origin.x, 0, target_origin.z)
		var tobject_origin_plane = Vector3(object_origin.x, 0, object_origin.z)
		var diff = target_origin_plane - tobject_origin_plane
		
		body.move_left = false
		body.move_right = false
		body.move_up = false
		body.move_down = false
		body.move_jump = false
		
		#print(diff.length())
		
		if diff.length() > 0.2:
			var angle = (diff.signed_angle_to(Vector3(1,0,0),Vector3(0,1,0)) + PI) / 2
			var direction = snapped(angle / PI * (8 - 0.25), 1) + 1
			if direction == 9 or direction == 8 or direction == 1 or direction == 2: body.move_left = true
			if direction == 2 or direction == 3 or direction == 4: body.move_up = true
			if direction == 4 or direction == 5 or direction == 6: body.move_right = true
			if direction == 6 or direction == 7 or direction == 8: body.move_down = true
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Engine.is_editor_hint():
		pass

func take_attack(attacker):
	if attacker.points != null:
		attacker.points += 50
	queue_free()

func process_state_machine():
	# if no target, move randomly
	if target == null:
		body.move_left = false
		body.move_right = false
		body.move_up = false
		body.move_down = false
		body.move_jump = false
	
		var random = rng.randi_range(0,8)
		if random == 8 or random == 1 or random == 2: body.move_left = true
		if random == 2 or random == 3 or random == 4: body.move_up = true
		if random == 4 or random == 5 or random == 6: body.move_right = true
		if random == 6 or random == 7 or random == 8: body.move_down = true
	#else:
		#print(body.global_transform.origin.angle_to(target.get_node("Body").global_transform.origin))
	#var velocity = global_position.direction_to(target) * speed
	#if global_position.distance_to(target) > 5:
	#	velocity = move_and_slide(velocity)
	
func collision_generic_callback(collider):
	pass
	
func collision_DynamicObject_callback(object):
	pass
