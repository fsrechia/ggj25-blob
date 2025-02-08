extends Node3D

# When the root scene changes using get_tree().change_scene_to_file() or get_tree().change_scene_to_packed() all non-autoload scenes get deleted
# This is a problem for any autoload script that gets nodes with get_tree().get_first_node_in_group() or similar functions
# At this point the fetched node becomes <Freed Object>
# The goal of this fix is to fetch the node from the group again every time the root scene changes
# Unfortunately, there isn't a signal for reacting to root scene changing, so we need to use the node_added signal
@onready var player = get_tree().get_first_node_in_group("player")
@onready var label = $Label

const base_text = "Press Interact Button to "

var active_areas = []
var can_interact = true

func _ready():
	get_tree().node_added.connect(func(_node):
		player = get_tree().get_first_node_in_group("player")
	)

func register_area(area: InteractionArea):
	print("REGISTER AREA")
	active_areas.push_back(area)
	active_areas.sort_custom(_sort_by_distance_to_player)
	
func unregister_area(area: InteractionArea):
	print("UNREGISTER AREA")
	active_areas.erase(area)
	#var index = active_areas.find(area)
	active_areas.sort_custom(_sort_by_distance_to_player)
	#if index != -1:
	#	active_areas.remove_at(index)
		
func _process(delta: float) -> void:
	if active_areas.size() > 0 && can_interact:
		#print("CAN INTERACT")
		
		label.text = base_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position
		#print("POS:", active_areas[0].global_position)
		#print("POS LABEL:", label.global_position)
		#print("LABEL TEXT:", label.text)
		label.global_position.y +=10
		label.global_position.z +=10
		#label.global_position.x += 10
		#print("LABEL POS:",label.global_position)
		label.show()
	else:
		label.hide()

func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = player.global_position.distance_squared_to(area1.global_position)
	var area2_to_player = player.global_position.distance_squared_to(area2.global_position)
	
	return area1_to_player < area2_to_player

func _input(event):
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			print("BUTTON PRESSED")
			await active_areas[0].interact.call()
			
			can_interact = true
