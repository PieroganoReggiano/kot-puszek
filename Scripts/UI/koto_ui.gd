extends HBoxContainer
var numersy = [11, 12, 13, 14, 15, 16]
var pozycja_animacji = 1
var animowane_piwo: Texture2D

var meter
var cat_score
var drunkard_score

var h1
var h2
var h3
var h4
var h5
var h6
var h7
var h8

# Called when the node enters the scene tree for the first time.
func _ready():
	meter = get_node("Control/MarginContainer2/Drunkness")
	cat_score = get_node("Control/Scoreboard/CatScore")
	drunkard_score = get_node("Control/Scoreboard/DrunkardScore")
	
	h1 = get_node("Control/Hearts/1")
	h2 = get_node("Control/Hearts/2")
	h3 = get_node("Control/Hearts/3")
	h4 = get_node("Control/Hearts/4")
	h5 = get_node("Control/Hearts/5")
	h6 = get_node("Control/Hearts/6")
	h7 = get_node("Control/Hearts/7")
	h8 = get_node("Control/Hearts/8")


	#var test = get_node("Control/MarginContainer2/Drunkness").texture
	#animowane_piwo = test
	#animowane_piwo = get_child(0).get_child(0).get_child(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	meter.texture.atlas = load("res://Images/UI/frames/healthbar" + str(numersy[pozycja_animacji]) + ".png")
	pozycja_animacji += 1
	if pozycja_animacji == numersy.size():
		pozycja_animacji = 0
		
	var player_node
	var drunkard_node
		
	if(has_node("../../LevelContainer/Level/Drunkard")):
		drunkard_node = get_node("../../LevelContainer/Level/Drunkard")
		
	if(has_node("../../LevelContainer/Level/Player")):
		player_node = get_node("../../LevelContainer/Level/Player")
	elif(has_node("../../LevelContainer/Level/Puszek")):
		player_node = get_node("../../LevelContainer/Level/Puszek")
		
		
	if(drunkard_node != null):
		var drunkness_level = minf(drunkard_node.alcohol_level / 100, 1)
		#print(meter.texture.region)
		meter.texture.region.position.y = (1.0-drunkness_level)*128
		meter.texture.margin.position.y = (1.0-drunkness_level)*128
		#print(meter.texture.region)
		
		drunkard_score.text = str(int(drunkard_node.points))
		
		h1.visible = (drunkard_node.body.health >= 1)
		h2.visible = (drunkard_node.body.health >= 2)
		h3.visible = (drunkard_node.body.health >= 3)
		h4.visible = (drunkard_node.body.health >= 4)
		h5.visible = (drunkard_node.body.health >= 5)
		h6.visible = false #(drunkard_node.body.health >= 6)
		h7.visible = false # (drunkard_node.body.health >= 7)
		h8.visible = false # (drunkard_node.body.health >= 8)
		
	if(player_node != null):
		cat_score.text = str(int(player_node.points))
		
