extends Node2D
class_name Level

signal ready2

@export_group("Propertys", "p")
@export var p_run_map: bool = false
@onready var map_enc: MapEnc = %MapEnc
@onready var chunk: Chunk = %Chunk
@onready var player: Character2D = $Player
@onready var map: TileMapLayer = $Map

var data: Dictionary = {}
var textures: Dictionary = {
	0: load("res://Sprites/ground.png")
}

func _ready() -> void:
	## Variabes
	data = Global.data
	## End/ Variabes
	if name == "Editor":
		Global.editor = self
	else:
		Global.level = self
	
	chunk.start(self)
	
	await get_tree().physics_frame
	emit_signal("ready2")
	
	await get_tree().create_timer(Global.get_current_level().chunk.p_distance_size / 10.0).timeout
	player._static = name == "Editor"
