extends Camera2D


enum ShakeType {
	BOUNCE,
	DAMAGE,
}


@export_category("Bounce shake params")
@export var bounce_shake_speed := 10.0
@export var bounce_shake_strength := 20.0
@export var bounce_shake_decay_rate := 10.0

@export_category("Damage shake params")
@export var damage_shake_speed := 30.0
@export var damage_shake_strength := 60.0
@export var damage_shake_decay_rate := 5.0

@export var noise_frequency := 5.0

var noise_i := 0.0
var current_shake_strength := 0.0
var shake_type: ShakeType


@onready var rand := RandomNumberGenerator.new()
@onready var noise := FastNoiseLite.new()


func _ready():
	rand.randomize()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = rand.randi()
	noise.frequency = noise_frequency


func stop_shake():
	current_shake_strength = 0.0
	

func apply_shake(new_shake_type = ShakeType.BOUNCE):
	match new_shake_type:
		ShakeType.BOUNCE:
			if current_shake_strength < bounce_shake_strength:
				current_shake_strength = bounce_shake_strength
				shake_type = ShakeType.BOUNCE
		ShakeType.DAMAGE:
			shake_type = ShakeType.DAMAGE
			current_shake_strength = damage_shake_strength


func _process(delta: float):
	# Fade out the intensity over time
	match shake_type:
		ShakeType.BOUNCE:
			current_shake_strength = lerp(current_shake_strength, 0.0, bounce_shake_decay_rate * delta)
			offset = get_noise_offset(delta, bounce_shake_speed, current_shake_strength)
		ShakeType.DAMAGE:
			current_shake_strength = lerp(current_shake_strength, 0.0, damage_shake_decay_rate * delta)
			offset = get_noise_offset(delta, damage_shake_speed, current_shake_strength)


func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	if noise_i >= 10000:
		noise_i = 0
	return Vector2(
		noise.get_noise_2d(rand.randi_range(1, 10000), noise_i) * strength,
		noise.get_noise_2d(rand.randi_range(1, 10000), noise_i) * strength
	)


# Temp fix to camera not being removed correctly while waiting for beta18
func _exit_tree() -> void:
	for group in get_groups():
		remove_from_group(group)
