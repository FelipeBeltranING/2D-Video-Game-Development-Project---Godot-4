extends Node2D

@export var attack_duration := 0.35
@export var attack_range := 25.0
@export var knockback_force := 300.0
@export var R_cooldown = 20.0
@export var R_duration = 10.0
@export var damage := 100.0
var base_speed = 100.0
var base_attack_duration = 0.35
var base_damage =100.0

var combo := 0
var hit_enemies := []
var puede_atacar := true
var puede_R := true
var is_R_active = false

@onready var attack_hitbox := $attack_hitbox
var hitbox_origin: Vector2

func _ready():
	hitbox_origin = attack_hitbox.position
	attack_hitbox.body_entered.connect(_on_hitbox_body_entered)
	
func _process(delta: float) -> void:
	# Solo rotamos el arma (no al jugador)
	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("AtaqueBasico"):
		attack()

	if Input.is_action_just_pressed("R"):
		R()
		
	queue_redraw()

func _on_hitbox_body_entered(body):
	if body.is_in_group("Enemy") and body not in hit_enemies:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		hit_enemies.append(body)
		
func attack():
	if not puede_atacar:
		return

	puede_atacar = false

	hit_enemies.clear()

	attack_hitbox.position = Vector2.RIGHT * attack_range
	attack_hitbox.monitoring = true

	await get_tree().create_timer(attack_duration).timeout

	attack_hitbox.monitoring = false
	attack_hitbox.position = hitbox_origin

	combo += 1
	if combo == 3:
		apply_knockback()
		combo = 0

	puede_atacar = true


func apply_knockback():
	for enemy in hit_enemies:
		if enemy and enemy.has_method("apply_knockback"):
			var dir : Vector2 = (enemy.global_position - global_position).normalized()
			enemy.apply_knockback(dir * knockback_force)

func R():
	if not puede_R or is_R_active:
		return
	
	puede_R = false
	is_R_active = true
	
	damage *= 1.8
	attack_duration *= 0.6
	get_parent().SPEED *= 1.4

	print("R ACTIVADA")

	await get_tree().create_timer(R_duration).timeout
	
	damage = base_damage
	attack_duration = base_attack_duration
	get_parent().SPEED = base_speed
	
	is_R_active = false
	print("R TERMINADA")

	await get_tree().create_timer(R_cooldown).timeout
	puede_R = true

func _draw():
	draw_line(
		Vector2.ZERO,
		Vector2.RIGHT * attack_range,
		Color.RED,
		2
	)
