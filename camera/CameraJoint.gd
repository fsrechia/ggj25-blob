extends Node3D

@export var mouse_sensitivity := 0.05
@export var pitch_range := Vector2(-80.0, -10.0)

func _ready () -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rotation_degrees.x = pitch_range.x / 5 * 4 + pitch_range.y / 5 * 1

static func get_camera_movement_input() -> Vector2:
	var vector := Vector2(
		Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down"),
		Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right")
	)
	return vector

func _process(delta: float) -> void:
	#if event is InputEventJoypadMotion && (event.axis == JOY_AXIS_RIGHT_X or event.axis == JOY_AXIS_RIGHT_Y):
	var cam_movement: Vector2 = get_camera_movement_input()
	rotation_degrees.x -= cam_movement.x
	rotation_degrees.x = clamp(rotation_degrees.x, pitch_range.x, pitch_range.y)
	
	rotation_degrees.y -=  cam_movement.y
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, pitch_range.x, pitch_range.y)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
