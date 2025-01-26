extends AudioStreamPlayer

@onready var st = stream as AudioStreamSynchronized
@onready var global = Autoloader

const NORMAL_VOLUME := 0
const MUTE_VOLUME := -60
var t = Timer.new()

func _ready() -> void:
	st.set_sync_stream_volume(global.SongState.CHILL,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.CLOCK,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.TENSE,NORMAL_VOLUME)
	st.set_sync_stream_volume(global.SongState.TENSE_TRAP,MUTE_VOLUME)

	t.start(5.0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
