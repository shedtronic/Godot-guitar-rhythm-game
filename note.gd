extends Node2D
class_name Note

var speed = 300.0
var target_y = 0.0
var string_index = 0
var has_triggered_sound = false
@onready var color_rect: ColorRect = $"../Fretboard/HitZone/ColorRect"
var hit_zone_y = 0.0



func _process(delta):
	position.y += speed * delta

	if position.y > get_viewport_rect().size.y:
		queue_free()



func trigger_sound():
	get_parent().play_string_sound(string_index)
