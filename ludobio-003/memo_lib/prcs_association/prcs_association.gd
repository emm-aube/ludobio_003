extends Node


var souvenirs_array:Array
var current_souvenir_associating:Node2D

# INIT FROM POOL
func initialize(souvenirs:Array):
	souvenirs_array = souvenirs
	for souvenir in souvenirs_array:
		for associated_souvenir in souvenir.association_array:
			if associated_souvenir.souvenir_ID != "Origin":
				associated_souvenir.needs_association = true
		if souvenir.souvenir_ID == "Origin":
			souvenir.needs_association = false
			
# UPDATE SOUVENIRS ON RECOLLECT
func _input(event: InputEvent) -> void:
	if !MemoryPool.instance.start_processing:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			for souvenir in souvenirs_array:
				var label = souvenir.get_node("RichTextLabel")
				if label.get_global_rect().has_point(event.position):
					var souvenir_clicked = souvenir.process_association("check")
					if souvenir_clicked != null:
						if current_souvenir_associating == null:
							current_souvenir_associating = souvenir_clicked
							current_souvenir_associating.process_association("activate")
							for associated_souvenir in current_souvenir_associating.association_array:
								associated_souvenir.is_associated = true
						elif current_souvenir_associating == souvenir_clicked:
								current_souvenir_associating.process_association("clean")
								for associated_souvenir in current_souvenir_associating.association_array:
									associated_souvenir.is_associated = false
								current_souvenir_associating = null
						else:
							current_souvenir_associating.process_association("clean")
							for associated_souvenir in current_souvenir_associating.association_array:
								associated_souvenir.is_associated = false 
							current_souvenir_associating = souvenir_clicked
							current_souvenir_associating.process_association("activate")
							for associated_souvenir in current_souvenir_associating.association_array:
								associated_souvenir.is_associated = true