extends Character2D

@onready var ui_mobile: MarginContainer = $CanvasLayer/MarginContainer
@onready var coyote_time: Timer = $Coyote_time
@onready var camera: Camera2D = %Camera

var input_move: int = 0
var _static: bool = true
var can_jump: bool = false

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
	if Input.is_action_just_pressed("jump") and can_jump:
		can_jump = false
		velocity.y = jump_force
	## End/ Jump
	
	## Camera
	camera.position.x = lerpf(camera.position.x, 5.0 * direction, 0.1)
	camera.position.y = lerpf(camera.position.y, (velocity.y / 10.0) - 10.0, 0.05)
	
	move_and_slide()
	_animate()
	
func _animate() -> void:
	if is_on_floor():
		play_anim = ("walk" if input_move else "idle")
	else:
		play_anim = ("jump" if velocity.y < 0.0 else "fall")

func _on_coyote_time_timeout() -> void:
	can_jump = false

func _on_foot_body_entered(_body: Node2D) -> void:
	can_jump = true
	coyote_time.stop()

func _on_foot_body_exited(_body: Node2D) -> void:
	coyote_time.start()
