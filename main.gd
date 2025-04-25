extends Node2D

const STRINGS = 6
const INPUT_KEYS = ["a", "s", "d", "f", "g", "h"]
const NOTE_SPEED = 300.0

@onready var fretboard := $Fretboard
@onready var hitzone := $HitZone
@onready var audio_players := {
	0: $Audio/E_low_player,
	1: $Audio/A_player,
	2: $Audio/D_player,
	3: $Audio/G_player,
	4: $Audio/B_player,
	5: $Audio/E_high_player,
}

var note_scene = preload("res://Note.tscn")

# Beatmap: array of { time, string } entries
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

var chart_index = 0
var song_time = 0.0
var is_playing = false

func _ready():
	is_playing = true
	# You could also start an AudioStreamPlayer here if you want to sync audio

func _process(delta):
	if is_playing:
		song_time += delta
		# spawn notes at scheduled times
		while chart_index < note_chart.size() and note_chart[chart_index]["time"] <= song_time:
			var string_index = note_chart[chart_index]["string"]
			_spawn_note_on_string(string_index)
			chart_index += 1

	# Check for player input
	for i in STRINGS:
		if Input.is_action_just_pressed(INPUT_KEYS[i]):
			_check_hit(i)

func _spawn_note_on_string(index):
	var note = note_scene.instantiate()
	var string_pos = fretboard.get_child(index).global_position
	note.position = string_pos - Vector2(0, 400)
	note.target_y = string_pos.y
	note.speed = NOTE_SPEED
	note.string_index = index
	add_child(note)

func _check_hit(index: int):
	for child in get_children():
		if child is Note and child.string_index == index:
			if abs(child.position.y - fretboard.get_child(index).global_position.y) < 20:
				print("Hit string ", index)
				child.queue_free()
				audio_players[index].play()
				return
