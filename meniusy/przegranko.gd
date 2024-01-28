extends Control

var time = 0.0
var position_poczatkowa : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	position_poczatkowa = $CanvasLayer/ColorRect2.position
	$AudioStreamPlayer2D.play()
	$CanvasLayer/ColorRect2/AnimatedSprite2D.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta

	var hmm = time * 130.0 / 60.0 / 2.0
	#hmm -= int(hmm)
	hmm *= 2*PI
	var scale = 1.0 + 0.7 * sin(hmm)
	var offset = sin(hmm) * 60.0
	if time > 30:
	
		$CanvasLayer/ColorRect2.scale = Vector2(scale, scale)
		$CanvasLayer/ColorRect2.position = position_poczatkowa + Vector2(offset, offset)
		$CanvasLayer/ColorRect2.rotation = time
		
		if time > 120:
			$CanvasLayer/ColorRect2.rotation = time * 6
			scale = 1.2 + 0.9 * sin(hmm)
			$CanvasLayer/ColorRect2.scale = Vector2(scale, scale)
		
	else:
		$CanvasLayer/ColorRect2.position = position_poczatkowa + Vector2(offset, 0.0)
		


func _on_wracanie_pressed():
	var korzen = get_node_or_null("../..")
	if (korzen == null):
		get_tree().change_scene_to_file("res://meniusy/startowe_menu.tscn")
	else:
		korzen.full_reset()
