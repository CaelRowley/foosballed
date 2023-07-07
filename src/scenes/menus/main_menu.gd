extends Control


func _ready():
	AudioManager.play_music(AudioManager.Music.MENU)


func _on_btn_play_pressed():
	SceneManager.goto_scene("res://scenes/levels/level.tscn")


func _on_btn_settings_pressed():
	SceneManager.goto_scene("res://scenes/menus/settings_menu.tscn")


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
