extends Node2D

func _ready():
	$StaticBody2D/CollisionShape2D/AnimatedSprite2D.play("cut")
