extends Node3D

@export var countdown_time = Autoloader.TIME_TO_DISASTER
@onready var countdown_label = $TimeRemaining

var time_remaining: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_remaining = countdown_time
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_remaining > 0.0:
		time_remaining -= delta
		var number_text: String = "%0.2f" % time_remaining
		countdown_label.set_text(number_text)
		if time_remaining < (countdown_time / 2) && time_remaining > (countdown_time / 3):
			$ScriptedAudioStream.play_clock()
		if time_remaining < (countdown_time / 3):
			$ScriptedAudioStream.play_tense()
	else:
		countdown_label.set_text("0.00")		
