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

var beers_drank:int = 0

func anim_drink():
	body.play_animation("drink")
	$timer.one_shot = true
	$timer.timeout.connect(anim_laugh)
	$timer.set_wait_time(2)
	$timer.start()
func anim_laugh():
	body.play_animation("laugh")
	$timer.one_shot = true
	$timer.timeout.disconnect(anim_laugh)
	$timer.timeout.connect(anim_idle)
	$timer.set_wait_time(2)
	$timer.start()
func anim_idle():
	$timer.timeout.disconnect(anim_idle)
	body.play_animation("idle")
	
	
func drink_beer():
	beers_drank += 1
	anim_drink()

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

#func _process(delta):
	
