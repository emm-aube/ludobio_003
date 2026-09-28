extends Node

@export var souvenir_width: int
@export var souvenir_height: int

var souvenirs_array = []


# ON START JUST CREATE ARRAY OF ALL SOUVENIRS PER CELL 
func _ready() -> void:
	pass
	#stretch mode so that vieport size does not change
#	var viewport_size = get_viewport().get_visible_rect().size
#	var nb_h_cells = viewport_size.x / souvenir_width
#	var nb_v_cells = viewport_size.y / souvenir_height
	
	#for x_cell in range (0, nb_h_cells):
	#	for y_cell in range (0, nb_v_cells):
	##		souvenirs_array.append()
	#		souvenirs_array[array_ID] = []
	#		souvenirs_array[array_ID].append("test")
	#		print(souvenirs_array)
		#for souvenir in get_tree().get_nodes_in_group("souvenir"):
			#if (cell_nb * souvenir_width < souvenir.position.x > (cell_nb +1) * souvenir_width):
			#	if(cell_nb * souvenir_height < souvenir.position.> (cell_nb +1) * souvenir_height):



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
