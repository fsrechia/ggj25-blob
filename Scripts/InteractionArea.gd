extends Area3D
class_name InteractionArea

@export var action_name: String = "interact"

var interact: Callable = func ():
	pass


func _on_body_entered(body: Node3D) -> void:
	print("ENTERED; REGISTER")
	InteractionManager.register_area(self)

func _on_body_exited(body: Node3D) -> void:
	print("EXITED; UNREGISTER")
	InteractionManager.unregister_area(self)
