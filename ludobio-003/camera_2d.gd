extends Camera2D

var mouse_pos:Vector2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mouse_pos = get_viewport().get_mouse_position()

	