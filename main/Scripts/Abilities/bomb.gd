extends Node2D

@export var damage := 25
@export var min_fall_time := 0.0
@export var max_fall_time := 1.6
@export var active_time := 0.5

@onready var area: Area2D = $Area2D

func _ready():
	area.monitoring = false
	
	var fall_time = randf_range(min_fall_time, max_fall_time)
	await get_tree().create_timer(fall_time).timeout
	
	explode()

func explode():
	area.monitoring = true
	print("Se genero una bomba")
	await get_tree().create_timer(active_time).timeout
	queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
