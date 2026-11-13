extends Camera2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	if(mouse_pos.x <= 50):
		if position.x > -500:
			position.x -= 20
		else:
			position.x = -500
	elif(mouse_pos.x >= 1950):
		if position.x < 2500:
			position.x += 20
		else:
			position.x = 2500
	if(mouse_pos.y <= 50):
		if position.y > -250:
			position.y -= 20
		else:
			position.y = -250
	elif(mouse_pos.y >= 950):
		if position.y < 1250:
			position.y += 20
		else:
			position.y = 1250
	