extends Node


const AUDIO_BUSES := {
	"Master": "Master",
	"Music": "Music",
	"SFX": "SFX"
}

enum Music {
	STINGERS,
	MENU,
	IN_GAME
}
enum SFX {
	BOUNCE,
	MENU_FORWARD,
	MENU_BACKWARD,
	SAVE_SETTINGS,
}

var stingers := [
]
var menu_songs := [
	preload("res://audio/music/orgate/track03.wav"),
]
var in_game_songs := [
	preload("res://audio/music/orgate/track01.wav"),
]
var sfx := {
	SFX.BOUNCE: [
		preload("res://audio/sfx/Puzzle_Game_Accent_Boing_02.wav"),
	],
	SFX.MENU_FORWARD: [
		preload("res://audio/sfx/Puzzle_Game_Magic_Item_Unlock_1.ogg"),
	],
	SFX.MENU_BACKWARD: [
		preload("res://audio/sfx/Puzzle_Game_Magic_Item_Unlock_2.ogg"),
	],
	SFX.SAVE_SETTINGS: [
		preload("res://audio/sfx/Puzzle_Game_Magic_Item_Unlock_5.ogg"),
	],
}

var bus_volumes := {
	AUDIO_BUSES.Master: 1.0,
	AUDIO_BUSES.Music: 0.5,
	AUDIO_BUSES.SFX: 1.0,
}
var current_theme = null

@onready var audio_stream_player := $AudioStreamPlayer as AudioStreamPlayer


func play_music(theme: int):
	current_theme = theme
	match theme:
		Music.STINGERS: audio_stream_player.stream = stingers[randi() % stingers.size()]
		Music.MENU: audio_stream_player.stream = menu_songs[randi() % menu_songs.size()]
		Music.IN_GAME: audio_stream_player.stream = in_game_songs[randi() % in_game_songs.size()]
	
	audio_stream_player._set_playing(true)
	
	await audio_stream_player.finished
	play_music(theme)


func play_sfx(sound_effect: int):
	var audio_player := AudioStreamPlayer.new()
	audio_player.set_bus("SFX")
	add_child(audio_player)
	audio_player.stream = sfx.get(sound_effect)[randi() %  sfx.get(sound_effect).size()] as AudioStream
	audio_player.play()
	await audio_player.finished
	remove_child(audio_player)
	audio_player.queue_free()


func set_volume(audio_bus: String, volume: float):
	bus_volumes[audio_bus] = volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio_bus), linear_to_db(volume))


func get_volume(audio_bus: String) -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index(audio_bus))
