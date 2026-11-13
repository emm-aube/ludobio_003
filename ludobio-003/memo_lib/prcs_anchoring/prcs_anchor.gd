extends Node

var souvenirs_array:Array
var anchored_souvenirs_array:Array
var zoomout_value = 0.3
var zoom_duration = 0.25
var current_anchor : String = ""
var active_souvenirs_array:Array

# JUST INIT FROM MEMORY POOL
func initialize(souvenirs:Array) -> void:
	souvenirs_array = souvenirs
	
	$LineEdit.visible = false
	$Button.visible = false
	$ColorRect.visible = false
	$ColorRect/RichTextLabel.visible = false
	
# DETECT BUTTON TO DISPLAY SEARCH BAR & ENTER / CLICK TO SEARCH
func _input(event):
	if (event.is_action_pressed("Anchor")):
		if MemoryPool.instance.is_anchoring == false:
			MemoryPool.instance.zoomzoom(zoom_duration, zoomout_value)
			await get_tree().create_timer(zoom_duration).timeout
			MemoryPool.instance.order_clarity()
			$LineEdit.visible = true
			$Button.visible = true
			$ColorRect.visible = true
			$ColorRect/RichTextLabel.visible = true
			$LineEdit.grab_focus()
		else:
			MemoryPool.instance.zoomzoom(zoom_duration, 1)
			$LineEdit.visible = false
			$Button.visible = false
			$ColorRect.visible = false
			$ColorRect/RichTextLabel.visible = false
			$LineEdit.text = ""
	elif (event.is_action_pressed("Search")):
		search()
func _on_button_pressed() -> void:
	search()

# LAUNCH A SEARCH 4 THE ANCHOR IN ALL DIARY
func search():
	for souvenir in souvenirs_array:
		souvenir.process_anchoring(true, "", 0.0)
	current_anchor = $LineEdit.text
	for entry in MemoryPool.instance.ze_diary:
		print(entry)
		print(entry[1])
		if entry[1].has(current_anchor):
			print("ok it's in")
			var weight_value= float(entry[1].find(current_anchor))
			weight_value = 1 / (1 + weight_value)
			print(weight_value)
			if active_souvenirs_array.size() >= souvenirs_array.size():
				break
			var souvenir_to_take = souvenirs_array.pick_random()
			while active_souvenirs_array.has(souvenir_to_take):
				souvenir_to_take = souvenirs_array.pick_random()
			active_souvenirs_array.append(souvenir_to_take)
			souvenir_to_take.process_anchoring(false, entry[2], weight_value)
	$LineEdit.text = ""
	MemoryPool.instance.order_recollection()
	await get_tree().create_timer(0.1).timeout
	$LineEdit.grab_focus()
	$LineEdit.edit()
