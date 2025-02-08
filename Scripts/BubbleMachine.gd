extends Node3D

var activated = false
var entered = false
var items_delivered = 0
var max_items = 3

@onready var player = get_tree().get_first_node_in_group("player")
@onready var WaterDelivered = $WaterDelivered
@onready var SoapDelivered = $SoapDelivered
@onready var CylinderDelivered = $CylinderDelivered
@onready var interaction_area: InteractionArea = $InteractionArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_activate_machine")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if entered && !activated:
	#	message3D.show()
	#else:
	#	message3D.hide()

	#if Input.is_action_just_pressed("interact") && activated:
	#	print("Pressed")
		#WaterDelivered.show()
		#var timer : Timer = Timer.new()
		#add_child(timer)
		#timer.one_shot = true
		#timer.autostart = false
		#timer.wait_time = 2.0
		#timer.timeout.connect(_timer_Timeout)
		#timer.start()
	pass

func _activate_machine():
	print("Activate machine")
	if player.has_water:
		player.has_water = false
		#Play some anim/effect
		items_delivered += 1
	if player.has_oxygen_cylinder:
		player.has_oxygen_cylinder = false
		items_delivered += 1
		
	if player.has_soap:
		player.has_soap = false
		items_delivered += 1
		
	if items_delivered == max_items:
		print("Activated")
		activated = true


func _on_area_3d_body_entered(body: Node3D) -> void:
	print("body entered ", body.name, " with groups ",body.get_groups())
	if body.is_in_group("player"):
		entered = true
		if body.has_water:
			body.has_water = false
			#Play some anim/effect
			items_delivered += 1
			#WaterDelivered.show()
			#var timer : Timer = Timer.new()
			#add_child(timer)
			#timer.one_shot = true
			#timer.autostart = false
			#timer.wait_time = 2.0
			#timer.timeout.connect(_timer_Timeout)
			#timer.start()
			

		if body.has_oxygen_cylinder:
			body.has_oxygen_cylinder = false
			items_delivered += 1
			#CylinderDelivered.show()
			##Play some anim/effect
			#var timer2 : Timer = Timer.new()
			#add_child(timer2)
			#timer2.one_shot = true
			#timer2.autostart = false
			#timer2.wait_time = 2.0
			#timer2.timeout.connect(_timer2_Timeout)
			#timer2.start()
		
		if body.has_soap:
			body.has_soap = false
			items_delivered += 1
			#Play some anim/effect
			#SoapDelivered.show()
			#var timer3 : Timer = Timer.new()
			#add_child(timer3)
			#timer3.one_shot = true
			#timer3.autostart = false
			#timer3.wait_time = 2.0
			#timer3.timeout.connect(_timer3_Timeout)
			#timer3.start()
			
		if items_delivered == max_items:
			print("Activated")
			activated = true

#func _on_area_3d_body_exited(body: Node3D) -> void:
#	if "Player" in body.name:
#		entered = false

#func _timer_Timeout():
#	WaterDelivered.hide()
#func _timer2_Timeout():
#	CylinderDelivered.hide()
#func _timer3_Timeout():
#	SoapDelivered.hide()
