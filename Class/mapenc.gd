extends Node
class_name MapEnc

var key: String = "batata com azeitona é muito bom!"

func export(file_path: String, data: Dictionary) -> void:
	var new_data: Array = []
	if Global.mobile():
		OS.alert(file_path)
	for pos in data.keys():
		var propertys: Array = []
		for p in data[pos].keys():
			var value: Variant = data[pos][p]
			if p in ["tile"]:
				match p:
					"tile":
						propertys.append([value.x, value.y])
			else:
				propertys.append(value)
		new_data.append([[pos.x, pos.y], propertys])
	FileAccess.open(file_path, FileAccess.WRITE).store_string(str(new_data))

func import(file_path: String) -> void:
	var new_data: Dictionary = {}
	for list in JSON.parse_string(FileAccess.open(file_path, FileAccess.READ).get_as_text()):
		var pos: Vector2i = _get_vector(list[0])
		new_data[pos] = {}
		new_data[pos]["tile"] = _get_vector(list[1][0])
		new_data[pos]["id"] = list[1][1]
	Global.mapMap = file_path.split("/")[file_path.count("/")]
 	#if Global.data != new_data:
	Global.data = new_data
	Transition.reload()

func _get_vector(array: Array) -> Vector2i:
	return Vector2i(array[0], array[1])
