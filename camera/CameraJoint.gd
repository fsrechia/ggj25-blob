extends Node3D

@export var mouse_sensitivity := 0.05
@export var pitch_range := Vector2(-80.0, -10.0)

func _ready () -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	rotation_degrees.x = pitch_range.x / 5 * 4 + pitch_range.y / 5 * 1

static func get_camera_movement_input() -> Vector2:
	var vector := Vector2(
		Input.get_action_strength("cam_left") - Input.get_action_strength("cam_right"),
		Input.get_action_strength("cam_up") - Input.get_action_strength("cam_down")
	)
	return vector
	
func _rotate_camera(movement: Vector2, sensitivity: float):
	rotation_degrees.x -= movement.y * sensitivity
	rotation_degrees.x = clamp(rotation_degrees.x, pitch_range.x, pitch_range.y)
	rotation_degrees.y -= movement.x * sensitivity
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)

func _process(delta: float) -> void:
	var cam_movement: Vector2 = get_camera_movement_input()
	_rotate_camera(cam_movement, 1.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_rotate_camera(event.relative, mouse_sensitivity)
