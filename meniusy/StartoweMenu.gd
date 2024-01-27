extends Control
var plum_player: AudioStreamPlayer2D
# Called when the node enters the scene tree for the first time.
func _ready():
	plum_player = get_child(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func plumkaj():
	plum_player.play()

func _on_start_pressed():
	plumkaj()
	get_tree().change_scene_to_file("res://level.tscn")
	


func _on_credits_pressed():
	plumkaj()


func _on_quit_pressed():
	plumkaj()
	get_tree().root.free()
