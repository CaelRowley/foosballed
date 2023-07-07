extends Control

var previous_scene_path := "res://scenes/menus/main_menu.tscn"
var current_scene: Node = null

@onready var animation_player := $CanvasLayer/AnimationPlayer as AnimationPlayer


func _ready() -> void:
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	previous_scene_path = current_scene.scene_file_path
	fade_in(0.5)


func goto_previous_scene(speed_scale: float = 1.0) -> void:
	call_deferred("_deferred_goto_scene", previous_scene_path, speed_scale)


func goto_scene(path: String, speed_scale: float = 1.0) -> void:
	animation_player.set_speed_scale(speed_scale)
	call_deferred("_deferred_goto_scene", path, speed_scale)


func _deferred_goto_scene(path: String, speed_scale: float = 1.0) -> void:
	#Set current scene as previous scene and then clear it
	previous_scene_path = current_scene.scene_file_path
	
#	Fade out then load the next scene
	fade_out(speed_scale)
	await animation_player.animation_finished
	
	current_scene.queue_free()
	var next_scene := ResourceLoader.load(path) as PackedScene
	current_scene = next_scene.instantiate()
	
#	Fade set new active scene then fade in
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	fade_in(speed_scale)


func fade_in(speed_scale: float = 1.0) -> AnimationPlayer:
	animation_player.set_speed_scale(speed_scale)
	animation_player.play("fade_in")
	return animation_player


func fade_out(speed_scale: float = 1.0) -> AnimationPlayer:
	animation_player.set_speed_scale(speed_scale)
	animation_player.play("fade_out")
	return animation_player
