extends Node3D

var win_timer:Timer = Timer.new()

func _on_zombie_easy_spawner_trigger_body_entered(body):
	var parent = body.get_parent()
	if parent != null:
		if parent.name == "Drunkard":
			get_node("Spawners/Zombie_Easy_Drunkard").enable()
			get_node("../..").get_node("Musicco").order_danger()


func _on_zombie_medium_spawner_trigger_2_body_entered(body):
	var parent = body.get_parent()
	if parent != null:
		if parent.name == "Drunkard":
			get_node("Spawners/Zombie_Medium_Drunkard").enable()
			get_node("Spawners/Zombie_Medium_Puszek").enable()
			get_node("../..").get_node("Musicco").order_large_fight()


func _on_zombie_hard_spawner_trigger_body_entered(body):
	var parent = body.get_parent()
	if parent != null:
		if parent.name == "Drunkard":
			get_node("Spawners/Zombie_Hard_Drunkard").enable()
			get_node("Spawners/Zombie_Hard_Puszek").enable()
			get_node("../..").get_node("Musicco").order_hard_style()


func make_win():
	get_node("../..").victory()

func _on_winning_zone_body_entered(body):
	var parent = body.get_parent()
	if parent != null:
		if parent.name == "Drunkard":
			win_timer.timeout.connect(make_win)
			win_timer.set_wait_time(3)
			win_timer.one_shot = true
			win_timer.start()

func _ready():
	add_child(win_timer)
