extends Node2D
class_name FoosballPlayer

var head_tween: Tween
var body_tween: Tween
var should_kick := false

@onready var head := $Head as Node2D
@onready var body := $Body as StaticBody2D
@onready var kick_timer := $KickTimer as Timer
@onready var collision_shape := $Body/CollisionShape2D as CollisionShape2D
@onready var kick_particles := $CPUParticlesKick as CPUParticles2D


func start_kicking():
	kick_timer.stop()
	kick_timer.start(1.0)


func stop_kicking():
	kick_timer.stop()


func kick():
	if head_tween:
		head_tween.kill()
	head_tween = create_tween()
	head_tween.tween_property(head, "position", Vector2(0, 20), 0.2)
	head_tween.tween_property(head, "position", Vector2(0, -20), 0.1)
	head_tween.tween_property(head, "position", Vector2(0, 0), 0.4)
	
	if body_tween:
		body_tween.kill()
	body_tween = create_tween()
	body_tween.tween_property(body, "position", Vector2(0, -40), 0.2)
	body_tween.tween_property(body, "position", Vector2(0, 60), 0.1)
	body_tween.tween_property(body, "position", Vector2(0, 0), 0.4)


func handle_player_collision():
	kick_particles.emitting = true
	collision_shape.disabled = true
	await get_tree().create_timer(0.15).timeout
	collision_shape.disabled = false


func get_width() -> float:
	return $Body/ColorRect.size.x


func _on_kick_timer_timeout():
	kick()
	kick_timer.start(1.0)
