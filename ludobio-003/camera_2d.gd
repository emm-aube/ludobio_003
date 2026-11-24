extends Camera2D

var mouse_pos:Vector2


# JUST MOVE CAMERA 
func _process(_delta: float) -> void:
	mouse_pos = get_viewport().get_mouse_position()
	if(mouse_pos.x < 50 and position.x > -500):
		position.x -= 30
	if(mouse_pos.x > 1950 and position.x < 2500):
		position.x += 30
	if(mouse_pos.y < 40 and position.y > -250):
		position.y -= 30
	if(mouse_pos.y > 950 and position.y < 1250):
		position.y += 30

	