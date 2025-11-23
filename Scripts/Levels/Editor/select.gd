extends Node2D

func _set_pos() -> void:
	position = get_global_mouse_position().snapped(Vector2(20.0, 20.0)).floor()
	Global.set_value_in_editorData(self, "Select", ["position"])

func _get_pos() -> Vector2i:
	return position

func _create_block() -> void:
	var pos: Vector2i = _get_pos() / 20
	if not _has_block():
		Global.editor.data[pos] = {}
		for p in Global.editor.blockData.keys():
			Global.editor.data[pos][p] = Global.editor.blockData[p]
		Global.editor.map.set_cell(pos, Global.editor.blockData["id"], Global.editor.blockData["tile"])
	else:
		Global.editor.map.set_cell(pos, -1)
		Global.editor.data.erase(pos)

func _has_block() -> bool:
	var pos: Vector2i = _get_pos() / 20
	for i in Global.editor.data.keys():
		if i == pos:
			return true
	return false

func _input(event: InputEvent) -> void:
	if Global.editor.blocks.visible: return
	if Global.pc():
		if event is  InputEventMouse:
			if event.is_pressed():
				if event.button_mask == 1:
					_create_block()
				elif event.button_mask == 2:
					_set_pos()
	elif Global.mobile():
		if event is InputEventScreenTouch:
			if event.is_pressed():
				await get_tree().physics_frame
				_set_pos()
				
func _on_create_block_pressed(_T) -> void:
	_create_block()
