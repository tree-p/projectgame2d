class_name Player
extends CharacterBody2D

signal coin_collected()
signal player_died()

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -725.0
const TERMINAL_VELOCITY = 700

@export var action_suffix := ""
@export var max_health: int = 100
var current_health: int

var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var shoot_timer := $ShootAnimation as Timer
@onready var sprite := $Sprite2D as Sprite2D
@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var gun = sprite.get_node(^"Gun") as Gun
@onready var camera := $Camera as Camera2D
var _double_jump_charged := false

enum State { STOP, MOVE }
var state = State.MOVE


func _ready() -> void:
	current_health = max_health
	add_to_group("player") # ✅ ให้ Player อยู่ใน group

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_double_jump_charged = true
	if Input.is_action_just_pressed("jump" + action_suffix):
		try_jump()
	elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		velocity.y *= 0.6

	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	if not is_zero_approx(velocity.x):
		sprite.scale.x = 1.0 if velocity.x > 0.0 else -1.0

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var is_shooting := false
	if Input.is_action_just_pressed("shoot" + action_suffix):
		is_shooting = gun.shoot(sprite.scale.x)

	var animation := get_new_animation(is_shooting)
	if animation != animation_player.current_animation and shoot_timer.is_stopped():
		if is_shooting:
			shoot_timer.start()
		animation_player.play(animation)

func get_new_animation(is_shooting := false) -> String:
	var animation_new: String
	if is_on_floor():
		animation_new = "run" if absf(velocity.x) > 0.1 else "idle"
	else:
		animation_new = "falling" if velocity.y > 0.0 else "jumping"

	if is_shooting:
		animation_new += "_weapon"
	return animation_new

func try_jump() -> void:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	elif _double_jump_charged:
		_double_jump_charged = false
		velocity.x *= 2.5
		jump_sound.pitch_scale = 1.5
	else:
		return
	velocity.y = JUMP_VELOCITY
	jump_sound.play()

func play_walk_in_animation():
	state = State.STOP
	animation_player.play("DoorIn")

# ----------------------------
# ✅ ระบบ HP / Damage / Die
# ----------------------------
func take_damage(amount: int) -> void:
	current_health -= amount
	print("Player HP:", current_health)
	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, max_health)

func die() -> void:
	print("Player is Dead!")
	emit_signal("player_died")
	call_deferred("queue_free")
