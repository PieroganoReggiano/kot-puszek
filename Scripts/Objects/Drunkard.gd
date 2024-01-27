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

var anim_timer:Timer = Timer.new()
var beers_drank:int = 0

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
	beers_drank += 1
	anim_drink()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(anim_timer)
	
	body.sprite_frames = sprite_frames
	body.gravity_enabled = gravity_enabled
	body.gravity = gravity
	body.speed = speed
	body.jump_speed = jump_speed
	body.acceleration = acceleration
	body.deceleration = deceleration
	
	body.collision_width_override = 16
	
	body.init()

#func _process(delta):
	
