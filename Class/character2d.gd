extends CharacterBody2D
class_name Character2D

signal charcater_ready

@export_group("Nodes", "n")
@export var n_sprite: Sprite2D
@export var n_animation: AnimationPlayer

@export_subgroup("Character", "n")
@export var n_add_effects: Node2D

@export_group("Propertys", "p")
@export_subgroup("Status", "p")

@export_subgroup("Movement", "p")
@export var p_speed: float = 100.0
@export var p_running_speed: float = 130.0
@export var p_smooth: Dictionary = {
	"stop": 0.5,
	"walk": 0.8,
	"flip": 0.3,
	} 

@export_subgroup("Gravity and jump", "p")
@export var p_jump_height: float = 16.0:
	set(value):
		p_jump_height = value
		_ready()
@export var p_time_jump_apex: float = 0.5:
	set(value):
		p_time_jump_apex = value
		_ready()

var is_ready: bool = false

var jump_force: float = 0.0
var gravity: float = 0.0

var running: bool = false
var direction: int = 1

var play_anim: String:
	set(value):
		var error = false
		if not n_animation: error = true; if not n_animation.has_animation(play_anim): error = true; if not n_animation.current_animation == value: error = true
		if not error:
			play_anim = value
			n_animation.play(play_anim)

func _ready() -> void:
	jump_force = - (p_jump_height * 2) / p_time_jump_apex
	gravity = (p_jump_height * 2) / pow(p_time_jump_apex, 2)
	if not is_ready and is_inside_tree():
		is_ready = true
		charcater_ready.emit()
		
func _has_smooth(keys: Array, add = false) -> bool:
	if add:
		if not _find_keys_array(keys, p_smooth.keys()):
			p_smooth[keys] = null
	else:
		if not _find_keys_array(keys, p_smooth.keys()):
			return false
	return true

func _find_keys_array(array1: Array, array2: Array) -> bool:
	for key in array1:
		if not key in array2:
			return false
	return true

func flip(data: Dictionary) -> void:
	if not n_add_effects:
		return
	if not _find_keys_array(["value", "smooth"], data.keys()):
		return
	n_add_effects.scale.x = lerpf(n_add_effects.scale.x, data.value, p_smooth[data.smooth])
	
func move(data: Dictionary) -> void:
	if _has_smooth([data.smooth]):
		for i in data:
			if i in ["x", "y"]:
				match i:
					"x":
						velocity.x = lerpf(velocity.x, data["x"], p_smooth[data["smooth"]])
					"y":
						velocity.y = lerpf(velocity.y, data["y"], p_smooth[data["smooth"]])
