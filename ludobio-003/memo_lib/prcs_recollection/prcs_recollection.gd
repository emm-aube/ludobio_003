extends Node

@export var recollection_depth_max:int 
@export var recollection_current_level:int
@export var recollection_speed:int
@export var recollection_tolerance:int
@export var recollection_threshold:int

var souvenirs_array:Array

# INIT FROM POOL
func initialize(souvenirs:Array):
	souvenirs_array = souvenirs
	for souvenir in souvenirs_array:
		souvenir.process_recollection(recollection_current_level, recollection_threshold, recollection_tolerance)
	# just a debug label
	$dbg_reco_lvl.visible = false

# UPDATE SOUVENIRS ON RECOLLECT
func _unhandled_input(event: InputEvent) -> void:
	if(MemoryPool.instance.start_processing == true):
		# check if mouse wheel AND if pan gesture in case mac trackpad (twice, just reverse values)
		if (event.is_action_pressed("Zoom_In")) or (event is InputEventPanGesture and event.delta.y < 0):
			if recollection_current_level < recollection_depth_max:
				recollection_current_level = mini(recollection_current_level + recollection_speed, recollection_depth_max)
				# update every souvenir with new recollection value (threshold and tolerance just set at start)
				for x in souvenirs_array:
					x.process_recollection(recollection_current_level, recollection_threshold, recollection_tolerance)
					debug_display()
		if (event.is_action_pressed("Zoom_Out")) or (event is InputEventPanGesture and event.delta.y > 0):
			if recollection_current_level > 0:
				recollection_current_level = maxi(recollection_current_level - recollection_speed, 0)
				for x in souvenirs_array:
					x.process_recollection(recollection_current_level, recollection_threshold, recollection_tolerance)
					debug_display()

# DEBUG DISPLAY
func debug_display():
	pass
	$dbg_reco_lvl.text = str(recollection_current_level)