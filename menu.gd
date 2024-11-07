extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://map.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_back_to_menu"):
		get_tree().quit()
