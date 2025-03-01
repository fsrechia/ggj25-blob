extends CharacterBody3D

@export var speed := 14.0
@export var jump_strength := 10.0

@export var velocity_control_floor := 50.0
@export var velocity_control_air := 5.0

@export var torque_control_floor := 10.0
@export var torque_control_air := 1.0

@export var health : int

@onready var _balance_point: BalancePoint = $BalancePoint
@onready var _camera_anchor: CameraAnchor = $CameraAnchor

@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var healthbar = $CanvasLayer/HealthBar
@onready var hurt_box: Area3D = $HurtBox


var has_water := false
var has_oxygen_cylinder := false
var has_soap := false

func _ready():
	health = 100
	healthbar.init_health(health)

static func get_movement_input() -> Vector2:
	var vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("back") - Input.get_action_strength("forward")
	)
	if vector.length_squared() > 1:
		return vector.normalized()  # e.g. keyboard input
	else:
		return vector


static func project_movement_intention(basis: Basis, up: Vector3, movement_input: Vector2) -> Vector3:
	if movement_input == Vector2.ZERO:
		return Vector3.ZERO

	movement_input = movement_input.normalized() * min(movement_input.length(), 1)

	var up_surface = -up.cross(basis.x).normalized()
	var right_surface = -up.cross(basis.y).normalized()
	
	return up_surface * movement_input.y + right_surface * movement_input.x


func _physics_process(delta: float) -> void:
	# Update where we are
	_camera_anchor.target_origin = _balance_point.global_transform.origin
		
	var acceleration := _balance_point.acceleration
	if acceleration == Vector3.ZERO:
		# Weeee floating in free space!
		move_and_slide()
		return
	
	# Because we have it, update where up / down is
	_camera_anchor.target_down = _balance_point.down
	set_up_direction(_balance_point.up)

	# What controls is the player inputting?
	var movement_input := get_movement_input()


	# Where does the player want to move?
	var movement_intention := project_movement_intention(
		get_viewport().get_camera_3d().global_transform.basis,
		_balance_point.up,
		movement_input
	)
	if movement_intention != Vector3.ZERO:
		$AnimationTree.set("parameters/movements/transition_request", "walk")
	else:
		$AnimationTree.set("parameters/movements/transition_request", "idle")

	# How much control does the player get over the character?
	var current_velocity_control: float
	var current_torque_control: float
	if self.is_on_floor():
		$AnimationTree.set("parameters/in_air/transition_request", "false")
		current_velocity_control = velocity_control_floor
		current_torque_control = torque_control_floor
	else:
		#$AnimationTree.set("parameters/in_air/transition_request", "floating")
		current_velocity_control = velocity_control_air
		current_torque_control = torque_control_air
	
	# Jumping
	self._process_jumping()
	
	# Walking
	_process_walking(movement_intention, current_velocity_control * delta)
	
	# Forces acting on us
	velocity += acceleration * delta
	
	# Finally, we move!
	move_and_slide()
	
	# ... and turn
	_process_turning(movement_intention, current_torque_control * delta)


func _process_jumping():
	var up := _balance_point.up
	
	var is_jumping := self.is_on_floor() and Input.is_action_just_pressed( "jump")
	if is_jumping:
		velocity += up * jump_strength - velocity.project(up)
		$AnimationTree.set("parameters/in_air/transition_request", "true")

	

func _process_walking(movement_intention: Vector3, control: float):
	var up := _balance_point.up

	var desired_velocity_change :Vector3 = movement_intention * speed - velocity
	# Just in case: delete "up" component.
	# If we didn't do this, we would stay levitating in the air.
	desired_velocity_change -= desired_velocity_change.project(up)



	velocity = velocity.move_toward(
		velocity + desired_velocity_change,
		 control
	)


func _process_turning(movement_intention: Vector3, control: float):
	var forward := -transform.basis.z
	var up := _balance_point.up
	
	var look_intention_horizontal: Vector3
	if movement_intention != Vector3.ZERO:
		look_intention_horizontal = Vector3(-movement_intention.x, movement_intention.y, -movement_intention.z)
	else:
		# If the player provides no input, we want to turn forward, parallel to the floor.
		look_intention_horizontal = forward - forward.project(up)
	
	var look_intention := Basis.IDENTITY.looking_at(look_intention_horizontal, up)
	transform = Transform3D(
		transform.basis.slerp(look_intention, control).orthonormalized(),
		transform.origin
	)

func player_death():
	#TODO: Play death anim
	hurt_box.set_block_signals(true)
	
	#queue_free()
	#TODO: Generate some code to get when player died, to call GameOver Screen

func update_health(value: int) -> void:
	health -= value
	healthbar.health = health
	
	if health <= 0:
		player_death()
	

func _on_hurt_box_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		print("Enemy entered, damage:", body.damage_amount)
		update_health(body.damage_amount)
	
