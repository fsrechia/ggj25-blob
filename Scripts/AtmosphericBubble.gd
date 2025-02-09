extends MeshInstance3D

@export var bubble_initial_scale = Vector3(90.0,90.0,90.0)
@export var final_global_position : = Vector3(0.0,0.0,0.0)
@export var final_scale : = Vector3(120.0,120.0,120.0)
@export var growth_speed = 0.02

@onready var bubble_growing = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Atmosphere initial scale ",self.get_scale())
	print("Atmosphere initial size ",self.get_aabb().size)
	self.set_scale(bubble_initial_scale)
	print("Atmosphere scale set to ",self.get_scale())

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if bubble_growing:
		var growth_vector = Vector3(1,1,1) + Vector3(1,1,1) * growth_speed * delta
		# print("growth_vector ",growth_vector)
		scale_bubble_by(growth_vector)

func start_growth():
	print("started growing the atmospheric bubble")
	bubble_growing = true

func scale_bubble_by(new_scale):
	var current_transform := self.get_transform()
	self.set_transform(current_transform.scaled_local(new_scale))
	#print("Atmosphere scale set to current_transform ",current_transform)
	#print("Atmosphere scale set to get_scale ",self.get_scale())
	if self.get_scale() >= final_scale:
		print("stopped growing the atmospheric bubble")
		bubble_growing = false
	
