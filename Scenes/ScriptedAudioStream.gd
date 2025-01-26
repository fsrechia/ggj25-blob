extends AudioStreamPlayer

@onready var st = stream as AudioStreamSynchronized
@onready var global = Autoloader

const NORMAL_VOLUME := 0
const MUTE_VOLUME := -60
var t = Timer.new()

func _ready() -> void:
	play_chill()

func play_chill() -> void:
	st.set_sync_stream_volume(global.SongState.CHILL,NORMAL_VOLUME)
	st.set_sync_stream_volume(global.SongState.CLOCK,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.TENSE,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.TENSE_TRAP,MUTE_VOLUME)

func play_clock() -> void:
	st.set_sync_stream_volume(global.SongState.CHILL,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.CLOCK,NORMAL_VOLUME)
	st.set_sync_stream_volume(global.SongState.TENSE,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.TENSE_TRAP,MUTE_VOLUME)

func play_tense() -> void:
	st.set_sync_stream_volume(global.SongState.CHILL,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.CLOCK,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.TENSE,NORMAL_VOLUME)
	st.set_sync_stream_volume(global.SongState.TENSE_TRAP,MUTE_VOLUME)

func play_trap() -> void:
	st.set_sync_stream_volume(global.SongState.CHILL,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.CLOCK,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.TENSE,MUTE_VOLUME)
	st.set_sync_stream_volume(global.SongState.TENSE_TRAP,NORMAL_VOLUME)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
