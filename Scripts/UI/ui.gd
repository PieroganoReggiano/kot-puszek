extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var is_menu_visible = get_child(1).visible
	if Input.is_action_just_released("escape"):
		if is_menu_visible:
			get_child(1).hide()
		else:
			get_child(1).show()
