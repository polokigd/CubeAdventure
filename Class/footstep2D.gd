@tool
extends Node
class_name FootSteps2D

enum types {Normal, Advance}

@export_group("Nodes", "n")
@export var n_sound: AudioStreamPlayer = null
@export var n__sound: AudioStreamPlayer2D = null

@export_group("Propertys", "p")
@export var p_type: types = 0:
	set(value):
		p_type = value
		notify_property_list_changed()
@export var p_id: String = "id"
@export var p_sounds: Dictionary = {
	"id": {
		"active": 10,
		"sound": "path",
		"loop_perfect": true,
	}
}

var footstep: int = 0

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not p_id in p_sounds.keys(): return
	var properys: Dictionary = p_sounds[p_id]
	if footstep == 0 or footstep > properys["active"]:
		var audio = (n_sound if p_type == types.Normal else n__sound)
		
		if footstep != 0: footstep = 0
		audio.stream = load(properys["path"])
		if "loop_perfect" in properys:
			if properys["loop_perfect"]:
				audio.stop()
		audio.play()
	print(footstep)
		
func _validate_property(property: Dictionary) -> void:
	if property.name in ["n_sound", "n__sound"]:
		match p_type:
			0:
				if property.name == "n__sound":
					property.usage = PROPERTY_USAGE_NO_EDITOR
			1:
				if property.name == "n_sound":
					property.usage = PROPERTY_USAGE_NO_EDITOR
