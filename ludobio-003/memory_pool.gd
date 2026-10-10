class_name MemoryPool
extends Node

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

	# init each SOUVENIR
	souvenirs_length = souvenir_nb_lines * souvenir_nb_char
	for x in (get_tree().get_nodes_in_group("souvenir")):
		souvenirs_array.append(x)
	for x in souvenirs_array:
		x.initialize($prcs_clarity.clarity_expected)
	
	# INIT AL PROCESSES
	# Association (first because we need to know if they need association or not)
	$prcs_association.initialize(souvenirs_array)
	# Recollection (calculates initial recollection state)
	$prcs_recollection.initialize(souvenirs_array)
	# Clarity
	$prcs_clarity.initialize(souvenirs_array)
	# Noise
	$prcs_noise.initialize(souvenirs_array)
	
	# AUTHORIZE PROCESSING FOR ALL (for those who have input)
	start_processing = true
	
	# START ALL PROCESSES (for those who have timers)
	$prcs_clarity.start()
	$prcs_noise.start()
