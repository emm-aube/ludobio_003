class_name MemoryPool
extends Node

var souvenir_width:int = 200
var souvenir_height:int = 200
var souvenir_nb_char:int = 17
var souvenir_nb_lines:int = 8
var souvenirs_length:int = 136
var start_processing:bool = false
var souvenirs_array = []

static var instance: MemoryPool

func _enter_tree() -> void:
	MemoryPool.instance = self

# ON START JUST CREATE ARRAY OF ALL SOUVENIRS PER CELL 
func _ready() -> void:
	
	await get_tree().process_frame

	souvenirs_length = souvenir_nb_lines * souvenir_nb_char
	for x in (get_tree().get_nodes_in_group("souvenir")):
		souvenirs_array.append(x)
	for x in souvenirs_array:
		x.initiate()

	start_processing = true