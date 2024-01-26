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

@export var speed = 3.0
@export var target: Node3D
@export var offset = Vector3.ZERO

func _physics_process(delta):
	if !target:
		return

	var subtarget = target.get_node("Body/node_center")
	if !subtarget:
		return
		
	var target_xform = subtarget.global_transform.translated_local(offset)
	global_transform = global_transform.interpolate_with(target_xform, speed * delta)

	look_at(subtarget.global_transform.origin, subtarget.transform.basis.y)
	
func _process(delta):
	pass
	#var camera_pos = get_viewport().get_camera().global_transform.origin
	#camera_pos.y = 0
	#look_at(camera_pos, Vector3(0, 1, 0))
