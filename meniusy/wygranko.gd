extends Control

var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time > 60.0:
		time -= 60.0
	
	var hmm = time * 140.0 / 60.0
	hmm -= int(hmm)
	$CanvasLayer/TextureRect.visible = hmm > 0.5
	$CanvasLayer/TextureRect2.visible = hmm <= 0.5
