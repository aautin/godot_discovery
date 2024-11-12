extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://map.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_back_to_menu"):
		get_tree().quit()
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://map.tscn")

func center() -> void:
	var win_size = get_viewport_rect().size
	if camera:
		camera.position = Vector2(win_size.x / 2, win_size.y / 2)
	if buttons:
		buttons.position = Vector2((win_size.x - buttons.size.x) / 2, (win_size.y - buttons.size.y) / 2)

func _ready() -> void:
	center()

@onready var buttons = $Buttons_vbox
@onready var camera = $Camera2D
func _on_resized() -> void:
	center()
