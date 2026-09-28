extends Node

@export var clarity_tolerance:int
@export var clarity_threshold:int

var souvenirs_array:Array = []
var clarity_is_discrete:bool = false

func _ready() -> void:
	for x in get_tree().get_nodes_in_group("souvenir"):
		souvenirs_array.append(x)
		x.process_clarity(get_viewport().get_mouse_position(), clarity_threshold, clarity_tolerance)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		for x in souvenirs_array:
			x.process_clarity(event.position, clarity_threshold, clarity_tolerance)
