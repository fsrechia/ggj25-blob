extends Node

const PLANET_SCENE = preload("res://Scenes/PlanetScene.tscn")
const CREDITS = preload("res://Scenes/Menus/Credits/Credits.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(PLANET_SCENE)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_packed(CREDITS)


func _on_quit_pressed() -> void:
	get_tree().quit()
