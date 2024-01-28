@tool

extends Node3D

func _ready():
	if not Engine.is_editor_hint():
		visible = false
