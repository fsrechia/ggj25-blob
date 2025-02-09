extends MeshInstance3D

@export var initial_scale = Vector3(100.0,100.0,100.0)
@export var final_global_position : = Vector3(0.0,0.0,0.0)
@export var final_scale : = Vector3(110.0,110.0,110.0)
@export var growth_speed = 105.0

@onready var bubble_growing = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Atmosphere initial scale ",self.get_scale())
	print("Atmosphere initial size ",self.get_aabb().size)
	self.set_scale(initial_scale)
	print("Atmosphere scale set to ",self.get_scale())
	start_growth()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if bubble_growing:
		grow_bubble_by(growth_speed * delta * Vector3(1.0,1.0,1.0))

func start_growth():
	print("started growing the atmospheric bubble")
	bubble_growing = true

func grow_bubble_by(x):
	var current_scale := self.get_scale()
	current_scale += x
	self.set_scale(self.get_scale())
	print("Atmosphere scale set to current_scale ",current_scale)
	if current_scale >= final_scale:
		print("stopped growing the atmospheric bubble")
		bubble_growing = false
	
