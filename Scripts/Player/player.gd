extends Character2D

@onready var ui_mobile: MarginContainer = $CanvasLayer/MarginContainer

var input_move: int = 0
var _static: bool = true

func _on_charcater_ready() -> void:
	if not Global.mobile():
		for node in [ui_mobile]:
			node.queue_free()
	
func _physics_process(delta: float) -> void:
	if _static: return
	
	## Variables
	var smooth_move: StringName = ("walk" if input_move else "stop")  
	input_move = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	if input_move:
		direction = input_move
	## End/ Variables
	
	## Walk
	move({"x": input_move * p_speed, "smooth": smooth_move})
	n_sprite.scale.x = direction
	## End/ Walk
	
	## Gravity
	if not is_on_floor():
		velocity.y += gravity * delta * (2.0 if velocity.y > -10.0 else 1.0)
	## End/ Gravity
	
	## Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	## End/ Jump
	
	move_and_slide()
	_animate()
	
func _animate() -> void:
	if is_on_floor():
		play_anim = ("walk" if input_move else "idle")
	else:
		play_anim = ("jump" if velocity.y < 0.0 else "fall")
