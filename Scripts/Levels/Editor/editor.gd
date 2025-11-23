extends Level
class_name Editor

@export_group("Propertys", "p")
@export_subgroup("Status", "p")

@export_subgroup("Movement", "p")
@export var p_speed: float = 100.0

@onready var camera: Camera2D = $Camera
@onready var ui_mobile: MarginContainer = %Ui_mobile
@onready var blocks: Control = %Blocks
@onready var grid_blocks: GridContainer = %Grid_blocks
@onready var grid: Node2D = $Grid
@onready var block_icon: Sprite2D = $Interface/Show_blocks/Block_icon
@onready var file_dialog: FileDialog = $Interface/FileDialog
@onready var map_name: Label = %MapName

var blockData: Dictionary = {}
var zoom: Vector2 = Vector2.ZERO
var selected_block: ActionButton:
	set(value):
		var old_value: ActionButton = selected_block
		if old_value:
			old_value.self_modulate = Color.WHITE
		selected_block = value
		selected_block.self_modulate = Color.GREEN

func _on_ready_2() -> void:
	## Variables
	#var dataBlocks: Dictionary = {
		#"ground_1": {
			#"texture": 0,
			#"tiles": {
				#0: [0, 0],
				#1: [1, 0],
				#2: [2, 0],
			#}
		#}
	#}
	## End/ Variables
	
	## Adjust icon of block
	block_icon.position = block_icon.get_parent().size / 2.0
	block_icon.scale = Vector2.ONE * block_icon.get_parent().size.x / 40.0
	## End/ Adjust icon of block
	
	blocks.hide()
	map_name.text = (tr("noname") if Global.mapMap == "" else Global.mapMap)
	
	grid_blocks.columns = 10 
	
	## Connect buttons to '_pressed_button'
	for i in get_tree().get_nodes_in_group("button"):
		i.pressed.connect(_pressed_button.bind(i.name.to_lower()))
	## End/ Connect buttons to '_pressed_button'
	
	## Create select blocks to build your map
	#for key in dataBlocks:
		#for tile in dataBlocks[key]["tiles"]:
			#var icon: Sprite2D = Sprite2D.new()
			#var button: ActionButton = preload("res://Scenes/Ui/action_button.tscn").instantiate()
			#if key == "ground_1" and tile == 0:
				#selected_block = button
				#blockData["tile"] = Vector2(dataBlocks[key]["tiles"][tile][0], dataBlocks[key]["tiles"][tile][1])
				#blockData["texture"] = dataBlocks[key]["texture"]
				#block_icon.texture = load(textures[dataBlocks[key]["texture"]])
				#block_icon.region_rect.position = Vector2(dataBlocks[key]["tiles"][tile][0], dataBlocks[key]["tiles"][tile][1]) * 20.0
			#tile = dataBlocks[key]["tiles"][tile]; tile = Vector2(tile[0], tile[1]) * 20.0
			#icon.region_enabled = true
			#icon.region_rect = Rect2(tile.x, tile.y, 20, 20)
			#icon.texture = load(textures[dataBlocks[key]["texture"]])
			#button.p_icon_texture = null
			#button.editor_description = str(dataBlocks[key]["texture"])
			#button.pressed.connect(_select_block.bind(button, tile / 20.0))
			#grid_blocks.add_child(button)
			#button.custom_minimum_size = Vector2.ONE * 40.0
			#icon.position = button.size / 2.0
			#icon.scale = Vector2.ONE * button.size / 40.0
			#button.add_child(icon)
			#await get_tree().physics_frame
	## End/ Create select blocks to build your map
		
	blocks.hide()
	zoom = camera.zoom
	if not Global.mobile():
		ui_mobile.queue_free()
		
func _process(delta: float) -> void:
	if file_dialog.visible:
		return
	
	## Variables
	var wheel: float = Input.get_axis("zoom_dowm", "zoom_up")
	## End/ Variables
	
	## Read editorData
	for obj in Global.editorData.keys():
		for p in Global.editorData[obj]:
			get_node(obj).set(p, Global.editorData[obj][p])
	## End/ Read editorData
	
	## Move camera
	camera.position += Input.get_vector("left", "right", "up", "down") * p_speed * delta / camera.zoom.x * p_speed * delta
	Global.set_value_in_editorData(camera, "Camera", ["position", "zoom"])
	## End/ Move camera
	
	## Zoom
	zoom += Vector2(wheel, wheel) * (delta * 3.0) * camera.zoom.x
	zoom = clamp(zoom, Vector2.ONE / 30.0, Vector2.ONE * 8.0)
	camera.zoom = lerp(camera.zoom, zoom, camera.rotation_smoothing_speed / 20.0)
	## End/ Zoom
	
	if not $Interface/Label.visible:
		return
	
	## Show data
	#$Interface/Label.text = ""
	#for property in data.keys():
		#$Interface/Label.text = $Interface/Label.text + "{0}: {1}\n".format([property, data[property]])
	#$Interface/Label.text = $Interface/Label.text + "\nPos: {0}\nBlockData: {1}\nEditorData: {2}".format([$Select.global_position, blockData, Global.editorData])
	## End/ Show data

func _pressed_button(_T, button: StringName) -> void:
	match button:
		"show_grid":
			grid.visible = not grid.visible
		"export_map":
			if Global.android():
				DisplayServer.file_dialog_show("", "0/storage/emulated", "map{0}.txt".format([randf_range(0, 9000000)]), false, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, (["*.txt"]), _file_android.bind("export"))
			else:
				file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
				file_dialog.show()
		"import_map":
			if Global.android():
				DisplayServer.file_dialog_show("", "0/storage/emulated", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, (["*.txt"]), _file_android.bind("import"))
			else:
				file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
				file_dialog.show()
func _file_android(_status: bool, selected_paths: PackedStringArray, _selected_filter_index: int, type: String) -> void:
	if not selected_paths.is_empty():
		match type:
			"export":
				_export_map(selected_paths[0])
			"import":
				_import_map(selected_paths[0])
	
func _export_map(path: String) -> void:
	var file_path: String = ("{0}/{1}.txt".format([path, randf_range(0, 99999)]) if Global.mapMap == "" else Global.mapMap)
	map_enc.export(file_path, data)
	
func _import_map(file_path: String) -> void:
	map_enc.import(file_path)

func _select_block(_T, button: ActionButton, tile: Vector2i) -> void:
	selected_block = button
	blockData["tile"] = tile
	blockData["texture"] = int(selected_block.editor_description)
	block_icon.texture = load(textures[blockData["texture"]])
	block_icon.region_rect.position = blockData["tile"] * 20.0

func _on_show_blocks_pressed(_action_button: ActionButton) -> void:
	blocks.show()
	if ui_mobile:
		ui_mobile.hide()

func _on_hide_blocks_pressed(_action_button: ActionButton) -> void:
	blocks.hide()
	if ui_mobile:
		ui_mobile.show()

func _on_play_pressed(_action_button: ActionButton) -> void:
	Global.data = data
	Transition.start("run")

func _on_file_dialog_dir_selected(dir: String) -> void:
	_export_map(dir)

func _on_file_dialog_file_selected(path: String) -> void:
	_import_map(path)
