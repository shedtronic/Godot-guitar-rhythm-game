extends Node2D
class_name Note
var speed = 300.0
var target_y = 0.0
var string_index = 0

func _process(delta):
	position.y += speed * delta
	if position.y > 800:
		queue_free()
