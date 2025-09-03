class_name Bullet
extends RigidBody2D

@export var speed: float = 600.0
@export var damage: int = 25

@onready var sprite: Sprite2D = $Sprite2D

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# เปิดการตรวจจับการชน
	contact_monitor = true
	max_contacts_reported = 1

	# ตั้งค่า velocity เริ่มต้นของกระสุน
	linear_velocity = direction * speed

	# ตั้งเวลาอัตโนมัติให้กระสุนหายไป ถ้าไม่ชนอะไรเลย
	await get_tree().create_timer(3.0).timeout
	queue_free()

	# ตั้งค่า velocity เริ่มต้นของกระสุน
	linear_velocity = direction * speed
	# ตั้งเวลาอัตโนมัติให้กระสุนหายไป ถ้าไม่ชนอะไรเลย
	await get_tree().create_timer(3.0).timeout
	queue_free()

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	linear_velocity = direction * speed

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
