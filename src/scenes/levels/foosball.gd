extends Node2D


@export_range(0.0, 1.0) var player_friction := 0.01
@export var goals_to_win := 3

var player_resource := preload("res://scenes/player/player.tscn")
var player_goals := 0
var enemy_goals := 0

@onready var player_spawn := $PlayerSpawn as Node2D
@onready var player := player_resource.instantiate() as Player
@onready var player_goal_particle := $Goals/PlayerGoal/PlayerGoalParticle as CPUParticles2D
@onready var enemy_goal_particle := $Goals/EnemyGoal/EnemyGoalParticle as CPUParticles2D 
@onready var player_score := $CanvasLayer/ScoreBox/PlayerScore as Label
@onready var enemy_score := $CanvasLayer/ScoreBox/EnemyScore as Label
@onready var lose_message := $CanvasLayer/LoseMessage as Label
@onready var win_message := $CanvasLayer/WinMessage as Label
@onready var player_goal_message := $CanvasLayer/PlayerGoalMessage as Label
@onready var enemy_goal_message := $CanvasLayer/EnemyGoalMessage as Label


func _ready():
	player_spawn.add_child(player)
	player.connect("died", _on_player_died)
	player.has_gravity = false
	player.friction = 0.01
	if Settings.show_tooltip:
		_show_tooltip()
		TimeManager.pause()
	else:
		AudioManager.play_music(AudioManager.Music.IN_GAME)
		_hide_tooltip()
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		AudioManager.play_sfx(AudioManager.SFX.MENU_BACKWARD)
		SceneManager.goto_scene("res://scenes/menus/main_menu.tscn")


func _on_player_goal_body_entered(body):
	if body is Player:
		TimeManager.reset()
		enemy_goals += 1
		enemy_score.set_text(str(enemy_goals))
		player_goal_particle.emitting = true
		AudioManager.play_sfx(AudioManager.SFX.ENEMY_GOAL)
		if enemy_goals >= goals_to_win:
			TimeManager.set_time_scale(0.1)
			lose_message.visible = true
			await player.stop_effect(false)
			TimeManager.reset()
			lose()
		else:
			enemy_goal_message.visible = true
			reset_position()


func _on_enemy_goal_body_entered(body):
	if body is Player:
		TimeManager.reset()
		player_goals += 1
		player_score.set_text(str(player_goals))
		enemy_goal_particle.emitting = true
		AudioManager.play_sfx(AudioManager.SFX.PLAYER_GOAL)
		if player_goals >= goals_to_win:
			TimeManager.set_time_scale(0.1)
			win_message.visible = true
			await player.stop_effect(false)
			TimeManager.reset()
			win()
		else:
			player_goal_message.visible = true
			reset_position()


func reset_position():
	player.velocity = Vector2.ZERO
	await player.stop_effect(true)
	await player.dissolve()
	enemy_goal_message.visible = false
	player_goal_message.visible = false
	var transition := SceneManager.fade_out()
	await transition.animation_finished
	player.position = Vector2.ZERO
	player.assemble()
	SceneManager.fade_in()


func win():
	SceneManager.goto_scene("res://scenes/menus/win_menu.tscn")


func lose():
	SceneManager.goto_scene("res://scenes/menus/lose_menu.tscn")


func _on_player_died():
	lose()


func _show_tooltip():
	$CanvasLayer/ColorRectTooltip.show()
	$CanvasLayer/HowToPlayTitle.show()
	$CanvasLayer/HowToPlayMessage.show()
	$CanvasLayer/VBoxContainer.show()


func _hide_tooltip():
	$CanvasLayer/ColorRectTooltip.hide()
	$CanvasLayer/HowToPlayTitle.hide()
	$CanvasLayer/HowToPlayMessage.hide()
	$CanvasLayer/VBoxContainer.hide()


func _on_btn_close_tooltip_pressed() -> void:
	AudioManager.play_music(AudioManager.Music.IN_GAME)
	TimeManager.unpause()
	_hide_tooltip()


func _on_check_box_tooltip_toggled(button_pressed: bool) -> void:
	Settings.show_tooltip = !button_pressed
