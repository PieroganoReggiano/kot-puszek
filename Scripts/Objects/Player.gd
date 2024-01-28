@tool
extends Node3D

@export var gravity_enabled = false
@export var speed:float = 1.4
@export var acceleration:float = 2
@export var deceleration:float = 4
@export var jump_speed:float = 35
@export var gravity:float = 10

@onready var body = self.get_node("Body")
@onready var attack_area = self.get_node("Body/attack_area")

# ---- non-modifiable parameters ----
var attack_cooldown:float = 1

# ---- player states ----
var rooted : bool = false
var points:int = 0
var has_can:bool = false
var move_attack:bool = false
var attack_timer:float = 999




# Called when the node enters the scene tree for the first time.
func _ready():
	body.sprite_frames = load("res://Images/Player/Frames.tres")
	body.gravity_enabled = gravity_enabled
	body.gravity = gravity
	body.speed = speed
	body.jump_speed = jump_speed
	body.acceleration = acceleration
	body.deceleration = deceleration
	body.is_player = true
	
	body.collision_width_override = 13
	
	body.init()
	
	body.get_node("sprite_center/Sprite").connect("animation_finished", _on_sprite_animation_finished)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Engine.is_editor_hint():
		process_player_input()
	if attack_timer < attack_cooldown:
		attack_timer += delta
		
func _physics_process(delta):
	if move_attack and attack_timer > attack_cooldown:
		body.animation_use_move = false
		body.play_animation("move_attack", 0)
		attack_timer = 0
		var attackable_objects = attack_area.get_overlapping_bodies()
		for object in attackable_objects:
			if(object != body):
				if(object.get_parent().has_method("take_attack")):
					object.get_parent().take_attack(self)
					#print("attacking: " + object.get_parent().name)
	
# if attack has ended force idle animation
func _on_sprite_animation_finished():
	if(body.animation_playing == "move_attack"):
		body.animation_use_move = true
		

func process_player_input():
	body.move_left = Input.is_action_pressed("move_left") if not rooted else false
	body.move_right = Input.is_action_pressed("move_right") if not rooted else false
	body.move_up = Input.is_action_pressed("move_up") if not rooted else false
	body.move_down = Input.is_action_pressed("move_down") if not rooted else false
	body.move_jump = Input.is_action_pressed("move_jump") if not rooted else false
	move_attack = Input.is_action_pressed("move_attack") if not rooted else false
	
func collision_generic_callback(collider):
	pass
	#print(collider.name)
#	collider.queue_free()

func collision_DynamicObject_callback(object):
	# detect can
	#print(object.name)
	if(object.name.begins_with("Can")):
		if not has_can:
			points += 25
			body.animation_modifier = "_can"
			body.update_animation()
			object.queue_free()
			has_can = true
	if(object.name == "Drunkard"):
		if has_can:
			points += 75
			body.animation_modifier = ""
			body.update_animation()
			object.drink_beer()
			has_can = false
