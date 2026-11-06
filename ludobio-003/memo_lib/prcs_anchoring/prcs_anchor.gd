extends Node

var souvenirs_array:Array
var anchored_souvenirs_array:Array
var zoomout_value = 0.3
var zoom_duration = 0.25
var current_anchor : String = ""

# JUST INIT FROM MEMORY POOL
func initialize(souvenirs:Array) -> void:
	souvenirs_array = souvenirs
	
	$LineEdit.visible = false
	$Button.visible = false
	
# DETECT BUTTON TO DISPLAY SEARCH BAR & ENTER / CLICK TO SEARCH
func _input(event):
	if (event.is_action_pressed("Anchor")):
		if MemoryPool.instance.is_anchoring == false:
			MemoryPool.instance.zoomzoom(zoom_duration, zoomout_value)
			await get_tree().create_timer(zoom_duration).timeout
			MemoryPool.instance.order_clarity()
			$LineEdit.visible = true
			$Button.visible = true
			$LineEdit.grab_focus()
		else:
			MemoryPool.instance.zoomzoom(zoom_duration, 1)
			$LineEdit.visible = false
			$Button.visible = false
			$LineEdit.text = ""
	elif (event.is_action_pressed("Search")):
		search()
func _on_button_pressed() -> void:
	search()

# CHECK IF TAG EXISTS THEN LAUNCH A SEARCH 
func search():
	for souvenir in souvenirs_array:
		souvenir.process_anchoring(true, "")
	current_anchor = $LineEdit.text
	for entry in MemoryPool.instance.ze_diary:
		if entry[1].has(current_anchor):
			souvenirs_array[1].process_anchoring(false, entry[2])
	$LineEdit.text = ""
	await get_tree().create_timer(0.2).timeout
	$LineEdit.grab_focus()
	$LineEdit.edit()