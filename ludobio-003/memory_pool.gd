class_name MemoryPool
extends Node

var souvenir_nb_char:int = 17
var souvenir_nb_lines:int = 8
var souvenirs_length:int = 136
var start_processing:bool = false
var souvenirs_array = []
var menu_removed:bool 
var end_reached:bool

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
	$Camera2D.global_position = get_viewport().get_visible_rect().size / 2

# REMOVE MENU / TUTOS AND DISPLAY HIDDEN TILES
func remove_menu():
	menu_removed = true
	for souvenir in get_tree().get_nodes_in_group("menu_empties"):
		souvenir.visible = true
	for child in $Menu.get_children():
		child.visible = false
func add_menu():
	menu_removed = false
	for souvenir in get_tree().get_nodes_in_group("menu_empties"):
		souvenir.visible = false
	for child in $Menu.get_children():
		child.visible = true

# HANDLE ENDING
func ending(ending_souvenir:Node2D):
	start_processing = false
	for souvenir in get_tree().get_nodes_in_group("hide_at_end"):
		souvenir.visible = false
	for child in $Ending.get_children():
		child.visible = true
	end_reached = true
	for souvenir in souvenirs_array:
		if souvenir != ending_souvenir:
			souvenir.deactivate()
	
