extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Autoloader.bubble_growing:
		grow_bubble()


func grow_bubble():
	var size: Vector3 = self.get_scale()
	size *= 1.02
	self.set_scale(self.get_scale())
	
