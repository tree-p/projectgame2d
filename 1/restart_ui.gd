extends CanvasLayer

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://1/game_level_01.tscn") # เปลี่ยน path ให้ตรงจริง


func _on_mainmenu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn") # เปลี่ยน path ให้ตรงจริง
