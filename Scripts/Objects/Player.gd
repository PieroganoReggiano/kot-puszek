@tool
extends Node3D

@export var max_health:float = 5

@onready var body = self.get_node("Body")

var sound_player : AudioStreamPlayer3D;


# ---- player states ----
var rooted : bool = false
var points:int = 0
var has_can:bool = false
var has_pan:bool = false

var krok_integral = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	body.sprite_frames = load("res://Images/Player/Frames.tres")
	body.gravity_enabled = true
	body.gravity = 30
	body.speed = 7
	body.jump_speed = 120
	body.acceleration = 6
	body.deceleration = 10
	body.is_player = true
	
	body.collision_width_override = 13
	body.collision_height_offsety = 0
	
	body.attack_class = 1
	body.max_health = 0 #max_health
	body.stunnable = true
	
	body.attack_range = 55.0
	
	body.init()
	
	sound_player = AudioStreamPlayer3D.new()
	body.add_child(sound_player)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Engine.is_editor_hint():
		process_player_input()
		
	if has_can and has_pan: body.animation_modifier = "_pan_can"
	elif has_can: body.animation_modifier = "_can"
	elif has_pan: body.animation_modifier = "_pan"
	else: body.animation_modifier = ""
	
	
	if body.velocity.length() > 0.1:
		var threshold = 2.5
		krok_integral += (body.velocity * delta).length()
		if krok_integral > threshold:
			krok_integral -= threshold
			if not sound_player.playing:
				sound_player.stream = load("res://kot-krok.wav")
				sound_player.play()
	
func _physics_process(delta):
	pass
	
func death(attacker):
	body.force_stun = true
	body.max_health = 0
	body.play_animation("death")

func sound_jump():
	if not sound_player.playing or (sound_player.playing && sound_player.stream != load("res://skoku.ogg")):
		sound_player.stream = load("res://skoku.ogg")
		sound_player.play()

func sound_attack():
	if has_pan:
		sound_player.stream = load("res://swist1.wav")
		sound_player.play()
	else:
		sound_player.stream = load("res://swist3.wav")
		sound_player.play()
		

#func is_stunned():
#	if stun_timer < stun_time:
		

func process_player_input():
	body.move_left = Input.is_action_pressed("move_left") if not rooted else false
	body.move_right = Input.is_action_pressed("move_right") if not rooted else false
	body.move_up = Input.is_action_pressed("move_up") if not rooted else false
	body.move_down = Input.is_action_pressed("move_down") if not rooted else false
	body.move_jump = Input.is_action_pressed("move_jump") if not rooted else false
	body.move_attack = Input.is_action_pressed("move_attack") if not rooted else false
	
func collision_generic_callback(collider):
	pass
	#print(collider.name)
#	collider.queue_free()

func collision_DynamicObject_callback(object):
	# detect can
	#print(object.name)
	if(object.name.begins_with("Can")):
		if not has_can:
			has_can = true
			points += 25
			body.update_animation()
			object.queue_free()
			sound_player.stream = load("res://pucha2.ogg")
			sound_player.play()

	if(object.name == "Drunkard" and not object.dead):
		if has_can:
			has_can = false
			points += 75
			body.update_animation()
			object.drink_beer()
			
	if(object.name.begins_with("Pan")):
		has_pan = true
		body.attack_range = 70.0
		points += 200
		body.update_animation()
		body.attack_strength = 2.0
		object.queue_free()

