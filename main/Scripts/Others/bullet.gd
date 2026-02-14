extends Node2D

@export var damage := 10.0
@export var SPEED := 500.0
@export var LIFE_TIME := 3.0
@onready var hitbox = $Area2D
var direction := Vector2.ZERO

func init(dir: Vector2):
	direction = dir.normalized()
	rotation = direction.angle()

func _physics_process(delta):
	global_position += direction * SPEED * delta

func _ready():
	await get_tree().create_timer(LIFE_TIME).timeout
	queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
