extends CharacterBody2D

@export var SPEED := 200.0
@export var SPRINT_MULTIPLIER := 1.5
@export var SHOOT_SLOW_MULTIPLIER := 0.5

@export var DRONE_DURATION := 10.0
@export var COOLDOWN_R := 20.0

@export var dron_scene: PackedScene
@export var bullet1_scene: PackedScene
@export var bullet2_scene: PackedScene
@export var bomb_scene: PackedScene

@export var FIRE_RATE := 0.15
@export var COOLDOWN_RIGHTCLICK := 4.0
@export var COOLDOWN_E := 8.0

const DRONE_OFFSETS = [
	Vector2(-30, -20),
	Vector2(0, -35),
	Vector2(30, -20)
]

const OFFSET := 20
var BOMB_AMOUNT := 6
var BOMB_RADIUS := 120

# ================= ESTADOS =================

var drones_active := false
var drone_on_cooldown := false

var is_shooting := false
var is_shooting2 := false
var can_move := true
var look_dir := Vector2.DOWN

var fire_timer := 0.0
var right_click_timer := 0.0
var e_timer := 0.0

@onready var hitbox: Area2D = $Arma/Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# ================= PROCESS =================

func _physics_process(delta):
	is_shooting = Input.is_action_pressed("AtaqueBasico")
	is_shooting2 = Input.is_action_pressed("AtaqueFuerte")

	fire_timer -= delta
	right_click_timer -= delta
	e_timer -= delta

	if can_move:
		handle_movement()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

	update_look_direction()

	if is_shooting:
		try_shoot_1()
	elif is_shooting2:
		try_shoot_2()

# ================= MOVIMIENTO =================

func handle_movement():
	var speed = SPEED

	if not is_shooting and not is_shooting2 and Input.is_action_pressed("Movilidad"):
		speed *= SPRINT_MULTIPLIER

	if is_shooting:
		speed *= SHOOT_SLOW_MULTIPLIER

	velocity = get_input_direction() * speed
	move_and_slide()

func get_input_direction() -> Vector2:
	return Input.get_vector("Izquierda", "Derecha", "Arriba", "Abajo")

# ================= APUNTADO =================

func update_look_direction():
	var mouse_pos = get_global_mouse_position()
	var dir = mouse_pos - global_position
	if dir == Vector2.ZERO:
		return

	look_dir = dir.normalized()
	update_hitbox_direction(look_dir)
	update_sprite_direction(look_dir)

func update_hitbox_direction(dir):
	if abs(dir.x) > abs(dir.y):
		hitbox.position = Vector2(OFFSET, 0) if dir.x > 0 else Vector2(-OFFSET, 0)
	else:
		hitbox.position = Vector2(0, OFFSET) if dir.y > 0 else Vector2(0, -OFFSET)

func update_sprite_direction(dir):
	if abs(dir.x) > abs(dir.y):
		sprite.play("Right" if dir.x > 0 else "Left")
	else:
		sprite.play("Down" if dir.y > 0 else "Up")

# ================= DISPARO =================

func try_shoot_1():
	if fire_timer > 0:
		return
	fire_timer = FIRE_RATE
	shoot(bullet1_scene)

func try_shoot_2():
	if right_click_timer > 0:
		return
	right_click_timer = COOLDOWN_RIGHTCLICK
	shoot(bullet2_scene)

func shoot(bullet_scene):
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = hitbox.global_position

	var dir = (get_global_mouse_position() - bullet.global_position).normalized()
	bullet.init(dir)

# ================= INPUT =================

func _input(event):
	if event.is_action_pressed("E") and e_timer <= 0:
		e_timer = COOLDOWN_E
		cast_bombardment()

	if event.is_action_pressed("R"):
		try_spawn_drones()

# ================= DRONES =================

func try_spawn_drones():
	if drones_active or drone_on_cooldown:
		return
	spawn_drones()

func spawn_drones():
	drones_active = true
	var drones := []

	for offset in DRONE_OFFSETS:
		var dron = dron_scene.instantiate()
		get_tree().current_scene.add_child(dron)

		dron.global_position = global_position
		dron.player = self
		dron.follow_offset = offset
		dron.bullet_scene = bullet1_scene

		drones.append(dron)

	await get_tree().create_timer(DRONE_DURATION).timeout

	for d in drones:
		if is_instance_valid(d):
			d.queue_free()

	drones_active = false
	start_drone_cooldown()

func start_drone_cooldown():
	drone_on_cooldown = true
	await get_tree().create_timer(COOLDOWN_R).timeout
	drone_on_cooldown = false

# ================= BOMBARDEO =================

func cast_bombardment():
	if bomb_scene == null:
		return

	var center = get_global_mouse_position()
	for i in BOMB_AMOUNT:
		var bomb = bomb_scene.instantiate()
		bomb.global_position = center + get_random_point_in_circle(BOMB_RADIUS)
		get_tree().current_scene.add_child(bomb)

func get_random_point_in_circle(radius):
	var angle = randf() * TAU
	var r = sqrt(randf()) * radius
	return Vector2(cos(angle), sin(angle)) * r
