extends Node2D

@export_group("Propertys", "p")
@export var p_grid_size: int = 20
@export var p_size: int = 20
@export var p_width: int = 2
@export var p_color: Color = Color.WHITE

@onready var camera: Camera2D = $"../Camera"

func _ready() -> void:
	for x in range(-p_grid_size, p_grid_size + 1):
		var line: Line2D = Line2D.new()
		line.points = [Vector2(x * p_grid_size, -300.0), Vector2(x * p_grid_size, 300.0)]
		line.width = p_width
		line.default_color = p_color
		add_child(line)
	for y in range(-p_grid_size, p_grid_size + 1):
		var line: Line2D = Line2D.new()
		line.points = [Vector2(-300.0, y * p_grid_size), Vector2(300.0, y * p_grid_size)]
		line.width = p_width
		line.default_color = p_color
		add_child(line)

func _process(_delta: float) -> void:
	if not visible:
		return
	var target_position: Vector2 = camera.position.snapped(Vector2(p_size, p_size)) + Vector2(0.0, p_size / 2.0)
	position = target_position
