extends Node


const CONFIG_FILE := "user://config.cfg"

const SECTIONS := {
	"Volume": "Volume",
}

const KEYS := {
	"Master": "Master",
	"Music": "Music",
	"SFX": "SFX",
}

var default_config: Dictionary = {
	SECTIONS.Volume:  {
		KEYS.Master: 1.0,
		KEYS.Music: 1.0,
		KEYS.SFX: 1.0,
	},
}

@onready var config := ConfigFile.new()


func _init():
	#To see directiory files are saves
	print(OS.get_user_data_dir())


func _ready():
	load_config()


func save_config() -> int:
	return config.save(CONFIG_FILE)


func load_config():
	var err := config.load(CONFIG_FILE)
	if err: 
		revert_config()
		return
	if not _check_config(): 
		revert_config()
		return

	AudioManager.set_volume(AudioManager.AUDIO_BUSES.Master, get_value(SECTIONS.Volume, KEYS.Master))
	AudioManager.set_volume(AudioManager.AUDIO_BUSES.Music, get_value(SECTIONS.Volume, KEYS.Music))
	AudioManager.set_volume(AudioManager.AUDIO_BUSES.SFX, get_value(SECTIONS.Volume, KEYS.SFX))
	

func revert_config():
	for section in default_config.keys():
		for key in default_config[section]:
			config.set_value(section, key, default_config[section][key])
	save_config()
	load_config()


func set_value(section: String, key: String, value):
	config.set_value(section, key, value)


func get_value(section: String, key: String):
	if config.has_section_key(section, key):
		return config.get_value(section, key)
	return null


func _check_config() -> bool:
	if (get_value(SECTIONS.Volume, KEYS.Master) != null): 
		return true
	
	return false
