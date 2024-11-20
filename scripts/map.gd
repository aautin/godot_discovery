extends Node3D

@onready var camera = $Camera3D
@onready var player = $Player
@onready var state = $State

var map_state : Array

func center_camera_on_player() -> void:
	camera.position = Vector3(player.position.x, player.position.y + 20, player.position.z + 25)

func _ready() -> void:
	var map_state_file = "res://map_state.txt"
	var map_state = state.read_file_to_int_array(map_state_file)
	print(map_state)  # This will print the 2D array of integers
	center_camera_on_player()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_back_to_menu"):
		get_tree().change_scene_to_file("res://menu.tscn")
