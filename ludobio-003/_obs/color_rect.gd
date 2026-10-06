
extends ColorRect

func _process(_delta: float) -> void:
    var mouse_pos = get_viewport().get_mouse_position()
    var screen_size = get_viewport_rect().size

    material.set_shader_parameter("mouse_pos", mouse_pos / screen_size)
