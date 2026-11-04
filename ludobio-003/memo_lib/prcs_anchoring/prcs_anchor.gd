extends Node

var zoomout_value = 0.3
var zoom_duration = 0.25
var current_anchor : String = ""

func _ready() -> void:
	$LineEdit.visible = false
	$Button.visible = false

func _input(event):
	if (event.is_action_pressed("Anchor")):
		if MemoryPool.instance.is_anchoring == false:
			MemoryPool.instance.zoomzoom(zoom_duration, zoomout_value)
			await get_tree().create_timer(zoom_duration).timeout
			$LineEdit.visible = true
			$Button.visible = true
			$LineEdit.grab_focus()
		else:
			MemoryPool.instance.zoomzoom(zoom_duration, 1)
			$LineEdit.visible = false
			$Button.visible = false
			$LineEdit.text = ""

func _on_button_pressed() -> void:
	if Anchor.anchor_enum.has($LineEdit.text):
		current_anchor = $LineEdit.text
	else:
		pass
	$LineEdit.text = ""