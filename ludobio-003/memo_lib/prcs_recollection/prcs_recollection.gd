extends Node

@export var recollection_depth_max:int 
@export var recollection_current_level:int
@export var recollection_speed:int
@export var recollection_tolerance:int
@export var recollection_threshold:int
@export var recollection_degress:int

var souvenirs_array:Array
var recollection_is_discrete:bool

# INIT
func _ready() -> void:
	if recollection_degress == 0:
		recollection_is_discrete = true

	for x in get_tree().get_nodes_in_group("souvenir"):
		souvenirs_array.append(x)
		x.process_recollection(recollection_current_level, recollection_threshold, recollection_tolerance)

# UPDATE SOUVENIRS ON RECOLLECT
func _unhandled_input(event: InputEvent) -> void:
	if (event.is_action_pressed("Zoom_In")) or (event is InputEventPanGesture and event.delta.y < 0):
		if recollection_current_level < recollection_depth_max:
			recollection_current_level += recollection_speed
			for x in souvenirs_array:
				x.process_recollection(recollection_current_level, recollection_threshold, recollection_tolerance)
				debug_display()
	if (event.is_action_pressed("Zoom_Out")) or (event is InputEventPanGesture and event.delta.y > 0):
		if recollection_current_level > 0:
			recollection_current_level -= recollection_speed
			for x in souvenirs_array:
				x.process_recollection(recollection_current_level, recollection_threshold, recollection_tolerance)
				debug_display()

# DEBUG DISPLAY
func debug_display():
	$dbg_reco_lvl.text = str(recollection_current_level)
