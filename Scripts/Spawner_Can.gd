@tool
extends Node3D

var object_to_load:PackedScene
var script_to_load:Script
@export var interval:float = 1
@export var spawn_count:int = 100
@export var enabled:bool = false
@export var trigger_react_to:Node3D

@onready var scene_root = get_parent()

var logic_timer:Timer = Timer.new()
var rng = RandomNumberGenerator.new()
var spawn_counter:int = 0

func _ready():
	if not Engine.is_editor_hint():
		object_to_load = load("res://DynamicObject.tscn")
		script_to_load = load("res://Scripts/Objects/Can.gd")
		
		add_child(logic_timer)
		logic_timer.timeout.connect(spawn_object)
		logic_timer.set_wait_time(interval)
		logic_timer.start()
		get_node("Area3D/CSGBox3D").queue_free()

func enable(body=null):
	enabled = true
func disable(body=null):
	enabled = false

func spawn_object():
	if not enabled:
		return
	if spawn_counter >= spawn_count:
		spawn_counter += 1
		return
		
	var obj = object_to_load.instantiate()
	obj.set_script(script_to_load)
	
	var min_x = self.global_position.x - self.global_transform.basis.x.length()
	var max_x = self.global_position.x + self.global_transform.basis.x.length()
	var min_y = self.global_position.y - self.global_transform.basis.y.length()
	var max_y = self.global_position.y + self.global_transform.basis.y.length()
	var min_z = self.global_position.z - self.global_transform.basis.z.length()
	var max_z = self.global_position.z + self.global_transform.basis.z.length()
	
	var pos_x = rng.randf_range(min_x, max_x)
	var pos_y = rng.randf_range(min_y, max_y)
	var pos_z = rng.randf_range(min_z, max_z)
	
	scene_root.add_child(obj)
	
	obj.global_position = Vector3(pos_x, pos_y, pos_z)
	obj.name = "Can_a_" + str(spawn_counter)
