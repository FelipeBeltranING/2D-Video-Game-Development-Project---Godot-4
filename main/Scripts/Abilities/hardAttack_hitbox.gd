extends Area2D

@export var hardAttack_duration := 2.0
@export var hardAttack_range := 50.0
@export var hardAttack_cooldown := 5.0
@export var damage := 20.0

var hit_enemies := []
var puede_hardAttack := true

var hitbox_origin: Vector2

func _ready():
	hitbox_origin = position
	monitoring = false
	body_entered.connect(_on_hitbox_body_entered)
	
func _process(delta: float) -> void:

	if Input.is_action_just_pressed("AtaqueFuerte"):
		hardAttack()

func hardAttack():
	if not puede_hardAttack:
		return

	puede_hardAttack = false
	hit_enemies.clear()
	
	position = Vector2.RIGHT * hardAttack_range
	monitoring = true
	
	await get_tree().create_timer(hardAttack_duration).timeout

	monitoring = false
	position = hitbox_origin
	
	await get_tree().create_timer(hardAttack_cooldown).timeout
	puede_hardAttack = true

func _on_hitbox_body_entered(body):
	if body in hit_enemies:
		return

	hit_enemies.append(body)

	if body.has_method("take_damage"):
		body.take_damage(damage)
