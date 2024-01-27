extends CanvasLayer

func _process(delta):
	var treenode = get_parent()
	get_node("Score").text = "Score: " + str(treenode.get_node("Puszek").points)
	get_node("DrunkLevel").text = "Drunkness: " + str(treenode.get_node("Drunkard").alcohol_level)
