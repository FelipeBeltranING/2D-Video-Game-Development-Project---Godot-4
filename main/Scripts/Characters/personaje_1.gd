extends CharacterBody2D

@export var SPEED := 100
var can_move := true

@export var max_dashes := 5
@export var dash_recharge_time := 2
@export var dash_duration := 0.20
@export var dash_speed := 600.0
@export var dash_cooldown := 2

var dash_count := max_dashes
var is_dashing := false
var dash_direction := Vector2.ZERO
var recharge_queue := 0
var is_recharging := false

@onready var colorprueba := $CollisionShape2D

func _physics_process(delta: float) -> void:
	
	if is_dashing:
		velocity = dash_direction * dash_speed
		move_and_slide()
		return
		
	if can_move:
		handle_movement()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

	update_animation()

	if Input.is_action_just_pressed("Movilidad"):
		start_dash()
		
# --------------------
# MOVIMIENTO
# --------------------
func handle_movement():
	velocity = get_input_direction() * SPEED
	move_and_slide()

func get_input_direction() -> Vector2:
	return Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")

# --------------------
# DASH
# --------------------
func start_dash():
	if dash_count <= 0 or is_dashing:
		return

	dash_count -= 1
	recharge_queue += 1

	is_dashing = true

	dash_direction = get_input_direction()
	if dash_direction == Vector2.ZERO:
		dash_direction = (get_global_mouse_position() - global_position).normalized()

	can_move = false

	await get_tree().create_timer(dash_duration).timeout

	is_dashing = false
	can_move = true
	velocity = Vector2.ZERO

	# 🔁 Si no hay recarga activa, empieza
	if not is_recharging:
		process_recharge_queue()


func process_recharge_queue():
	if recharge_queue <= 0:
		is_recharging = false
		return

	is_recharging = true

	await get_tree().create_timer(dash_recharge_time).timeout

	dash_count = min(dash_count + 1, max_dashes)
	recharge_queue -= 1

	process_recharge_queue()



# --------------------
# DIRECCIÓN (MOUSE)
# --------------------
func get_aim_angle() -> float:
	var dir = get_global_mouse_position() - global_position
	return rad_to_deg(dir.angle())

func get_facing_direction() -> String:
	var angle = get_aim_angle()

	if angle >= -22.5 and angle < 22.5:
		return "right"
	elif angle >= 22.5 and angle < 67.5:
		return "diagonal_down_right"
	elif angle >= 67.5 and angle < 112.5:
		return "down"
	elif angle >= 112.5 and angle < 157.5:
		return "diagonal_down_left"
	elif angle >= 157.5 or angle < -157.5:
		return "left"
	elif angle >= -157.5 and angle < -112.5:
		return "diagonal_up_left"
	elif angle >= -112.5 and angle < -67.5:
		return "up"
	else:
		return "diagonal_up_right"

# --------------------
# ANIMACIÓN
# --------------------
func update_animation():
	var dir := get_facing_direction()
	match dir:
		"up":
			colorprueba.debug_color = Color(0.6, 0.6, 1)
		"diagonal_down_right":
			colorprueba.debug_color = Color(0.962, 0.066, 0.64, 1.0)
		"diagonal_down_left":
			colorprueba.debug_color = Color(0.0, 0.637, 0.605, 1.0)
		"down":
			colorprueba.debug_color = Color(0.6, 1, 0.6)
		"diagonal_up_left":
			colorprueba.debug_color = Color(0.835, 0.271, 0.0, 1.0)
		"diagonal_up_right":
			colorprueba.debug_color = Color(0.067, 0.514, 0.157, 1.0)
		"left":
			colorprueba.debug_color = Color(1, 0.6, 0.6)
		"right":
			colorprueba.debug_color = Color(1, 1, 0.6)
