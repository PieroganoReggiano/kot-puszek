extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func plumkaj():
	$"..".plumkaj()

func znikanko():
	$koto_ui.hide()

func pojawianko():
	$koto_ui.show()

func _process(delta):
	pass


func _on_return_pressed():
	plumkaj()
	znikanko()


func _on_meniu_pressed():
	plumkaj()
