class_name Bullet
extends RigidBody2D

@export var speed: float = 600.0
@export var damage: int = 25
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1

	# ลบตัวเองอัตโนมัติหลัง 3 วินาที
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(func(): queue_free())
	add_child(timer)
	timer.start()

	# connect signal body entered
	self.body_entered.connect(_on_Bullet_body_entered)

func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	linear_velocity = direction * speed

func _on_Bullet_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
