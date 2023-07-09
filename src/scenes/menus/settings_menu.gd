extends Control


func _ready():
	$VBoxContainer/SliderVolume.value = Settings.get_value(Settings.SECTIONS.Audio, Settings.KEYS.Master)
	$VBoxContainer/SliderMusic.value = Settings.get_value(Settings.SECTIONS.Audio, Settings.KEYS.Music)
	$VBoxContainer/SliderSFX.value = Settings.get_value(Settings.SECTIONS.Audio, Settings.KEYS.SFX)
	$VBoxContainer/SliderDifficulty.value = Settings.get_value(Settings.SECTIONS.Gameplay, Settings.KEYS.Difficulty)
	$VBoxContainer/FullscreenContainer/CheckBoxFullscreen.set_pressed_no_signal(Settings.get_value(Settings.SECTIONS.Display, Settings.KEYS.Fullscreen))

func _on_btn_back_pressed():
	AudioManager.play_sfx(AudioManager.SFX.MENU_BACKWARD)
	Settings.load_config()
	SceneManager.goto_scene("res://scenes/menus/main_menu.tscn", 2.0)


func _on_btn_save_pressed():
	AudioManager.play_sfx(AudioManager.SFX.SAVE_SETTINGS)
	Settings.save_config()
	SceneManager.goto_scene("res://scenes/menus/main_menu.tscn", 2.0)


func _on_slider_volume_value_changed(value: float):
	Settings.set_value(Settings.SECTIONS.Audio, Settings.KEYS.Master, value)
	AudioManager.set_volume(AudioManager.AUDIO_BUSES.Master, value)


func _on_slider_music_value_changed(value: float) -> void:
	Settings.set_value(Settings.SECTIONS.Audio, Settings.KEYS.Music, value)
	AudioManager.set_volume(AudioManager.AUDIO_BUSES.Music, value)


func _on_slider_sfx_value_changed(value: float) -> void:
	Settings.set_value(Settings.SECTIONS.Audio, Settings.KEYS.SFX, value)
	AudioManager.set_volume(AudioManager.AUDIO_BUSES.SFX, value)


func _on_slider_difficulty_value_changed(value: float) -> void:
	Settings.set_value(Settings.SECTIONS.Gameplay, Settings.KEYS.Difficulty, value)


func _on_check_box_fullscreen_toggled(button_pressed: bool) -> void:
	Settings.set_value(Settings.SECTIONS.Display, Settings.KEYS.Fullscreen, button_pressed)
	if (get_window().mode != get_window().MODE_FULLSCREEN and Settings.get_value(Settings.SECTIONS.Display, Settings.KEYS.Fullscreen)) or (get_window().mode == get_window().MODE_FULLSCREEN and !Settings.get_value(Settings.SECTIONS.Display, Settings.KEYS.Fullscreen)):
		get_window().mode = get_window().MODE_FULLSCREEN if Settings.get_value(Settings.SECTIONS.Display, Settings.KEYS.Fullscreen) else get_window().MODE_WINDOWED
