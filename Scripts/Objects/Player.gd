@tool
extends Node3D

@export var sprite_frames:SpriteFrames
@export var gravity_enabled = false
@export var speed:float = 1.4
@export var acceleration:float = 2
@export var deceleration:float = 4
@export var jump_speed:float = 35
@export var gravity:float = 10

@onready var body = get_node("Body")

# Called when the node enters the scene tree for the first time.
func _ready():
	body.sprite_frames = sprite_frames
	body.gravity_enabled = gravity_enabled
	body.gravity = gravity
	body.speed = speed
	body.jump_speed = jump_speed
	body.acceleration = acceleration
	body.deceleration = deceleration
	body.init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Engine.is_editor_hint():
		process_player_input()


func process_player_input():
	body.move_left = Input.is_action_pressed("move_left")
	body.move_right = Input.is_action_pressed("move_right")
	body.move_up = Input.is_action_pressed("move_up")
	body.move_down = Input.is_action_pressed("move_down")
	body.move_jump = Input.is_action_pressed("move_jump")
	
func collision_generic_callback(collider):
	print(collider.name)
#	collider.queue_free()
	
func collision_DynamicObject_callback(object):
	# detect can
	print(object.name)
	if(object.name == "Can1"):
		object.queue_free()
	if(object.name == "Drunkard"): object.drink_beer()
