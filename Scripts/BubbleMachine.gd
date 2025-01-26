extends Node3D

var activated = false
var entered = false
var items_delivered = 0
var max_items = 3

@onready var message3D = $Message3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if entered && !activated:
		message3D.show()
	else:
		message3D.hide()
	

	if Input.is_action_just_pressed("interact") && activated:
		queue_free()



func _on_area_3d_body_entered(body: Node3D) -> void:
	if "Player" in body.name:
		entered = true
		
		if body.has_water:
			body.has_water = false
			#Play some anim/effect
			items_delivered += 1

		if body.has_oxygen_cylinder:
			body.has_oxygen_cylinder = false
			items_delivered += 1
			#Play some anim/effect
		
		if body.has_soap:
			body.has_soap = false
			items_delivered += 1
			#Play some anim/effect
			
		if items_delivered == max_items:
			activated = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if "Player" in body.name:
		entered = false
