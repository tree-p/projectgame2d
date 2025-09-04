extends CharacterBody2D

signal boss_died

@export var max_health: int = 200
@export var attack_damage: int = 25
@export var attack_interval: float = 1
@export var wave_scene: PackedScene
@onready var spawn_point := $AnimatedSprite2D/SpawnPoint

var current_health: int
var is_hit: bool = false
var is_dead: bool = false

func _ready():
	current_health = max_health
	$Timer_Attack.wait_time = attack_interval
	$Timer_Attack.start()

	# เริ่มด้วย idle
	if $AnimatedSprite2D.sprite_frames.has_animation("idle"):
		$AnimatedSprite2D.play("idle")
	else:
		push_warning("AnimatedSprite2D ไม่มี animation 'idle'")

@onready var anim_player := $AnimationPlayer

func _on_Timer_Attack_timeout():
	if is_hit:
		return
	if anim_player:
		anim_player.play("boss_attack_sequence")


	# เล่นท่าโจมตี + ปล่อยคลื่น
	if $AnimatedSprite2D.sprite_frames.has_animation("attack"):
		$AnimatedSprite2D.play("attack")
	else:
		push_warning("AnimatedSprite2D ไม่มี animation 'attack'")

	shoot_energy_wave()

func shoot_energy_wave():
	if wave_scene == null:
		push_warning("wave_scene is not assigned on Boss")
		return

	var wave := wave_scene.instantiate()
	wave.global_position = spawn_point.global_position  # ใช้ global_position เสมอ
	# ตรวจสอบ SpawnPoint ก่อนใช้งาน



	# เล็งไปหา player
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		var dir: Vector2 = (player.global_position - spawn_point.global_position).normalized()
		if wave.has_method("set_direction"):
			wave.set_direction(dir)
		elif "direction" in wave:
			wave.direction = dir

	get_parent().add_child(wave)



func take_damage(amount: int):
	if amount <= 0 or is_dead:
		return

	current_health -= amount
	print("Boss HP:", current_health)

	is_hit = true
	if $AnimatedSprite2D.sprite_frames.has_animation("hit"):
		$AnimatedSprite2D.play("hit")
	else:
		push_warning("AnimatedSprite2D ไม่มี animation 'hit'")

	$Timer_Hit.start()

	# เด้งถอยหลัง
	var player := get_tree().get_first_node_in_group("player")
	if player and player is Node2D:
		velocity = (global_position - player.global_position).normalized() * 80.0

	if current_health <= 0:
		die()

func _on_Timer_Hit_timeout():
	is_hit = false
	if current_health > 0 and $AnimatedSprite2D.sprite_frames.has_animation("idle"):
		$AnimatedSprite2D.play("idle")

func _on_AnimatedSprite2D_animation_finished():
	if not is_hit and current_health > 0:
		if $AnimatedSprite2D.animation != "idle" and $AnimatedSprite2D.sprite_frames.has_animation("idle"):
			$AnimatedSprite2D.play("idle")

func die():
	if is_dead:
		return
	is_dead = true
	boss_died.emit()

	print("Boss is Dead!")
	

	if $AnimatedSprite2D.sprite_frames.has_animation("die"):
		$AnimatedSprite2D.play("die")
	else:
		push_warning("AnimatedSprite2D ไม่มี animation 'die'")

	queue_free()
