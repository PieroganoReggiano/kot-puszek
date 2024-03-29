'''extends Node3D

@export var target:Node3D
@export var speed :float

func _process(delta):
   global_transform.origin = lerp(global_transform.origin, target.global_position, delta*speed)
   #var current_rotation = Quaternion(global_transform.basis)
   #var next_rotation = current_rotation.slerp(Quaternion(target.global_position), delta*speed)
   #global_transform.basis = Basis(next_rotation)

'''

extends Camera3D

@export var speed = 5.0
@export var rotation_speed = 3.0
@export var target: Node3D
@export var offset = Vector3.ZERO

# PIERWOTNE USTAWIENIA KAMERY: 0, 6.5, 5.5

func _process(delta):
	if Input.is_physical_key_pressed(KEY_1):
		offset = Vector3(0, 6.5, 5.5)
	if Input.is_physical_key_pressed(KEY_2):
		offset = Vector3(0, 4.5, 7)

func _physics_process(delta):
	if !target:
		return

	var subtarget = target.get_node("Body/node_center")
	if !subtarget:
		return
		
	var prev_rotation = rotation
	
	var target_xform = subtarget.global_transform.translated_local(offset)
	global_transform = global_transform.interpolate_with(target_xform, speed * delta)


	look_at(subtarget.global_transform.origin, subtarget.transform.basis.y)
	
	rotation = lerp(rotation, prev_rotation, pow(0.5, rotation_speed))
	

