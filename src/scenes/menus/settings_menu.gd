extends Control


func _ready():
	$VBoxContainer/SliderVolume.value = Settings.get_value(Settings.SECTIONS.Volume, Settings.KEYS.Master)
	$VBoxContainer/SliderMusic.value = Settings.get_value(Settings.SECTIONS.Volume, Settings.KEYS.Music)
	$VBoxContainer/SliderSFX.value = Settings.get_value(Settings.SECTIONS.Volume, Settings.KEYS.SFX)


func _on_btn_back_pressed():
	AudioManager.play_sfx(AudioManager.SFX.MENU_BACKWARD)
	Settings.load_config()
	SceneManager.goto_previous_scene(2.0)


func _on_btn_save_pressed():
	AudioManager.play_sfx(AudioManager.SFX.SAVE_SETTINGS)
	Settings.save_config()
	SceneManager.goto_previous_scene(2.0)


func _on_slider_volume_value_changed(value: float):
	Settings.set_value(Settings.SECTIONS.Volume, Settings.KEYS.Master, value)
	AudioManager.set_volume(AudioManager.AUDIO_BUSES.Master, value)


func _on_slider_music_value_changed(value: float) -> void:
	Settings.set_value(Settings.SECTIONS.Volume, Settings.KEYS.Music, value)
	AudioManager.set_volume(AudioManager.AUDIO_BUSES.Music, value)


func _on_slider_sfx_value_changed(value: float) -> void:
	Settings.set_value(Settings.SECTIONS.Volume, Settings.KEYS.SFX, value)
	AudioManager.set_volume(AudioManager.AUDIO_BUSES.SFX, value)
