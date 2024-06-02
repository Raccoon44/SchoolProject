extends Area2D

func _ready():
	pass

func _on_DashItem_body_entered(body):
	if body.is_in_group("Player"):
		queue_free()
