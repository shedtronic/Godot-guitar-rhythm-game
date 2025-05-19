extends Node2D

# Number of playable strings (6 for standard guitar tuning: E A D G B E)
const STRINGS = 6

# Optional: legacy input keys for manual polling (not used if Input Map is active)
const INPUT_KEYS = ["a", "s", "d", "f", "g", "h"]

# Note fall speed (pixels per second)
const NOTE_SPEED = 300.0

# References to scene nodes
@onready var fretboard := $Fretboard
@onready var hitzone := $HitZone
@onready var color_rect: ColorRect = $HitZone/ColorRect  # Hit zone visual reference

# Each AudioStreamPlayer is mapped to a string index
@onready var audio_players := {
	0: $E_low_player,
	1: $A_player,
	2: $D_player,
	3: $G_player,
	4: $B_player,
	5: $E_high_player,
}

# Holds references to the string lanes (ColorRects) so we can spawn notes above them
var string_nodes = []

# Preloaded note scene (Note.tscn)
var note_scene = preload("res://Note.tscn")

# Static beatmap used for early testing (each note has a time and string index)
var note_chart = [
	{ "time": 0.5, "string": 0 },
	{ "time": 1.0, "string": 1 },
	{ "time": 1.5, "string": 2 },
	{ "time": 2.0, "string": 3 },
	{ "time": 2.5, "string": 4 },
	{ "time": 3.0, "string": 5 },
	{ "time": 3.5, "string": 2 },
	{ "time": 4.0, "string": 3 }
]

# Chart playback state
var chart_index = 0
var song_time = 0.0
var is_playing = false

func _ready():
	is_playing = true

	# Dynamically space the 6 strings evenly across 60% of screen width
	var screen_width = get_viewport_rect().size.x
	var start_x = screen_width * 0.2
	var end_x = screen_width * 0.8
	var spacing = (end_x - start_x) / (STRINGS - 1)

	print("HitZone Y:", $HitZone/ColorRect.global_position.y)

	# Store references to the strings and space them horizontally
	string_nodes.clear()
	string_nodes.append_array([
		$Fretboard/E,
		$Fretboard/A,
		$Fretboard/D,
		$Fretboard/G,
		$Fretboard/B,
		$Fretboard/E2
	])

	for i in STRINGS:
		var string_node = string_nodes[i]
		string_node.position.x = start_x + i * spacing


func _process(delta):
	if is_playing:
		song_time += delta

		# Spawn notes when their scheduled time arrives
		while chart_index < note_chart.size() and note_chart[chart_index]["time"] <= song_time:
			var string_index = note_chart[chart_index]["string"]
			_spawn_note_on_string(string_index)
			chart_index += 1

		# Loop chart for now (good for testing)
		if chart_index >= note_chart.size():
			song_time = 0.0
			chart_index = 0

	# (Legacy key input support - can be removed if Input Map is used exclusively)
	for i in STRINGS:
		if Input.is_action_just_pressed(INPUT_KEYS[i]):
			_check_hit(i)


# Input Map-based key handling (preferred method)
func _input(event):
	if event.is_action_pressed("hit_string_0"):
		_check_hit(0)
	elif event.is_action_pressed("hit_string_1"):
		_check_hit(1)
	elif event.is_action_pressed("hit_string_2"):
		_check_hit(2)
	elif event.is_action_pressed("hit_string_3"):
		_check_hit(3)
	elif event.is_action_pressed("hit_string_4"):
		_check_hit(4)
	elif event.is_action_pressed("hit_string_5"):
		_check_hit(5)


# Spawns a note on the specified string index
func _spawn_note_on_string(index):
	var note = note_scene.instantiate()
	var string_node = string_nodes[index]
	var string_center_x = string_node.global_position.x + (string_node.size.x / 2)
	var string_center_y = string_node.global_position.y

	var hit_y = $HitZone/ColorRect.global_position.y
	note.position = Vector2(string_center_x, string_center_y - 400)  # Start well above screen
	note.target_y = string_center_y
	note.speed = NOTE_SPEED
	note.string_index = index
	note.hit_zone_y = hit_y  # Pass the actual hit zone Y to the note
	add_child(note)


# Check if a player hit was successful, and judge it
func _check_hit(index: int):
	var hit_y = string_nodes[index].global_position.y

	for child in get_children():
		if child is Note and child.string_index == index:
			var distance = abs(child.position.y - hit_y)

			if distance < 10:
				print("Perfect!")
				audio_players[index].play()
				child.queue_free()
				return
			elif distance < 25:
				print("Good!")
				audio_players[index].play()
				child.queue_free()
				return
			elif distance < 40:
				print("Miss!")  # Too far from target, no sound
				child.queue_free()
				return


# Called from Note.gd if auto-play mode is re-enabled
func play_string_sound(index):
	audio_players[index].play()
