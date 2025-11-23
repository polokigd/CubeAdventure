@tool
extends TextureRect
class_name ActionButton

signal pressed(action_button: ActionButton)
signal released(action_button: ActionButton)

@export_group("Propertys", "p")
@export_subgroup("Main", "p")
@export_subgroup("Input", "p")
@export var p_input: StringName = ""
	#set(value):
		#p_input = value
		#if not p_input.is_empty():
			#if is_inside_tree(): name = p_input.to_upper().substr(0, 1) + p_input.to_lower().substr(1, p_input.length())
@export var p_passby_press: bool = false

@export_subgroup("Textures", "p_texture")
@export var p_texture_normal: Texture2D:
	set(value): p_texture_normal = value; texture = p_texture_normal
@export var p_texture_pressed: Texture2D

@export_subgroup("Touch")
@export_subgroup("Touch/Normal", "p_touch_normal")
@export var p_touch_normal_color: Color = Color.WHITE
@export_subgroup("Touch/Pressed", "p_touch_pressed")
@export var p_touch_pressed_color: Color = Color(1.0, 1.0, 1.0, 0.5)

@export_subgroup("Icon", "p_icon")
@export var p_icon_active_region: bool = true:
	set(value):
		p_icon_active_region = value
		_update_icon()
		notify_property_list_changed()
@export var p_icon_position: Vector2 = Vector2.ZERO:
	set(value):
		p_icon_position = value
		_update_icon()
@export var p_icon_rotation: float:
	set(value):
		p_icon_rotation = value
		_update_icon()
@export_custom(PROPERTY_HINT_LINK, "") var p_icon_scale: Vector2 = Vector2.ONE:
	set(value):
		p_icon_scale = value
		_update_icon()
@export var p_icon_region: Rect2:
	set(value):
		p_icon_region = value
		_update_icon()
@export var p_icon_texture: Texture2D:
	set(value):
		p_icon_texture = value
		_update_icon()

var can_change_icon_property: bool = true
var icon: Sprite2D = Sprite2D.new()
var index_touch: int = - 1:
	set(value):
		if is_inside_tree():
			index_touch = value
			if index_touch != - 1: pressed_ = true
			else: pressed_ = false
var pressed_: bool:
	set(value):
		pressed_ = value
		if is_inside_tree() and InputMap.has_action(p_input):
			if pressed_:
				emit_signal("pressed", self)
				Input.action_press(p_input)
			else:
				emit_signal("released", self)
				Input.action_release(p_input)
		
		modulate = (p_touch_normal_color if not pressed_ else p_touch_pressed_color)
		if pressed_:
			if p_texture_pressed:
				texture = p_texture_pressed
		else:
			if p_texture_normal:
				texture = p_texture_normal
		
func _ready() -> void:
	for i in get_children():
		if i.name in ["Icon"]:
			i.queue_free()
	icon.name = "Icon"
	resized.connect(_update_icon)
	add_child(icon)
	add_to_group("ksjaiai298")
	_update_icon()
	modulate = p_touch_normal_color
	if p_texture_normal:
		texture = p_texture_normal

func _update_icon() -> void:
	if can_change_icon_property:
		if icon.is_inside_tree():
			icon.region_enabled = p_icon_active_region
			icon.region_rect = p_icon_region
			icon.position = size / 2.0 + p_icon_position
			icon.scale = p_icon_scale
			icon.rotation_degrees = p_icon_rotation
			icon.texture = p_icon_texture
			can_change_icon_property = false
			await get_tree().physics_frame
			can_change_icon_property = true
	
func _input(event: InputEvent) -> void:
	if visible and is_visible_in_tree():
		if event is InputEventScreenTouch:
			if event.is_pressed():
				if get_global_rect().has_point(event.position):
					index_touch = event.index
					get_viewport().set_input_as_handled()
					pressed.emit(self)
			else:
				if index_touch == event.index:
					index_touch = -1
					released.emit(self)
		elif event is InputEventScreenDrag:
			if p_passby_press:
				if get_global_rect().has_point(event.position): index_touch = event.index
				elif not get_global_rect().has_point(event.position) and index_touch == event.index: index_touch = - 1

func _validate_property(property: Dictionary) -> void:
	match p_icon_active_region:
			false:
				if property.name == "p_icon_region":
					property["usage"] = PROPERTY_USAGE_NONE
			
