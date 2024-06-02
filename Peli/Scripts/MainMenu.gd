extends Control

func _ready():
	pass

#Open Game
func _on_Start_pressed():
	get_node("/root/Hud").visible = true
	get_tree().change_scene("res://Scenes/World.tscn")

#Close Game
func _on_Quit_pressed():
	get_tree().quit()
