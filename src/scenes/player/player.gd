extends CharacterBody2D
class_name Player

signal died()

@export_category("Jump and bounce params")
@export var min_jump_distance := 5.0
@export var max_jump_distance := 1500.0
@export var jump_multiplier := 10.0
@export var bounce_multiplier := 0.9
@export var kick_multiplier := 1.2
@export var min_kick_speed := 1000
@export var max_kick_speed := 4000

@export_category("Squash deformation strength")
@export var jump_squash_deformation := Vector2(0.0, 0.3)
@export var jump_aim_squash_deformation := Vector2(0.25, 0.0)
@export var bounce_squash_deformation := Vector2(0.0, 0.15)

@export_category("Camera params")
@export var default_zoom := Vector2(0.7, 0.7)
@export var aim_zoom := Vector2(0.65, 0.65)
@export var aim_offset := 400

@export_category("Misc params")
@export var trajectory_line_points := 50
@export var has_gravity := true
@export var friction = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float

var mouse_start_pos := Vector2.ZERO
var trajectory_direction := Vector2.UP
var trajectory_speed := 1.0

var tween: Tween
var can_jump := false
var has_started_jump := false
var use_gravity := has_gravity
var was_kicked := false

@onready var trajectory := $Trajectory as Line2D
@onready var trajectory_body := $Trajectory/Body as CharacterBody2D
@onready var player_sprite := $Sprite2D as Sprite2D
@onready var camera := $Camera2D as Camera2D
@onready var jump_timer := $JumpTimer
@onready var kicked_timer := $KickedTimer
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var collision_shape := $CollisionShape2D as CollisionShape2D


func _ready():
	assemble()


func _physics_process(delta: float):
	player_sprite.rotation = velocity.angle() + deg_to_rad(90)
	velocity = velocity.lerp(Vector2.ZERO, friction)

	if not is_on_floor():
		if has_gravity and use_gravity:
			velocity.y += gravity * delta

		var collision := move_and_collide(velocity * delta)
		if collision:
			_handle_collision(collision)
	
	if can_jump:
		if has_started_jump and Input.is_action_just_released("jump"):
			_jump()
		
		if not has_started_jump and Input.is_action_just_pressed("jump"):
			_start_aim()
			
		if has_started_jump and Input.is_action_pressed("jump"):
			_update_aim(delta)


func update_trajectory(dir: Vector2, speed: float, delta: float):
	delta = delta / Engine.time_scale
	trajectory.clear_points()
	var pos := Vector2.ZERO
	var vel := dir * speed
	
	for i in trajectory_line_points:
		trajectory.add_point(pos)
		if has_gravity and use_gravity:
			vel.y += gravity * delta
		var collision = trajectory_body.move_and_collide(vel * delta)
		if collision:
			vel = vel.bounce(collision.get_normal()) * bounce_multiplier
		pos += vel * delta
		trajectory_body.position = pos


func squash(in_deformation: Vector2, out_deformation: Vector2, time_in: float, time_out: float, should_unsquash := true):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(player_sprite.material, "shader_parameter/deformation", in_deformation, time_in)
	if should_unsquash:
		tween.tween_property(player_sprite.material, "shader_parameter/deformation", out_deformation, time_out)


func stun(time = 0.5):
	TimeManager.reset()
	can_jump = false
	has_started_jump = false
	player_sprite.material.set_shader_parameter("flash_strength", 0.7)
	jump_timer.stop()
	jump_timer.start(time)


func kill():
	TimeManager.reset()
	camera.apply_shake(camera.ShakeType.DAMAGE)
	await stop_effect(true)
	await dissolve()
	queue_free()
	emit_signal("died")


func stop_effect(intense: bool):
	if intense:
		camera.apply_shake(camera.ShakeType.DAMAGE)
	else:
		camera.apply_shake(camera.ShakeType.BOUNCE)
	jump_timer.stop()
	velocity = Vector2.ZERO
	use_gravity = false
	can_jump = false
	await get_tree().create_timer(0.05).timeout
	player_sprite.material.set_shader_parameter("flash_strength", 0.7)
	await get_tree().create_timer(0.05).timeout
	player_sprite.material.set_shader_parameter("flash_strength", 0.2)
	await get_tree().create_timer(0.05).timeout
	player_sprite.material.set_shader_parameter("flash_strength", 0.7)
	await get_tree().create_timer(0.05).timeout	
	player_sprite.material.set_shader_parameter("flash_strength", 0.7)
	await get_tree().create_timer(0.05).timeout
	player_sprite.material.set_shader_parameter("flash_strength", 0.2)
	await get_tree().create_timer(0.05).timeout
	use_gravity = true


func dissolve():
	AudioManager.play_sfx(AudioManager.SFX.DISSOLVE)
	camera.apply_shake(camera.ShakeType.DAMAGE)
	jump_timer.stop()
	TimeManager.reset()
	velocity = Vector2.ZERO
	use_gravity = false
	can_jump = false
	animation_player.play("dissolve")
	await animation_player.animation_finished
	use_gravity = true


func assemble():
	AudioManager.play_sfx(AudioManager.SFX.ASSEMBLE)
	player_sprite.material.set_shader_parameter("flash_strength", 0.0)
	squash(Vector2.ZERO, Vector2.ZERO, 0.0, 0.0, true)
	trajectory.clear_points()
	jump_timer.stop()
	TimeManager.reset()
	use_gravity = false
	can_jump = false
	animation_player.play("assemble")
	await animation_player.animation_finished
	can_jump = true
	use_gravity = true
	camera.apply_shake(camera.ShakeType.BOUNCE)


func _jump():
	AudioManager.play_sfx(AudioManager.SFX.BOING)
	camera.zoom = default_zoom
	camera.position = Vector2.ZERO
	animation_player.play("jump")
	can_jump = false
	has_started_jump = false
	player_sprite.material.set_shader_parameter("flash_strength", 0.4)

	jump_timer.stop()
	jump_timer.start(0.3)
	camera.apply_shake(camera.ShakeType.BOUNCE)
	TimeManager.reset()
	trajectory.clear_points()
	velocity = trajectory_direction * trajectory_speed
	squash(jump_squash_deformation, Vector2.ZERO, 0.1, 0.2)


func _start_aim():
	has_started_jump = true
	TimeManager.slow_down()
	mouse_start_pos = get_local_mouse_position()
	squash(jump_aim_squash_deformation, Vector2.ZERO, 0.5 * Engine.time_scale, 0.0, false)


func _update_aim(delta: float):
	camera.stop_shake()
	camera.zoom = camera.zoom.lerp(aim_zoom, 0.05)
	player_sprite.rotation = trajectory_direction.angle() + deg_to_rad(90)
	trajectory_direction = (mouse_start_pos - get_local_mouse_position()).normalized()
	trajectory_speed = clamp(mouse_start_pos.distance_to(get_local_mouse_position()) * jump_multiplier, min_jump_distance, max_jump_distance) as float
	update_trajectory(trajectory_direction, trajectory_speed, delta)
#	Points camera where player is aiming, but effects controls
#	camera.position = trajectory_direction * aim_offset


func _handle_collision(collision: KinematicCollision2D):
	var collider := collision.get_collider() as Node2D
	if collider is Obstacle:
		collider.collide(self)
	camera.apply_shake(camera.ShakeType.BOUNCE)
	AudioManager.play_sfx(AudioManager.SFX.BOUNCE)
	if collider.owner is FoosballPlayer:
		collider.owner.handle_player_collision()
		if !was_kicked:
			was_kicked = true
			animation_player.play("jump")
			kicked_timer.stop()
			kicked_timer.start(0.3)
			stun()
		velocity = velocity.bounce(collision.get_normal()) * kick_multiplier * (max(Settings.get_value(Settings.SECTIONS.Gameplay, Settings.KEYS.Difficulty) * 1.2, 1.0))
		if velocity.length() > max_kick_speed:
			velocity = velocity.normalized() * max_kick_speed
		if velocity.length() < min_kick_speed:
			velocity = velocity.normalized() * min_kick_speed
	else:
		velocity = velocity.bounce(collision.get_normal()) * bounce_multiplier
	if not Input.is_action_pressed("jump"):
		squash(bounce_squash_deformation, Vector2.ZERO, 0.1, 0.2)
	else:
		squash(bounce_squash_deformation, jump_aim_squash_deformation, 0.1, 0.5 * Engine.time_scale)


func _on_jump_timer_timeout():
	player_sprite.material.set_shader_parameter("flash_strength", 0.0)
	can_jump = true
	jump_timer.stop()


func _on_kicked_timer_timeout():
	was_kicked = false
	kicked_timer.stop()
