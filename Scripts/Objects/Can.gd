@tool
extends Node3D

@export var gravity_enabled = false
@export var gravity = 75

@onready var body = get_node("Body")

# Called when the node enters the scene tree for the first time.
func _ready():
	body.sprite_frames = load("res://Images/Can/Frames.tres")
	body.gravity_enabled = gravity_enabled
	body.gravity = gravity
	body.speed = 0
	body.jump_speed = 0
	body.acceleration = 0
	body.deceleration = 0
	body.init()
