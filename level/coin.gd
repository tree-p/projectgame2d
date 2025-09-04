class_name Coin extends Area2D
## Collectible that disappears when the player touches it.


@onready var animation_player := $AnimationPlayer as AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.emit_signal("coin_collected")  # แจ้ง Player ว่าเก็บเหรียญแล้ว
		animation_player.play("picked")
		queue_free()  # ลบเหรียญหลังเก็บแล้ว
