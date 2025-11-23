extends Node
class_name Chunk

@export_range(1, 32, 1) var p_distance_size: int = 8
@export_range(0.1, 2.0, 0.001) var p_delay_check: float = 0.2

var level: Level = null
var timer: Timer = Timer.new()
var chunkData: Dictionary = {}
var chunkState: Dictionary = {}
var chunk_loaded: int = 0
var blocks_to_create: Dictionary = {}
var blocks_to_delete: Array = []
var currentChunk: Vector2 = Vector2.ONE * 100.0

func _delete_blocks() -> void:
	for pos in blocks_to_delete:
		Global.level.map.set_cell(pos, -1)
		chunkState.erase(pos)
		await get_tree().physics_frame
			
func _create_blocks() -> void:
	for pos in blocks_to_create.keys():
		Global.get_current_level().map.set_cell(pos, 0, Vector2i.ZERO)
		await get_tree().physics_frame

func _check_distance() -> void:
	for pos in chunkState.keys():
		if pos.distance_to(Global.level.player.position / 20) > p_distance_size:
			blocks_to_delete.append(pos)
			await get_tree().physics_frame
			
func start(l: Level) -> void:
	level = l
	if level.name.to_lower() in ["editor"]:
		blocks_to_create = Global.data
		_create_blocks()
		return
	chunkData = Global.data.duplicate()
	Global.data.clear()
	_loop()
	timer.timeout.connect(_loop)
	timer.tree_exited.connect(_stop)
	level.add_child(timer)
	timer.start(p_delay_check)
	timer.one_shot = false

func _loop() -> void:
	if Global.level.player.position.distance_to(currentChunk) > 20:
		currentChunk = Global.level.player.position
		for x in range(Global.level.player.position.x / 20 - p_distance_size, Global.level.player.position.x / 20 + p_distance_size + 1):
			for y in range(Global.level.player.position.y / 20 - p_distance_size, Global.level.player.position.y / 20 + p_distance_size + 1):
				var pos: Vector2i = Vector2i(x, y)
				if chunkData.has(pos):
					if not chunkState.has(pos):
						blocks_to_create[pos] = chunkData[pos].duplicate()
						chunkState[pos] = chunkData[pos].duplicate()
		
		if not blocks_to_create.is_empty():
			chunk_loaded += 1
			if chunk_loaded >= 2:
				chunk_loaded = 0
				print(chunk_loaded)
				await _check_distance()
				
		await _delete_blocks()
		await _create_blocks()
		blocks_to_create.clear()
		blocks_to_delete.clear()
	#$"../Player/CanvasLayer/Label".text = str(chunkState)
	
func _stop() -> void:
	timer.stop()
