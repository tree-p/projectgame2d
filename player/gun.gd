class_name Gun
extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.25
var can_shoot: bool = true

func shoot(direction_x: float) -> bool:
	if not can_shoot or bullet_scene == null:
		return false

	can_shoot = false

	# สร้าง bullet
	var bullet = bullet_scene.instantiate()

	# spawn ด้านหน้า player
	bullet.global_position = global_position + Vector2(20 * sign(direction_x), 0)

	# set direction
	if bullet.has_method("set_direction"):
		bullet.set_direction(Vector2(sign(direction_x), 0))
	elif "direction" in bullet:
		bullet.direction = Vector2(sign(direction_x), 0)

	# เพิ่ม bullet ลง scene
	get_tree().current_scene.add_child(bullet)

	# Timer เพื่อ fire_rate
	var t = Timer.new()
	t.wait_time = fire_rate
	t.one_shot = true
	t.timeout.connect(func(): can_shoot = true)
	get_tree().current_scene.add_child(t)
	t.start()

	return true
