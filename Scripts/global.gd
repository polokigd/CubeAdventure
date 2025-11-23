extends Node

@export_group("Propertys")
@export_enum("get", "pc", "mobile", "linux", "windows", "android") var platform: String = "get"

var level: Level = null
var editor: Editor = null
var data: Dictionary = {}
var editorData: Dictionary = {}
var mapMap: String = ""

func _ready() -> void:
	OS.request_permissions()
	clear_editorData()
	#OS.alert(OS.get_name())
	if platform == "get":
		platform = OS.get_name().to_lower()
		if platform in ["linux", "windows"]:
			platform = "pc"
		elif platform in ["android"]:
			platform = "mobile"
	#OS.alert(platform)

func set_value_in_editorData(object: Node2D, key: String, propertys: Array) -> void:
	for p in propertys:
		editorData[key][p] = object.get(p)

func get_current_level() -> Level:
	return get(("level" if Global.level else "editor"))
func clear_editorData() -> void:
	editorData = {
		"Select": {
			"position": Vector2(-20.0, -19.5)
		},
		"Camera": {
			"position": -Vector2.ONE * 10.0
		}
	}

func pc() -> bool:
	if platform == "pc":
		return true
	return false

func mobile() -> bool:
	if platform == "mobile":
		return true
	return false

func android() -> bool:
	if OS.get_name().to_lower() == "android":
		return true
	return false
	
func linux() -> bool:
	if OS.get_name().to_lower() == "linux":
		return true
	return false
	
func windows() -> bool:
	if OS.get_name().to_lower() == "windows":
		return true
	return false

func linux_or_windows() -> bool:
	if OS.get_name().to_lower() in ["linux", "windows"]:
		return true
	return false

func _input(event: InputEvent) -> void:
	var key: String = ""
	if linux_or_windows():
		if event is InputEventKey:
			if not get_tree().current_scene or Transition.visible:
				return
			key = event.as_text_keycode().to_lower()
	match key:
		"escape":
			if _get_current_scene() == "run":
				_play_scene("editor")

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if _get_current_scene() == "run" and get_tree().current_scene:
			_play_scene("editor")

func _get_current_scene() -> String:
	if not get_tree().current_scene:
		return ""
	return get_tree().current_scene.name.to_lower()

func _play_scene(scene: String) -> void:
	Transition.start(scene)
	if _get_current_scene() != "eidtor":
		data = level.chunk.chunkData.duplicate()
		level.chunk.chunkData.clear()
