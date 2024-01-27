extends HBoxContainer
var numersy = [11, 12, 13, 14, 15, 16]
var pozycja_animacji = 1
var animowane_piwo: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	animowane_piwo = get_child(0).get_child(0).get_child(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	animowane_piwo.set_texture(load("res://Images/UI/frames/healthbar" + str(numersy[pozycja_animacji]) + ".png"))
	pozycja_animacji += 1
	if pozycja_animacji == numersy.size():
		pozycja_animacji = 0
