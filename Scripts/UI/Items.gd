extends CanvasLayer

@onready var soap_label: Label = $GridContainer/SoapLabel
@onready var water_label: Label = $GridContainer/WaterLabel
@onready var oxygen_label: Label = $GridContainer/OxygenLabel

var max_items = 1
var item_initial_value = 0
var base_text = " / " +  str(max_items)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	soap_label.text = str(item_initial_value) + base_text
	water_label.text = str(item_initial_value) + base_text
	oxygen_label.text = str(item_initial_value) + base_text
	
	CustomSignals.item_collected.connect(_on_item_collected)

func _on_item_collected(item: Autoloader.ItemType) -> void:
	if item == Autoloader.ItemType.SOAP:
		soap_label.text = str (max_items) + base_text
	elif item == Autoloader.ItemType.WATER:
		water_label.text = str (max_items) + base_text
	elif item == Autoloader.ItemType.OXYGEN:
		oxygen_label.text = str (max_items) + base_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
