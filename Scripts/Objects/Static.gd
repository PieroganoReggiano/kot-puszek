@tool
extends Node3D

@export var sprite_frames:SpriteFrames
@export var gravity_enabled = false
@export var gravity = 75
@export var dont_block:bool = false

@onready var body = get_node("Body")

# Called when the node enters the scene tree for the first time.
func _ready():
	body.sprite_frames = sprite_frames
	body.gravity_enabled = gravity_enabled
	body.gravity = gravity
	body.dont_block = dont_block
	body.init()
