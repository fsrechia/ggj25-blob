extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	print(self.name, " - body entered: ", body.name, " with groups: ", body.get_groups())
	if body.is_in_group("player"):
		print("picked ", self.name)
		var item = Autoloader.ItemType.NONE
		if is_in_group("WaterItem"):
			body.has_water = true
			item = Autoloader.ItemType.WATER
		elif is_in_group("OxygenItem"):
			body.has_oxygen_cylinder = true
			item = Autoloader.ItemType.OXYGEN
		elif is_in_group("SoapItem"):
			body.has_soap = true
			item = Autoloader.ItemType.SOAP
			
		if item != Autoloader.ItemType.NONE:
			CustomSignals.item_collected.emit(item)
		#Play SFX
		queue_free()
