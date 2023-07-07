extends Control


func _ready():
	AudioManager.play_music(AudioManager.Music.MENU)


func _on_btn_retry_pressed():
	AudioManager.play_sfx(AudioManager.SFX.MENU_FORWARD)
	SceneManager.goto_previous_scene()


func _on_btn_main_menu_pressed():
	AudioManager.play_sfx(AudioManager.SFX.MENU_BACKWARD)
	SceneManager.goto_scene("res://scenes/menus/main_menu.tscn")
