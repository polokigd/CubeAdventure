@tool
extends EditorPlugin

func _enable_plugin() -> void:
	add_autoload_singleton("Transition", "res://addons/transition/transition.tscn")
	
func _disable_plugin() -> void:
	remove_autoload_singleton("Transition")
