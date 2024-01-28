extends Node3D

func _on_zombie_easy_spawner_trigger_body_entered(body):
	var parent = body.get_parent()
	if parent != null:
		if parent.name == "Drunkard":
			get_node("Spawners/Zombie_Easy_Drunkard").enable()
			get_node("../..").get_node("Musicco").order_danger()
