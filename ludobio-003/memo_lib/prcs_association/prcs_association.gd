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
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			for souvenir in souvenirs_array:
				var label = souvenir.get_node("RichTextLabel")
				if label.get_global_rect().has_point(event.position):
					var result = souvenir.process_association()
					print(result)
					var status_changed = result[0]
					var is_selected = result[1]
					var associated_array = result[2]
					if(status_changed):
						for any_souvenir in souvenirs_array:
							if any_souvenir != souvenir:
								any_souvenir.clean_association()
								any_souvenir.is_associated = false
								any_souvenir.is_selected = false
								any_souvenir.process_recollection(MemoryPool.instance.get_node("prcs_recollection").recollection_current_level, MemoryPool.instance.get_node("prcs_recollection").recollection_threshold, MemoryPool.instance.get_node("prcs_recollection").recollection_tolerance)
						for associated_souvenir in associated_array:
							if(is_selected):
								associated_souvenir.is_associated = true