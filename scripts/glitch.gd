extends Control
class_name Glitch


@export var rand_interval: Vector2 = Vector2(3, 5)
@export var rand_duration: Vector2 = Vector2(0.1, 0.25)

var timer: float = 0
var is_glitching = false
var shader_mat: ShaderMaterial


func _ready() -> void:
	material = material.duplicate()
	shader_mat = material


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		if is_glitching:
			# wait for next glitch
			timer = randf_range(rand_interval.x, rand_interval.y)
			shader_mat.set_shader_parameter("enable_shift", 0.0)
		else:
			# start glitching
			timer = randf_range(rand_duration.x, rand_duration.y)
			shader_mat.set_shader_parameter("enable_shift", 1.0)
		is_glitching = not is_glitching
