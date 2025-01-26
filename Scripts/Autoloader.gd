extends Node

enum SongState {
	CHILL,
	CLOCK,
	TENSE,
	TENSE_TRAP
}

const TIME_TO_DISASTER = 60.0

var bubble_growing :bool = false

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
