extends AudioStreamPlayer

class Phase:
	var streams : Array[AudioStream]
	var loop_start : int = 0
	
@export var streams_chill : Array[AudioStream]
@export var loop_chill : int = 0
@export var streams_beginning : Array[AudioStream]
@export var loop_beginning : int = 0
@export var streams_danger : Array[AudioStream]
@export var loop_danger : int = 0
@export var streams_large_fight : Array[AudioStream]
@export var loop_large_fight : int = 0
@export var streams_hard_style : Array[AudioStream]
@export var loop_hard_style : int = 0

var chill : Phase = Phase.new()
var beginning : Phase = Phase.new()
var danger : Phase = Phase.new()
var large_fight : Phase = Phase.new()
var hard_style : Phase = Phase.new()


var rng = RandomNumberGenerator.new()
var ordered_phase = 0
var current_phase = 0
var current_pattern_number = 0
var should_play = true

func order_chill():
	ordered_phase = 0

func order_beginning():
	ordered_phase = 1
	
func order_danger():
	ordered_phase = 2
	
func order_large_fight():
	ordered_phase = 3
	
func order_hard_style():
	ordered_phase = 4
	
func force_order():
	if current_phase == ordered_phase:
		return
	stop()
	current_phase = ordered_phase
	current_pattern_number = -1
	_cycle()
	
func time_to_pattern_end():
	return 0.0;
	
func get_progress():
	if not playing:
		return 0.0
	return get_playback_position() / stream.get_length()
	
func get_remaining():
	if not playing:
		return 0.0
	return stream.get_length() - get_playback_position()

func get_next_pattern_time():
	if not playing:
		return 0.0
	var phase = _get_current_phase()
	if len(phase.streams) < 1:
		return 0.0
	var next_pattern_index = current_pattern_number + 1
	if (next_pattern_index >= len(phase.streams)):
		next_pattern_index = phase.loop_start
	return phase.streams[next_pattern_index].get_length()

func _get_current_phase():
	var phase = chill
	if current_phase == 1:
		phase = beginning
	elif current_phase == 2:
		phase = danger
	elif current_phase == 3:
		phase = large_fight
	elif current_phase == 4:
		phase = hard_style
	return phase
	

func _ready():
	chill.streams = streams_chill
	chill.loop_start = loop_chill
	beginning.streams = streams_beginning
	beginning.loop_start = loop_beginning
	danger.streams = streams_danger
	danger.loop_start = loop_danger
	large_fight.streams = streams_large_fight
	large_fight.loop_start = loop_large_fight
	hard_style.streams = streams_hard_style
	hard_style.loop_start = loop_hard_style
	current_pattern_number = -1
	_cycle()
			 
func _process(delta):
	if not should_play:
		stop()
	if not playing and should_play:
		play()
	if Input.is_physical_key_pressed(KEY_Y):
		order_chill()
	if Input.is_physical_key_pressed(KEY_U):
		order_beginning()
	if Input.is_physical_key_pressed(KEY_I):
		order_danger()
	if Input.is_physical_key_pressed(KEY_O):
		order_large_fight()
	if Input.is_physical_key_pressed(KEY_P):
		order_hard_style()
	if Input.is_physical_key_pressed(KEY_SPACE):
		force_order()
	pass
	
func _cycle():
	if current_phase != ordered_phase:
		current_phase = ordered_phase
		current_pattern_number = -1
	if not playing:
		var phase = _get_current_phase()
		if len(phase.streams) < 1:
			return
		current_pattern_number += 1
		if current_pattern_number >= len(phase.streams):
			current_pattern_number = phase.loop_start
		stream = phase.streams[current_pattern_number]
		play()
	

func _on_finished():
	_cycle()
