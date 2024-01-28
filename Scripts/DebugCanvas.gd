extends CanvasLayer

func _process(delta):
	var treenode = get_parent()
	
	get_node("Score_Cat").text = "Cat Score: " + str(treenode.get_node("Puszek").points)
	get_node("Score_Drunkard").text = "Drunkard Score: " + str(int(treenode.get_node("Drunkard").points))
		
	get_node("Health_Cat").text = "Cat Health: " + str(treenode.get_node("Puszek").body.health)
	get_node("Health_Drunkard").text = "Drunkard Health: " + str(treenode.get_node("Drunkard").body.health)
		
	
	get_node("DrunkLevel").text = "Drunkness: " + str(treenode.get_node("Drunkard").alcohol_level)
