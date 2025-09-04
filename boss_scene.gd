extends Node2D

func spawn_boss():
	var boss = preload("res://Boss_Scene.tscn").instantiate()
	add_child(boss)
	boss.boss_died.connect(_on_boss_died)

var label_complete

func _ready():
	label_complete = get_tree().root.get_node("Game_05_05/CanvasLayer/Label_Complete2")

func _on_boss_died():
	if label_complete:
		label_complete.text = "COMPLETE"
		label_complete.visible = true
