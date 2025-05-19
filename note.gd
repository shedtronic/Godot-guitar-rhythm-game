
extends Node2D
class_name Note

# Controls the behavior of a single falling note (arrow) in the rhythm game

# Speed at which the note moves down the screen (pixels per second)
var speed = 300.0

# The Y-coordinate where this note is expected to reach (usually aligned with the string on the fretboard)
var target_y = 0.0

# Index of the string this note belongs to (0 = low E, up to 5 = high E)
var string_index = 0

# Tracks whether the note has already triggered a sound or judgment (for future use, like auto-miss)
var has_triggered_sound = false

# The global Y-position of the hit zone, passed in when the note is spawned (used for timing checks)
var hit_zone_y = 0.0

# Optional: Direct reference to the hit zone ColorRect, currently unused but could be used for alignment or debug
@onready var color_rect: ColorRect = $"../Fretboard/HitZone/ColorRect"

func _process(delta):
	# Move the note down each frame
	position.y += speed * delta

	# Automatically delete the note once it's off-screen
	# This also acts as a "miss" if the player fails to hit it in time
	if position.y > get_viewport_rect().size.y:
		queue_free()

# Called from Main.gd when the player successfully hits this note
# Responsible for playing the correct string's sound
func trigger_sound():
	get_parent().play_string_sound(string_index)
