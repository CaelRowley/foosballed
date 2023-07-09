extends CharacterBody2D

@export var max_speed := 800.0
@export var acceleration := 5000
@export var distance_to_wall := 492.0
@export var num_of_players := 3
@export var distance_between_players := 300.0

@export var FoosballPlayer: PackedScene

var start_pos := Vector2.ZERO
var centre_pos := Vector2.ZERO
var player: Player
var player_list := []

var player_centre_position := 0.0
var size_of_player := 0.0
var max_distance := 0.0

@onready var foosball_players := $Players
@onready var sprite := $Sprite2D
@onready var is_odd := num_of_players & 1

func _ready():
	# Hard moves twice as fast as normal
	max_speed *= max(Settings.get_value(Settings.SECTIONS.Gameplay, Settings.KEYS.Difficulty) * 3.0, 0.3)
	acceleration *= max(Settings.get_value(Settings.SECTIONS.Gameplay, Settings.KEYS.Difficulty) * 3.0, 0.3)
	
	centre_pos = sprite.global_position
	start_pos = position
	
	var left_count := 0
	var right_count := 0
	var furthest_distance := 0
	
	for i in num_of_players:
		var new_player := FoosballPlayer.instantiate() as Node2D
		if i == 0:
			size_of_player = new_player.get_width()
			player_centre_position = ($ColorRect.size.x - new_player.get_width()) / 2.0
		if is_odd:
			if i == 0:
				new_player.position.x = player_centre_position
			elif i % 2 == 0:
				left_count += 1
				new_player.position.x = player_centre_position - (distance_between_players * left_count)
			else:
				right_count += 1
				new_player.position.x = player_centre_position + (distance_between_players * right_count)
		else:
			if i == 0:
				new_player.position.x = player_centre_position - (distance_between_players / 2.0)
			elif i == 1:
				new_player.position.x = player_centre_position + (distance_between_players / 2.0)
			elif i % 2 == 0:
				left_count += 1
				new_player.position.x = player_centre_position - (distance_between_players * left_count) - (distance_between_players / 2.0)
			else:
				right_count += 1
				new_player.position.x = player_centre_position + (distance_between_players * right_count) + (distance_between_players / 2.0)
		player_list.push_back(new_player)
		if new_player.position.x - centre_pos.x > furthest_distance:
			furthest_distance = new_player.position.x - centre_pos.x
		foosball_players.add_child(new_player)
	max_distance = distance_to_wall - furthest_distance - size_of_player


func _physics_process(delta):
	if (player != null):
		_force_max_distance()
		velocity = velocity.move_toward(_get_direction() * max_speed, acceleration * delta)
		move_and_slide()


func _force_max_distance():
	if (centre_pos.distance_to(sprite.global_position) > max_distance):
		if sprite.global_position.x < centre_pos.x:
			position = Vector2(start_pos.x - max_distance, start_pos.y)
		else:
			position = Vector2(start_pos.x + max_distance, start_pos.y)


func _get_direction() -> Vector2:
	var direction: Vector2
	
	if (player.global_position.x > sprite.global_position.x):
		#This prevents a gap opening on the far right
		if player.global_position.x > centre_pos.x:
			var most_right_player_pos := 0
			var second_most_right_player_pos := 0
			var current_player_pos := 0
			for i in player_list.size():
				current_player_pos = player_list[i].global_position.x
				if i == 0:
					most_right_player_pos = current_player_pos
				elif most_right_player_pos < current_player_pos:
					most_right_player_pos = current_player_pos
			for i in player_list.size():
				current_player_pos = player_list[i].global_position.x
				if current_player_pos < most_right_player_pos:
					if second_most_right_player_pos == 0:
						second_most_right_player_pos = current_player_pos
					elif second_most_right_player_pos < current_player_pos:
						second_most_right_player_pos = current_player_pos
			if player.global_position.x < most_right_player_pos and player.global_position.x > second_most_right_player_pos:
				direction = Vector2.LEFT
			else:
				direction = Vector2.RIGHT
		#This prevents a gap opening in the middle for even numbers
		elif not is_odd and player.global_position.x < player_list[1].global_position.x:
			direction = Vector2.LEFT
		else:
			direction = Vector2.RIGHT
	else:
		#This prevents a gap opening on the far left
		if player.global_position.x < centre_pos.x:
			var most_left_player_pos := 0
			var second_most_left_player_pos := 0
			var current_player_pos := 0
			for i in player_list.size():
				current_player_pos = player_list[i].global_position.x
				if i == 0:
					most_left_player_pos = current_player_pos
				elif most_left_player_pos > current_player_pos:
					most_left_player_pos = current_player_pos
			for i in player_list.size():
				current_player_pos = player_list[i].global_position.x
				if current_player_pos > most_left_player_pos:
					if second_most_left_player_pos == 0:
						second_most_left_player_pos = current_player_pos
					elif second_most_left_player_pos > current_player_pos:
						second_most_left_player_pos = current_player_pos
			if player.global_position.x > most_left_player_pos and player.global_position.x < second_most_left_player_pos:
				direction = Vector2.RIGHT
			else:
				direction = Vector2.LEFT
		#This prevents a gap opening in the middle for even numbers
		elif not is_odd and player.global_position.x > player_list[0].global_position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
	#This stops them blocking the player from going backawards
	if player.global_position.y < sprite.global_position.y:
		direction *= -1
	return direction


func _on_area_2d_body_entered(body):
	if body is Player:
		player = body
		for foosball_player in foosball_players.get_children():
			foosball_player.start_kicking()


func _on_area_2d_body_exited(body):
	if body is Player:
		player = null
		for foosball_player in foosball_players.get_children():
			foosball_player.stop_kicking()
