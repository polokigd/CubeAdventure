extends Node
class_name MapEnc

var file: ConfigFile = ConfigFile.new()

func export(file_path: String, data: Dictionary) -> void:
	## Get map properties to export
	for pos in data.keys():
		file.set_value("Map", str(pos), [data[pos]["tile"], data[pos]["id"]])
	## End/ Get map properties to export
	
	## Get player properties to export
	for p in ["position"]: 
		file.set_value("Player", p, Global.get_current_level().player.get(p))
	## End/ Get player properties to export
	
	## Get information about to export (LOl)
	for i in [["time", Time.get_time_dict_from_system(true)], ["version", ProjectSettings.get_setting("application/config/version")], ["os", OS.get_name().to_lower()], ["day", Time.get_date_dict_from_system(true)]]:
		file.set_value("Info", i[0], i[1])
	## End/ Get information about to export (LOl)
		
	var getDataMap = func() -> String:
		return file.encode_to_text()
		
	print(getDataMap.call())
	
	file.save(file_path)

func import(file_path: String) -> void:
	var new_data: Dictionary = {}
	match  file.load(file_path):
		0:
			## Get blocks
			for pos in file.get_section_keys("Map"):
				var new_pos = pos.split("(")[1].split(")")[0].split(","); new_pos = Vector2i(int(new_pos[0]), int(new_pos[1]))
				var values: Array = file.get_value("Map", pos)
				new_data[new_pos] = {}
				new_data[new_pos] = {
					"tile": values[0],
					"id": values[1],
				}
				#new_data[Vector2i()] = {}
			## End/ Get blocks
			print(new_data)
			Global.data = new_data
			Transition.reload()
			
func _array_to_vector(array: Array) -> Vector2:
	return Vector2(array[0], array[1])
	
func _vector_to_array(vector: Vector2) -> Array:
	return [int(vector.x), int(vector.y)]
