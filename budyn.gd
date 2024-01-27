extends StaticBody3D

@export var size : Vector3 = Vector3(1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape3D.transform.origin = size / 2.0
	$CSGBox3D.transform.origin = size / 2.0
	$CSGBox3D.size = size
	var box_shape = BoxShape3D.new()
	$CollisionShape3D.shape = box_shape
	box_shape.size = size
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
