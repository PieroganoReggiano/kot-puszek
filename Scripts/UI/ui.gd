extends Control
var plum_player: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	plum_player = get_child(2)

func plumkaj():
	plum_player.play()

func znikanko():
	if get_child(1).visible:
		get_child(1).hide()
		get_tree().paused = false
	else:
		get_child(1).show()
		get_tree().paused = true
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("escape"):
		znikanko()


func _on_return_pressed():
	plumkaj()
	znikanko()


func _on_meniu_pressed():
	plumkaj()
