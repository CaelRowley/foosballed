extends Control


func _ready():
	if AudioManager.current_theme != AudioManager.Music.MENU:
		AudioManager.play_music(AudioManager.Music.MENU)


func _on_btn_play_pressed():
	AudioManager.play_sfx(AudioManager.SFX.MENU_FORWARD)
	SceneManager.goto_scene("res://scenes/levels/level.tscn")


func _on_btn_settings_pressed():
	AudioManager.play_sfx(AudioManager.SFX.MENU_FORWARD)
	SceneManager.goto_scene("res://scenes/menus/settings_menu.tscn", 2.0)


func _on_btn_quit_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.MENU_BACKWARD)
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
