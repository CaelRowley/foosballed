extends Node

const NORMAL_TIME_SCALE := 1.0

@export var slow_time_scale := 0.1
@export var fast_time_scale := 1.5


func pause():
	get_tree().paused = true


func unpause():
	get_tree().paused = false


func speed_up():
	Engine.time_scale = fast_time_scale


func slow_down():
	Engine.time_scale = slow_time_scale


func set_time_scale(new_time_scale: float):
	Engine.time_scale = new_time_scale


func reset():
	Engine.time_scale = NORMAL_TIME_SCALE
