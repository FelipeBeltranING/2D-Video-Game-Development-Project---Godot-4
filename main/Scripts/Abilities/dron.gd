extends CharacterBody2D

@export var max_speed := 120.0
@export var acceleration := 1400.0
@export var friction := 1600.0

@export var fire_rate := 0.8
@export var max_range := 300.0

@onready var shoot_point: Marker2D = $Marker2D

var player: Node2D
var follow_offset := Vector2.ZERO
var bullet_scene: PackedScene

var fire_timer := 0.0

func _physics_process(delta):
	fire_timer -= delta
	handle_follow(delta)
	handle_shooting()

# ================= MOVIMIENTO CON INERCIA =================

func handle_follow(delta):
	if player == null:
		return

	var target = player.global_position + follow_offset
	var dir = target - global_position
	var dist = dir.length()

	if dist > 5:
		dir = dir.normalized()
		velocity += dir * acceleration * delta
		velocity = velocity.limit_length(max_speed)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()

# ================= DISPARO =================

func handle_shooting():
	if fire_timer > 0:
		return

	var enemy = get_closest_enemy()
	if enemy == null:
		return

	fire_timer = fire_rate
	shoot(enemy)

func get_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var closest = null
	var min_dist = INF

	for e in enemies:
		if not e.is_inside_tree():
			continue

		var d = global_position.distance_to(e.global_position)
		if d < min_dist and d <= max_range:
			min_dist = d
			closest = e

	return closest

func shoot(target):
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = shoot_point.global_position
	var dir = (target.global_position - bullet.global_position).normalized()
	bullet.init(dir)
