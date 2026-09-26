extends Node2D

@export var recollection_target:int
@export var clarity_target_offset:Vector2

var clarity_target:Vector2
var is_recollected:bool
var is_clear:bool
var recollection_shader_value:float
var clarity_shader_value:float

func _ready() -> void:
	clarity_target = Vector2(position.x,position.y)
	#clarity_target += clarity_target_offset
	$TextureRect.material = $TextureRect.material.duplicate()


# CALLED FROM RECOLLECTION PROCESS
# defines if the current level of focus of memory is the same plane 
func process_recollection(current_depth:int, recollection_threshold:int, recollection_tolerance:int):
	var recollection_distance = abs(current_depth - recollection_target)
	if(recollection_distance < recollection_threshold):
		if(recollection_distance < recollection_tolerance):
			recollection_shader_value = 1
			is_recollected = true
		else:
			recollection_shader_value = recollection_threshold - recollection_distance
			recollection_shader_value = float(recollection_shader_value/recollection_threshold)
			is_recollected = false
	else :
		recollection_shader_value = 0
		is_recollected = false
	
	$TextureRect.material.set_shader_parameter("reco_strength", recollection_shader_value)


# CALLED FROM CLARITY PROCESS
func process_clarity(current_aim:Vector2, clarity_threshold:int, clarity_tolerance:int ):
	var clarity_distance = current_aim.distance_to(clarity_target)
	if(clarity_distance < clarity_threshold):
		if(clarity_distance < clarity_tolerance):
			clarity_shader_value = 0
		else:
			clarity_shader_value = clarity_threshold - clarity_distance
			clarity_shader_value = float(clarity_shader_value / clarity_threshold)
	else:
		clarity_shader_value = 1

	$TextureRect.material.set_shader_parameter("clarity_strength", clarity_shader_value) 
