extends MeshInstance3D



@export var final_global_position : = Vector3(0.0,0.0,0.0)
@export var final_scale : = Vector3(115.0,115.0,115.0)
@export var growth_speed = 0.2
@export var move_speed = 0.2

@onready var bubble_growing = false 
@onready var bubble_moving = false
@onready var machine_position =  $"..".position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Atmosphere initial scale ",self.get_scale())
	print("Atmosphere initial size ",self.get_aabb().size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if bubble_growing:
		var growth_vector = Vector3(1,1,1) + Vector3(1,1,1) * growth_speed * delta
		# print("growth_vector ",growth_vector)
		scale_bubble_by(growth_vector)

func move_bubble():
	print("moving bubble up")
	
	# first stage is moving towards the bubble machine door while the door animation plays
	var increments = 1000.0
	var initial_position = self.position
	print("initial position:", initial_position)
	var door_position = initial_position
	door_position.y += 11 # right at the machine's door
	print("move to door position:", door_position)
	for i in range(0,increments):
		var weight :float = i/increments
		self.position = initial_position.lerp(door_position, weight)
		await get_tree().process_frame
	
	# second stage is moving up together with bubble growth
	# tie the position to the radius of the bubble now.
	print("keep moving the bubble steadily up while it grows...")
	while bubble_growing:
		var radius = self.get_aabb().size.y * self.scale.y / 2
		self.position.y = door_position.y + radius - 2
		await get_tree().process_frame

	print("now move it to the center of the planet when it is done")
	initial_position = self.global_position
	for i in range(0, increments):
		var weight :float = i/increments
		self.global_position = initial_position.lerp(Vector3.ZERO, weight)
		await get_tree().process_frame

	bubble_moving = false
	$"../../Instancer_trees".grow_meshes()
	$"../../Instancer_bushes".grow_meshes()
	$"../../Instancer_cacti".grow_meshes()

func start_growth():
	print("started growing the atmospheric bubble")
	bubble_growing = true
	bubble_moving = true
	move_bubble()

func scale_bubble_by(new_scale):
	var current_transform := self.get_transform()
	self.set_transform(current_transform.scaled_local(new_scale))
	#print("Atmosphere scale set to current_transform ",current_transform)
	#print("Atmosphere scale set to get_scale ",self.get_scale())
	if self.get_scale() >= final_scale:
		print("stopped growing the atmospheric bubble")
		bubble_growing = false
	
