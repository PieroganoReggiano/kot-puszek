extends Control
var plum_player: AudioStreamPlayer2D
# Called when the node enters the scene tree for the first time.
func _ready():
	plum_player = $AudioStreamPlayer2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func plumkaj():
	plum_player.play()

func _on_start_pressed():
	plumkaj()
	var korzen = get_node_or_null("../..")
	if korzen == null:
		get_tree().change_scene_to_file("res://level.tscn")
	else:
		korzen.begin_game()
	


func _on_credits_pressed():
	plumkaj()


func _on_quit_pressed():
	plumkaj()
	get_tree().root.free()
