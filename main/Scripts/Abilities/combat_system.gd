extends Node2D

@onready var hitbox := $Area2D
@export var damage = 20.

func _ready():
	hitbox.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
