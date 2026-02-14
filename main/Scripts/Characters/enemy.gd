extends CharacterBody2D

@export var SPEED := 100
@export var max_health := 100

var health := max_health

func take_damage(amount: int) -> void:
	health -= amount
	
	if health <= 0:
		die()

func die():
	queue_free()
