@tool
extends Node3D

# ---- arguments ----
@export var sprite_frames:SpriteFrames
@export var is_player:bool = false
@export var gravity_enabled = false
@export var gravity:float = 0.2


@export var collision_width_override:float = 0
@export var collision_height_override:float = 0
@export var collision_height_offsety:float = 0
# ---- ----



var animation_states:Dictionary
var animation_playing:String = "idle"
var animation_modifier:String = ""

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
	


	

func _physics_process(delta):
	if(!initialized):
		return
		

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

