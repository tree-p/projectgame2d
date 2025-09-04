<<<<<<< Updated upstream
class_name Enemy 
extends CharacterBody2D

=======
class_name Enemy
extends CharacterBody2D
>>>>>>> Stashed changes

enum State {
	WALKING,
	DEAD,
}

const WALK_SPEED = 22.0
@export var max_hp: int = 50
var current_hp: int = max_hp

var _state := State.WALKING

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var floor_detector_left := $FloorDetectorLeft as RayCast2D
@onready var floor_detector_right := $FloorDetectorRight as RayCast2D
@onready var sprite := $Sprite2D as Sprite2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var explode_sound := $Explode as AudioStreamPlayer2D
@onready var hit_sound := $Hit as AudioStreamPlayer2D
@onready var explosion := $Explosion as AnimatedSprite2D


func _ready() -> void:
	add_to_group("Enemy") # ทำให้ Player/Bullet รู้ว่านี่คือศัตรู

func _physics_process(delta: float) -> void:
	if _state != State.WALKING:
		return

	if _state == State.WALKING and velocity.is_zero_approx():
		velocity.x = WALK_SPEED

	velocity.y += gravity * delta

	if not floor_detector_left.is_colliding():
		velocity.x = WALK_SPEED
	elif not floor_detector_right.is_colliding():
		velocity.x = -WALK_SPEED

	if is_on_wall():
		velocity.x = -velocity.x

	move_and_slide()

	if velocity.x > 0.0:
		sprite.scale.x = 0.8
	elif velocity.x < 0.0:
		sprite.scale.x = -0.8

	var animation := get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func get_new_animation() -> StringName:
	var animation_new: StringName
	if _state == State.WALKING:
		if velocity.x == 0:
			animation_new = &"idle"
		else:
			animation_new = &"walk"
	else:
		animation_new = &"destroy"
	return animation_new


# 🩸 ฟังก์ชันรับดาเมจจาก bullet หรือ player
func take_damage(amount: int) -> void:
	if _state == State.DEAD:
		return

	current_hp -= amount
	print("Enemy HP:", current_hp)

	if current_hp <= 0:
		die()
	else:
		if hit_sound: hit_sound.play()


# 💥 ตาย / ระเบิด
func die() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO

	if explode_sound: explode_sound.play()
	if explosion:
		explosion.show()
		explosion.play("explode")

	# เล่นแอนิเมชัน แล้วค่อย queue_free()
	animation_player.play("destroy")
	await animation_player.animation_finished
	queue_free()
