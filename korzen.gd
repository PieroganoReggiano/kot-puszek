extends Node

@export var default_level : Resource

var time_to_start : float = -20000.0
var camera_animation_time : float = 1.0

var camera_start : Vector3
var camera_end : Vector3


func _ready():
	immobilize()
	var camera = _get_camera()
	camera.target = null
	camera.speed = 5
	$ui.znikanko()
	
func _get_puszek():
	var level = get_node_or_null("LevelContainer/Level")
	if not level:
		return null
	var puszek = level.get_node_or_null("Player")
	if (puszek == null):
		puszek = level.get_node_or_null("Puszek")
	return puszek
	
func _get_drunkard():
	var level = get_node_or_null("LevelContainer/Level")
	if not level:
		return null
	var drunkard = level.get_node_or_null("Drunkard")
	return drunkard

func _get_camera():
	var level = get_node_or_null("LevelContainer/Level")
	if not level:
		return null
	var camera = level.get_node_or_null("Camera3D")
	return camera

func plumkaj():
	$PlumPlayer.play()

func begin_game():
	create_level_if_inexistent()
	start_camera_manipulation()
	pop_menu()
	
func immobilize():
	var puszek = _get_puszek()
	if (puszek == null):
		return
	puszek.rooted = true
	
func mobilize():
	var puszek = _get_puszek()
	if (puszek == null):
		return
	puszek.rooted = false
	
func set_slow_camera(progress : float = 0.5):
	var camera = _get_camera()
	if camera == null:
		return
	camera.speed = 0.7
	progress = lerp(0.0, progress, progress)
	progress = lerp(0.0, progress, progress)
	camera.rotation_speed = lerp(0.000, 1.6, progress)
	
func set_fast_camera():
	var camera = _get_camera()
	if camera == null:
		return
	camera.speed = 5.0
	camera.rotation_speed = 3.0

func create_level_if_inexistent():
	var level = $LevelContainer.get_child(0)
	if level == null:
		level = default_level.instantiate()
		$LevelContainer.add_child(level)
		level.get_node("Camera3D").target = null
	
func start_camera_manipulation():
	var default_minimum_time_to_start = 4.0
	time_to_start = $Musicco.get_remaining()
	if time_to_start < default_minimum_time_to_start:
		time_to_start += $Musicco.get_next_pattern_time()
	else:
		$Musicco.order_beginning()
	camera_animation_time = time_to_start
	var puszek = _get_puszek()
	if (puszek == null):
		return
	camera_end = puszek.position + Vector3(0.0, 6.5, 5.5)
	var camera = _get_camera()
	camera_start = camera.position
	camera.target = puszek
	set_slow_camera(0.0)
		
func pop_menu():
	var menu = $MenuContainer.get_child(0)
	$MenuContainer.remove_child(menu)
	menu.queue_free()
	
func victory():
	$Musicco.order_chill()
	$Musicco.force_order()
	$Musicco.should_play = false
	while $MenuContainer.get_child_count() > 0:
		var menu = $MenuContainer.get_child(0)
		$MenuContainer.remove_child(menu)
		menu.queue_free()
	while $LevelContainer.get_child_count() > 0:
		var level = $LevelContainer.get_child(0)
		$LevelContainer.remove_child(level)
		level.queue_free()
	var victory_menu = load("res://meniusy/wygranko.tscn").instantiate()
	$MenuContainer.add_child(victory_menu)
	time_to_start = -20000.0
		
func full_reset():
	$Musicco.order_chill()
	$Musicco.force_order()
	$Musicco.should_play = true
	while $MenuContainer.get_child_count() > 0:
		var menu = $MenuContainer.get_child(0)
		$MenuContainer.remove_child(menu)
		menu.queue_free()
	while $LevelContainer.get_child_count() > 0:
		var level = $LevelContainer.get_child(0)
		$LevelContainer.remove_child(level)
		level.queue_free()
	var menu = load("res://meniusy/startowe_menu.tscn").instantiate()
	$MenuContainer.add_child(menu)
	create_level_if_inexistent()
	
func start_level_logic():
	mobilize()
	get_node("LevelContainer/Level/Drunkard").start_moving = true

func _process(delta):
	if Input.is_key_pressed(KEY_0):
		victory()
	if time_to_start < -10000.0:
		return
	time_to_start -= delta
	var camera = _get_camera()
	var progress = (camera_animation_time - time_to_start)/camera_animation_time
	if camera:
		camera.position = \
			lerp(camera_start, camera_end, progress)
		set_slow_camera(progress)
	if time_to_start <= 0.0:
		start_level_logic()
		time_to_start = -20000.0
		set_fast_camera()
		$ui.pojawianko()
	elif (time_to_start - 0.1 < $Musicco.get_remaining()):
		$Musicco.order_beginning()
	
	
