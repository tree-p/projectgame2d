# Wave.gd
extends Area2D

@export var speed: float = 600.0
var direction: Vector2 = Vector2.RIGHT
@export var damage: int = 10

func _process(delta):
	position += direction * speed * delta

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
		return
	if body.is_in_group("world"):
		queue_free()
