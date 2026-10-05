extends Node

@export var association_depth_max:int
@export var association_current_level:int  

var association_speed:float = 10.0
var souvenirs_array:Array
var current_souvenir_associating:Node2D

# INIT
func _ready() -> void:
	for x in get_tree().get_nodes_in_group("souvenir"):
		souvenirs_array.append(x)
		#x.process_recollection(recollection_current_level, recollection_threshold, recollection_tolerance)

# UPDATE SOUVENIRS ON RECOLLECT
func _unhandled_input(event: InputEvent) -> void:
	if(MemoryPool.instance.start_processing == true):
		if (event.is_action_pressed("Zoom_In")) or (event is InputEventPanGesture and event.delta.y < 0):
		#	if association_current_level < association_depth_max:
		#		association_current_level += association_speed
			current_souvenir_associating = null
			for souvenir in souvenirs_array:
				if(souvenir.is_clear == true):
					current_souvenir_associating = souvenir
			if(current_souvenir_associating != null):
				for souvenir in souvenirs_array:
					if(current_souvenir_associating.association_array.has(souvenir)):
						souvenir.association_target = move_toward(souvenir.association_target, current_souvenir_associating.recollection_target, association_speed)
					else:
						souvenir.association_target = move_toward(souvenir.association_target, current_souvenir_associating.recollection_target, association_speed)
					souvenir.process_association()
				#x.process_recollection(recollection_current_level, recollection_threshold, recollection_tolerance)
			
		#if (event.is_action_pressed("Zoom_Out")) or (event is InputEventPanGesture and event.delta.y > 0):
		#	if recollection_current_level > 0:
		#		recollection_current_level -= recollection_speed
		#		for x in souvenirs_array:
		#			x.process_recollection(recollection_current_level, recollection_threshold, recollection_tolerance)
			

# DEBUG DISPLAY
#func debug_display():
#	$dbg_reco_lvl.text = str(recollection_current_level)
