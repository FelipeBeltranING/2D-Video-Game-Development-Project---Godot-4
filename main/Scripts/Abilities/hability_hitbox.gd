extends Area2D

@export var spin_duration := 2.0
@export var spin_tick := 0.33     
@export var spin_speed := 1.0 
@export var spin_cooldown := 5.0

var damage = 25.0
var puede_hability = true
var enemigos_en_cooldown := {}

func _ready() -> void:
	monitoring = false
	body_entered.connect(_on_hitbox_body_entered)

func _process(delta: float) -> void:
	for enemy in enemigos_en_cooldown.keys():
		enemigos_en_cooldown[enemy] -= delta
		if enemigos_en_cooldown[enemy] <= 0:
			enemigos_en_cooldown.erase(enemy)
			
	if Input.is_action_just_pressed("E"):
		hability()

func hability():
	if not puede_hability:
		return
	
	print("ejecutando E")
	puede_hability = false

	monitoring = true 
	
	await get_tree().create_timer(spin_duration).timeout
	
	monitoring = false
	
	await get_tree().create_timer(spin_cooldown).timeout
	
	puede_hability = true

func _on_hitbox_body_entered(body):
	if not body.has_method("take_damage") :
		return
		
	if enemigos_en_cooldown.has(body):
		return
		
	body.take_damage(damage)
	enemigos_en_cooldown[body] = spin_tick
		
