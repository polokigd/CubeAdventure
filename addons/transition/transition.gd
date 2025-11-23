extends CanvasLayer

@export_group("Propertys", "p")
@export var p_delay: float = 0.45
@export var p_scenes: Dictionary = {
	"your_scene": "path"
}
@onready var animation: AnimationPlayer = $Animation

var value: Variant = null
var is_playing: bool = false

func start(v: Variant) -> void:
	if not is_playing:
		is_playing = true
		value = v
		animation.play("start")

func quit() -> void:
	start("quit")

func reload() -> void:
	start("reload")

func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name != "end":
		animation.play("end")
		if not value in ["reload", "quit"]:
			if not value == null:
				if value is String:
					if value in p_scenes.keys():
						get_tree().change_scene_to_file(p_scenes[value])
					else:
						get_tree().change_scene_to_file(value)
				elif value is PackedScene:
					get_tree().change_scene_to_packed(value)
		else:
			match value:
				"reload":
					get_tree().reload_current_scene()
				"quit":
					get_tree().quit()
		get_tree().paused = false
	await get_tree().create_timer(p_delay).timeout
	is_playing = false
